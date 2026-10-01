# Bend optimization: 2026-10-01

## Accepted result

This release keeps the rating caches and direct board validation inside BENCH. The empty-cell bitset and all batch chunk sizes were rejected after staged measurements showed mixed effects. The production search, solver, candidate, counter and generator modules remain byte-for-byte identical to base `648cd0cf65e7e3cc48c2f063dddc377f947481f2`.

The final 300-puzzle rating batch at one thread improved from 1005.688 ms to 172.022 ms (5.85×). All numbers below compare the pinned old Bend binary against the selected new Bend binary, not a new cross-language run.

### Selected workloads

| Workload | Before median ms (IQR) | After median ms (IQR) | Before / after |
|---|---:|---:|---:|
| rate_new_easy | 3.196 (2.932–3.321) | 1.535 (1.405–1.657) | 2.082× |
| rate_original_hard | 3.428 (3.318–3.563) | 1.254 (1.190–1.286) | 2.734× |
| batch_rate-300_rate_t1 | 1005.688 (977.075–1032.556) | 172.022 (166.064–180.082) | 5.846× |
| batch_rate-300_rate_t8 | 180.625 (164.541–187.368) | 40.021 (36.945–45.578) | 4.513× |
| batch_rate-300_rate_t16 | 198.575 (184.812–208.715) | 40.892 (37.956–43.361) | 4.856× |
| bench_easy-10000_t1 | 295.762 (281.556–302.238) | 255.564 (244.111–269.037) | 1.157× |
| bench_easy-10000_t8 | 102.987 (100.854–108.696) | 96.275 (94.652–97.314) | 1.070× |
| bench_easy-10000_t16 | 116.654 (108.977–122.862) | 103.472 (99.994–108.502) | 1.127× |
| bench_mixed-1000_t1 | 40.718 (39.838–43.309) | 36.406 (35.408–37.116) | 1.118× |

## What changed

- Rating: build unit coverage in one pass rather than 27 full-board scans per step; initialize candidate masks from fixed-digit coverage; use an affine cell array for nine-cell hidden-single, locked-candidate and naked-pair scans. Preserve the original public list-state helpers as the regression oracle and preserve action order, scores, fuel boundaries and partial-state semantics.
- BENCH: validate the solved board and clues directly rather than serialize the result, parse it again and then validate it. Puzzle parsing, input validation, complete-grid checks, clue checks and unit validation are retained.
- Add exact search/fuel golden observations, rating state/action tests, direct-BENCH reference comparisons and portable benchmark/correctness scripts with frozen gzip inputs.

BENCH-only improvement is reported separately: the same required semantic checks remain, but formatting/reparsing work inside its timer has been removed. Its internal time is not a pure solver-kernel measurement and is not interchangeable with the old implementation boundary. Ordinary solve performance must be assessed with the solve/batch-solve rows, not inferred from BENCH.

## Candidate screening and rejected changes

Each initial screen used two warmups and nine randomized paired fresh-process samples; confirmations and the final pass used 21 samples. Aggregate screen results are retained below; only selected-release numeric samples are published.

- Coverage-only rating: batch300 was 990→600 ms (1.65×). Coverage plus cached initialization screened at 1.72× versus the old baseline.
- Adding cached hidden/locked scans: batch300 was 1005→207 ms (4.86×).
- Cached pair scans were confirmed directly against the hidden/locked variant with 21 samples: batch300 was 201→176 ms (1.141×); hard single rating was 2.158→1.238 ms (1.743×).
- Empty-cell words initially showed 5–11% gains on selected workloads. A combined 21-sample run failed to confirm the hard-count gain and showed a possible generation slowdown. A controlled 21-sample ablation found bulk solve about 4–6% faster, hard count about 1% faster, and 1,000-puzzle generation varying from 1.8% slower at 36 clues to 2.9% faster at 28 clues. This mixed/marginal change was excluded. The generic search/fuel regression test was retained.
- Chunk sizes 4, 8 and 16 passed independent verdicts and 516 output comparisons each. Easy single-thread batch improved approximately 7–10%, but multithreaded rating worsened approximately 3–7%, with other mixed/benchmark regressions. All chunk changes and proof adaptations were excluded.

Rejected experiment patches and machine-specific raw material are omitted from the publication copy.

## Correctness and proof boundary

- Final `verify.sh`: exit 0; independent Lean-4.34.0-built BendTT verdict says `ALL PROOFS CHECK`.
- Existing 49 native assertions and three optimization assertions, 216 CLI cases, independent generation uniqueness/minimality and technique-reference checks, mutation detection, and production fuel/valid-prefix tests pass.
- Eleven new rating QA groups cover exact action order, all relevant technique fuel boundaries, 82 malformed/partial ladder states, 1,000 initializer states and 1,000 coverage states, including bit0 and upper-bit masks.
- Direct BENCH validation matches the string/reparse reference on 100 generated boards and edge cases.
- 1,931 additional baseline comparisons cover all seven commands, 347 distinct puzzles, seed boundaries, malformed inputs, physical lines, the 16 MiB limit and ordered batch output at threads 1/8/16. Successful solutions and rating results are independently validated. Only BENCH timing fields are normalized.
- 6,060 exact search/fuel observations match the frozen baseline golden hash: state tags, depths, solution counts, board cells and active stack words. Both limits 1/2 cover fuel 0–300 on five inputs and hard samples up to 200,000.
- `LAWS.bend` and `PROOF.bend` are unchanged. The laws prove their existing finite executable and structural scope, not the entire Sudoku solver. No unsafe/foreign shortcuts, compiler changes or proof weakening were introduced.
- All seven native and Bend-invocation commands pass. Five Node-compatible commands pass; JS batch/bench file effects still require Bun and were not run. No GPU performance claim is made.

## Method and reproducibility

Baseline source was recovered from the private remote main commit and every blob hash verified before changes. Bend 2.0.34 was restored from the official pinned release, its full `bend guide` executed and read before design, and the independent unmodified BendTT kernel rebuilt using Lean 4.34.0. Actual Clang 19.1.7 built both variants with identical Bend defaults: `-std=c11 -O3 -lpthread -lm`, no CPU-specific flags. Compiler versions and the pinned baseline commit are recorded in summary.json.

Both versions were measured serially on the same Linux x86-64 cloud host. Other builds/tests were stopped during timing; frequency and unrelated tenant activity were not controlled. Machine-specific identifiers are omitted.

The final pass has two warmups per variant/case followed by 21 samples, deterministic randomized pair order, and one process at a time. Wall time includes startup, parsing, file IO, computation, output and capture. `wait4` records child-specific user/system CPU. True engine peak RSS is measured separately by a tiny C launcher; the raw wall-run RSS fields can include Python pre-exec high-water marks and are not used for the memory claims. BENCH internal milliseconds are separate in raw data. Tiny ~1 ms CLI cases are startup-dominated; differences in unchanged commands must not be presented as algorithmic speedups. All results, including slower medians and spread, appear below.

The corpus comes from verified published benchmark commit `e286b377307a5e2013f07e89dabf0f1e0fad8189`: fixed first-line subsets of easy/mixed/rating/hard files plus the unchanged verification file. Selection and decompressed hashes are in `qa/perf-20261001/corpus-manifest.json`. See [reproduction instructions](../../../qa/perf-20261001/README.md). No original Sudoku implementation source was read.

## Full final wall-time results

Ratios above 1 favor the selected new version. IQR is the 25th–75th percentile interval.

| Case | Before median ms (IQR) | After median ms (IQR) | Speedup |
|---|---:|---:|---:|
| solve_new_easy | 1.060 (1.027–1.141) | 0.977 (0.938–1.039) | 1.086× |
| solve_original_hard | 6.759 (6.423–7.197) | 7.036 (6.498–7.507) | 0.961× |
| solve_new_complete | 1.005 (0.965–1.068) | 1.013 (0.963–1.083) | 0.992× |
| solve_new_multi_solution | 1.064 (1.015–1.197) | 1.052 (0.976–1.139) | 1.012× |
| count_new_easy | 0.975 (0.919–1.018) | 0.952 (0.912–1.007) | 1.024× |
| count_original_hard | 10.479 (10.222–11.478) | 10.526 (10.106–11.032) | 0.996× |
| count_new_complete | 0.939 (0.874–1.109) | 0.950 (0.920–1.041) | 0.988× |
| count_new_multi_solution | 1.072 (0.986–1.146) | 1.067 (1.031–1.168) | 1.004× |
| rate_new_easy | 3.196 (2.932–3.321) | 1.535 (1.405–1.657) | 2.082× |
| rate_original_hard | 3.428 (3.318–3.563) | 1.254 (1.190–1.286) | 2.734× |
| rate_new_complete | 1.158 (1.103–1.286) | 0.996 (0.940–1.048) | 1.163× |
| rate_new_multi_solution | 3.425 (3.283–3.555) | 1.290 (1.252–1.327) | 2.656× |
| generate100_clues36 | 23.731 (22.015–24.570) | 22.931 (22.001–25.106) | 1.035× |
| generate_minimal | 3.786 (3.566–4.196) | 3.678 (3.490–3.934) | 1.029× |
| batch_easy-10000_solve_t1 | 315.496 (311.266–328.175) | 313.145 (311.724–326.304) | 1.008× |
| batch_mixed-1000_solve_t1 | 37.455 (36.433–38.979) | 36.796 (35.515–38.186) | 1.018× |
| batch_hard-100_count_t1 | 224.615 (219.236–232.899) | 225.571 (218.520–236.399) | 0.996× |
| batch_rate-300_rate_t1 | 1005.688 (977.075–1032.556) | 172.022 (166.064–180.082) | 5.846× |
| batch_verification_check_t1 | 1.735 (1.632–1.904) | 1.801 (1.653–1.936) | 0.964× |
| bench_easy-10000_t1 | 295.762 (281.556–302.238) | 255.564 (244.111–269.037) | 1.157× |
| bench_mixed-1000_t1 | 40.718 (39.838–43.309) | 36.406 (35.408–37.116) | 1.118× |
| batch_easy-10000_solve_t8 | 123.652 (115.512–131.677) | 124.403 (120.976–140.219) | 0.994× |
| batch_mixed-1000_solve_t8 | 14.049 (12.825–15.507) | 14.854 (12.866–15.614) | 0.946× |
| batch_hard-100_count_t8 | 60.236 (56.832–66.819) | 57.539 (55.921–62.822) | 1.047× |
| batch_rate-300_rate_t8 | 180.625 (164.541–187.368) | 40.021 (36.945–45.578) | 4.513× |
| batch_verification_check_t8 | 2.116 (1.975–2.221) | 2.121 (2.002–2.307) | 0.998× |
| bench_easy-10000_t8 | 102.987 (100.854–108.696) | 96.275 (94.652–97.314) | 1.070× |
| bench_mixed-1000_t8 | 15.731 (14.830–16.904) | 15.238 (14.728–16.319) | 1.032× |
| batch_easy-10000_solve_t16 | 127.925 (120.369–140.263) | 127.901 (121.048–136.445) | 1.000× |
| batch_mixed-1000_solve_t16 | 16.218 (14.889–17.461) | 16.503 (15.399–18.162) | 0.983× |
| batch_hard-100_count_t16 | 59.250 (57.004–65.794) | 60.792 (55.815–68.715) | 0.975× |
| batch_rate-300_rate_t16 | 198.575 (184.812–208.715) | 40.892 (37.956–43.361) | 4.856× |
| batch_verification_check_t16 | 2.685 (2.594–3.328) | 2.670 (2.568–2.823) | 1.006× |
| bench_easy-10000_t16 | 116.654 (108.977–122.862) | 103.472 (99.994–108.502) | 1.127× |
| bench_mixed-1000_t16 | 16.897 (15.978–18.048) | 15.831 (15.050–16.628) | 1.067× |

## CPU and resident memory examples

| Case | Before CPU ms | After CPU ms | Before peak RSS KiB | After peak RSS KiB |
|---|---:|---:|---:|---:|
| batch_rate-300_rate_t1 | 1004.290 | 171.034 | 2444 | 2068 |
| batch_rate-300_rate_t8 | 1191.827 | 200.926 | 3968 | 4176 |
| bench_easy-10000_t1 | 294.149 | 253.155 | 21324 | 21088 |
| generate100_clues36 | 23.377 | 22.471 | 1372 | 1116 |

RSS is OS peak resident memory, not allocator heap accounting. Selected-release numeric samples are in `timings.json.gz`, aggregate statistics in `summary.json`, and reliable engine RSS in `memory.json` (two warmups plus seven serial randomized samples). Paths, machine/account identifiers, binary/output hashes and unrelated provenance have been removed from the publication copy. Raw launch RSS is excluded because it is not engine footprint. GitHub CI status is separate from these completed local gates.
