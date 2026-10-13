# Sudoku engine in Bend

Seven-command, standard-library-only Sudoku engine: solve, check, count, rate, generate, batch and bench.

## Build and verify

```sh
./setup.sh
./build.sh
./verify.sh
bin/bend-sudoku --threads 1 generate --seed 42 --clues 32
```

The Linux x86_64 setup downloads checksum-locked official Bend **2.0.37**
(stable release published 2026-10-13 10:13:41 UTC), preserves Lean **4.34.1**, and preserves the
compatible Clang **19.1.7** backend. It builds the unmodified release's BendTT kernel with
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
`./setup.sh --lean-version 4.34.0`; this is an explicit compatibility fallback to the preserved 4.34.1 selection. Running `./setup.sh` restores the default 4.34.1.

Verification runs the existing gates in a fresh `.verification/<run>/work/`
copy and writes its log, summary and evidence there. Historical committed results
and fixtures are never overwritten. `./verify.sh --skip-benchmark` runs all
correctness, proof and lane gates while explicitly omitting timing measurements.
See the [stable-toolchain validation](.omo/evidence/stable-toolchains-20261001/REPORT.md)
and [.omo/evidence/contracts.md](.omo/evidence/contracts.md) for CLI and proof scope.

## Low-memory verification

```sh
./verify.sh --low-memory
# Optional: omit timing only; all correctness/proof/lane gates still run.
./verify.sh --low-memory --skip-benchmark
# Fast adapter safety regressions (no toolchain installation needed):
python3 -m unittest discover -s qa -p 'test_low_memory.py' -v
```

This opt-in mode releases Bend before launching Clang for **every** native
build, including nested mutation tests. Proof verification checks a private
snapshot of the local import closure for unsafe/foreign promises, exports it
without scope diagnostics, exits Bend, and runs the same locked, unmodified
Lean-backed BendTT kernel. Only its exact successful kernel verdict is accepted.
The compiler, native `-std=c11 -O3 … -lpthread -lm` flags, all original gates,
mutation timeouts, and benchmark workload are unchanged. Ordinary `./verify.sh`
continues to use the upstream integrated compiler/verdict path.

The mode supplies `BUN_JSC_forceRAMSize=67108864` when no value is already set.
This is a compiler GC scheduling hint, **not a memory limit**. Process separation
reduces overlapping toolchain heaps; individual compiler phases can still use
about 1 GiB, and execution can still fail under resource pressure. It does not
reduce the Sudoku runtime's memory or change its solver algorithms.

Each run stays isolated under `.verification/`. Its summary and benchmark JSON
record `execution_mode` and the actual GC hint; failed earlier runs remain failed.
The summary distinguishes a completed benchmark from one never reached. The
adapter is private to this verification flow, not a general replacement for
Bend: sequential native builds support this project's Linux CPU lane without
X11/ALSA/GPU, require fresh output paths, and refuse existing files, directories
or symlinks. Proof snapshots support Base and contained relative `.bend` imports;
symlink/noncanonical proof entrypoints, unsupported imports and unexpected
diagnostics fail closed. The adapter refuses unreviewed future compiler pins. Check-only,
JavaScript export and interpreter lanes still use the pinned Bend directly.

## 2026-10-13 current compiler upgrade

The current target is **Bend 2.0.37**, preserving production/proof code, Lean
4.34.1 and Clang 19.1.7. This release predates the update request; the initial
2.0.36 selection relied on a stale web `/releases/latest` redirect. The explicit
release and GitHub release API identify 2.0.37. See the [current Japanese report](qa/compiler-20261013-v2037/REPORT.ja.md)
for verification and comparisons against both 2.0.35 and 2.0.36.

## 2026-10-13 intermediate 2.0.36 checkpoint

The following measurements remain valid for 2.0.36. The archived report’s
claim that 2.0.36 was latest is superseded by the 2.0.37 report above.

Bend is updated to 2.0.36 with unchanged production/proof code, Lean 4.34.1
and Clang 19.1.7. Both versions pass the existing low-memory verification gates.
The same-host fixed 35-case comparison measured 1.01249x overall speedup
(95% paired-bootstrap CI 1.00076–1.02545), with a 5.44% hard-count regression
at 16 threads on the nine-CPU allocation. Native file size falls by 37.91%;
RSS is broadly similar. See the [Japanese upgrade and comparison report](qa/compiler-20261013/REPORT.ja.md)
for all cases, verification, reproduction and limitations.

## 2026-10-04 compiler upgrade

Bend is updated to 2.0.35 with unchanged production/proof code. The fixed 35-case
same-source comparison is 1.0399x faster overall (95% CI 1.0343–1.0456), with a
single-thread hard-count regression. See the [compiler upgrade report](qa/compiler-20261004/REPORT.md)
for verification, compiler-memory recovery, per-case results and reproduction.

## 2026-10-03 cloud optimization

Publication includes code, tests, reproduction scripts and result summaries. Full raw measurements and trial dumps remain in the separately delivered archive. See [publication and reproduction notes](qa/cloud-20261003/PUBLICATION.md) and [fresh publication verification](qa/cloud-20261003/PUBLICATION-VERIFICATION.md). Earlier reports describe their historical archive checkpoints.

The cloud continuation preserves the pinned toolchain, fixed 35-case workload and exact NS→MRV search/fuel semantics. See the [cloud report](qa/cloud-20261003/REPORT.md) for the current result, retained rejected trials, per-case tradeoffs and correctness scope. The earlier reports below are historical checkpoints, not descriptions of the latest source.

## 2026-10-01 optimization (historical)

That revision added measured rating caches and direct board validation inside BENCH. All seven CLI commands, independent rating/solution oracles, 6,060 exact search/fuel observations and the Lean-backed verdict pass. Solver/search/candidate code and the existing laws are unchanged. See the [current before/after report](.omo/evidence/optimization-20261001/REPORT.md) and [reproduction instructions](qa/perf-20261001/README.md), including rejected experiments and all timing samples.

## Earlier Go comparison (648cd0c)

Hard single-thread solve and count beat the unchanged Go reference in two paired measurements. The confirmation pass gives1.39× and1.25× respectively; single-thread mixed1000 batch is1.31×. This is a partial target achievement: easy bulk and rating remain slower than Go; generation100 is approximately tied.

See the [full performance report](.omo/evidence/optimization-report.md) for exact inputs,1/8/16-thread results, variability, memory, remaining gaps and reproducible scripts. All existing gates, independent kernel recheck,638 Go differential cases and68 extra line-boundary cases pass.
