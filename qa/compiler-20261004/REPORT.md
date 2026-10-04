# Bend 2.0.35 compiler upgrade

## Result

The project lock moves from Bend **2.0.34 to 2.0.35**, the latest official stable
release checked on 2026-10-04. Lean **4.34.1** and Clang **19.1.7** are unchanged.
All production/proof Bend sources remain byte-identical to published main
`d1f8980754f4c19c073ce46f71c21b12b2412556` (tree
`19586e72df06b13f46f9975b9e9b36eaf18887bb`). No search, fuel, rating, seed,
arithmetic workaround, or test assertion was changed.

The fixed 35-case compiler-only comparison is **1.03990x faster overall**
(paired-bootstrap 95% CI **1.03434–1.04562x**), or **3.84% less elapsed time**.
This is a fresh same-host comparison of identical engine code, not a comparison
with the pre-optimization engine and not a new claim about the earlier 5x goal.

## Official release and lock

- [Release v2.0.35](https://github.com/bendlang/bend/releases/tag/v2.0.35), published
  2026-10-03 11:32:50 UTC; neither draft nor prerelease.
- Source commit: `79df8d9c40722ee9507a1e253f283b51025f9d6c`.
- Linux x64 archive SHA-256:
  `63039d1a119f716767ac5a7d8fe0717cfacf219c6c253c35192148e0dade722f`.
- Executable SHA-256:
  `af967c7c37aced4491e0f4344e3bb9de837c2c89b7519f7e0b8c71935be1840a`.
- BendTT source SHA-256:
  `e15042434e73aab07ab05cea4b77b5619082c00a6d4924ea2d4a2cdec05facce`.

The release includes CPU task scheduling/allocation changes, direct U32 division
and remainder on CPU/CUDA, namespace/constructor fixes, and proof-verdict fixes.
The official executable and unmodified proof-kernel source were used; the kernel
was rebuilt with the existing locked Lean version. Nothing was installed
system-wide. Benchmark metadata now reads the project lock instead of falsely
labeling every future run as 2.0.34; it explicitly identifies that provenance.

## Verification

All substantive existing gates completed through the staged path described
below. A fresh integrated verification retry with the temporary compiler GC
hint also terminated with exit 137 during the native build. Neither ordinary
full run is reported as passing; see [verification-summary.json](results/verification-summary.json).

- Native QA and all existing optimized-mask, row-bitmap, queued-candidate,
  singleton, arithmetic, peer, validation, tail, order-statistic, rating/cache,
  array, candidate, and direct-benchmark gates passed.
- Direct adaptive traces: **20 complete traces, 239,111 transitions and 239,131
  comparisons**, no capped incomplete trace.
- Golden state/fuel gate: **3,030 production outcomes plus 3,030 legacy direct
  transition observations**. These are not 6,060 live adaptive-stack traces.
- Integration, independent rating fixtures, **216 ordinary CLI cases**, fuel
  exits, and both mutation checks passed.
- All **7 native/Bend** and **5 Node-compatible** command lanes passed. The
  existing JS file-I/O limitation remains: Bun is not installed as a separate
  runtime, so that lane was not tested.
- All **15 normal benchmark records** completed successfully.
- Extra same-source comparisons passed: **1,931 CLI comparisons**, **129 file
  boundary comparisons covering 928 lines**, and **944 frozen randomized cases**
  (914 distinct puzzles; 2,832 standalone plus 9 batch comparisons).
- New scheduler regression: **60 exact comparisons**, threads **3 and 5**, batch
  sizes **127/128/129 and 255/256/257**, all four batch commands plus bench.
- Randomized independent count oracle: **799 known, 1 unknown, 144 invalid**.
  The one unknown exhausted its existing node budget; both engine results were
  still compared, but that count is not independently established. No oracle
  budget or assertion was weakened. These finite tests are not an exhaustive
  proof of the whole engine.

Processed results are in [results/](results/). The input-provenance check passed
before and after measurement, including frozen corpus hashes/counts, all 35
cases, source/proof files, validation inputs, and both binary hashes.

## Performance and memory

Two serial randomized blocks each used 21 measured pairs plus 2 warmups per
engine/case. All 42 pairs are pooled; neither block was discarded. The statistic
is the sum of the 35 per-case median wall times, with 5,000 paired-bootstrap
resamples. Processes include startup, parsing and output. Compiler construction
time is excluded. The host, CPU affinity, cases, hashes and individual case
medians are in [pooled.json](results/pooled.json).

The cloud host reports AMD EPYC 9V74 and exposes 9 logical CPUs, affinity 0–8.
The frozen 16-thread cases therefore oversubscribe this allocation; their result
is specific to this host and is not evidence of scaling on 16 physical cores.

| Measure | 2.0.34 | 2.0.35 | Old/new ratio |
|---|---:|---:|---:|
| Sum of 35 case medians | 422.6221 ms | 406.4068 ms | 1.03990x |
| Hard-100 count, 1 thread | 32.8910 ms | 34.1936 ms | 0.96191x |
| Hard-100 count, 8 threads | 9.2494 ms | 8.7658 ms | 1.05516x |
| Hard-100 count, 16 threads | 9.9347 ms | 7.7579 ms | 1.28060x |

The improvement is **not uniform**. Hard-count single-thread elapsed time is
**3.96% worse**; its speed ratio CI is **0.95296–0.97535x**. The 8-thread and
16-thread ratios have CIs **1.00400–1.15520x** and **1.20162–1.32338x** respectively.
These are per-case intervals, not a multiple-comparison guarantee.
The two overall blocks independently measured 1.03537x and 1.04246x.

Six fresh child-RSS comparisons used a tiny C launcher, two warmups and seven
measured pairs. Memory was broadly similar: easy-10000 solve at 1 thread changed
23,324→23,296 KiB; its 8-thread version 23,640→23,536 KiB; rate-300 at 1 thread
1,884→1,928 KiB. These small differences and overlapping ranges do not establish
a general memory reduction. See [memory.json](results/memory.json).

## Build recovery and limitations

Default integrated attempts terminated with exit 137, including a fresh build
using the unchanged old compiler. The signal alone does not prove an OOM cause;
the sandbox did not expose cgroup OOM counters. One monitored proof attempt
reported a 1,157,012 KiB process peak before SIGKILL. Failures and interrupted
diagnostic retries were retained, not relabeled as passes.

Recovery kept the exact official compiler, source, checker and Clang flags:

1. Compile retained C emitted by the normal 2.0.35 native build using
   `clang -std=c11 -O3 FILE.c -lpthread -lm -o BINARY`, after checking `BANGS=0`
   and absence of X11/ALSA imports. These are the
   [official CPU flags](https://github.com/bendlang/bend/blob/79df8d9c40722ee9507a1e253f283b51025f9d6c/bend2/main.ts#L422-L444).
2. Recheck the exact proof input retained by three ordinary verdict invocations
   using the installed new BendTT kernel and upstream
   `LEAN_STACK_SIZE_KB=4194304`. All inputs hash to
   `164993e7218bcf198a48edad81ffe8aafc0deee77f1c9e086c1e3beecca1aed0`.
   The kernel exits zero and prints `ALL PROOFS CHECK`.
   [Upstream control flow](https://github.com/bendlang/bend/blob/79df8d9c40722ee9507a1e253f283b51025f9d6c/bend2/safe.ts#L1525-L1548)
   writes this input only after the checked book passes unsafe/foreign and
   out-of-scope checks. This establishes staged proof verification, not success
   of those terminated integrated invocations.
3. Emit the large QA harness C with temporary
   `BUN_JSC_forceRAMSize=268435456`, then compile it sequentially with the same
   Clang flags. Emission succeeded in 24.01 seconds with 944,616 KiB peak RSS.
   This is a compiler-process GC/memory hint, **not a 256 MiB limit**. It was not
   added to the project defaults or used to tune native performance measurements.
4. Run the byte-for-byte existing gate suffix starting at `./bin/qa-run --threads 1`,
   with timing included and that temporary compiler hint. All gates passed.

The ordinary production build subsequently succeeded for **both compiler
versions** with the hint. The old executable exactly matches the benchmarked
baseline. A fresh 2.0.35 C emission with the hint is byte-identical to the original
normal emission. The normal new binary and the initially staged binary differ
only in compilation filename/symbol metadata and derived build ID: after removing
symbols and the build-ID note, both have SHA-256
`5fd7ab7dcfc74167058758c03fe144ea4d3e369689024f1bef1e8091be8f30b3`.
No stripped binary was benchmarked. Recompiling with the normal C basename also
reproduces the normal binary byte-for-byte.

Binary identities:

- Benchmarked old: `9ed5b3446c426fd561586d35e4481c72f852a1cca66bd2d12e33f78358753a44`
- Benchmarked staged new: `9f907f07117d8426c27cde0c58dea0386617f4a3b72b6aefffbb37475ceee5eb`
- Reproduced normal new: `147112785c0dee0ca00a0bbae0cbe56bb2f26b641883919785f9c169567d8bc2`

## Reproduction and evidence

Use the root README setup/build/verify entrypoints. If this host's compiler
memory behavior recurs, the temporary environment hint above can be supplied
explicitly; inspect the exit status and retain failed attempts. Do not replace a
failed full verification with a smoke test.

Build published main's unchanged production source once with each locked
compiler (keep Lean/Clang identical), restore the five frozen corpora using
`qa/perf-20261001/corpus-manifest.json`, then run:

```sh
sh qa/compiler-20261004/compare.sh OLD_BINARY NEW_BINARY CORPORA EMPTY_OUTPUT
```

The script rejects changed corpus hashes/counts and nonempty output directories,
records input fingerprints before/after, preserves failures, and reruns all
additional checks plus the full two-block measurement protocol. Full normal or
documented equivalent staged verification is a separate prerequisite.

Full chronological logs, original failed summaries, proof/C emissions, binary
identities and raw measurement/correctness data are retained in the separate
compiler-upgrade evidence archive. The repository contains processed results
and portable comparison scripts; absolute paths inside result metadata describe
this run and are not portable entrypoints.
