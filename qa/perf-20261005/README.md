# 2026-10-05 performance investigation

Baseline: `06b49c06e07b447f2a077183515570695592a3b4`, tree
`99de0480a911d3dc27591c61513d893ce02c054e`.

## Current decision

The first three production candidates are **rejected**. They pass correctness,
but the combined build is slower on the unchanged 35-case benchmark. Production
engine files and the original verification gates have been restored to baseline.
Further candidates are kept in isolated overlays pending measured acceptance.
No compiler pins, flags, workloads, search order, fuel, seeds, or CLI output change.

## Round 1: locked measurements

Bend 2.0.35 / Clang 19.1.7 / Lean 4.34.1; GitHub Ubuntu 24.04 runner,
AMD EPYC 9V45 with 2 CPU affinity. Eight/sixteen-thread cases oversubscribe that
host; results must not be generalized to an 8/16-core machine. Each case has
2 warmups and 21 randomized serial baseline/candidate pairs. The unchanged 35-case
workload and corpus hashes are used; individual screens use 7 preselected cases.
The ratio is sum(baseline case medians)/sum(candidate case medians), so larger
than 1 is faster. Confidence intervals use 5,000 paired bootstrap samples.

| Candidate | Cases | Ratio | 95% interval | Decision |
|---|---:|---:|---:|---|
|Skip false flag writes during fresh encoding|7|0.97945|0.96693–1.01796|Reject: no clear gain|
|Combine missing-support and hidden-single scans|7|0.99734|0.98487–1.01749|Reject: no clear gain|
|Carry row occupancy and column while parsing|7|0.98859|0.97675–0.99856|Reject: slower|
|All three together|35|0.98218|0.96634–0.99464|Reject: slower|

Combined median sums: baseline 539.638659 ms, candidate 549.431848 ms (+1.81% time).
The successful workflow conclusion describes successful execution, **not**
performance acceptance. Full verification passed in 853.82 s, including the
independent Lean-backed verdict, mutation/fuel checks, native/Bend/Node lanes,
216 CLI cases, and three additional focused equivalence tests. The additional
CLI differential passed 1,931 comparisons across 347 distinct puzzles. No correctness
or formal-proof scope is strengthened by these performance experiments.

Evidence: [locked-round1](locked-round1/), including every paired raw observation,
per-case medians/quartiles, source patch, build logs, checksums and toolchain
provenance. Immutable tested commit:
`bbb66c9ca9010dd582bb4eac40472c624a2e160e`.
[Workflow run](https://github.com/sh4869221b/sudoku-engine-bend/actions/runs/37300725140).

To reproduce round 1, check out that immutable commit, run `./setup.sh`, then
`bash qa/perf-20261005/locked-compare.sh` from a clean checkout. That script
compares the immutable baseline and each isolated candidate, runs the full
correctness gates and differential, and retains all raw observations.

## Diagnostic-only exploration

The editing host could not download the locked binary toolchain. Local exploration
used the byte-verified source of Bend 2.0.35 at
`79df8d9c40722ee9507a1e253f283b51025f9d6c`, Node 24.19.0 and GCC 13.3.0.
Compiler source was unchanged. Only a separate emitted-C copy removed Clang
`musttail` annotations before GCC compilation with
`-std=c11 -O3 -foptimize-sibling-calls -lpthread -lm`.
Some tests required larger stack limits because GCC lacks mandatory tail calls.
These results are not locked-release verification, Lean acceptance, or reliable
Clang performance predictions. All five diagnostic aggregate confidence intervals
include 1: fresh encoding, fused rating, row-local parsing, row+column parsing,
and scalar missing-support deficit. No diagnostic candidate was accepted.
Raw data, focused QA logs and provenance are in [diagnostic](diagnostic/).

## Round 2: predeclared acceptance

Candidates are screened before expensive full verification. Screening requires
aggregate ratio >= 1.03, lower 95% bound > 1, and at least one declared substantial
(>= 5 ms baseline) affected case >= 1.05. A candidate that passes then runs the
original 35-case comparison with 21 pairs; acceptance requires aggregate >= 1.03,
lower 95% bound > 1 and no substantial case more than 5% slower. Only a candidate
passing these checks proceeds through the complete correctness/proof/lane gates
and 1,931-case differential. Every rejection and all raw data are retained.

To reproduce round 2 from a clean checkout after `./setup.sh`:

```sh
export BEND_PERF_WORK="$(mktemp -u -d)"
python3 qa/perf-20261005/round2.py
```

The manifest names five isolated variants and their predeclared combination.
Each is built from the immutable baseline plus declared overlay files. Original
production files in this branch remain unchanged pending acceptance. A successful
workflow can mean every candidate was rejected; consult `decision.json`.
