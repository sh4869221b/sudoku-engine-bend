# Sudoku engine in Bend

Seven-command, standard-library-only Sudoku engine: solve, check, count, rate, generate, batch and bench.

## Build and verify

```sh
./setup.sh
./build.sh
./verify.sh
bin/bend-sudoku --threads 1 generate --seed 42 --clues 32
```

The Linux x86_64 setup downloads checksum-locked official Bend **2.0.34**
(latest stable on 2026-10-01) and Lean **4.34.1**, and preserves the compatible
Clang **19.1.7** backend. It builds the unmodified release's BendTT kernel with
Lean. [toolchain.lock.json](toolchain.lock.json) records versions, release URLs,
archive hashes and the Bend executable/kernel-source hashes. Nothing is installed
system-wide; tools live in ignored `.toolchains/`.

Prerequisites: Python 3, curl, tar, zstd, dpkg-deb, a C toolchain and the usual
Debian-compatible native development/runtime libraries (listed in the lock).
The complete verification also uses Node for its existing JavaScript lane.
The engine itself remains standard-library-only.

Build and verification check the installed lock and tool versions, then select
explicit tool paths. Ambient `BEND`, `CC` and `BENDTT` cannot silently select
another compiler. Set `BEND_TOOLCHAIN_DIR` to reuse an installation made by this
lockfile. For the earlier upstream-matched proof compiler, explicitly run
`./setup.sh --lean-version 4.34.0`; this is a compatibility fallback, not the
latest stable selection. Running `./setup.sh` restores the default 4.34.1.

Verification runs the existing gates in a fresh `.verification/<run>/work/`
copy and writes its log, summary and evidence there. Historical committed results
and fixtures are never overwritten. `./verify.sh --skip-benchmark` runs all
correctness, proof and lane gates while explicitly omitting timing measurements.
See the [stable-toolchain validation](.omo/evidence/stable-toolchains-20261001/REPORT.md)
and [.omo/evidence/contracts.md](.omo/evidence/contracts.md) for CLI and proof scope.

## 2026-10-03 cloud optimization

Publication includes code, tests, reproduction scripts and result summaries. Full raw measurements and trial dumps remain in the separately delivered archive. See [publication and reproduction notes](qa/cloud-20261003/PUBLICATION.md) and [fresh publication verification](qa/cloud-20261003/PUBLICATION-VERIFICATION.md). Earlier reports describe their historical archive checkpoints.

The cloud continuation preserves the pinned toolchain, fixed 35-case workload and exact NS→MRV search/fuel semantics. See the [cloud report](qa/cloud-20261003/REPORT.md) for the current result, retained rejected trials, per-case tradeoffs and correctness scope. The earlier reports below are historical checkpoints, not descriptions of the latest source.

## 2026-10-01 optimization (historical)

That revision added measured rating caches and direct board validation inside BENCH. All seven CLI commands, independent rating/solution oracles, 6,060 exact search/fuel observations and the Lean-backed verdict pass. Solver/search/candidate code and the existing laws are unchanged. See the [current before/after report](.omo/evidence/optimization-20261001/REPORT.md) and [reproduction instructions](qa/perf-20261001/README.md), including rejected experiments and all timing samples.

## Earlier Go comparison (648cd0c)

Hard single-thread solve and count beat the unchanged Go reference in two paired measurements. The confirmation pass gives1.39× and1.25× respectively; single-thread mixed1000 batch is1.31×. This is a partial target achievement: easy bulk and rating remain slower than Go; generation100 is approximately tied.

See the [full performance report](.omo/evidence/optimization-report.md) for exact inputs,1/8/16-thread results, variability, memory, remaining gaps and reproducible scripts. All existing gates, independent kernel recheck,638 Go differential cases and68 extra line-boundary cases pass.
