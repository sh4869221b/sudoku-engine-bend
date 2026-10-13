# Sudoku engine の Bend 2.0.37 更新と旧版比較

2026年10月13日実測。対象は sh4869221b/sudoku-engine-bend。

## 結論

Bend **2.0.35 → 2.0.37**へ更新しました。探索順序、fuel、seed、評価アルゴリズム、本体と既存proofは変更していません。中間版2.0.36も残して、新たに両旧版と比較しました。

- 2.0.35 対 2.0.37: **465.0200 → 453.1718 ms**。速度比 **1.02615倍**、95%区間 **1.01496–1.04368倍**。所要時間の変化 **-2.55%**。
- 2.0.36 対 2.0.37: **478.2136 → 466.3196 ms**。速度比 **1.02551倍**、95%区間 **1.00569–1.04534倍**。所要時間の変化 **-2.49%**。
- 37は通常経路・low-memory経路の両方で全proof/正しさ/CLI/lane gateに合格しました。計測用binaryは両経路の検証対象とSHA-256が一致します。
- native実行ファイルは **1,394,120 → 865,672 → 342,048 bytes**（35 → 36 → 37）。37は35比 **75.46%減**、36比 **60.49%減**です。
- ファイルサイズと実行時RSSは別の指標です。RSSの6ケース実測と個別性能の増減は後掲します。
- 全ケースが速くなるわけではありません。35対37ではgenerate100の中央値が約4.97%増、rate-300のsingle-threadが約4.04%増でした。これらの個別CIは算出していないため、継続的な悪化と断定せず、用途別の確認が必要です。

速度比は旧版÷37で、1より大きいほど37が速い値です。95%区間が1を含む場合、この測定では改善・悪化を断定しません。単一のshared cloud hostの測定であり、全マシン・全盤面に対する保証ではありません。

## 最新版の訂正と更新対象

[公式 v2.0.37](https://github.com/bendlang/bend/releases/tag/v2.0.37) は **2026-10-13 10:13:41 UTC** にstableとして公開され、依頼時刻10:20:38 UTCより前です。[公式release API](https://api.github.com/repos/bendlang/bend/releases/tags/v2.0.37)でも draft=false / prerelease=false を確認しました。

最初の2.0.36選択は、webの `/releases/latest` が36へ転送されたことに基づいていました。再確認ではこの転送と、37を示すrelease API/明示tagページの不一致が再現しました。本成果では37を採用します。前の36測定値は有効な中間版比較として保持し、「36がlatest」という説明だけを訂正します。ZIPの `checkpoint36/` と `evidence36/` は歴史的記録です。

旧基準は main commit `06b49c06e07b447f2a077183515570695592a3b4`、Bend2.0.35。認証済み接続から全819ファイルを取得し、Git blob SHA-1とサイズを照合したsnapshotです。Git clone用認証が利用できなかったため、作業用gitの初期commit IDは元commitと異なります。添付patchは元commitの同じ内容へ適用できます。基準819 blobsを完了時にも再照合しました。

新Bend source commitは `4ff8545f19b09b7d2b8ca2303668100eac8efd66`。公式Linux x64 archiveのSHA-256と実downloadは一致しました。

`84c32465a39bc9ac315eade23f470cb8db03153dc860f89564fcfec153c3e445`

変更はlock、低メモリadapterの正確なsource/version allowlist、回帰tests、説明と測定資料です。既存production/proof/gateの56ファイルはbyte-identical。Lean **4.34.1**、Clang **19.1.7**、native flags **-std=c11 -O3 -lpthread -lm**を維持し、37同梱の未改変BendTTを新規再構築しました。旧kernelの流用はありません。この検証レポートの作成時点（2026-10-13 11:45 UTC）では、GitHub push、PR、mergeは未実施でした。その後のbranch公開状態はGitHubのcommit履歴を参照してください。

## 37の変更と互換性

- CPU schedulerが、遅いgrowで生じるforkをidle threadへ渡すようになりました。upstreamの「14 threadsで2.6倍」はその専用workloadの値であり、このSudokuの改善率ではありません。
- native build前のメモリ処理はcache解放と強制GCです。compiler process終了とは異なるため、既存の逐次low-memory adapterも維持しました。37の通常full build/verifyが今回通ったことは確認済みですが、旧版と同条件のcompiler RSS比較を行ったわけではなく、メモリ削減率は主張しません。
- JS hostとのNat受け渡しが **BigIntからNumber**へ変わりました。Bend内の `5n` 表記は変更不要です。このrepoは独自JS FFIを持たず、production source移行は不要でした。追加実テストでNat戻り値、0・2^48境界・2^53上限の往復、BigInt/負値/小数/非有限/上限超過の拒否を確認しました。上限付近の任意のNat演算精度を保証する試験ではありません。
- IO.exitの変更に関連する既存CLI exit code契約は差分テストで確認しました。File-effect JS経路はBun未導入のため未実行です。Nodeの `bench --generate 10` はFileを使わず、変更されたIO.now経路を追加確認しました。
- proof exportとkernel verdictの厳格な判定、unsafe/foreign拒否、unexpected diagnostics拒否、既存出力保護を維持しました。unreviewed future pinはfail closedです。

詳細な[upstream source review](UPSTREAM-REVIEW.md)は実行前レビューを含みます。実際に通した範囲は以下と保存ログで区別しています。

## 正しさと安全性の検証

37の `./verify.sh --skip-benchmark` と `./verify.sh --low-memory --skip-benchmark` がともにPASS。timingだけ別実行し、元の `qa/benchmark.py` の15 recordsも完了しています。35/36は同日実行済みの既存low-memory全gateと各15 benchmark recordsを保持しました。

- 全native QA、候補集合、算術、validation、rating/cache、array、direct BENCH
- 独立Lean-backed kernelのproof verdict。有限・個別法則の検証であり、solver全体やcompiler translation全体の形式証明ではありません
- 適応探索20 traces、239,111 transitions、239,131 comparisons、未完了traceなし
- golden search/fuel 6,060 observations、216 CLIケース、独立rating、fuel exit、両mutation検出
- 全7 native/Bend commands、既存Node互換5 commands
- 35↔37、36↔37の各比較で1,931 CLI差分 /347盤面、129 file差分 /928 lines、944固定randomized cases /914盤面（2,832 standalone＋9 batch）
- 各比較でthreads3/5、batch sizes127/128/129/255/256/257の60 scheduler差分
- adapter unit 41件、新real-harness unit 12件、JS-harness unit 12件。追加harnessはoptimized Pythonでも確認
- 実toolchain smoke 14件。通常/low-memoryのvalid・false・unsafe-kind・quantity-dependent-pair proof、tiny native出力/hash一致、既存出力保護
- JS実行記録32 processes。13 host-boundary結果、13 exact native/Node CLI比較（6 seeded生成盤面）、2 generated-bench checks。盤面のclue数と行・列・boxの重複も独立確認

randomized count oracleは各比較でknown799 / unknown1 / invalid144。unknownは既存node budgetを使い切った1件で、独立のcount正解は未確定です。旧新版の一致は確認し、budget/assertionを弱めていません。

37 full gate所要時間は通常349.703秒、low-memory 462.961秒。測定目的のcompiler speed benchmarkではなく、単発の検証経過時間です。通常経路はGC hintなし、low-memoryは67,108,864 bytesのGC scheduling hintを使いました。これはメモリ上限ではありません。

| 版 | native bytes | SHA-256 |
|---|---:|---|
| 2.0.35 | 1,394,120 | `147112785c0dee0ca00a0bbae0cbe56bb2f26b641883919785f9c169567d8bc2` |
| 2.0.36 | 865,672 | `d42bfff854cc290cfc9e29db70c6d0d26e0c732896482963e9da2811fe9cf7fc` |
| 2.0.37 | 342,048 | `4cffba4f3a652ed9224dd1b7342ff42147641237338d0e0f6de10306a1a4c63d` |

## 性能測定方法

同じLinux x86_64 cloud、AMD EPYC9V74、9 logical CPUs、affinity0–8。16 threadsは割当を超えるoversubscriptionで、16 physical coresのscaling結果ではありません。

既存の5 corpora、全7 commandsとthreads1/8/16を含む固定35ケースを変更せず使用しました。各case/版で2 warmups＋21 measured pairsを2 blocks、合計42 measured pairs。順序は固定seedでrandomized、process直列です。全block・全sampleを保存し、都合のよいblock選択はしていません。

fresh processの起動・parse・出力を含むwall-timeを測定し、終了code/stdout/stderrを照合、BENCHの時刻欄だけ正規化しました。前後のbinary/source/corpus hashも照合しています。主指標は35ケースの中央値合計の比、5,000回paired-bootstrap。個別CIは多重比較未補正です。既知の他taskのCPU-heavy処理を止めて測りましたが、shared hostの外部負荷は制御できません。

35↔37と36↔37は別の連続した測定窓です。過去35↔36測定との数値を機械的に連結した3者同時計測ではありません。

### 2.0.35 対 2.0.37 全35ケース

単位ms。速度比は旧版÷37。時間増減は37の所要時間変化です。

| ケース | 2.0.35 ms | 2.0.37 ms | 速度比 | 時間増減 |
|---|---:|---:|---:|---:|
| solve_new_easy | 0.9937 | 0.9817 | 1.0123 | -1.21% |
| solve_original_hard | 2.2661 | 2.1703 | 1.0441 | -4.23% |
| solve_new_complete | 1.0838 | 1.0290 | 1.0532 | -5.05% |
| solve_new_multi_solution | 1.0977 | 1.0640 | 1.0317 | -3.07% |
| count_new_easy | 1.0199 | 1.0415 | 0.9793 | +2.11% |
| count_original_hard | 2.9035 | 2.8405 | 1.0222 | -2.17% |
| count_new_complete | 0.9744 | 0.9581 | 1.0170 | -1.67% |
| count_new_multi_solution | 0.9738 | 1.0103 | 0.9639 | +3.74% |
| rate_new_easy | 1.0714 | 1.0490 | 1.0213 | -2.09% |
| rate_original_hard | 1.0764 | 1.0582 | 1.0172 | -1.69% |
| rate_new_complete | 1.0400 | 1.0295 | 1.0102 | -1.01% |
| rate_new_multi_solution | 1.0670 | 1.1140 | 0.9578 | +4.41% |
| generate100_clues36 | 9.1236 | 9.5768 | 0.9527 | +4.97% |
| generate_minimal | 1.5163 | 1.4862 | 1.0203 | -1.99% |
| batch_easy-10000_solve_t1 | 80.9020 | 78.7235 | 1.0277 | -2.69% |
| batch_mixed-1000_solve_t1 | 11.0424 | 10.6790 | 1.0340 | -3.29% |
| batch_hard-100_count_t1 | 38.4635 | 37.2781 | 1.0318 | -3.08% |
| batch_rate-300_rate_t1 | 16.7382 | 17.4143 | 0.9612 | +4.04% |
| batch_verification_check_t1 | 1.7052 | 1.5347 | 1.1111 | -10.00% |
| bench_easy-10000_t1 | 68.3166 | 67.5381 | 1.0115 | -1.14% |
| bench_mixed-1000_t1 | 11.1094 | 11.0595 | 1.0045 | -0.45% |
| batch_easy-10000_solve_t8 | 44.7476 | 42.5390 | 1.0519 | -4.94% |
| batch_mixed-1000_solve_t8 | 7.9387 | 7.2365 | 1.0970 | -8.85% |
| batch_hard-100_count_t8 | 9.6381 | 9.5423 | 1.0100 | -0.99% |
| batch_rate-300_rate_t8 | 5.4506 | 5.5236 | 0.9868 | +1.34% |
| batch_verification_check_t8 | 1.8842 | 1.8930 | 0.9954 | +0.47% |
| bench_easy-10000_t8 | 32.0490 | 31.2243 | 1.0264 | -2.57% |
| bench_mixed-1000_t8 | 5.6613 | 5.2793 | 1.0724 | -6.75% |
| batch_easy-10000_solve_t16 | 41.8317 | 39.7883 | 1.0514 | -4.88% |
| batch_mixed-1000_solve_t16 | 6.9434 | 6.6682 | 1.0413 | -3.96% |
| batch_hard-100_count_t16 | 8.1970 | 7.9153 | 1.0356 | -3.44% |
| batch_rate-300_rate_t16 | 5.6102 | 5.7862 | 0.9696 | +3.14% |
| batch_verification_check_t16 | 2.3177 | 2.2421 | 1.0337 | -3.26% |
| bench_easy-10000_t16 | 32.5103 | 31.1923 | 1.0423 | -4.05% |
| bench_mixed-1000_t16 | 5.7553 | 5.7052 | 1.0088 | -0.87% |

Block別の速度比と95%区間:

- Block1: 1.02405倍 [1.00770, 1.04845]
- Block2: 1.02935倍 [1.00635, 1.06101]

hard-100 countの個別95%区間:

- batch_hard-100_count_t1: 1.03180倍 [0.98716, 1.06636]
- batch_hard-100_count_t8: 1.01004倍 [0.96522, 1.10295]
- batch_hard-100_count_t16: 1.03558倍 [1.00671, 1.07670]

### 2.0.35 対 2.0.37 実行時RSS

KiB、中央値（最小–最大）。tiny C launcherによるfork/exec/wait4でPythonのpre-exec high-water mark混入を避け、各case/版で2 warmups＋7 samplesをrandomized直列実行しました。

| ケース | 2.0.35 KiB | 2.0.37 KiB |
|---|---:|---:|
| generate100_clues36 | 1,212 (1,204–1,264) | 1,144 (1,136–1,216) |
| batch_easy-10000_solve_t1 | 23,332 (23,288–23,344) | 23,196 (23,192–23,276) |
| batch_rate-300_rate_t1 | 1,872 (1,828–1,896) | 1,792 (1,780–1,856) |
| bench_easy-10000_t1 | 25,704 (25,656–25,752) | 25,700 (25,692–25,708) |
| batch_easy-10000_solve_t8 | 23,612 (23,504–23,784) | 23,532 (23,144–23,780) |
| batch_rate-300_rate_t8 | 3,452 (2,912–3,580) | 3,292 (2,752–3,328) |

### 2.0.36 対 2.0.37 全35ケース

単位ms。速度比は旧版÷37。時間増減は37の所要時間変化です。

| ケース | 2.0.36 ms | 2.0.37 ms | 速度比 | 時間増減 |
|---|---:|---:|---:|---:|
| solve_new_easy | 1.0553 | 1.0030 | 1.0522 | -4.96% |
| solve_original_hard | 2.1618 | 2.0054 | 1.0780 | -7.23% |
| solve_new_complete | 1.0294 | 1.0748 | 0.9578 | +4.41% |
| solve_new_multi_solution | 1.0043 | 0.9952 | 1.0092 | -0.91% |
| count_new_easy | 1.0107 | 1.0028 | 1.0079 | -0.78% |
| count_original_hard | 2.7618 | 2.7317 | 1.0110 | -1.09% |
| count_new_complete | 1.1747 | 1.0876 | 1.0801 | -7.42% |
| count_new_multi_solution | 1.0010 | 1.0141 | 0.9871 | +1.31% |
| rate_new_easy | 1.0830 | 1.0943 | 0.9896 | +1.05% |
| rate_original_hard | 1.0956 | 1.1306 | 0.9690 | +3.20% |
| rate_new_complete | 1.0447 | 1.0074 | 1.0370 | -3.57% |
| rate_new_multi_solution | 1.1533 | 1.1809 | 0.9766 | +2.39% |
| generate100_clues36 | 9.6027 | 9.6483 | 0.9953 | +0.47% |
| generate_minimal | 1.5948 | 1.5558 | 1.0250 | -2.44% |
| batch_easy-10000_solve_t1 | 79.2675 | 81.0872 | 0.9776 | +2.30% |
| batch_mixed-1000_solve_t1 | 11.6953 | 11.7114 | 0.9986 | +0.14% |
| batch_hard-100_count_t1 | 43.7500 | 40.2963 | 1.0857 | -7.89% |
| batch_rate-300_rate_t1 | 18.0693 | 17.6497 | 1.0238 | -2.32% |
| batch_verification_check_t1 | 1.4906 | 1.5408 | 0.9674 | +3.37% |
| bench_easy-10000_t1 | 71.3894 | 70.4837 | 1.0128 | -1.27% |
| bench_mixed-1000_t1 | 10.6956 | 10.7270 | 0.9971 | +0.29% |
| batch_easy-10000_solve_t8 | 43.6194 | 41.8732 | 1.0417 | -4.00% |
| batch_mixed-1000_solve_t8 | 6.6343 | 6.7105 | 0.9886 | +1.15% |
| batch_hard-100_count_t8 | 10.6654 | 9.9299 | 1.0741 | -6.90% |
| batch_rate-300_rate_t8 | 6.0327 | 5.8406 | 1.0329 | -3.18% |
| batch_verification_check_t8 | 1.9434 | 1.9298 | 1.0071 | -0.70% |
| bench_easy-10000_t8 | 32.3882 | 31.2133 | 1.0376 | -3.63% |
| bench_mixed-1000_t8 | 6.0787 | 5.8312 | 1.0425 | -4.07% |
| batch_easy-10000_solve_t16 | 44.8947 | 40.8331 | 1.0995 | -9.05% |
| batch_mixed-1000_solve_t16 | 7.0123 | 6.4131 | 1.0934 | -8.55% |
| batch_hard-100_count_t16 | 9.7992 | 9.0055 | 1.0881 | -8.10% |
| batch_rate-300_rate_t16 | 5.5975 | 5.8369 | 0.9590 | +4.28% |
| batch_verification_check_t16 | 2.3493 | 2.4692 | 0.9514 | +5.11% |
| bench_easy-10000_t16 | 32.4026 | 32.7762 | 0.9886 | +1.15% |
| bench_mixed-1000_t16 | 5.6651 | 5.6291 | 1.0064 | -0.64% |

Block別の速度比と95%区間:

- Block1: 1.02964倍 [0.99946, 1.05698]
- Block2: 1.01815倍 [0.99446, 1.03923]

hard-100 countの個別95%区間:

- batch_hard-100_count_t1: 1.08571倍 [1.02663, 1.13633]
- batch_hard-100_count_t8: 1.07407倍 [0.97248, 1.13786]
- batch_hard-100_count_t16: 1.08814倍 [0.98804, 1.18322]

### 2.0.36 対 2.0.37 実行時RSS

KiB、中央値（最小–最大）。tiny C launcherによるfork/exec/wait4でPythonのpre-exec high-water mark混入を避け、各case/版で2 warmups＋7 samplesをrandomized直列実行しました。

| ケース | 2.0.36 KiB | 2.0.37 KiB |
|---|---:|---:|
| generate100_clues36 | 1,256 (1,244–1,260) | 1,140 (1,128–1,216) |
| batch_easy-10000_solve_t1 | 23,344 (23,316–23,360) | 23,208 (23,192–23,276) |
| batch_rate-300_rate_t1 | 1,912 (1,896–1,920) | 1,856 (1,780–1,856) |
| bench_easy-10000_t1 | 25,700 (25,684–25,744) | 25,696 (25,640–25,728) |
| batch_easy-10000_solve_t8 | 23,660 (23,412–23,912) | 23,524 (23,388–23,736) |
| batch_rate-300_rate_t8 | 3,572 (3,200–3,712) | 3,188 (3,056–3,648) |

## ファイル縮小の内訳

GNU sizeのdata集計は35の1,052,840 →36の528,552 →37の4,912 bytes、text集計は301,338 →300,254 →302,038 bytes、bss集計は99,664 bytesで共通です。これは複数sectionをまとめた集計欄で、個別のELF section名ではありません。`io_eff_rows` symbolは1,048,576 →524,288 →640 bytes。37でeffect tableを実際のconstructor IDsへ合わせるupstream変更と整合し、縮小の大部分はこの静的tableです。solver本体の大幅削減ではありません。実測のRSSは前節を参照してください。

## 再現と成果物

配布ZIPの `START_HERE.ja.md` を入口にしてください。

- `candidate/`: Bend2.0.37版。`baseline/`: 元2.0.35の819-file snapshot。`checkpoint36/`: 検証済み中間版
- `bend-2.0.37.patch`: 元2.0.35内容に適用するsource差分
- `REPRODUCE.sh`: 各versionのsetup/build/full verification、追加実test、同じ2比較を実行
- `evidence37/`: release metadata、setup/full-gate logs、JS/kernel実行結果、binary identity、全比較raw samples
- `evidence36/`: 最初の35↔36実測と全検証。結果は保持、latest説明は本報告で訂正
- `binaries/`: 実際に検証・計測したLinux x64 native binaries3本。toolchain自体は含めず、公式lockから再現
- `SOURCE_MANIFEST.json`: 全配布ファイルのSHA-256とサイズ

必要環境はLinux x86_64、Python3、curl、tar、zstd、dpkg-deb、C toolchain、flock、realpath、Nodeとlock記載のDebian系libraries。新規downloadにはネット接続が必要です。toolchainはproject内の.toolchainsに置き、system-wide更新はしません。

未検証はGPU、Windows/macOS、Bun File-effect JS、任意の他CPU/盤面、未reviewの将来Bend pinです。今回のfinite proofと差分testだけで全solver・全compilerの完全正しさを主張しません。
