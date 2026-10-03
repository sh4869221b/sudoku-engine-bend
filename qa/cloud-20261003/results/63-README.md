# Trial63: fused BENCH verification, rejected

Based on accepted62 commit ef7580a932e1afaecb5979cedc3b984221639d5c. Only the prepared BENCH solved branch changes. Its actual solver call and search/fuel are untouched. It reads each original/solution logical cell once, checks digits1..9 and clue preservation, checks9 scalar row masks, and independently accumulates/checks9column+9box masks in reset original-board padding81..98. All logical original cells remain intact until read. No solver/parser occupancy is trusted.

The old clues/direct_checked, string/reparse BENCH verifier, and public V.validate/Board.full remain unchanged as independent oracles. The generated QA adds an independent value-equality/list-membership27-unit oracle using separate geometry arithmetic.

## Decision

REJECT. The seven-case screen was positive (1.013640x,95%CI[1.001783,1.041533]); the predeclared full35case21paired confirmation was inconclusive (1.007285x,95%CI[0.993679,1.021624]). Keep accepted62. One measured structural variant only; no confirmation rerun.

Easy10000 BENCH t1 improved1.053494x,95%CI[1.011453,1.127197]. BENCH t8/t16 and mixed-lane improvements were not established. Hard100-count t1/t8/t16 ratios were1.027145/0.957882/1.039806; all CIs include1. The t8 point estimate regresses about4.4%, so preservation of count performance is not claimed for this candidate.

## Correctness

- PASS16,609 focused board pairs against independent27-unit equality oracle, old BENCH clue/direct path, and public validate/full.
- PASS1931 original CLI differential comparisons, including independent solved-grid/rating checks.
- PASS existing direct BENCH/string-reparse QA with100generated boards and edge cases.
- Build/check and git diff --check pass.
- Full release gates were not run for this rejected candidate.

The focused test exhausts81positions with24invalid values under2original variants (3888cases),729legal-digit replacements,972clue checks,63isolated row/column/box violations including Latin grids with invalid boxes,653poisonedpadding cases,2048shuffled valid/partial solution pairs,8192bounded/full-width arbitrary pairs and64generated puzzles solved using the public solver.

## Evidence

All63-* files in this directory belong to this trial. See63-decision.json for hashes, aggregate intervals and individual BENCH/count tradeoffs;63-production.patch and63-fused-qa.patch for source; *.json.raw.json.gz for every timing/CLI observation. Native QA source is ../../fused-bench-validation.bend. Binary is /workspace/scratch/b81277eea609/cloud-trial63.

All CPU-heavy commands were serialized under exclusive flock /tmp/bend-cloud-cpu.lock using the unchanged locked toolchain. Original cases/corpora, runtime/compiler/flags/FFI/unsafe/main.bend were unchanged. Main worktree was not modified; nothing was pushed or merged.
