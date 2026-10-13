# Sudoku engine の Bend 2.0.36 更新と前版比較

2026年10月13日実測。対象は sh4869221b/sudoku-engine-bend。

## 結論

Bend **2.0.35 → 2.0.36**へ更新したコードと再現可能な差分を用意しました。本体、探索順序、fuel、seed、評価アルゴリズム、既存のproofは変更していません。

- 正しさ検証は旧新版とも合格。追加の差分テスト、proof安全性テストも合格しました。
- 固定35ケースの実行時間中央値合計は **453.8765 → 448.2775 ms**。速度比 **1.01249倍**、実行時間 **1.23%減**です。95% paired-bootstrap区間は **1.00076–1.02545倍**。改善は小幅です。
- hard-100 count の16スレッドでは **8.1950 → 8.6412 ms（5.44%増）**。速度比の個別95%区間は **0.91099–0.97512倍**で、この測定では悪化が確認されました。
- native実行ファイルは **1,394,120 → 865,672 bytes（37.91%減）**。
- 実行時peak RSSは概ね同程度です。ファイルが小さくなったことから、実行時メモリも同じ割合で減ったとはいえません。

大幅な高速化を目的とした更新ではありません。公式最新版への追従、proof検査の改善、ファイルサイズ削減が主な利点です。16スレッドhard-countを重視する用途では今回の悪化に注意してください。

GitHubへのpush、PR作成、mergeは行っていません。

## 更新内容と基準

旧版は main の commit `06b49c06e07b447f2a077183515570695592a3b4`（Bend 2.0.35）。認証済み接続から全819ファイルを取得し、各Git blob SHA-1とサイズを照合したsnapshotを基準にしました。Git用認証がないため通常のcloneは利用できず、ローカルgitの基準commit IDは元のcommit IDと異なります。差分は元commitの同じファイルに適用できます。

新版は[公式 v2.0.36](https://github.com/bendlang/bend/releases/tag/v2.0.36)、2026-10-07 04:53:15 UTC公開、draft/prereleaseではありません。2026-10-13確認時のlatest stableです。source commitは `ae1101ca7d15364f9274fa6b1367d175884a7da7`。

Linux x64 archiveのSHA-256は公式metadataと実downloadの双方で一致しました。

`02089dc0eed0fd5fd6d73c74cc9cffcb2c6638dd3b02ae83f7b8cc57fbe381ba`

変更はtoolchain lock、low-memory adapterの正確なversion/source allowlist、回帰tests、説明と結果資料です。元のBendファイルと既存gateファイル56個はbyte-identicalです。Lean **4.34.1**、Clang **19.1.7**、native flags **-std=c11 -O3 -lpthread -lm**を維持しました。

BendTTはv2.0.36に同梱された未改変sourceから別途再構築しました。旧kernelを流用していません。新版ではquantityを含むproof出力形式が変わるため、この再構築が必要です。明示的なBENDTTを使用する既存構成は維持できます。[upstream確認記録](UPSTREAM-REVIEW.md)を参照してください。

## 検証

両版で `./verify.sh --low-memory --skip-benchmark` が成功しました。計測を分離するためtimingだけを後回しにし、その後、元の `qa/benchmark.py` も両版で各15 recordsすべて成功しました。

- 全native QA、候補集合、算術、validation、rating/cache、array、direct BENCH gate
- 独立Lean-backed BendTTのproof verdict
- 適応探索20 traces、239,111 transitions、239,131 state comparisons。未完了traceなし
- 既存golden search/fuel 6,060 observations（3,030 production outcomes＋3,030 legacy transition observations）
- 216 CLIケース、独立rating、fuel exit、両mutation検出
- 全7 native/Bend commands、Node互換5 commands
- 1,931 CLI差分、347 distinct puzzles
- 129 file境界差分、928 lines
- 固定randomized 944 cases、914 distinct puzzles、2,832 standalone＋9 batch差分
- threads 3/5、batch sizes 127/128/129/255/256/257 の60 scheduler差分
- adapter unit tests **41件**、追加ハーネスunit tests **10件**
- 新版実toolchain smoke **14件**。通常とlow-memoryでvalid/false/unsafe-kind/quantity-polymorphic proofを検証し、tiny nativeの出力とbinary hash一致、既存出力保護も確認

追加randomized独立count oracleは known **799**、unknown **1**、invalid **144**。unknown 1件は従来のnode budgetを使い切ったため、そのcountの独立正解は未確定です。旧新版の出力一致は確認しました。budgetやassertionは弱めていません。

計測に使った両binaryは、それぞれfull-gateで実行したbinaryとSHA-256が一致します。

| 版 | binary SHA-256 |
|---|---|
| 2.0.35 | `147112785c0dee0ca00a0bbae0cbe56bb2f26b641883919785f9c169567d8bc2` |
| 2.0.36 | `d42bfff854cc290cfc9e29db70c6d0d26e0c732896482963e9da2811fe9cf7fc` |

実行詳細は[検証summary](results/verification-summary.json)、[binary identity](results/binary-identity.json)、配布ZIPのevidence内の全ログにあります。

## 性能測定条件

同一cloud Linux x86_64、AMD EPYC 9V74、利用可能9 logical CPUs、affinity 0–8。16スレッドはこの割当を超えるoversubscriptionです。16 physical coresのscaling結果を示しません。

既存の固定5 corporaと35ケースを変更せず、全7コマンドとthreads 1/8/16を測定しました。ケースごとに各版2 warmups＋21 measured pairsを2 blocks、合計42 measured pairsです。順序は固定seedのrandomized pair、processは直列。両blockを保持し、都合のよいblockだけを選んでいません。

時刻計測はfresh processの起動・parse・出力を含み、compilerのbuild時間は含みません。BENCH内蔵timerは別記録です。終了code/stdout/stderrは一致を必須とし、BENCHの時刻欄だけ正規化しました。測定前後にcorpus/source/binaryのhashを検証しました。

C3を含む同cloudの既知のbuild/testを止めて計測しました。共有hostの外部負荷は制御できません。

主指標は35ケースのwall-time中央値の合計の比、5,000回paired-bootstrapです。1st blockは **1.02601倍**、2nd blockは **1.00576倍**（2ndの95%区間は0.99057–1.02623）でした。小さな差なので環境を変えて同じ改善率が出るとは限りません。個別CIは多重比較補正をしていません。

### 全35ケース

旧/新はwall-time中央値、単位ms。速度比は旧÷新で、1より大きいほど新版が速い値です。増減は新版の所要時間変化です。

| ケース | 2.0.35 ms | 2.0.36 ms | 速度比 | 時間増減 |
|---|---:|---:|---:|---:|
| solve_new_easy | 0.9870 | 0.9641 | 1.0237 | -2.32% |
| solve_original_hard | 2.0443 | 2.0029 | 1.0207 | -2.03% |
| solve_new_complete | 1.0039 | 0.9875 | 1.0166 | -1.64% |
| solve_new_multi_solution | 1.0172 | 1.0150 | 1.0022 | -0.22% |
| count_new_easy | 0.9677 | 0.9755 | 0.9921 | +0.80% |
| count_original_hard | 2.6883 | 2.7169 | 0.9895 | +1.07% |
| count_new_complete | 0.9685 | 0.9768 | 0.9915 | +0.86% |
| count_new_multi_solution | 0.9801 | 0.9899 | 0.9901 | +1.00% |
| rate_new_easy | 1.1238 | 1.0521 | 1.0682 | -6.39% |
| rate_original_hard | 1.0526 | 1.0948 | 0.9615 | +4.01% |
| rate_new_complete | 1.0404 | 1.0358 | 1.0045 | -0.44% |
| rate_new_multi_solution | 1.1534 | 1.1313 | 1.0196 | -1.92% |
| generate100_clues36 | 9.5756 | 9.3560 | 1.0235 | -2.29% |
| generate_minimal | 1.4461 | 1.5346 | 0.9423 | +6.12% |
| batch_easy-10000_solve_t1 | 78.3548 | 76.9668 | 1.0180 | -1.77% |
| batch_mixed-1000_solve_t1 | 11.2153 | 11.1628 | 1.0047 | -0.47% |
| batch_hard-100_count_t1 | 40.3077 | 40.8794 | 0.9860 | +1.42% |
| batch_rate-300_rate_t1 | 17.1486 | 16.9169 | 1.0137 | -1.35% |
| batch_verification_check_t1 | 1.5131 | 1.4323 | 1.0564 | -5.34% |
| bench_easy-10000_t1 | 66.7608 | 64.9471 | 1.0279 | -2.72% |
| bench_mixed-1000_t1 | 10.7654 | 10.3872 | 1.0364 | -3.51% |
| batch_easy-10000_solve_t8 | 42.6923 | 42.5308 | 1.0038 | -0.38% |
| batch_mixed-1000_solve_t8 | 6.2637 | 6.3196 | 0.9912 | +0.89% |
| batch_hard-100_count_t8 | 9.4037 | 9.8022 | 0.9593 | +4.24% |
| batch_rate-300_rate_t8 | 5.5719 | 5.5867 | 0.9973 | +0.27% |
| batch_verification_check_t8 | 2.0046 | 1.9877 | 1.0085 | -0.84% |
| bench_easy-10000_t8 | 30.4032 | 30.2621 | 1.0047 | -0.46% |
| bench_mixed-1000_t8 | 5.5882 | 5.5041 | 1.0153 | -1.50% |
| batch_easy-10000_solve_t16 | 39.7211 | 38.6006 | 1.0290 | -2.82% |
| batch_mixed-1000_solve_t16 | 6.1781 | 6.1972 | 0.9969 | +0.31% |
| batch_hard-100_count_t16 | 8.1950 | 8.6412 | 0.9484 | +5.44% |
| batch_rate-300_rate_t16 | 5.4707 | 5.4389 | 1.0059 | -0.58% |
| batch_verification_check_t16 | 2.2834 | 2.3517 | 0.9710 | +2.99% |
| bench_easy-10000_t16 | 32.2831 | 30.9398 | 1.0434 | -4.16% |
| bench_mixed-1000_t16 | 5.7028 | 5.5891 | 1.0203 | -1.99% |

[全体集計](results/pooled-aggregate.json)、[ケース別summary](results/case-summary.json)、[hard-count個別区間](results/hard-count-ci.json)。全warmup/計測サンプルはZIPのevidence/comparisonに保存しています。

## 実行時メモリと実行ファイル

RSSはtiny C launcherのfork/exec/wait4を使用し、Pythonのpre-exec high-water mark混入を避けました。各case/版で2 warmups＋7 measured samples、randomized serial orderです。

| ケース | 2.0.35 KiB 中央値（最小–最大） | 2.0.36 KiB 中央値（最小–最大） |
|---|---:|---:|
| generate100_clues36 | 1,216 (1,204–1,236) | 1,260 (1,244–1,264) |
| batch_easy-10000_solve_t1 | 23,320 (23,288–23,348) | 23,344 (23,332–23,344) |
| batch_rate-300_rate_t1 | 1,896 (1,864–1,928) | 1,920 (1,864–1,920) |
| bench_easy-10000_t1 | 25,688 (25,660–25,732) | 25,712 (25,684–25,716) |
| batch_easy-10000_solve_t8 | 23,516 (23,320–23,912) | 23,668 (23,536–23,924) |
| batch_rate-300_rate_t8 | 3,536 (3,016–3,720) | 3,456 (3,068–3,712) |

小さな差や範囲の重なりが多く、一般的なRSS削減を示しません。

実行ファイルの減少528,448 bytesのうち、symbol `io_eff_rows` は1,048,576 → 524,288 bytesとなり、524,288 bytesの差を占めます。ELFのtextは301,338 → 300,254 bytes、dataは1,052,840 → 528,552 bytes、bssは99,664 bytesで同じです。これらはbinaryを直接調べた値で、アルゴリズム最適化によるものとは主張しません。

## 制約

- full検証は既存のlow-memory分離経路です。大型projectの通常integrated full build/verdictを改めて成功したとは扱いません。通常経路の小さなproof/native smokeは成功しています。
- GC hintは67,108,864 bytesですがmemory capではありません。compiler各phaseは依然大きなメモリを使います。
- 初期のbuild計測補助で `/usr/bin/time` がなく実行開始前に失敗し、標準Pythonによる記録に切り替えました。build wall-timeは参考値のみ。child CPU/RSSはshellから累積usageを継承しうるため、compiler性能改善の根拠には使っていません。
- JS file-I/O専用laneはBun未導入のため未検証。GPU/Windows/ARMの性能や互換性は今回測定していません。
- 有限の入力testと既存の限定されたlawsの検証であり、solver全体の完全性・唯一性を普遍的に証明するものではありません。
- 過去の2.0.34→2.0.35やGo比較の数値は今回の測定に混ぜていません。

## 再現とファイル

配布ZIPを新しい場所に展開し、Linux x86_64で `./REPRODUCE.sh` を実行します。Python3、curl、tar、zstd、dpkg-deb、gcc、flock、realpath、C toolchain、Nodeとlockに記載したLinux librariesが必要です。Bend/Lean/Clangはchecksum確認付きでworkspace内に配置します。toolchainのsystem-wide installやlogin/publishは不要です。

既存repoへの適用は、元commit `06b49c06e07b447f2a077183515570695592a3b4` のclean checkoutで配布の `bend-2.0.36.patch` を `git apply --check` し、適用します。ZIP内baselineは変更前、candidateは更新後のsourceです。patch適用結果とcandidateのファイル内容を照合しています。

歴史的なreportやraw resultsは上書きしていません。今回の全raw data・ログ・比較入力・tested native binariesはZIPに、再現用コードと処理済みsummaryはこのdirectoryに分けています。
