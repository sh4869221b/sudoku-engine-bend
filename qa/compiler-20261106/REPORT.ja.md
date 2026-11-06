# Bend 2.0.40 対応と旧版比較

2026-11-06、sh4869221b/sudoku-engine-bendで実測。基準mainは `42ed83aeb51c502d15d57e10088a8e3a7d830c4e`、Bend 2.0.37です。

## 結果

Bend **2.0.37 → 2.0.40**へ更新しました。ベンチマーク以外に、実行時引数の移行、CLIの案内、QA、低メモリアダプター、回帰テスト、GitHub Actions、再現手順を反映しています。

固定35ケースの中央値合計は **524.8168 → 537.7896 ms**、所要時間の変化 **+2.47%**。速度比（旧版÷新版）は **0.97588倍**、paired-bootstrap 95%区間は **0.96736–0.98684倍**です。この測定窓では全体の低速化が見られます。 単一のshared cloud hostの結果であり、任意のマシン・盤面への保証ではありません。

新版は通常経路と低メモリ経路の全gateに合格し、旧版の通常全gateも同じ環境で再実行して合格しました。比較に用いたnative binaryは対応する検証workのbinaryとSHA-256が一致します。低メモリ経路と通常経路の新版native binaryも一致します。

## 最新版と互換性対応

[公式v2.0.40](https://github.com/bendlang/bend/releases/tag/v2.0.40) は2026-11-06 02:06:29 UTC公開のstableです。APIの `draft=false / prerelease=false`、tagのsource commit `624dd9f4607cd29b0871a9b96d413bfb11e92f52`、公式配布archiveのSHA-256を確認しました。Web検索のcached一覧が示した2.0.39は使っていません。保存した [release.json](release.json) とlockから再確認できます。

- native runtimeのオプションは `+RTS --threads N -RTS` へ移行しました。従来の `--threads N --` はapplication引数になり、これまでのQA起動方法では検証できません。CLIのhelp、全active QA起動、Go比較、旧新版比較を対応しました。
- `qa/runtime_args.py` は `BEND_LEGACY_BINARY` で明示した旧binaryだけを旧形式で起動します。新版はRTSブロックを使用します。計測前のprobe processはありません。比較entrypointで `BENDRTS` を空にして、ambient runtime設定を除いています。
- Lean **4.34.1**、Clang **19.1.7**、native flags **-std=c11 -O3 -lpthread -lm**を維持し、2.0.40同梱の未改変BendTTを再構築しました。旧kernelは流用していません。
- 低メモリadapterは新版sourceとversionの正確な組だけを許可し、unsafe/foreign、export診断、成功文言の不一致、既存出力上書きを引き続き拒否します。
- NodeのFile-effect対応を受け、従来skipしていた `batch` / `bench` もactive lane検証に加えました。
- engineとproofの本体はbyte-identicalです（[hash記録](results/environment.json)）。`main.bend` はruntime-helpの一文だけを変更しました。探索順序、fuel、seed、評価アルゴリズム、unsafe array accessなどの最適化は変更していません。

詳細は [upstream review](UPSTREAM-REVIEW.md) に記録しています。

## 正しさの検証

| 検証 | 結果 | gate実行時間 |
|---|---|---:|
| 2.0.37 通常 `--skip-benchmark` | PASS | 425.238秒 |
| 2.0.40 通常 `--skip-benchmark` | PASS | 312.871秒 |
| 2.0.40 `--low-memory --skip-benchmark` | PASS | 474.135秒 |

gate時間は一回の検証経過時間です。通常の両版検証は一部並行実行しており、compiler速度比較には使いません。性能計測は全compiler/QAの終了後、直列で行いました。low-memoryのGC hintは67,108,864 bytesで、メモリ上限ではありません。

各full gateはnative QA、独立Lean-backed kernel verdict、候補集合・算術・rating/cache・array・BENCH、全20 adaptive traces（239,111 transitions /239,131 comparisons、打ち切りなし）、6,060 search/fuel observations、CLI216ケース、独立生成/評価oracle、fuel exit、counter/mirror-law mutation、Bend/Node/native lanesを含みます。通常経路の初回snapshotは従来のNode5 commands、更新後のlow-memory snapshotはNode7 commandsを実行しました。有限law・個別のproofの確認であり、solver全体やcompiler translation全体の完全な形式証明ではありません。

追加検証:

- Python回帰44件、kernel-harness回帰12件（optimized Pythonでも実行）、JS-harness回帰12件。
- 実proof/native smoke14項目: valid/false/unsafe-kind/dependent-pair、通常と逐次のnative出力/hash一致、既存出力保護。
- JS実テスト: Nat host境界13結果、native/Node CLI13比較（6seeded生成盤面のclue数・重複も独立検査）、生成bench2 lane、計32 processes。
- native runtime ABIの実テスト3件。
- 旧新版でCLI1,931比較 /347盤面、file129比較、randomized944ケース /914盤面（standalone2,832比較＋batch9比較）、odd-threadとbatch境界のscheduler60比較がPASS。独立count oracleはknown799 /unknown1 /invalid144で、1件は50,000 node budgetを使い切り正解count未確定です。両版の出力一致は確認し、予算やassertionは緩めていません。結果は [comparison/](results/comparison/) に保存しています。

最初の追加harnessは、upstreamで変わったunsafe依存関係のグループ表示とNat host入力エラー文言で失敗しました。拒否対象は変わっておらず、新版の正確な表示を要求するようharnessを移行し再実行しました。4つの異なるunsafe依存名・拒否exit1・6種類の不正host値の拒否を維持しています。最初の失敗JSONと再実行の成功JSONをともに保存しています。

## 性能測定条件

CPU: **AMD EPYC 7763 64-Core Processor**。Linux x86_64、affinity **[0, 1, 2, 3, 4]**、cgroup CPU quota **400000 100000**（4 CPU相当）。8/16 threadsは割当超過で、8/16 physical coresのscaling測定ではありません。shared hostの外部負荷は制御できません。

既存の5つのhash固定corporaと全7 commandsを含む35ケースを維持しました。各case/版に2 warmups＋21 measured pairs、2 blocksで合計42 measured pairsです。seed固定のrandomized順、process直列、fresh processの起動・parse・出力を含むwall-timeです。出力/exitを照合し、BENCHの時刻欄だけを正規化しました。CLI差分gateでは、意図したruntime-help一文の変更も明示的に正規化しています。他の出力・判定は弱めていません。

主指標は35ケースの中央値合計の比、5,000回paired-bootstrapの95%区間です。全block・全sampleを保存し、選択的な除外はありません。これは固定workloadの重み付き結果であり、全commandが一様に速くなるという意味ではありません。過去の別hostの2.0.37 timingsは比較に混ぜていません。binary/source/corpora hashを計測前後で照合しています。

| ケース | 2.0.37 ms | 2.0.40 ms | 速度比 | 時間増減 |
|---|---:|---:|---:|---:|
| solve_new_easy | 1.1204 | 1.2075 | 0.9279 | +7.77% |
| solve_original_hard | 2.3660 | 2.3549 | 1.0047 | -0.47% |
| solve_new_complete | 1.1011 | 1.2462 | 0.8836 | +13.18% |
| solve_new_multi_solution | 1.1396 | 1.1408 | 0.9990 | +0.10% |
| count_new_easy | 1.0894 | 1.1122 | 0.9795 | +2.10% |
| count_original_hard | 3.0797 | 3.1126 | 0.9894 | +1.07% |
| count_new_complete | 1.0774 | 1.1226 | 0.9597 | +4.20% |
| count_new_multi_solution | 1.1890 | 1.1858 | 1.0026 | -0.26% |
| rate_new_easy | 1.2188 | 1.2507 | 0.9746 | +2.61% |
| rate_original_hard | 1.1485 | 1.2172 | 0.9436 | +5.98% |
| rate_new_complete | 1.1381 | 1.1999 | 0.9485 | +5.43% |
| rate_new_multi_solution | 1.2177 | 1.2740 | 0.9558 | +4.62% |
| generate100_clues36 | 11.0522 | 10.7239 | 1.0306 | -2.97% |
| generate_minimal | 1.8743 | 1.8627 | 1.0062 | -0.62% |
| batch_easy-10000_solve_t1 | 85.3936 | 87.5915 | 0.9749 | +2.57% |
| batch_mixed-1000_solve_t1 | 12.0422 | 12.5217 | 0.9617 | +3.98% |
| batch_hard-100_count_t1 | 45.5403 | 44.9299 | 1.0136 | -1.34% |
| batch_rate-300_rate_t1 | 18.4413 | 17.9228 | 1.0289 | -2.81% |
| batch_verification_check_t1 | 1.6416 | 1.7103 | 0.9598 | +4.18% |
| bench_easy-10000_t1 | 74.1172 | 77.8132 | 0.9525 | +4.99% |
| bench_mixed-1000_t1 | 11.9943 | 11.9960 | 0.9999 | +0.01% |
| batch_easy-10000_solve_t8 | 46.6724 | 48.5931 | 0.9605 | +4.12% |
| batch_mixed-1000_solve_t8 | 7.5928 | 7.6711 | 0.9898 | +1.03% |
| batch_hard-100_count_t8 | 13.0314 | 12.8164 | 1.0168 | -1.65% |
| batch_rate-300_rate_t8 | 6.9278 | 6.8620 | 1.0096 | -0.95% |
| batch_verification_check_t8 | 2.0654 | 2.0969 | 0.9850 | +1.52% |
| bench_easy-10000_t8 | 38.1775 | 40.7036 | 0.9379 | +6.62% |
| bench_mixed-1000_t8 | 6.2520 | 6.4752 | 0.9655 | +3.57% |
| batch_easy-10000_solve_t16 | 47.6755 | 48.8524 | 0.9759 | +2.47% |
| batch_mixed-1000_solve_t16 | 7.5459 | 7.8085 | 0.9664 | +3.48% |
| batch_hard-100_count_t16 | 14.3692 | 14.2050 | 1.0116 | -1.14% |
| batch_rate-300_rate_t16 | 7.5572 | 7.4905 | 1.0089 | -0.88% |
| batch_verification_check_t16 | 2.3743 | 2.3989 | 0.9897 | +1.04% |
| bench_easy-10000_t16 | 38.9323 | 40.4395 | 0.9627 | +3.87% |
| bench_mixed-1000_t16 | 6.6603 | 6.8801 | 0.9681 | +3.30% |

Blockごとの速度比と95%区間:

- Block 1: 0.97900倍 [0.96360, 0.99614]
- Block 2: 0.98100倍 [0.96467, 0.99269]

case別の四分位範囲・min/maxは `block1.json` / `block2.json` / `pooled.json`、全反復は対応する `.raw.json.gz` にあります。hard-countの個別区間は `hard-count-ci.json` にあります。個別ケースの区間は多重比較未補正です。

## 配布サイズと実行時メモリ

native fileは **342,048 → 287,520 bytes（15.94%減）**です。これはdisk上のファイルサイズで、実行時RSS削減率ではありません。旧binary SHA-256は `4cffba4f3a652ed9224dd1b7342ff42147641237338d0e0f6de10306a1a4c63d`、新版は `cc23e86c6ba5c2d2e3b6fc9c291621ab751a70c9473c76eb1c1dea38735e1719` です。

実行時RSSは `comparison/memory.json` の6ケース、各版2 warmups＋7 samplesを参照してください。専用C launcherのfork/exec/wait4で子processのpeak RSSを記録し、Pythonのpre-exec high-water mark混入を避けています。通常のtiming rawにもRSS欄がありますが、memoryの判断には専用launcher結果を使います。

## 再現・GitHub・未検証範囲

[再現手順](README.md) を参照してください。公式checksum lockから各版を別々にsetup/buildし、全gate終了後に `compare.sh` を使います。toolchainとnative binaryはcommitしていません。`results/` に検証summary/log・初回不一致・再実行・環境・全測定sample・前後hashを保存しています。

変更は [ドラフトPR #3](https://github.com/sh4869221b/sudoku-engine-bend/pull/3) に反映しました。mainへのmergeはしていません。GitHub Actionsの状態はPRのChecksを参照してください。ローカル成功とCI成功を混同しません。

未検証: GPU、Windows/macOS、Bun lane、任意の他CPU/盤面、未reviewの将来Bend pin。全体QAのtiming gateは明示的にskipし、性能比較を別の固定35-case harnessで実行しています。Node File IOは7-command laneの範囲であり、全File APIや全入力の網羅試験ではありません。
