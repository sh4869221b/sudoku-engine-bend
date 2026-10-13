# Bend 2.0.37 adapter and JavaScript migration review

Reviewed 2026-10-13. This is source review plus Python-only regression evidence;
it does not claim that the rebuilt compiler, kernel, or Sudoku gates passed.

## Reviewed identity

- Official release: <https://github.com/bendlang/bend/releases/tag/v2.0.37>
- Source commit: `4ff8545f19b09b7d2b8ca2303668100eac8efd66`.
- Release API confirmed `draft=false`, `prerelease=false`, and publication at
  `2026-10-13T10:13:41Z`.
- Official Linux x64 archive SHA-256:
  `84c32465a39bc9ac315eade23f470cb8db03153dc860f89564fcfec153c3e445`.
- Comparison against 2.0.36 commit
  `ae1101ca7d15364f9274fa6b1367d175884a7da7`: 61 commits ahead.

## Native build memory and adapter decision

Keep the sequential adapter. The 2.0.37 improvement clears compiler caches and
forces garbage collection before Clang. It does not end a compiler worker or
replace the compiler process. `compile_book` assigns `FL = file_new(book,
false)` before returning C; `file_new` retains the checked book. `cli_emit`
writes the C text, calls `Bun.gc(true)`, then `cli_build` synchronously waits for
Clang. The compiler and its retained book can therefore still overlap Clang.
Source review alone cannot establish that an ordinary full Sudoku build fits
this host's memory budget.

Sources:
- [comp.ts lines 2887–2891](https://github.com/bendlang/bend/blob/4ff8545f19b09b7d2b8ca2303668100eac8efd66/bend2/comp.ts#L2887-L2891)
- [main.ts lines 385–393](https://github.com/bendlang/bend/blob/4ff8545f19b09b7d2b8ca2303668100eac8efd66/bend2/main.ts#L385-L393)
- [PR 1385](https://github.com/bendlang/bend/pull/1385)

For the project's supported Linux CPU case, the upstream command remains
`clang -std=c11 -O3 <C file> -lpthread -lm -o <binary>`. The existing adapter's
flags match. Keep its BANGS=0 / no-X11 / no-ALSA restriction, fresh-output
exclusive creation, private temporary paths, process death handling, and
matching C basename. No native pipeline semantic change was necessary.

## Proof protocol and Lean compatibility

The existing strict protocol remains appropriate:

1. Snapshot the supported local import closure.
2. Run the real compiler's `--check-only`; require its exact successful two-line
   verdict and no stderr. This is essential because a BendTT export by itself
   is not the unsafe/foreign-dependency check.
3. Export a fresh `.bendtt` file from the same snapshot. Refuse any stdout or
   stderr, including out-of-scope diagnostics. Upstream can write an export
   while also warning that definitions were omitted.
4. Run the pinned, rebuilt kernel after the compiler has exited, with
   `LEAN_STACK_SIZE_KB=4194304`. Accept exit 0 and the single `ALL PROOFS CHECK`
   line, with no stderr. Never relay the frontend success line as the final
   kernel verdict.

Upstream `safe.ts` still checks an explicit, nonempty `BENDTT` before its cached
kernel build path. That build path still requires Lean **4.34.0**. Thus retaining
the project's explicit kernel built with its existing Lean **4.34.1** pin is a
supported selection mechanism, but source inspection is not proof of build or
kernel compatibility: rebuild the 2.0.37 `bendtt.lean` source with 4.34.1 and run
the real proof gates. Never reuse the 2.0.36 kernel binary merely because the
CLI strings are unchanged. Preserve 4.34.0 as the explicit fallback if needed.

The adapter is intentionally stricter about stdout/stderr separation than
upstream's combined-log kernel reader; no relaxation is needed.

Sources:
- [main.ts verdict checks](https://github.com/bendlang/bend/blob/4ff8545f19b09b7d2b8ca2303668100eac8efd66/bend2/main.ts#L804-L821)
- [safe.ts kernel selection and checks](https://github.com/bendlang/bend/blob/4ff8545f19b09b7d2b8ca2303668100eac8efd66/bend2/safe.ts#L1480-L1572)

## Changes implemented

Only the requested candidate37 adapter and tests were edited. The 2.0.36
candidate remains untouched.

- `candidate37/qa/low_memory.py` now accepts only the exact pair 2.0.37 /
  `4ff8545f19b09b7d2b8ca2303668100eac8efd66`, with source-review comments.
- `candidate37/qa/test_low_memory.py` accepts that pair and rejects retired,
  future, unknown, and mismatched pairs before selecting any installed tools.
- Added `candidate37/qa/compiler-20261013-v2037/` with the separate 2.0.37-locked
  real harness, README, unit tests, license, and inherited fixtures.
- Historical `qa/compiler-20261013/` files remain byte-identical to the 2.0.36
  candidate, excluding generated Python cache files. No historical run results
  were copied into the new harness directory.
- Inherited fixtures retain their actual 2.0.36 source attribution and exact
  Git-blob-body checks; their provenance was not relabeled 2.0.37.

## JavaScript migration risks for Sudoku

2.0.37 changes the JavaScript host ABI for Nat from BigInt to Number. This is
not a change to Bend's `5n` syntax: all Bend Nat literals in `main.bend` and
`sudoku/*.bend` should remain unchanged. The project has no custom JavaScript
foreign-effect source or JavaScript caller of exported `.mjs` definitions in
its production engine, so this review found no required production-source
rewrite.

Specific boundaries and gaps:

- A JS caller or custom effect must use `5`, not `5n`. Top-level Nat arguments
  to exports and direct Nat answers from effects are checked as whole Numbers
  in the inclusive range 0 to 2^53. BigInts, negatives, fractions, NaN, infinity,
  and larger values are rejected. This boundary is not the same as the
  arithmetic immediate cap, whose existing diagnostic names 2^48−1.
- Nat fields nested in constructors/arrays are no longer recursively marshaled
  or checked at the boundary. A future host integration must validate those
  fields itself and must not rely on previous constructor-tag validation or
  copying. Arrays still cross in place. The upstream effect guide explicitly
  documents the unchecked nested-Nat behavior.
- `sudoku/bench.bend` uses `IO.now()` at lines 151, 156, and 239. The official
  `now.js` now returns a Number. Regenerate the whole JS output using 2.0.37;
  do not mix an old generated runtime/effect file with new output.
- Current `qa/lanes.py` skips `batch` and `bench` in Node because the selected
  test cases use File effects. That misses this changed IO.now boundary.
  Exercise `node bin/bend-sudoku.js bench --generate 1`, which avoids File IO,
  and validate its success, generated-case counts, and finite nonnegative timing
  fields. Continue to report the existing Node File-IO gap accurately.
- Existing `generate --seed 42 --clues 81` checks only exit 0 because its
  expected output is None. Compare exact deterministic board output between
  native/Bend/Node and validate the generated board, rather than treating any
  successful stdout as sufficient.
- `F32.show` now takes a plain argument. The engine calls it directly in
  `bench.bend`; it does not pass `+F32.show` as a higher-order function, so no
  wrapper migration is indicated.
- `IO.die` codes above 255 now fail with status 1 instead of wrapping. Sudoku
  uses documented exit codes 1–4, so its expected exit contract is unchanged.

Sources:
- [PR 1506, implementation and boundary regressions](https://github.com/bendlang/bend/pull/1506)
- [2.0.37 effect guide](https://github.com/bendlang/bend/blob/4ff8545f19b09b7d2b8ca2303668100eac8efd66/guide/EFFECTS.md#L80-L92)
- [2.0.37 compiler Nat input check](https://github.com/bendlang/bend/blob/4ff8545f19b09b7d2b8ca2303668100eac8efd66/bend2/comp.ts#L467-L476)

## Verification run by this reviewer

Python-only tests passed:

- Adapter suite: **41 tests**.
- New 2.0.37 harness suite: **12 tests**.
- New harness suite under `PYTHONOPTIMIZE=1`: **12 tests**.
- `git diff --check`: passed.

Logs are `adapter-unit-tests.log`, `harness-unit-tests.log`, and
`harness-optimized-unit-tests.log` beside this note. Exact edited-file hashes
and historical-file equality counts are in `adapter-unit-summary.json`.

No Bend, Lean, Clang, Node application, or benchmark execution was performed
by this reviewer. The parent owns setup and real verification.

## Recommended real checks before acceptance

1. Rebuild the new kernel with the preserved Lean 4.34.1 pin, verify binary and
   kernel-source hashes against the new lock/installed manifest, then run the
   complete existing project gates.
2. Run `qa/compiler-20261013-v2037/check_real.py` serially after full gates. Its
   14 acceptance records cover valid/false/unsafe-kind/dependent-pair ordinary
   and sequential verdicts, ordinary/sequential native builds and execution,
   byte identity, and refusing an existing adapter output.
3. Add ordinary and sequential verdict checks for the new upstream
   `tests/check/let_put_depth.bend` regression (PR 1368), if practical; this
   specifically covers changed safe.ts recursive-let elaboration. Base-free
   `nat_literal_no_arithmetic.bend` and `nat_literal_custom_arithmetic.bend`
   (PR 1337) cover the other directly changed export behavior.
4. Run the no-file Node benchmark and stronger generation comparison above.
   For an explicit ABI smoke test, export a tiny Nat identity/add library and
   test Number inputs and outputs, curried calls, and rejection of 1n, -1,
   1.5, NaN, infinity, and 2^53+2. Use identity, not arithmetic, when testing
   the accepted 2^53 endpoint.
5. Keep old/new performance measurements serial, with preserved Clang/Lean
   settings. Do not count upstream's memory-release changelog claim as a
   measured project speed or peak-memory improvement.
