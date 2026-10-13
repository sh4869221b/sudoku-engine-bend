> Historical pre-execution source review. The completed real-toolchain verification and 14-case smoke results are recorded in REPORT.ja.md and results/verification-summary.json. The last paragraph records pre-execution recommendations. Only the coverage explicitly listed in those final results is claimed as executed.

# Bend 2.0.36 low-memory adapter review

Reviewed on 2026-10-13 UTC against the Sudoku repository baseline
`06b49c06e07b447f2a077183515570695592a3b4`.

## Decision

Retain the existing sequential native-build and proof-verdict pipelines. Update
the adapter's single reviewed source/version pair to Bend **2.0.36** at
`ae1101ca7d15364f9274fa6b1367d175884a7da7`. Rebuild the release's BendTT kernel;
do not reuse the kernel built from Bend 2.0.35.

The reviewed old upstream source is
`79df8d9c40722ee9507a1e253f283b51025f9d6c`.
[Upstream comparison](https://github.com/bendlang/bend/compare/79df8d9c40722ee9507a1e253f283b51025f9d6c...ae1101ca7d15364f9274fa6b1367d175884a7da7)

## Native compilation

The supported Linux CPU invocation remains:

```text
CC -std=c11 -O3 GENERATED_C -lpthread -lm -o OUTPUT
```

Upstream still detects GPU work from `BANGS`, adds X11/ALSA libraries when
requested by includes, and selects a sufficiently new Clang. The project's
adapter restricts itself to Linux CPU C with `BANGS 0` and no X11/ALSA includes,
using the independently checked, explicit Clang path. Its flags match the
supported upstream branch exactly. No flag or native dispatch change is needed.
The adapter's stronger fresh-output refusal and exclusive final publication
remain in place.

[New native build implementation, main.ts lines 426–447](https://github.com/bendlang/bend/blob/ae1101ca7d15364f9274fa6b1367d175884a7da7/bend2/main.ts#L426-L447)

## Promise screening and export

`--check-only` still invokes `cli_verdict(book, false)`. It checks promises before
printing the success line and the hint to use `--verdict` for mathematical
validity. The two-line success protocol is unchanged.

Promise screening is stronger in 2.0.36: `book_promises` now scans each datatype's
own type (`T`) as well as its constructor types. This catches unsafe dependencies
in datatype kinds and parameters, including constructor-free datatypes. The
dependency traversal was also made iterative. Because the adapter invokes the
real compiler for this precheck, it receives the stronger screening without
reimplementing it.

[Verdict and promise screening, main.ts lines 722–774](https://github.com/bendlang/bend/blob/ae1101ca7d15364f9274fa6b1367d175884a7da7/bend2/main.ts#L722-L774)

Export alone is still insufficient for a successful verdict. `safe_emit` writes
the expressible subset; `cli_emit` reports out-of-scope definitions on stderr
without necessarily changing the successful process status. The adapter must
continue to reject any export stdout/stderr and require a nonempty fresh
artifact. Its private import snapshot ensures the precheck and export read the
same project source bytes.

[Export dispatch, main.ts lines 362–373](https://github.com/bendlang/bend/blob/ae1101ca7d15364f9274fa6b1367d175884a7da7/bend2/main.ts#L362-L373)

## Kernel and Lean version semantics

The kernel still accepts one input file and prints `ALL PROOFS CHECK` only after
successful parsing and checking, returning zero. Upstream `safe_check` requires
no out-of-scope definitions and a successful kernel result with that exact text
after trimming. `LEAN_STACK_SIZE_KB=4194304` is unchanged. The adapter separately
captures stdout and stderr and rejects a nonempty stderr, which is stricter than
upstream's combined trimmed output check. No relaxation is needed.

- [Kernel invocation and verdict, safe.ts lines 1517–1545](https://github.com/bendlang/bend/blob/ae1101ca7d15364f9274fa6b1367d175884a7da7/bend2/safe.ts#L1517-L1545)
- [Kernel CLI, bendtt.lean lines 1393–1406](https://github.com/bendlang/bend/blob/ae1101ca7d15364f9274fa6b1367d175884a7da7/bend2/bendtt.lean#L1393-L1406)

The new exact Lean **4.34.0** version check applies to upstream's automatic
kernel build. `kernel_bin` first returns a nonempty explicit `BENDTT`, before
reading source, selecting cached binaries, or checking Lean. For automatic
builds, the cache key now includes Lean version and source, and a cache miss
checks `lean --version` before compilation. Temporary kernel input cleanup now
uses `finally`.

Consequently the project's explicit, separately built **Lean 4.34.1** kernel
remains supported by this interface. It must be built from the new release's
source and pass real verification. This source-level review is not a claim that
the build or complete Sudoku gates have passed.

Rebuilding matters: the emitted language changed from literal kinds such as
`*1` to quantity terms such as `*(.Q1)`, adds meets, and changes generic definition
elaboration. An old BendTT executable is not an interchangeable kernel. The
existing installer copies the pinned kernel source and rebuilds it; its
installation manifest and lock-digest checks prevent silent reuse of an old
installation after the lock changes.

- [Explicit BENDTT and automatic build, safe.ts lines 1462–1496](https://github.com/bendlang/bend/blob/ae1101ca7d15364f9274fa6b1367d175884a7da7/bend2/safe.ts#L1462-L1496)
- [Quantity-term export, safe.ts lines 1421–1453](https://github.com/bendlang/bend/blob/ae1101ca7d15364f9274fa6b1367d175884a7da7/bend2/safe.ts#L1421-L1453)
- [Project toolchain installer and validation](https://github.com/sh4869221b/sudoku-engine-bend/blob/06b49c06e07b447f2a077183515570695592a3b4/qa/toolchain.py)

## Release provenance

The official release metadata identifies a stable, non-draft Bend 2.0.36 release
at the reviewed source commit, published 2026-10-07T04:53:15Z. Its Linux x64
archive digest is:

```text
02089dc0eed0fd5fd6d73c74cc9cffcb2c6638dd3b02ae83f7b8cc57fbe381ba
```

This review checked the release metadata and source via the GitHub connector.
Downloaded-byte verification and toolchain installation belong to the separate
upgrade build, not the adapter unit-test result below.

[Official release](https://github.com/bendlang/bend/releases/tag/v2.0.36)

## Changes and focused validation

Source changes in this review are restricted to:

- `candidate/qa/low_memory.py`: update the exact reviewed source/version pair and
  error text; document the explicit BENDTT behavior and required kernel rebuild.
- `candidate/qa/test_low_memory.py`: explicitly accept the exact reviewed pair,
  and reject the retired pair, both old/new mismatches, a same-version unknown
  source, a future version paired with the reviewed source, and a wholly
  unreviewed future pair. Every rejection checks that toolchain selection,
  environment construction, and dispatch did not occur.

The existing output protection, parent-death signal, sequential process,
snapshot, diagnostics, canonical verdict, ambient-tool override, isolation,
unconditional gate and timeout regressions remain unchanged.

Executed in `candidate/` after its lock update:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s qa -p 'test_low_memory.py' -v
git diff --check -- qa/low_memory.py qa/test_low_memory.py
```

Result: **41 tests passed in 1.114 seconds**, and diff whitespace validation
passed. The log is `adapter-unittests-2036.log` in the delivery archive under evidence/. Compiler
subprocesses are mocked in this suite; its process-lifecycle test uses a harmless
sleeping Python process. No Bend/Lean compilation was run for this result.

The full upgrade still requires a fresh kernel build and real ordinary and
low-memory proof checks, including an unsafe datatype-kind negative fixture and
an out-of-scope export rejection. Upstream's
[unsafe_kind.bend](https://github.com/bendlang/bend/blob/ae1101ca7d15364f9274fa6b1367d175884a7da7/tests/check/unsafe_kind.bend)
is a precise negative regression for the strengthened screening.
