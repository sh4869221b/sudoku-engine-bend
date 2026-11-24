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

## Array isolation, queued blanks, and adaptive snapshots

- Candidate masks from both the direct and cached readers decode to zero when shifted
  down by ten bits, for every input word. The proof is structural over the
  excluded high bits, not a sampling test. Fixed digits 1–9 are covered by
  the separate single-cell laws above.
- A write and a read whose normalized paths reach separate leaves return the
  same observed value before and after the write. A certificate is constructed
  by recursively following both routes through the actual array tree; it also
  records the exact updated tree and both (nonmutating) reads. The public
  board wrappers use the same measured capacity to normalize both addresses,
  and a separate theorem proves that a write preserves capacity.
  Different raw indices alone are not sufficient: on the 128-slot board,
  reading 128 after writing 0 reads the new value. The source law checks this
  alias directly.
- The queued flag-slot formula maps all 81 cells to padding slots 109–111.
  The flag writer itself preserves a separate logical cell under the same
  route and size hypotheses. The production low-bit lookup identifies each
  of the 32 one-hot positions, including bit 31 and wrapped multiplication.
- Cloning returns two exact source trees, and taking the guess branch passes
  the unchanged activated tree into the saved snapshot. Restoring a saved
  snapshot with no alternatives returns that very board, removes the snapshot
  from the stack, and enters backtracking. These laws do not assert that every
  live stack corresponds to a valid search history.

The public write noninterference proof is conditional on actual route
separation and common measured capacity. It does not yet prove that every
logical/padding index pair in every reachable board satisfies those premises,
or compose the 81 iterations of production encode and decode. Full
round-trip preservation, candidate/cache legality, and solver soundness still
need those stronger invariants. Production and existing regression gates
are unchanged.

## Regular 128-slot board verification

Measured capacity by itself does not certify that the array is balanced. A
source-level counterexample has a 64-leaf left subtree and only one right
leaf: its measured capacity is 128, but writing to metadata index 109 also
changes the value seen at logical cell 80. This is separate from out-of-range
wrapping on the regular board.

- The actual empty board starts with the perfect depth-seven shape. Base
  array swaps preserve the entire shape for arbitrary trees, data, indices,
  and routing choices; the public board setter preserves this shape too.
  The measured-size theorem relates the actual left-spine computation to the
  shape and establishes 128 for every perfect depth-seven array.
- Actual route separation depends only on tree shape, not on cell values.
  The kernel checks the complete 81-by-81 logical-cell comparison: distinct
  logical indices split to different leaves, while equal indices do not.
  It also checks all 81 logical positions against metadata locations
  108–111 in both directions.
- The actual queued decoder preserves the entire array shape for every
  starting offset, number of steps, and input array. This follows from the
  source's read and write functions by induction over the decoder loop.
  It does not assert that decoding preserves all logical cell values on an
  arbitrary input; it only preserves their locations.

The full encode/decode round trip still needs cell invariants over the
encoder and decoder together. The verification does not make a global
claim about reachable search caches or prove solver soundness.

## Queued encoder and cache-read shape

- The actual cache reader returns the exact input board alongside its mask.
  The proof follows all three production array reads and the merge and
  inversion helpers. It does not assert that an arbitrary input's cached
  masks are valid Sudoku candidates.
- The actual flag writer, blank-cell encoder and filled-cell encoder each
  preserve shape. The filled-cell proof splits the concrete U32 representation
  into zero and the 32 possible positions of the first set bit.
- The actual encoder loop preserves shape for any step count, offset and
  input. The public encoder also preserves shape through metadata initialization
  and its 81 iterations. Together with the decoder law this preserves the
  certified logical and metadata routes through both passes. It does not
  yet prove value-level encode/decode identity.

## Position-wise queued decoding

- On any perfect depth-seven board, a write preserves reads at every proven
  separate route. Both indices are normalized by the production 128-slot
  mask, so distinct raw integers alone are not a sufficient hypothesis.
- One production decoding step reads the current word, writes that word
  shifted right by ten to the same slot, and leaves any separately routed
  watched slot unchanged. Arbitrarily many such steps preserve an unwritten
  watched value when their routes are certified separate.
- In a decoder sweep, the value at a chosen iteration is the original word
  at that position shifted right by ten, provided all earlier and later
  writes route elsewhere. The theorem composes the production loop over
  both the prefix and the suffix, not a separate decoder implementation.
  It does not yet prove that encoding produces the corresponding word at
  every cell, nor solver soundness or cache correctness.

## Pointwise encode/decode round trip

- A production flag update leaves a word alone if it routes to a different
  slot. The public encoder's resets of slots 109–111 have the same property.
  For a blank cell, writing a candidate mask and then setting its urgency
  flag leaves the mask in the intended cell. No assumption about the
  correctness of the cached candidates is needed to decode that word to zero.
- For any of the ten Sudoku digits, a single production encoding step
  produces a word whose high bits decode to the original digit. Encoding
  an arbitrary U32 word also leaves a watched cell unchanged when both the
  logical write and the possible flag write route elsewhere.
- The source encoder and decoder together restore a chosen digit in the
  actual 81-step public round trip, including the initial flag resets.
  This is a pointwise theorem conditional on a perfect 128-slot tree, a digit
  in 0–9 at the chosen cell, and route separation for the preceding and
  following writes. The next theorem discharges those routing premises
  for every logical position.

## All 81 logical cells

- The board-position theorem accepts any of nine rows and nine columns.
  Each combination reduces to its actual prefix and suffix in the
  81-step sweep. The kernel checks both the exact iteration count and the
  normalized routes for the three initial padding writes, the target
  cell's flag write, and all preceding and following logical and flag
  writes. A constructive proof turns those checks into the encoder and
  decoder premises rather than assuming they hold independently.
- On any perfect 128-slot board, for any logical cell whose input is a
  Sudoku digit (including zero for blank), the actual public encoder
  followed by the 81-step decoder preserves that digit. The proof covers
  logical cell values, not word-for-word equality of the entire backing
  array or preservation of metadata. It does not prove solver soundness.

## Adaptive search boundaries and fixed cells

- Entering queued mode and immediately finishing or recording the encoded
  board preserves the digit at any of the 81 logical positions. This is a
  property of the actual adaptive-search functions and assumes a perfect
  board and a valid digit at the observed position.
- Clearing a forced placement in queued mode, and the direct forced-unwind
  branch that calls it, preserve the decoded digit at any separately
  routed clue. Restoring a snapshot with no remaining alternatives reads
  the digit from that exact snapshot in its current representation.
- Removing a candidate bit from a peer whose word is a fixed Sudoku digit
  shifted by ten is a no-op on the entire board. The proof goes through the
  actual array read and actual bit from a placed digit, not a simulated
  peer function. The first-empty pointer scan changes only metadata slot
  108, so it also preserves separately routed logical cells.
- These facts do not yet show that the selector always chooses an empty
  cell on every reachable board, that a whole placement preserves all
  earlier clues, or that all reachable snapshots have the clue invariant.

## Whole queued placement preserves a separately routed fixed clue

- The production peer edit preserves the regular board shape. It leaves a
  fixed word unchanged when the peer is the observed clue itself, and
  preserves that word at a separate route when both its data and possible
  flag writes route elsewhere.
- These cases compose over the actual row and column loops and the four
  box-peer updates. A first-empty pointer refresh only affects metadata
  at slot 108. The theorem combines them with the production fixed-word
  write and (when applicable) the flag clear in `Q.place`.
- The result is conditional: the starting board must have the fixed digit
  at the watched cell, the placement must be routed separately, and the
  logical and metadata peer routes must have the stated certificates.
  This section does not prove those certificates for every reachable
  selection or show that the inactive cache path satisfies the same
  invariant. It is not a claim about candidate legality or solution count.

## Placement routes for all logical coordinates

- The actual U32 equality test yields a proof of numeric equality.
  A constructive selector retrieves any entry of the already checked
  81-by-81 separation matrix, including equal positions. A same-cell peer
  is discharged by the fixed-word no-op; a different-cell peer is
  discharged by its data and flag separation.
- The finite board geometry checks connect the production row base,
  column index and four remaining box-peer indices to valid logical
  coordinates, and furnish the corresponding route checks including
  metadata 108–111. The proof uses the actual division/remainder and
  indexing expressions.
- For any two distinct logical cells and any regular queued board with a
  fixed digit in the observed cell, the actual placement at the other
  cell preserves that digit and the regular shape. No extra routing
  premise is required. The same result applies to the active forced
  placement transition. This does not yet show that the production
  selector always avoids the given cells across all reachable states,
  or establish the inactive path, snapshot-stack invariant, or solver
  soundness.

## Ordinary (non-queued) placement and clearance

- A witnessed source read followed by a unit or row-cache update writes
  only its requested metadata slot. The actual first-empty scan can
  write only slot 108. Both the direct minimum update for clearing a cell
  and the conditional rescan for filling a cell preserve other logical
  words and the perfect board shape.
- The kernel connects the production row, column and box arithmetic to
  slots 81–107, proves this range and slot 108 are separate from all
  81 logical cells, and composes the actual `C.swap` target write with
  all metadata updates. For distinct logical coordinates it preserves
  the watched word for any replacement value. The inactive adaptive
  `swapped` and `cleared` paths inherit that result.
- This is an isolation theorem, independent of the initial metadata
  values. Both cache construction paths can represent the same logical
  board with different bit 0 in the raw occupancy word. A runtime probe
  of row 0 on the all-blank board returned 523265 after `C.cache` and
  523264 after `P.prepare81`. Candidate computation observes occupancy
  bits 1–9, not bit 0; the empty-column bitmap and pointer are separate.
- A second runtime probe observed candidate mask 1022 before placing 1
  at cell 0, but 1020 at cell 1 after placing and clearing cell 0 in
  queued mode. That forced clear is part of backtracking, not a
  transition to a selectable state. Future cache correctness laws must
  distinguish selectable states and retained snapshots from transient
  unwind state; the isolation theorem does not establish those laws.

## First guess, queued guesses, and selector preconditions

- At every one of the 81 logical cells, a known digit 1–9 in a regular
  ordinary board becomes exactly the digit shifted left ten bits after
  actual activation. This proves the raw word, including zero in its lower
  ten bits, not merely that a subsequent decode recovers the digit.
- A guess saves the exact word of the activated board, including at the
  chosen cell. The active guess preserves a different fixed cell in the
  working board, and the same guarantees hold for the first guess that
  activates queued mode. The snapshot guarantee does not require
  distinct coordinates; the working-board guarantee does.
- Both production selectors trust their metadata. The kernel checks two
  deliberately inconsistent boards: a queued urgency flag selects the
  actual fixed word 1024 at cell 0, and an ordinary stale empty-column
  bit selects cell 0 even though it contains digit 1. These boards are
  not claimed reachable. Establishing that neither case occurs on a
  reachable forward turn requires maintenance of the urgency flags and
  ordinary empty-column bits as a separate invariant.

## Nonempty alternatives and snapshot replay

- For any word width, the implementation’s two’s-complement low-bit
  operation isolates the first set bit. The proof is by induction on
  the actual addition/subtraction words, not an enumeration of masks.
  The isolated bit is present in the original word. XOR removes exactly
  that first bit and preserves the complete suffix.
- Every nonempty mask containing only Sudoku digit bits 1–9 yields a
  selected digit in 1–9 and its corresponding present bit. The source
  performs the real masking and count-table lookup; no assumption about
  a valid digit is made in the public candidate lemma. This is not a
  claim about arbitrary high bits, bit 0, or an empty mask.
- The actual nonempty restore operation replays the guess from the saved
  pre-choice board, not from the transient unwind board. For every
  normalized nonempty remaining mask it preserves a different fixed
  digit on the new working board and every fixed digit on the new saved
  board, including at the chosen position of the saved board. In the
  live case the real placement is permitted to replace the chosen cell.
- The preservation result assumes a fixed clue on the restored board.
  Reaching such a board by all production selectors still requires the
  ordinary cached vacancy and queued urgency metadata invariants.

## Read-only candidate selection and generator acceptance

- The production ordinary selector reads slot 108, the row bitmap, and
  unit occupancy without changing any board word. This extends to the
  actual row scanner for arbitrary fuel and arbitrary intermediate
  state, including both exhaustion and early singleton or contradiction
  exits. The `C.cached_select` result carries exactly the input tree,
  even when the metadata values are inconsistent. This says nothing
  about whether a selected cell is actually blank.
- The queued scan's single-cell inspection and its urgent-choice read
  also retain the board. Its normal scan ignores exact fixed-digit words
  1–9 shifted left ten bits. Selection through queued urgency flags
  still depends on a separately maintained flag invariant.
- The actual generator reports fuel exhaustion rather than accepting a
  removal if its count has no fuel. A completed count of one is the only
  result whose branch returns the candidate and decrements the clue
  total. The real removal attempt counts an exact clone of the board it
  proposes to accept, and a fuel result is terminal through the dig loop.
  This verifies the acceptance protocol, not the correspondence between
  the count and mathematical uniqueness.
- A pinned native probe of a valid one-blank puzzle returned (found,
  first cell) equal to (1,5) for solve's limit-one search, and (1,0)
  for count's limit-two exhaustion; the public counter correctly returned
  1. The count API discards the decoded scratch-board payload. A
  completed solution-event theorem must be kept separate from a theorem
  about every terminal count payload.

## Full queued and adaptive selectors preserve ownership

- The actual queued fallback scan returns exactly the input board for
  arbitrary fuel, starting cell, and best-choice fields. The proof
  covers early exits at sizes 0, 1, and 2 and the real inspection step.
- The actual urgent-flag traversal retains the input board through the
  flag read, through live urgent reads and through the first-blank
  pointer fallback. It is not necessary to assume valid flag words
  for this non-mutation guarantee.
- The adaptive selector is read-only in both execution modes. A future
  selected-square validity theorem must still require and maintain
  live metadata consistency, not assume it from board identity.

## Queued flags: actual selected slot and required metadata

- With any nonzero 32-bit urgency word, the actual least-set-bit and
  de Bruijn lookup select an offset in 0–31 whose bit is present in
  that word. This joins the symbolic bit proof with the concrete table
  at all 32 offsets rather than testing a few input words.
- If every set bit in this particular urgency word names an actual
  in-range cell with a queued vacancy word, the offset selected by
  the real urgent-index arithmetic names an in-range vacancy too.
  The urgent result reports the exact count for known zero and
  known singleton candidate masks. This is conditional on truthful
  metadata; it does not prove the condition is maintained yet.
- The checker verifies intentionally stale-metadata counterexamples
  against actual `Q.select`. With an unflagged two-candidate word at
  cell 0 and the remaining logical words fixed, start 0 chooses
  (position 0, mask 6, count 2). Setting the first-blank pointer to 81
  instead yields the completion sentinel 81 despite that vacancy.
  Restoring start 0 but setting a false urgency flag chooses cell 0
  with count 1 despite the same two true candidates. Pinned native
  execution independently reproduced these three outputs.
- These are not claims about reachable normal search states. The
  fallback only needs an in-range scan start no later than any actual
  blank, not exact minimum-position equality for sound completion.
  A normal forced-vs-guessed count proof must establish truthful
  urgency metadata as well as the candidate-set correspondence.

## Queued fallback positional soundness

- Each actual fallback inspection retains a previously sound choice or
  takes an in-range cell whose actual queued word is below 1024. The
  proof ties the predicate to the actual array read, not an assumed
  independent value.
- The actual fallback scan preserves this guarantee through early
  termination and fuel exhaustion for all scans whose inspected
  positions are in range. The production fallback started at any of
  the 81 logical coordinates therefore returns either position 81 or
  a real queued vacancy. The end-only start at 81 returns the sentinel.
- This is not the converse theorem that a sentinel implies a full
  board. It needs a lower bound on blanks and correct mask cardinality.
  In particular, out-of-contract mask 1023 counts as 10, so the strict
  comparison does not replace the initial sentinel despite the raw
  word being below 1024. A pinned native check reproduced that case.
  Valid Sudoku mask words exclude bit 0 and can contain at most nine
  candidates; that separate range guarantee must be linked to real
  live selectable states before proving the no-blank converse.

## Queued fallback completion and eligible words

- Any in-range continuation with a non-sentinel best position cannot
  return to the completion position 81. This covers all actual scan
  exits, including its early terminal sizes and fuel exhaustion.
- A scanned word below 1024 with actual scalar size below 10 is eligible
  for the initial best slot. If a bounded fallback interval contains
  any eligible word, the actual scan started with the empty best slot
  cannot return the completion position. This is checked on arbitrary
  prefix/suffix windows and for the production fallback from every
  logical start coordinate.
- Consequently a completion result excludes any eligible word in the
  actual interval examined. To conclude no Sudoku blank remains, one
  must still show that the start does not skip any true blank and that
  all true blanks carry an eligible mask, in every live reachable state.
  This theorem does not assume those state invariants.

## Candidate shape implies fallback eligibility

- Every candidate word containing only bits 1–9 is below 1024 and
  has actual scalar size below 10. The proof reflects all 512 legal
  bit words into the production size lookup and extracts a case
  for an arbitrary normalized word by following its real bits.
- A bounded fallback interval containing a normalized candidate word
  at any witnessed position therefore cannot finish with the completion
  marker. The proof uses the actual array read and actual scan, not a
  mathematical substitute for the candidate-size table.
- The remaining completeness assumptions are state properties: a
  reachable queued blank must have a normalized mask, and the pointer
  must start no later than any of the blanks. This declaration does
  not prove those invariants or that each stored bit is Sudoku-legal
  for the neighboring digits.

## Production queued mask writes

- Cache inversion clips to bits 1–9 for arbitrary cached occupancy
  words. The actual queued encoder step reads a blank and writes a
  normalized mask at that cell on a 128-slot board when its separate
  flag slot does not alias the cell.
- On the same board shape and separation condition, the actual queued
  peer update preserves normalization at a cell that already has a
  normalized mask, whether it writes a changed mask or is a no-op.
  An update clears bits and cannot introduce an out-of-range bit.
- These are local transition laws. They are not yet an inductive
  invariant for the complete encoder, placement chain, and undo paths.
  They do not establish pointer coverage or mask legality.

## Blank candidates after complete queued activation

- For any of the 81 logical cells of a 128-slot board, if the input cell
  is zero, the full production `Q.encode` leaves it with a normalized
  candidate mask. This covers the seed writes, the earlier and later
  encoder iterations, the actual targeted write, and all 81 physical
  routes, not solely the isolated encoder step.
- The actual adaptive activation from ordinary mode therefore creates
  an eligible queued candidate at every input blank. This proves
  representation eligibility, not cache legality, scan-pointer coverage
  or preservation after subsequent placements and backtracking.

## Pointwise candidate normalization after full queued placement

- On a 128-slot board, placing a digit at a logical cell preserves
  the candidate mask format at every other logical cell whose mask
  was already normalized. The proof follows the actual production
  placement with either guess flag, including urgency-flag changes,
  the new fixed-word write, row, column and four additional box
  peer updates, and the start-pointer refresh.
- This proves preservation of the candidate format, not that the
  remaining digits are exactly the Sudoku-legal choices. It also
  does not prove the pointer stays at or before every remaining
  blank, or that all backtracking entry states maintain this premise.

## Vacant status is unchanged by a queued peer update

- Clearing the placement bit for a Sudoku digit leaves the high
  encoded word unchanged, for every U32 input. The real vacancy
  test, `word < 1024`, also stays unchanged; the lower ten bits
  do not determine whether the comparison is less than that cutoff.
- For the actual peer array update at a watched cell, the same
  vacancy law holds on a 128-slot board with nonaliasing flag route,
  whether the code takes its write or no-op branch. This includes
  pre-existing malformed candidate low bits. Extending it through
  the full placement and proving a bound for the scan pointer
  are separate obligations.

## Exact first-open pointer refresh

- When the actual refresh runs, it writes the first vacant position
  within the examined interval, or writes 81 if it exhausts that
  interval. The certificate records every cell it skipped as closed
  and uses the implementation's raw vacancy comparison. The exact
  array result is the input with the pointer slot written.
- When the placement is not at the old pointer, the refresh itself
  returns the input unchanged. From any of the 81 logical starting
  positions, a running refresh writes a genuine vacant logical position
  or 81. These are properties of the refresh on its input board.
- Proving that the prior part of the board contains no blank in every
  reachable state still requires linking non-target vacancy preservation,
  sound initial metadata, and restored snapshots across solver steps.

## Queued placement preserves vacancy at every other cell

- For two distinct logical positions on a 128-slot board, the actual
  placement of a digit 1–9, in either forced or guess mode, preserves
  whether the watched cell is vacant. Both initial truth values are
  covered, without a normalization premise on that cell's low bits.
- The proof composes the target write, flag updates, row and column
  passes, the four-cell block pass, and the refresh. A peer visit to the
  watched cell may clear a candidate without changing vacancy. Other
  writes preserve its raw word when their array routes do not alias.
- This does not prove that the placed cell is fixed on return or that
  every reachable board starts with a valid first-vacant pointer.

## Placement target and encoder pointer

- The actual queued placement writes the fixed encoded digit at its
  target and retains that word through all subsequent peer visits
  and pointer refresh. For digits 1–9 the resulting word is closed.
  Both forced and guessed placements are covered.
- The full queued encoder retains the initial pointer word in slot
  108, including its three flag resets and all 81 encoding steps.
  It does not establish that the initial pointer was accurate.

## Placement can refresh only at the previous pointer

- Neither the target write nor any flag, row, column or block update
  can write slot 108 for a logical placement. The proof constructs
  distinct array routes for all logical placements.
- The actual full placement preserves the exact slot-108 word when
  the target differs from the previous pointer. When equal, the
  existing refresh law applies to the suffix of the pre-refresh board.
  Initial pointer accuracy and the global prefix invariant are separate.

## Exact one-cell urgency update algebra

- For all 512 normalized blank-candidate masks and all nine placement
  digits, array-independent reflection checks the real peer guard and
  reflag predicate. If the previous bit agrees with zero-or-singleton
  status, keeping it or setting it as specified by the production
  update yields exactly the new zero-or-singleton status. The no-op
  digit-zero bit case is checked as well.
- This is the local word relation used to prove the global urgency-flag
  invariant. The flag-word writes, placement/restore transitions, and
  absence of padding flags have not yet been composed into that invariant.

## Actual flag-word update

- Reading the written flag slot after `Q.flag` returns the exact
  masked set/clear word. After the actual peer update, the observed
  flag word is either that exact set word or the prior unchanged word
  according to the production guard and reflag condition, on a
  128-slot board with nonaliasing cell and flag routes.
- This connects the local guard to array behavior, not yet the full
  per-bit invariant for adjacent flags, all positions, or snapshots.

## Exact urgency of the observed cell after an actual peer update

- For every logical cell, the actual peer update preserves the
  equivalence between that cell's observed urgency bit and its
  production zero-or-singleton predicate, assuming that before the
  update the cell had a normalized blank mask and a correct flag.
  The proof reads both the candidate word and actual flag-slot bit
  after the operation, including the guard's no-op branch.
- The flag mask is nonzero for every U32 input, and the target cell
  and its flag slot are proven nonaliasing at all logical positions.
  This remains a local theorem: other-position flags, flag padding,
  and reachability of the premises are separate obligations.

## Disjoint flag bits and unused high padding

- Setting or clearing a mask leaves every disjoint watched bit
  unchanged, for arbitrary 32-bit words. The proof lifts the bit
  property by induction, not enumeration of flag-word values.
- The highest 15 bits of flag word 111 represent no Sudoku cell.
  The seed writes zero to that word. For every logical position,
  the actual single-cell flag edit and peer update retain those
  padding bits, including the guarded no-op. This covers arbitrary
  candidate-removal masks for the local peer operation.
- This is a seed and local preservation result, not a claim about
  all intermediate placements, encoder steps, or restored snapshots.

## Watched flag and frozen encoding occupancy

- Actual flag and peer updates retain another flag bit given either
  disjoint flag slots or disjoint bit masks in the same word, and an
  independent written cell route for the peer update. This is a
  conditional array-level theorem, not yet a global all-cell invariant.
- Each of the 27 actual row, column, and block occupancy words is
  unchanged by the full queued encoder, and by any prefix after
  initialization. The actual cached candidate reader depends on
  precisely three such words and yields the same mask for each logical
  position on every intermediate prefix as on the original board.
- Correctness of the original ordinary cache against direct Sudoku
  legality and the exact final encoded mask of each blank are separate
  obligations. In particular, this does not assume that queued
  placement maintains the ordinary occupancy cache.

## Encoded blanks use the original cached mask

- The actual queued encoder at every initially blank logical cell
  stores exactly the candidate mask read from the original board's
  ordinary occupancy cache. It neither changes that blank before the
  cell's turn nor rewrites its encoded word afterward.
- The verification splits the actual loop into prefix, the real
  cache-reading blank update, and suffix, and applies the occupancy
  projection equality to the prefix. This ties normalization to an
  exact source value, without claiming the original ordinary cache
  already matches direct Sudoku legality.

## Conditional bridge from occupancy cache to direct candidates

- The real direct candidate scanner returns its input board and the
  digit complement of the three unit folds. Trimming the three input
  masks to bits 1–9 before combining them produces the same answer;
  blank bit 0 and metadata bits do not matter.
- If the corresponding ordinary cache words agree with those three
  unit folds on bits 1–9, a logical blank's actual queued encoding
  equals the actual direct candidate mask. Establishing that premise
  after initial parsing and valid search updates is separate.
- In an additional local runtime probe (not a formal theorem), making
  an invalid duplicate-1 row and clearing one occurrence causes the
  ordinary cache to disagree with direct scanning. A valid-state
  uniqueness invariant is needed for a general clearing theorem.

## Local ordinary cache writes preserve digit occupancy under uniqueness

- In the actual row and ordinary unit cache-write helpers, the
  observed digit bits after a replacement equal the unaffected
  digits plus the new digit, if the previous cached union was
  correct and the removed nonzero digit occurred nowhere else in
  the unit. Blank and row-empty metadata are clipped away.
- The row helper's actual empty-column marker is proven disjoint
  from the digit bits for every logical coordinate. This is local
  write correctness; the premises still need to be established
  for whole-board ordinary placement, clearing, and parsing.

## Ordinary occupancy initialization leaves the original cells intact

- The ordinary cache initializer's actual row and non-row scans
  return their input array with the computed unit word, then write
  only the selected occupancy slot. For the real row scan, digit
  bits agree with the direct row unit fold for each of the nine
  rows; the extra blank-column marks do not affect that projection.
- The full 27-unit initialization and every prefix leave all 81
  logical cells unchanged on a 128-slot board. The public ordinary
  cache also leaves them unchanged during its pointer refresh.
- A per-target fold transfer is still needed to establish that the
  final 27 cached words describe the original board, and the fused
  prepared parser remains a separate entry path.

## Ordinary cache rebuild and queued activation from a raw board

- The real `C.cache` rebuild writes all 27 unit digit projections
  correctly for the original board. Proofs cover the actual order:
  earlier writes preserve each scanner read, the unit's own write
  establishes its digit projection, later writes do not overlap it,
  and the first-empty pointer refresh writes only slot 108.
- On a 128-slot board, `Q.encode(C.cache(board))` stores the direct
  `C.at(board,p)` candidate mask at every initially blank logical
  position. This covers the explicit rebuild path, not arbitrary
  caller-supplied cached boards, fused prepared parsing, or
  preservation across the full solver transition system.

## Ordinary first-empty pointer initialization

- The actual ordinary first-empty scan writes precisely one field,
  slot 108. Its witness visits the prefix in order and proves each
  skipped word is not literal zero. It identifies the first zero or
  records exhaustion with the sentinel 81.
- The actual cache rebuild preserves all 81 logical reads before
  that scan; hence its initial pointer is the first blank of the
  original, pre-cache board or 81 if all cells are filled. There is
  no incoming-state pointer premise. This is not a proof of
  preservation across placements, clears, or fused prepared parsing.

## Full ordinary row words on cache rebuild

- The final row occupancy word for each of the nine rows equals
  the full fold of that row in the original board, not just its
  digit projection. This covers the high per-column vacancy marks
  initialized by the ordinary rebuild. The proof preserves the
  entire accumulator across earlier cache writes, the row's own
  write, later cache writes, and the pointer refresh.
- This initialization theorem does not assume uniqueness and does not
  establish row metadata preservation across arbitrary later writes.

## Ordinary swaps and fused parser's empty starting state

- The real ordinary swap returns the original target word, rather
  than a row/column/box bookkeeping word. It writes the requested
  value at a logical target and preserves the 128-slot shape. This
  complements the preexisting theorem for other logical cells.
- At the actual pointer update, clearing stores the minimum of the
  previous recorded pointer and the cleared position. Filling away
  from the pointer leaves that update's input unchanged, whereas
  filling at the pointer starts a no-skip scan of the suffix. This
  specifies local decisions without proving all reachable inputs
  already carry the globally first blank.
- The actual fused parser's pre-scan seed is a 128-slot board:
  each logical cell and each column/box occupancy word is zero,
  while all nine row words have their nine vacancy bits set and no
  digit occupancy. This does not characterize the parser's result
  after processing characters or later ordinary swaps.

## Fused parser shape during individual legal stores

- A store of any of the ten allowed digit values preserves the
  128-slot shape. This uses the actual row occupancy write,
  column and box occupancy writes, and logical cell write; the
  zero path is checked separately.
- The result does not by itself prove that the character scanner
  always produces one of these values or that the complete parser
  preserves the value and occupancy invariants across characters.

## Exact logical writes of individual prepared digits

- For each allowed digit 0 through 9, an actual prepared store writes
  that digit at the addressed cell of a 128-slot board. At every
  other logical coordinate it preserves the existing digit, including
  on the nonzero path with all three metadata writes. The three
  physical metadata addresses are checked for all 81 positions.
- This local result does not establish the full character parser's
  validity decisions or occupancy invariants over its entire scan.
