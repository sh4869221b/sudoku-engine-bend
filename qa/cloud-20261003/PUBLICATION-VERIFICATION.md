# Publication verification: staged PASS

Completed 2026-10-03 21:52:10 UTC. All normal verification gates completed successfully for publication tree `a8a8ca0531b6c74b635908f7f1b73fd076c7eb5c` (delivery commit `17035db074b1981478984bd76ac675b3440b5ff2`). No tracked project files changed during verification. The later publication projection removes archived raw observations/dumps and adds documentation only; all139 frozen production/test/fixture inputs remain byte-identical.

## Ordinary attempts and scheduling workaround

Two fresh ordinary `./verify.sh` attempts failed with exit 137 while compiling `qa_run.bend` to a native executable. They remain FAIL in their original summaries. The kernel did not expose the reason for termination; memory pressure is plausible but unproven. These failures do not supersede the separate successful 18:39 final optimization validation.

The second fresh isolated worktree was continued after its already successful build/proof/check gates. Under exclusive `flock /tmp/bend-cloud-cpu.lock`, the single failing native compilation was split into:

1. Pinned Bend 2.0.34 emits `qa_run.bend` as C and exits.
2. Pinned Clang 19.1.7 compiles that C with exactly `-std=c11 -O3 <file.c> -lpthread -lm -o <qa-run>`.
3. A SHA-256 equality check must pass before the QA executable runs.
4. The byte-for-byte suffix of the ordinary `qa/verify_gates.sh`, beginning with `./bin/qa-run --threads 1`, runs normally. `BEND_SKIP_BENCHMARK=0`.

The pinned compiler's installed implementation uses the same `compile_book` C emission for its `.c` and native targets and these same native flags for this Linux program. The emitted source has `BANGS=0` and no X11/ALSA imports. Only the lifetime overlap between Bend and Clang changed; no compiler, runtime, FFI, source, production flags, tests, or checks were changed.

Fresh C SHA-256: `87802d9b5f462ce7c2b8c4ba3e4b1623a97e135fbe77bb1617806a80660c6193`. This is identical to the C left by the ordinary native compiler invocation.

Fresh QA binary SHA-256: `993a4b80761ac97e3d4b9269f767384e64bcd2ad442f23259f20bf59ccd06169`. This is identical to the known-good 18:39 validation QA binary.

Production engine SHA-256: `9ed5b3446c426fd561586d35e4481c72f852a1cca66bd2d12e33f78358753a44`, matching final validation.

## Results and scope

- Native QA, optimization, generated count-table check, row bitmap, queued candidates, singleton predicate, bitmap arithmetic, peer equivalence, validation reason, output tails, order statistics, arithmetic, rating/cache/index/array, array techniques, candidate digits, and direct benchmark checks all passed.
- Direct adaptive trace: 20/20 completed traces, 239111 actual transitions, 239131 comparisons, no capped incomplete traces.
- Golden state/fuel comparison: 6060 observations. This comprises 3030 production terminal/fuel outcomes and 3030 legacy transition observations, not 6060 live adaptive stack observations.
- Integration and rate reference passed.
- Ordinary CLI gate: 216 cases passed. The larger 1931-case final corpus comparison remains separate evidence from the 18:39 final validation; this continuation does not claim to have rerun it.
- Production fuel exits, both mutation checks, all 7 native/Bend commands and 5 Node-compatible commands passed. The normal lane gate still notes that JS file IO needs Bun, which is not installed.
- Ordinary benchmark passed, all 15 records. This is the normal verification benchmark, not a new pooled optimization performance measurement.
- 139 production/test/build source fingerprints stayed unchanged. The publication worktree remains clean.

## Evidence

[Provenance/result JSON](publication-verification/staged-verification.json), [exact continuation script](publication-verification/staged-verification.sh), [execution wrapper](publication-verification/run-staged-verification.py), and the [gate summaries](publication-verification/summaries/) are included. The complete chronological console logs remain in the publication workspace; they are not part of the earlier18:39 archive.

The original second-run summary deliberately remains FAIL/137. This report records successful completion using the documented scheduling-only continuation.

The staged wrapper and shell script are exact historical session records with absolute workspace paths, not portable fresh-checkout entrypoints. Use README and PUBLICATION.md for reproduction. The staged source scan and final-validation input manifest each happen to contain139 entries, but they are different sets; only the latter is the mandatory frozen-input set preserved intact in this reduced publication. Archived trial-source files in the former may intentionally be omitted.
