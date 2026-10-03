> 公開版では追加raw観測・候補dumpを除外しています。完全な証拠と過去履歴は納品済みアーカイブに保持されています。 [公開範囲](../cloud-20261003/PUBLICATION.md)を参照。

# 構造最適化の最終結果

初期343bf98からの累積速度比 **1.4122倍**。全35固定ケースの壁時計中央値の合計は1089.050 ms→771.152 ms。95% paired bootstrap区間1.4039–1.4199倍。5倍未達。新しい構造案10種類に到達したため停止。採用は02/03/08の3案。前段の微最適化10案は別に保存され、今回の試行数に混ぜていない（総計20案）。

## 評価条件

Host cachyos-x8664 / AMD Ryzen 7 7700X 8-Core Processor. Bend2.0.34, Clang19.1.7, Lean4.34.1; unchanged build.sh, budgets, outputs. All35 frozen cases include7 commands, easy/mixed/hard/rating/generation and1/8/16 threads. Two warmups;21 paired serial randomized observations/case/engine; medians/IQR;5000 paired bootstrap resamples. Screens use7 substantial cases and9 observations versus current accepted binary. Corpus manifest/hash and selection were fixed before measurements. Main metric includes startup, parsing and output; internal BENCH is secondary. No case/test removed to claim a gain.

The host needed local official Debian shared libraries to run pinned Clang on CachyOS; their checksums and setup script remain in qa/perf-20261003. No runtime/compiler flags or OS tuning changes were used. Baseline binary SHA256 ba0d2e27c6ab81219f20fbb2cdb67389453b7d22b6ce4440bb887bf4c9979720; final d71295bb003303e7bb37bc8c8097835fc3874b0d66af70f7492e98e4b7c4ae0e.

## 実装した10案

|#|案|直前採用版に対する7ケース比|採否・理由|
|---|---|---:|---|
|01|Incremental packed candidates + decision snapshots|0.8258x|不採用: end-to-end slowdown; peer updates and snapshot costs exceed saved candidate recomputation|
|02|Fused parsing/validation/occupancy|1.1223x|採用: 35-case gain with CI above1; full gates and1931 independent comparisons pass|
|03|Persistent rating unit-digit support index|1.1159x|採用: rating screen2.276x incremental; same action/fuel sequences, independent index oracle, full gates and35-case cumulative confirmation pass|
|04|Hidden-single search propagation|1.2921x|不採用: violates resolved exact NS/MRV search order; multiple-solution first answers differ. Independent grid checks pass changed individual answers, CLI exact comparison fails. No test rewritten to claim compatibility.|
|05|Fused rating edit/index traversal|1.0044x|不採用: index oracle and CLI differential pass; aggregate gain0.44% is below reproducible meaningful threshold and CI includes slowdown|
|06|Generator occupancy reuse|0.9942x|不採用: 27-unit reinitialization removed correctly, but end-to-end screen0.994x; generator1.024x too small to establish meaningful overall effect|
|07|Compact initial-empty-position list|0.6581x|不採用: list traversal and duplication cost exceed saved fixed-cell reads; exact CLI compatibility passes but screen slows|
|08|Parallel output rope + linear flatten|1.1366x|採用: material incremental batch improvement; unchanged generic four-mode sequential equality proven using stronger tail induction and String associativity; all gates pass|
|09|Incremental missing-support count|0.9966x|不採用: every index and deficit count verified after actions; update255 access cost offsets saved missing scan; aggregate0.997x and rating1.002x below noise|
|10|Delay rating index until NS stalls|0.9797x|不採用: NS/HS/LC/NP and fuel oracles pass; rate workload1.125x but full incremental screen0.980x withCI below1; net regression therefore rejected|

01/04–07/09/10 are absent from final production source. Candidate patches/build logs/raw timings are retained.04 produced valid different individual multiple-solution grids and a6.054x hard-count screen, but breaks exact first-NS/otherwise-MRV selection; frozen CLI differential and diagnostic batch comparison failed. We did not change the specification or golden to accept it. All other trials passed1931 frozen CLI comparisons and independent solved-grid/rating checks;05/09/10 additionally passed dedicated action/fuel/index oracles.

## 採用した変更の累積確認

|採用後|基準中央値合計ms|候補中央値合計ms|累積比|95%区間|
|---|---:|---:|---:|---|
|02|1067.501|923.077|1.1565x|1.1487–1.1629|
|03|1069.546|841.066|1.2717x|1.2642–1.3161|
|08|1112.125|786.659|1.4137x|1.4067–1.4282|

These separate runs have different baseline medians because host timings fluctuate. Only same-run paired baseline/candidate measurements establish each ratio; the final run below is the reported endpoint.

## 最終全35ケース（中央値、四分位範囲）

|ケース|基準ms [p25,p75]|最終ms [p25,p75]|速度比|
|---|---:|---:|---:|
|solve_new_easy|0.614 [0.592,0.639]|0.637 [0.582,0.662]|0.964x|
|solve_original_hard|4.270 [4.224,4.349]|4.268 [4.220,4.325]|1.001x|
|solve_new_complete|0.620 [0.597,0.643]|0.614 [0.577,0.643]|1.008x|
|solve_new_multi_solution|0.645 [0.588,0.667]|0.629 [0.615,0.654]|1.026x|
|count_new_easy|0.625 [0.608,0.662]|0.632 [0.599,0.656]|0.989x|
|count_original_hard|6.881 [6.827,6.988]|6.874 [6.809,7.004]|1.001x|
|count_new_complete|0.607 [0.579,0.633]|0.604 [0.556,0.630]|1.005x|
|count_new_multi_solution|0.656 [0.637,0.667]|0.657 [0.614,0.667]|0.998x|
|rate_new_easy|0.918 [0.894,0.970]|0.752 [0.716,0.769]|1.221x|
|rate_original_hard|0.772 [0.724,0.789]|0.712 [0.698,0.736]|1.085x|
|rate_new_complete|0.611 [0.589,0.642]|0.633 [0.601,0.648]|0.965x|
|rate_new_multi_solution|0.801 [0.780,0.824]|0.745 [0.715,0.770]|1.075x|
|generate100_clues36|14.991 [14.865,15.242]|14.846 [14.694,15.275]|1.010x|
|generate_minimal|2.221 [2.189,2.306]|2.199 [2.163,2.266]|1.010x|
|batch_easy-10000_solve_t1|195.305 [193.124,198.058]|121.849 [121.049,123.053]|1.603x|
|batch_mixed-1000_solve_t1|23.776 [23.471,23.983]|18.959 [18.840,19.200]|1.254x|
|batch_hard-100_count_t1|149.598 [148.549,151.614]|148.298 [147.899,149.141]|1.009x|
|batch_rate-300_rate_t1|113.401 [112.270,148.299]|49.242 [48.338,49.725]|2.303x|
|batch_verification_check_t1|0.925 [0.884,0.944]|0.811 [0.754,0.840]|1.141x|
|bench_easy-10000_t1|162.330 [161.485,164.004]|117.871 [117.482,118.784]|1.377x|
|bench_mixed-1000_t1|24.755 [24.572,25.078]|20.320 [20.174,20.787]|1.218x|
|batch_easy-10000_solve_t8|64.835 [61.714,66.398]|43.354 [42.823,44.708]|1.495x|
|batch_mixed-1000_solve_t8|8.425 [7.953,8.948]|6.892 [6.749,7.244]|1.222x|
|batch_hard-100_count_t8|27.388 [26.654,28.504]|27.390 [26.681,28.556]|1.000x|
|batch_rate-300_rate_t8|20.899 [19.945,22.470]|10.133 [9.696,10.403]|2.062x|
|batch_verification_check_t8|1.177 [1.145,1.215]|1.163 [1.126,1.186]|1.012x|
|bench_easy-10000_t8|59.454 [58.825,60.088]|34.364 [33.836,35.150]|1.730x|
|bench_mixed-1000_t8|8.542 [8.243,8.942]|6.107 [5.934,6.266]|1.399x|
|batch_easy-10000_solve_t16|65.072 [63.890,67.999]|43.007 [42.063,44.304]|1.513x|
|batch_mixed-1000_solve_t16|7.893 [7.473,8.169]|6.550 [6.347,6.615]|1.205x|
|batch_hard-100_count_t16|29.539 [29.073,29.897]|27.942 [27.335,29.080]|1.057x|
|batch_rate-300_rate_t16|21.061 [20.569,22.447]|11.206 [10.736,11.629]|1.879x|
|batch_verification_check_t16|1.662 [1.539,1.744]|1.345 [1.300,1.386]|1.236x|
|bench_easy-10000_t16|59.584 [58.671,60.509]|34.223 [33.510,35.157]|1.741x|
|bench_mixed-1000_t16|8.198 [8.005,8.642]|5.324 [5.233,5.595]|1.540x|

## 正しさと証明

Final ./verify.sh PASS including the full timing benchmark. Independent final differential1931 comparisons/347 distinct puzzles PASS (all7 CLI commands, exact exit/stdout/stderr except BENCH timing, invalid inputs, file boundaries, deterministic seeded generation, ordered1/8/16-thread batch). Set-based solutions/clue preservation and independent Python rating trace oracle pass. Existing independent capped counter checks generated uniqueness and retained clue/pair minimality.216 CLI fixtures, forced-fuel/valid-prefix handling and mutation checks pass. Existing6060 exact search-state/fuel observations still pass; no solver algorithm/fuel change was adopted.

Indexed-rating tests compare every243 index entry to independent nine-cell scans after each action, exact NS/HS/LC/NP action order, fuel0..63/0..23 and empty-board boundary to unchanged list reference. All applicable finite laws and generic four-mode batch/sequence equality remain. Output rope needed additional String append identity/associativity and arbitrary-tail induction proofs; BendTT verdict PASS. The initial proof failure and failed old prepared-count mutant interception were retained, then fixed without removing the properties.

Native/Bend all7 commands and Node-compatible5 commands PASS. JS file IO requires Bun, which is not installed on this host; that pre-existing lane limitation remains and is explicitly reported by the suite. No permission barrier or unfinished engine correction remains.

## 再現

Working directory sudoku-engine-bend; local branch perf/structural-optimization. Production commits3f4730a (02), f978269 (03), a4d9e31 (08), then final evidence commit. No push/merge. See README.md for baseline rebuild and corpus restoration.

```sh
. ./toolchain-env.sh
./build.sh
./verify.sh
python3 qa/perf-20261001/prepare_corpus.py ../corpora
python3 qa/perf-20261001/differential.py --base ../baseline --candidate bin/bend-sudoku --repo . --corpora ../corpora --out /tmp/differential.json
python3 qa/perf-20261001/measure.py --base ../baseline --candidate bin/bend-sudoku --cases qa/perf-20261001/cases.json --corpora ../corpora --reps 21 --out /tmp/measurement.json
python3 qa/perf-20261003/analyze.py /tmp/measurement.json
```

Every trial has NN-change.patch plus measurements and raw samples in results/. final-confirm.json.raw.json.gz includes wall/user/system/RSS, stdout/stderr hashes, every warmup and observation, randomized order and internal BENCH time. Final source and reports remain local.
