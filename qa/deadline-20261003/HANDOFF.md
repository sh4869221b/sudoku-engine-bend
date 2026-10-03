> 公開版では追加raw観測・候補dumpを除外しています。完全な証拠と過去履歴は納品済みアーカイブに保持されています。 [公開範囲](../cloud-20261003/PUBLICATION.md)を参照。

# Cloud handoff — 2026-10-03

Experiments stopped at the user's explicit request to move to the cloud computer. No push or merge occurred. Keep the original PC copies.

Verified production head: `90df642` on `perf/structural-optimization`. Original baseline: `343bf98cd6d2b128882bc4dcd8300df0cd2b55c6`. A subsequent evidence-only handoff commit preserves this same production source.

Latest 35-case initial/current comparison: sum of wall-time medians 1082.351081 ms / 312.668306 ms = **3.461659x**, paired bootstrap 95% CI [3.444653, 3.476685]. Two warmups and 21 paired randomized serial repetitions per case. This is main-PC evidence, not a cloud result. Fivefold speedup has not been established. See `results/34-initial*`, `PROTOCOL.md`, `PROGRESS.md`, and all raw gzip observations. The planned final two independent blocks and full benchmark-enabled final verification have not yet run because the task moved environments.

Accepted structural trial numbers: 02,03,08,11,15,16,20,21,23,24,26,27,28,29,32,34. Structural experiments 01–35 were implemented and screened, with variants recorded separately; an earlier ten micro experiments are recorded under `qa/perf-20261003`. Trial 35/35b/35c bitplane and support variants failed performance gates and were reverted. Trial 36 cached cardinality: production build succeeded, but its new QA source failed affine checking (expected mask consumed twice). No correctness/performance result exists for 36; its incomplete patch is saved as `results/36-incomplete-change.patch` and is absent from production. Do not count it as verified or accepted.

The accepted 34 head passed full verification excluding the timing benchmark (`results/34-gates.log`), all 1931 differential comparisons across seven CLI commands, and exact fuel/choice observations through the verification gates. Custom output-tail and candidate invariant suites passed. Earlier accepted changes also passed their respective gates. JS file IO requires Bun, unavailable on the PC; native/Bend and five Node-compatible commands passed. No toolchain upgrades were made: Bend 2.0.34, Clang 19.1.7, Lean 4.34.1 are checksum locked.

Archive layout: `repository.bundle` includes all current refs and complete ancestry; `accepted-source/` is a plain snapshot for convenience; `corpora/` is the original fixed input collection; `SHA256SUMS` covers every file. No toolchain directories, compiled executables, authentication files, or local Git config are included.

Restore inside a private workspace:

```sh
sha256sum -c SHA256SUMS
git clone repository.bundle sudoku-engine-bend
cd sudoku-engine-bend
git switch perf/structural-optimization
python3 qa/toolchain.py setup
. ./toolchain-env.sh
./build.sh
cp bin/bend-sudoku ../cloud-final
./verify.sh
git worktree add --detach ../baseline-source 343bf98cd6d2b128882bc4dcd8300df0cd2b55c6
cd ../baseline-source
export BEND_TOOLCHAIN_DIR="$(realpath ../sudoku-engine-bend/.toolchains)"
. ./toolchain-env.sh
./build.sh
cp bin/bend-sudoku ../cloud-baseline
cd ../sudoku-engine-bend
python3 qa/perf-20261001/differential.py --base ../cloud-baseline --candidate ../cloud-final --repo . --corpora ../corpora --out qa/deadline-20261003/results/cloud-differential.json
python3 qa/perf-20261001/measure.py --base ../cloud-baseline --candidate ../cloud-final --cases qa/perf-20261001/cases.json --corpora ../corpora --out qa/deadline-20261003/results/cloud-block1.json --reps 21
python3 qa/perf-20261001/measure.py --base ../cloud-baseline --candidate ../cloud-final --cases qa/perf-20261001/cases.json --corpora ../corpora --out qa/deadline-20261003/results/cloud-block2.json --reps 21
python3 qa/deadline-20261003/combine_measurements.py qa/deadline-20261003/results/cloud-block1.json qa/deadline-20261003/results/cloud-block2.json --out qa/deadline-20261003/results/cloud-pooled.json
python3 qa/perf-20261003/analyze.py qa/deadline-20261003/results/cloud-pooled.json --out qa/deadline-20261003/results/cloud-pooled-aggregate.json
```

Resolve BEND_TOOLCHAIN_DIR to an absolute path if the shell/toolchain installer requires it. Compile both binaries with the same lock/configuration. Run no compiles or concurrent experiments during timing. Re-evaluate all 35 cases on the cloud host; do not compare cloud wall times directly to PC times. Preserve exact CLI outputs, choice/fuel behavior, seeds, validation and actual repeated searches. Report per-case/thread medians and quartiles, pooled all-case sum medians, and paired bootstrap confidence intervals. The user extended the deadline to 2026-10-03 19:00 UTC (Oct 4 04:00 JST), even if fivefold is reached.
