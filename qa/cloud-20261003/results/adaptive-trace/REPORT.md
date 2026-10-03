# Direct adaptive/legacy transition oracle

PASS: all 20 traces completed at a declared 200,000-transition cap. No trace was capped and no mismatch occurred.

## Coverage

- 239,111 actual search transitions; 239,131 state comparisons (initial state plus every transition endpoint).
- 119,844 forward transitions, including 119,700 while adaptive candidate encoding was active.
- 119,267 backtracking transitions.
- Ten fixtures, each at limits 1 and 2: easy, empty, complete, locally valid contradiction, both hard puzzles, and four deterministic hard-grid transformations.
- The transformations use seeds 42 and 20261003 for each hard grid; exact grids, digit maps, and Sudoku-preserving row/band/column/stack maps are in fixtures.json.
- Terminal states end immediately. No repeated completed states are counted.

## Independence and scope

qa/adaptive-trace.bend invokes the real F.selection/F.selected/F.backtrack transitions. Its live snapshot list is carried untouched; inspection clones the logical board and frames. Working adaptive board clones are decoded with F.finish(active, view). SnapshotDone answers are already decoded and are not decoded again.

The separately cached legacy board comes from the same cloned, locally validated raw grid. The reference uses C.scalar_start(Array.get(board,108)) with S.selected, and S.backtrack restores every placement independently. At each live endpoint the oracle compares phase, depth, found count, all 81 logical cells, and every active frame word after clearing only adaptive guess marker bit 21. Legacy old-value fields are also required to be zero. Terminal endpoints compare phase, found count, and all logical cells.

Actual snapshot restoration is therefore checked by logical board/frame equality after every backtracking step. Snapshot list contents are not separately inspected. This is finite differential coverage, not an exhaustive proof. The inherited 6,060 observations remain complementary and are excluded from these totals.

## Reproduction

From the repository root, source toolchain-env.sh with BEND_TOOLCHAIN_DIR pointing to the locked installation, then run:

    BEND="$BEND" python3 qa/adaptive_trace.py --output qa/cloud-20261003/results/adaptive-trace

The new wrapper takes the exclusive /tmp/bend-cloud-cpu.lock for check/build/run. If an aggregate runner already holds that lock, pass --lock-held to avoid a nested lock. Default evidence goes to .omo/evidence/adaptive-trace so isolated verification writes into its fresh work copy.

Proposed verify_gates.sh addition immediately after queued-candidates:

    BEND="$BEND" python3 qa/adaptive_trace.py --lock-held

No production source, existing gate, inherited golden record/hash, or experiment ledger was changed by this task. source-hashes-before.json and source-hashes-after.json are identical; summary.json embeds the same hashes.

## Trace counts

| Fixture | Limit | Transitions | Forward | Backtracking | Active forward | Found |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| easy | 1 | 52 | 52 | 0 | 0 | 1 |
| easy | 2 | 104 | 52 | 52 | 0 | 1 |
| empty | 1 | 82 | 82 | 0 | 81 | 1 |
| empty | 2 | 102 | 92 | 10 | 91 | 2 |
| complete | 1 | 1 | 1 | 0 | 0 | 1 |
| complete | 2 | 2 | 1 | 1 | 0 | 1 |
| contradiction | 1 | 24 | 12 | 12 | 0 | 0 |
| contradiction | 2 | 24 | 12 | 12 | 0 | 0 |
| hard | 1 | 27561 | 13811 | 13750 | 13810 | 1 |
| hard | 2 | 49762 | 24881 | 24881 | 24880 | 1 |
| hard-ai-escargot | 1 | 381 | 220 | 161 | 219 | 1 |
| hard-ai-escargot | 2 | 4850 | 2425 | 2425 | 2424 | 1 |
| hard-seed-42 | 1 | 3549 | 1805 | 1744 | 1804 | 1 |
| hard-seed-42 | 2 | 31544 | 15772 | 15772 | 15771 | 1 |
| hard-seed-20261003 | 1 | 30397 | 15229 | 15168 | 15228 | 1 |
| hard-seed-20261003 | 2 | 55234 | 27617 | 27617 | 27616 | 1 |
| hard-ai-escargot-seed-42 | 1 | 2131 | 1095 | 1036 | 1094 | 1 |
| hard-ai-escargot-seed-42 | 2 | 8550 | 4275 | 4275 | 4274 | 1 |
| hard-ai-escargot-seed-20261003 | 1 | 10217 | 5138 | 5079 | 5137 | 1 |
| hard-ai-escargot-seed-20261003 | 2 | 14544 | 7272 | 7272 | 7271 | 1 |

## Build fingerprint

- sudoku/adaptivesearch.bend: ce17c12e083a893d45660af9072c5639fe63c5a7ba3079dc453c306affc1bade
- sudoku/search.bend: d8130ef52e2da58cdde9c63fbc775ae52f1503acf1744991b3f8ffef1c42f394
- sudoku/candidates.bend: 7a260b5d40eb4b7917043949f23545bc20225ee12e5ee14a5ad55f041b74b6de
- sudoku/queuedcandidates.bend: 78268e7645fa9d9483797c99437874dbba4b743fd2924bf52eda488cee9e0b7f

Output SHA-256: bcdd8b60575ac52f823de274c30903a31c98a4a8b2489ca69a0f82189f6f4ba9

check.log, build.log, run.log, and verified-run.log record the final checked rebuild. first-run.log and million-run.log are earlier exploratory executions, not the authoritative version-fingerprinted acceptance run.
