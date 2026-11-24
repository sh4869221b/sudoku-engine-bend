# Proof-first verification

`./verify.sh --skip-benchmark` checks the locked Bend/Lean verdict and the
remaining runtime gates. `./verify.sh --low-memory --skip-benchmark` runs the
same gates with the separate-process compiler adapter. Neither runs the timing
suite; use `./verify.sh` when collecting performance measurements.

The laws in [LAWS.bend](../LAWS.bend) refer to the engine's actual Bend
functions. The proofs in [PROOF.bend](../PROOF.bend) are checked by the
checksum-locked Bend 2.0.40 compiler and its Lean-built BendTT kernel. The
replacements below concern source semantics, not independent proofs of the
native code generator, JavaScript code generator, or host effects.

| Former runtime assertion | Replacement and exact scope |
| --- | --- |
| Mirror for 81 indices | `mirror_involute`: applying `board.mirror` twice returns the original input for **every U32**, by induction on the subtraction word width. This is involution, not a separate proof of generator symmetry. |
| Set/get on an empty board at 128 indices × four values; finite boundary law | `board_set_get`: reading the same index from `board.set_cell` returns the written value for **every array, index and value** of types `Array<U32>`, `U32` and `U32` under Base's index semantics (wrapping for regular arrays). The proof follows the actual swap/get paths and preserves the measured size. It does not assert noninterference at other indices. |
| Candidate-mask bound on two boards; empty-board cell-0 law | `candidate_at_bounds`, `cached_candidate_bounds` and `row_candidate_bounds`: the mask excludes bit 0 and is at most 1022, for arbitrary input to `candidates.at`, `cached_at` and `row_mask`. The proof does not show that every included digit is legal, every legal digit is included, or that cached metadata is valid. |
| The 16 count-combination/output cases | `count_add_spec` covers every pair of Count constructors using saturated exact counts plus a fuel flag. `count_show_spec` proves the result's display for every constructor. Associativity still applies to decided counts only; the full operation is not associative when fuel is present. |
| Direct solve/count/rate zero-fuel samples | `solve_zero_fuel`, `count_zero_fuel`, `rate_zero_fuel`, and `legacy_rate_zero_fuel` cover the pure result for **every board**, with no assumptions on cells, at zero fuel. Generator early exit and outward exit-status, stdout/stderr and partial-prefix behavior remain runtime-tested. |
| `qa/output-tail.bend` board, generated puzzle, and job-line samples | `board_show_tail` covers every board and suffix by induction on the renderer's remaining cell count. `solved_tail` covers every solve result, including no solution and exhausted fuel. `unsolved_tail_text` and `out_of_fuel_tail_text` also pin the literal `unsolved` and `error:fuel` prefixes for every suffix. `batch_solve_leaf_tail` covers every puzzle string and suffix via the actual prepared parser. `batch_job_line` covers all four supported modes, all U32 indices and all puzzle strings. These prove equivalence to the non-suffix formatting, not the solver result or host output. |

The proof build replaces the finite laws and the corresponding assertions.
The native gate now compiles and runs `qa/run.bend` directly, checking its
imports and every remaining `qa_run.bend` assertion in one invocation rather
than checking the wrapper and compiling the suite separately.
The checker negative control now mutates the universal mirror claim; the native
mutated-counter control still demonstrates detection of a search/count regression.

## Additional source guarantees

These check actual production definitions, not a separate Sudoku solver.
None changes the search implementation or removes a native, JavaScript,
integration, performance, or compiler-boundary test.

| Area | What the BendTT kernel checks | What the claim does not say |
| --- | --- | --- |
| Board reads and validation | Reads return the exact same array tree, including padding, under Base's array index semantics. The unit scan and the full validator return the original board for every input array. A failed completeness or unit check cannot be overturned by processing another cell. A nonempty diagnostic survives subsequent unit results. | Not a proof that the validator is equivalent to a fully independent mathematical Sudoku specification. |
| Board geometry | All 27 actual row, column and box lists equal independently enumerated row-major indices: 243 memberships in order. The peer predicate rejects a cell compared with itself for every U32. | Not equivalence between the peer bitmap and the peer predicate; the existing native differential remains. |
| Direct and prepared search boundaries | Both search-state evaluators preserve terminal solutions or fuel results at every fuel and limit. The prepared public solve/count entry points return fuel at zero. An attempted adaptive restore without a snapshot returns fuel. The solver result adapter distinguishes a zero-result state, a one-result state and a fuel state. | Not legality of search placements, cache correctness, soundness of a returned solution, or completeness of the search. |
| Parser boundaries | Both paths preserve length-before-character error priority at their finishing helpers and reject input still containing characters once the scan reaches its capacity. | Not full parser equivalence or a proof about all host input processing. |

The raw solver accepts a prevalidated board by convention. For example, a full
board filled with the same digit can bypass Sudoku checks if passed straight to
the raw function (as opposed to the validated CLI). A useful solver-soundness
theorem must assume or establish valid givens and coherent cache/first-empty
metadata, then preserve them through placement, representation switches and
restoration. This work does not promote that assumption to a proved claim.

## Why the other runtime gates remain

- The production solver is not universally proved sound or complete. Zero fuel
  never tests a successful search. Independent Python Sudoku checks, exact fuel
  and adaptive-transition traces, and generator uniqueness, symmetry and
  minimality checks remain. A successful-solver proof would need invariants
  connecting validated givens and candidate completeness to every mutable
  board/cache edit, snapshot restore, and completion transition.
- The representation and arithmetic differentials still protect against bugs
  not covered by the mask bound: cached/uncached equivalence, row bitmaps, peer
  geometry, candidate enumeration, singleton and count-table semantics, and
  full-width substitutions. Validation and rater/technique reference checks are
  also still required.
- The existing pure batch tree laws do not cover tree construction from lists,
  physical line scanning, or ordered host writes. The list/tree comparison
  and native/JavaScript/interpreter tests still cover these separately, along
  with parser diagnostics, exit codes, and the large-input regressions. The
  bench command's functional/native/backend checks are not timing measurements
  and remain part of `--skip-benchmark`.

## Candidate enumeration and the queued cell codec

The kernel compares the production lookup and digit enumeration with separate
bit-by-bit references. Each of the 32 adjacent blocks has 32 inputs, covering
all 1,024 ten-bit inputs with no gaps. The count includes bit 0; the digit list
includes only enabled digits 1–9, in ascending order and without duplicates.
Separate word-level laws show, for every U32, that explicitly normalizing the
input first does not change either function's result: count masks with 1023,
and enumeration masks with 1022. These are properties of the representation,
not a claim that the chosen mask matches legal moves on a Sudoku board.

For the queue representation, the actual fixed-cell encoder writes digit×1024
back to the addressed cell for each digit 1–9, for any array and index under
Base's existing array semantics. The decoder writes the packed word shifted
right by ten; reading that cell after the write returns that value. We also
check the word-level round trip at each of the nine fixed digits and that
zero decode steps leave the array unchanged. This is not an 81-cell round-trip
theorem: the blank branch writes flag metadata and a whole-board proof still
needs to show that writes to distinct logical or metadata slots don't
interfere. The runtime codec, candidate, and search regressions remain enabled.
