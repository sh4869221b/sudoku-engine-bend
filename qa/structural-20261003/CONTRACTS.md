> 公開版では追加raw観測・候補dumpを除外しています。完全な証拠と過去履歴は納品済みアーカイブに保持されています。 [公開範囲](../cloud-20261003/PUBLICATION.md)を参照。

# Structural phase: specification and verification matrix

Authority: unchanged .omo/plans/source-spec.md Scope and resolved external
contracts in .omo/evidence/contracts.md. User 2026-10-03 09:19 UTC authorizes
large implementation/test rewrites provided final specification is preserved.
The previous perf-20261003 phase remains immutable evidence.

| Required final contract | Independent or boundary verification |
|---|---|
| Seven commands; stdout/stderr/exit 0/1/2/3/4 | existing CLI fixtures, malformed options and read errors |
| Exactly81 ASCII digits/dots; no whitespace; initial duplicate precedence | independent parsing and row/col/box validation; malformed Unicode/length |
| solve preserves clues and27 units; NS+MRV, lowest position ties, ascending digits | independent set-based grid checks; deterministic repeats; known multi/zero/unique cases |
| count capped2; sequential; Many dominates Fuel | independent Python capped counter; four-valued table; zero-fuel boundaries |
| fuel-first Nat budgets200000/20000, fuel failure never disguised as solution | direct budget tests; forced-zero CLI handler; documented placement/backtrack consumption |
| xorshift/canonical legal completed-board transformations; seed0 normalization | seeded complete-board properties; deterministic generation and seed wrap |
| generated unique; exact clues never undershoot; symmetric/pair minimal; prefix fuel | independent Python counting and every retained-removal-unit minimality check |
| rate NS/HS/LC/NP, weights1/2/5/10, thresholds25/60, actual action counts, guess/contradiction/fuel | independent Python technique oracle, synthetic technique/boundary states; exact compatible outputs |
| physical one-based line indices; skip empty/#; LF/CRLF;16MiB limit | byte/line boundary fixtures including invalid and fuel per-line output |
| balanced fork-join batch; four modes; output index order | sequential tree comparison and1/8/16-thread differential |
| bench actualN; separate preparation/internal timing; validate every solution/clue | direct independent grid/clue checks, invalid/unsolved/fuel failures, internal vs wall recorded |
| Bend only, pure engine core, standard library, no unsafe/FFI/custom runtime | source checks; pinned compiler and identical build settings; native/Bend/Node lanes |
| Existing finite laws + independent BendTT verdict | retain applicable laws; rework implementation-specific tests without weakening final properties |

Historical constraints about retaining exact DFS stack words, snapshots and
6060 search-state observations are implementation tests, not final public
specification. Replace them with semantic and budget tests. Historical guidance
against persistent solver candidates is an implementation choice superseded by
explicit large data-structure redesign authorization; public Array<U32>128
boards and digits0..9 remain. Internal packed scratch storage is separate from
public returned boards. The source plan is not edited.

Search budgets count actual forward selections/placements and backtracking
transitions of the current implementation, not simulated historical transitions.
Every placement (including forced) remains bounded; snapshot rollback is one
backtracking operation. No timeout, larger budget or correctness check removal
may be counted as a speedup. Rating action/fuel meanings are unchanged.
