# Bend Sudoku performance optimization

## Result: a partial Go-beating result

The optimized Bend engine is measurably faster than the unchanged Go reference for the hard search/count workload and single-thread mixed batch. It is **not faster across all workloads**: easy bulk workloads and rating remain slower, and 100-puzzle generation is approximately tied.

Reference: new Bend repository base `42d465a8d089e5d4662d892bc14da183cafef7ba`; Go 1.27.1 standard-library port, binary SHA-256 `ce3a34194fe36bc18b7b95c316cf1399f7a6acc5ab5f023048ef40da6ce3bd6b`. The Go source/binary were not changed during this optimization. No original Sudoku implementation source was used.

## Confirmed single-thread wins

An independent second pass used two warmups, 21 measured fresh CLI processes per engine, alternating engine order. Both interquartile ranges are separated on these two cases.

| Workload | Bend median ms (IQR) | Go median ms (IQR) | Go / Bend |
|---|---:|---:|---:|
| Hard solve | 7.312 (6.987–7.868) | 10.138 (9.219–10.690) | 1.39× |
| Hard count | 12.530 (11.768–13.354) | 15.693 (15.015–18.283) | 1.25× |

## Full paired benchmark highlights

| Workload | Threads | Bend median ms | Go median ms | Go / Bend |
|---|---:|---:|---:|---:|
| rate_new_easy | 1 | 3.197 | 1.640 | 0.51× |
| generate_100_clues36 | 1 | 24.291 | 24.410 | 1.00× |
| bench_easy10000 | 1 | 312.634 | 187.910 | 0.60× |
| batch_solve_easy10000 | 1 | 369.504 | 171.774 | 0.46× |
| bench_mixed1000 | 1 | 1691.786 | 2059.691 | 1.22× |
| batch_solve_mixed1000 | 1 | 1559.248 | 2039.966 | 1.31× |
| bench_easy10000 | 8 | 124.618 | 87.985 | 0.71× |
| batch_solve_easy10000 | 8 | 168.280 | 82.681 | 0.49× |
| bench_mixed1000 | 8 | 481.886 | 391.318 | 0.81× |
| batch_solve_mixed1000 | 8 | 398.730 | 348.463 | 0.87× |
| bench_easy10000 | 16 | 118.367 | 57.733 | 0.49× |
| batch_solve_easy10000 | 16 | 152.479 | 61.131 | 0.40× |
| bench_mixed1000 | 16 | 392.335 | 375.561 | 0.96× |
| batch_solve_mixed1000 | 16 | 336.919 | 358.953 | 1.07× |

Ratios above1 favor Bend. Mixed1000 is250 each of easy/medium/hard/complete. Easy10000 is100 distinct seed1..100,36-clue puzzles repeated100 times. These are explicit fixed corpora, not hidden repetitions inside the CLI. Tiny single-call results are startup-dominated and can be noisy.

## Direct before/after Bend comparison

Separate alternating before/after pass: two warmups, seven measured runs, one thread, unchanged input and same host.

| Workload | Before ms | After ms | Speedup |
|---|---:|---:|---:|
| solve_hard | 15.877 | 7.668 | 2.07× |
| count_hard | 25.631 | 12.523 | 2.05× |
| rate_easy | 100.560 | 3.674 | 27.37× |
| generate100 | 71.110 | 24.021 | 2.96× |
| bench_easy10000 | 623.911 | 334.651 | 1.86× |

## What changed

- Cache row/column/box occupancy in board padding81..107 and first empty position in108; preserve the public uncached candidate API
- Replace allocated candidate lists and frame lists with bit masks and a packed fixed-capacity affine frame array; maintain exact placement/backtracking fuel transitions
- Use low10-bit SWAR popcount; test equivalence to the previous bit loop
- Replace repeated rating digit-availability scans with unit coverage, and repeated linked-list indexing with linear scans
- Precompute complete-grid row/column permutations once per generated grid; RNG draws and puzzle sequence unchanged
- Single-pass puzzle parsing retains length-before-character error precedence; digit output avoids general integer formatting
- Tail-recursive physical-line scanner and consuming balanced tree builder avoid repeated list-prefix copies
- Remove unused validation look-ahead reads

## Method and memory

Bend2.0.34 / Clang19.1.7 and Go1.27.1 run on the same Linux cloud host, AMD EPYC 9V74 80-Core Processor. Two warmups, then11 samples for single/generation cases and7 for bulk cases; engine order alternates. Go GOMAXPROCS equals Bend --threads at1/8/16. Compilation and correctness checks finished before timing. Default Go GC, no CPU/GPU offload, no unsafe/foreign acceleration, no precomputed puzzle answers. CPU frequency and other tenant activity were not controlled.

Wall time includes fresh process startup, file/input parsing, work, output and capture. Internal bench time includes solve plus solution/clue validation and reduction; excludes file read/preparation. It is not a pure solver kernel. Internal integer-ms timing is recorded separately in the summary.

Linux wait4 child-specific peak RSS, seven runs: hard solve Bend1372KiB vsGo2064KiB; generation100 Bend1372 vsGo3216; easy10000 bench one-thread Bend21348 vsGo6160. Thus small-run Bend memory is lower, but bulk memory remains higher. RSS is OS resident memory, not allocator heap accounting.

## Correctness and proof boundary

- Final verify.sh exit0: independent Lean4.34.0-built BendTT kernel reports ALL PROOFS CHECK
- LAWS.bend and PROOF.bend remain byte-identical to the pinned base; the stated limited proof scope is unchanged
- 49 original native assertions plus3 optimization assertions (4096 popcount masks; upper-bit boundary; cached/public masks100 boards×81 cells)
- 216 original CLI cases; independent generator uniqueness/minimality and independent NS/HS/LC/NP rating reference
- 638 exact Go differential cases including seed wrap, minimality/symmetry, errors and1/8/16 batch ordering; successful bench timing numbers naturally are not compared for equality
- 68 additional physical-line boundary comparisons against the old Bend binary
- Fuel/valid-prefix tests, counter/mirror mutation detection,15 native benchmark sizes/thread combinations all pass
- Native and Bend-invocation all7 commands plus five Node-compatible commands pass; JS batch/bench still require unavailable Bun, so no new claim there

These tests and kernel acceptance do not prove universal solver completeness, generation uniqueness, or Go equivalence. Runtime structures differ between languages; this is an implementation comparison, not language-only causality. No GPU performance claim.

## Reproduce

Run ./verify.sh with BEND, CC and BENDTT (or matching Lean) configured. Build the unchanged Go reference, then:

```sh
GO_SUDOKU=/absolute/path/to/go-sudoku python3 qa/compare_go.py
```

Evidence under .omo/evidence/: optimization-summary.json (all37 cases, dispersion, hashes), optimization-confirmed-wins.json, optimization-before-after.json, optimization-memory.json, optimization-raw-timings.json.gz (each measured timing plus output digests), optimization-correctness.json.gz, optimization-line-boundaries.json and optimization-gates.log. The original complete raw stdout/stderr measurements are also retained in the local comparison deliverable.
