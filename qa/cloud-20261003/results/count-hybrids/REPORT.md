# Operation-specific count recovery experiments

Base: accepted54 `6bf2bb8fc89904d9df5d00ddf3c08bd60b339cc6`. All three candidates are rejected. No main worktree, compiler/runtime, laws, corpus, thread policy, or flags were changed.

Each trial used the unchanged35cases,21randomized paired repetitions and2warmups versus cloud-accepted54, followed by the existing5000paired bootstrap. All CPU-heavy work held the exclusive `/tmp/bend-cloud-cpu.lock`. Every observed output matched. Each source variant passed6060exact search/fuel observations,1931CLI differential versus original, independent MRV/occupancy checks and active mask/choice invariants before timing. The6060check uses the committed frozen observation hash.

## Trial59: Compile-time selector template

Aggregate 0.962332x,95%paired CI[0.952143,0.974985]. Binary SHA256 `fecb11eb4c7cb4ca1fd7073726492e563a46b94e7473073928a2981ef5262044`.

- batch_hard-100_count_t1: 0.901516x,95%CI[0.877441,0.941848],38.877478ms -> 43.124571ms
- batch_hard-100_count_t8: 0.896105x,95%CI[0.800981,0.976136],10.801569ms -> 12.053915ms
- batch_hard-100_count_t16: 0.908476x,95%CI[0.816162,1.024895],10.633976ms -> 11.705290ms

Full per-case ratios and intervals are in `confirm54-cases.json`; medians/IQRs/CPU/RSS are in `confirm54.json`, and every raw sample is retained in `confirm54.json.raw.json.gz`. Per-case intervals are descriptive, without multiplicity adjustment.

## Trial59b: Single loop, inactive-only operation branch

Aggregate 0.986489x,95%paired CI[0.976347,1.004398]. Binary SHA256 `9441154ff4aa77602cb2692c28ac052204152fcbd5666e87182f4f0a805129ee`.

- batch_hard-100_count_t1: 0.933232x,95%CI[0.900430,1.013754],38.978557ms -> 41.767258ms
- batch_hard-100_count_t8: 0.989379x,95%CI[0.902449,1.097702],10.536131ms -> 10.649239ms
- batch_hard-100_count_t16: 0.942297x,95%CI[0.859505,1.082501],10.636360ms -> 11.287693ms

Full per-case ratios and intervals are in `confirm54-cases.json`; medians/IQRs/CPU/RSS are in `confirm54.json`, and every raw sample is retained in `confirm54.json.raw.json.gz`. Per-case intervals are descriptive, without multiplicity adjustment.

## Trial60: Isolated accepted52 count loop and legacy helpers

Aggregate 1.009094x,95%paired CI[0.996248,1.021998]. Binary SHA256 `23d70c1b14ca7cd0fecd1f5009fdd40f6fcf303045ad0ad3d53b36d9bfad3426`.

- batch_hard-100_count_t1: 0.984899x,95%CI[0.961234,1.019352],38.432896ms -> 39.022187ms
- batch_hard-100_count_t8: 0.992456x,95%CI[0.822759,1.148793],10.826889ms -> 10.909191ms
- batch_hard-100_count_t16: 0.987464x,95%CI[0.924446,1.132704],10.834680ms -> 10.972223ms

Full per-case ratios and intervals are in `confirm54-cases.json`; medians/IQRs/CPU/RSS are in `confirm54.json`, and every raw sample is retained in `confirm54.json.raw.json.gz`. Per-case intervals are descriptive, without multiplicity adjustment.

## Interpretation

The template variant clearly regresses overall and hardcount. The inactive-only branch has no verified gain and does not recover count. The isolated52 loop is aggregate-inconclusive and all three hard100count medians remain slightly slower than54. Its single-hard-count improvement does not outweigh the failure on the explicit count batch target or its generation100 regression. Therefore there is no winning hybrid to compare for adoption; direct52timing was not run.

Selection alone cannot recover the count regression. Restoring52 inactive cache/swap also failed to recover it in this binary. Trial60 retains54 parser metadata initialization. These measurements do not isolate parser cost from native code-layout effects, so they do not establish the remaining cause.

Trial60 leaves `sudoku/adaptivesearch.bend` byte-for-byte identical to54. Its count-loop bodies match52 exactly after reversing namespace replacements and shared F.State constructor qualifications; see `source-manifest.json`. The five counthelpers reuse C’s scalar selector, cardinality table, low-unit updates, start handling, and Q’s active logic. The only production dispatch is `limit == 2`, once in S.run/run_prepared. No corpus or thread-name branch exists.

## Reproduce

Apply the chosen directory’s `change.patch` to a fresh worktree at6bf2bb8; patches are alternatives, not cumulative. In that worktree copy the corresponding QA directory and run from its root:

    export BEND_TOOLCHAIN_DIR=/workspace/scratch/b81277eea609/sudoku-engine-bend-cloud/.toolchains
    flock -x /tmp/bend-cloud-cpu.lock bash qa/cloud60/build.sh
    flock -x /tmp/bend-cloud-cpu.lock bash qa/cloud60/qa.sh
    flock -x /tmp/bend-cloud-cpu.lock bash qa/cloud60/confirm54.sh

Replace60with59or59b for their preserved variants. The scripts use the pinned Bend2.0.34,Clang19.1.7,Lean4.34.1 installation and immutable original/54binaries. Raw timing baseline/candidate hashes are in each measurement’s metadata. The first59build type-annotation error is retained as `build01-type.log` and was corrected before any test/timing. No full Lean-kernel verification was run for rejected trials; build typechecks and the explicitly requested focused correctness oracles passed.
