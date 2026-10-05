# 2026-10-05 performance trials

Baseline: `06b49c06e07b447f2a077183515570695592a3b4`, tree
`99de0480a911d3dc27591c61513d893ce02c054e`.

This work tests three source-level changes without changing CLI output, search
order, fuel, seeded generation, compiler pins, or benchmark inputs:

- Fresh queued-candidate encoding omits writes of flags already known to be zero.
- Rating combines missing-support detection and the first hidden single scan
  when no naked single is available. Later missing support still takes priority.
- Parsing carries the current row occupancy and column in scalars and writes
  the row word once per nine cells.

The new regressions compare all 128 encoded/parser words against frozen code,
exact parser error precedence, all 256 retained rating support words, action
order, and existing rating action/fuel traces. Existing gates are retained.

## Locked reproduction

Run from a clean checkout after `./setup.sh`:

```sh
bash qa/perf-20261005/locked-compare.sh
```

Set `BEND_PERF_WORK` to select an empty output directory. The script builds the
immutable baseline and each isolated candidate with the unchanged locked
toolchain, runs full correctness/proof/lane gates in the existing low-memory
mode, runs the 1,931-case CLI differential, then performs serial randomized
paired measurements. Each case has two warmups and 21 measured pairs. The
original 35-case workload and corpus hashes are unchanged; seven preselected
substantial cases separately screen each candidate. All samples and 5,000
paired bootstrap results are retained. The skipped built-in timing gate is
explicit; the fixed 35-case comparison runs afterward.

## Diagnostic environment

The editing host cannot download the locked release binaries. Local diagnostic
execution uses the byte-verified source of Bend 2.0.35 at
`79df8d9c40722ee9507a1e253f283b51025f9d6c`, Node 24.19.0 and GCC 13.3.0.
Original compiler source is unmodified. A separate emitted-C copy removes only
Clang `musttail` annotations and uses GCC `-std=c11 -O3 -foptimize-sibling-calls
-lpthread -lm`. Both baseline and candidate use the same process. Larger stack
limits are needed for some diagnostic QA because GCC lacks the required
Clang tail-call guarantee. This is not the locked toolchain and does not verify
the Lean-backed verdict. Diagnostic results must not be presented as a release
verification or as a reliable Clang performance prediction.

Initial local seven-case screens of the first encode, rating, and row-local
parser variants show approximately 1.02–1.03x aggregate ratios; every 95%
interval includes 1. These screens do not establish a speedup. The parser
column-scalar variant and locked results are evaluated separately. The trial
branch remains provisional pending meaningful measured improvement and the
locked correctness gates.
