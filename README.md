# Sudoku engine in Bend

Seven-command, standard-library-only Sudoku engine: solve, check, count, rate, generate, batch and bench.

## Build and verify

```sh
./build.sh
./verify.sh
bin/bend-sudoku --threads 1 generate --seed 42 --clues 32
```

Use Bend2.0.34 and Clang19.1.7. Verification requires matching BendTT/Lean4.34.0 for independent kernel checking. See [.omo/evidence/contracts.md](.omo/evidence/contracts.md) for CLI and proof scope.

## 2026-10-01 optimization

The latest revision adds measured rating caches and direct board validation inside BENCH. All seven CLI commands, independent rating/solution oracles, 6,060 exact search/fuel observations and the Lean-backed verdict pass. Solver/search/candidate code and the existing laws are unchanged. See the [current before/after report](.omo/evidence/optimization-20261001/REPORT.md) and [reproduction instructions](qa/perf-20261001/README.md), including rejected experiments and all timing samples.

## Earlier Go comparison (648cd0c)

Hard single-thread solve and count beat the unchanged Go reference in two paired measurements. The confirmation pass gives1.39× and1.25× respectively; single-thread mixed1000 batch is1.31×. This is a partial target achievement: easy bulk and rating remain slower than Go; generation100 is approximately tied.

See the [full performance report](.omo/evidence/optimization-report.md) for exact inputs,1/8/16-thread results, variability, memory, remaining gaps and reproducible scripts. All existing gates, independent kernel recheck,638 Go differential cases and68 extra line-boundary cases pass.
