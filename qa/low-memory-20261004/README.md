# Low-memory verification mode

Run `./verify.sh --low-memory` after normal locked toolchain setup. See the root
README for supported scope, the optional benchmark omission, and limitations.
This mode changes toolchain process lifetimes, not Sudoku runtime behavior.

## Acceptance invariants

- All production and proof Bend files, original gate commands, and existing
  mutation/interpreter timeouts remain unchanged.
- The adapter validates the installed toolchain on every invocation and only
  accepts the reviewed Bend 2.0.35 source pin. Ambient compiler variables cannot
  substitute another compiler, backend, or proof kernel.
- Native compilation emits fresh C, waits for Bend to exit, verifies the
  reviewed Linux CPU conditions, and calls pinned Clang with upstream flags.
  A fresh executable is published only after successful compilation. Existing
  outputs (including input aliases, hardlinks, symlinks and directories) are
  refused; failures cannot reuse an old executable.
- Proof checking snapshots the contained local import closure. Both precheck
  and export use that snapshot. Unsafe/foreign promises, scope diagnostics,
  missing fresh export, failed kernel exit, or an unexpected kernel verdict
  all fail. Only the final successful kernel result prints the proof verdict.
- Direct staged children receive Linux parent-death SIGKILL so a pre-existing
  mutation timeout killing the adapter does not leave its compiler running.
  This is not a guarantee that every descendant of an external tool is killed.
- Summaries and benchmarks record the execution mode and actual GC hint.
  Benchmark status distinguishes explicit omission and failure before completion.

## Source reference

The reviewed upstream control flow is in
[`bend2/main.ts`](https://github.com/bendlang/bend/blob/79df8d9c40722ee9507a1e253f283b51025f9d6c/bend2/main.ts)
and [`bend2/safe.ts`](https://github.com/bendlang/bend/blob/79df8d9c40722ee9507a1e253f283b51025f9d6c/bend2/safe.ts).
The adapter's native flags and proof precheck/export/kernel conditions preserve
those semantics for this project's documented callsites. It is not a general
Bend CLI replacement; unsupported argument layouts or source imports fail closed.

## Validation

Results from final-code validation are recorded in `results.json`. All earlier
ordinary integrated FAIL137 attempts remain failures; a low-memory PASS does not
retroactively change them. Finite tests plus the existing laws are not a proof
of the entire engine. The existing Node file-I/O exclusions remain unchanged
because a standalone Bun runtime is unavailable on the validation host.

Reproduce the additional real-toolchain safety smoke tests after the aggregate
run (do not overlap memory-heavy compiler processes):

```sh
python3 qa/low-memory-20261004/check_real.py --out /tmp/new-low-memory-smoke.json
```

Use a new output path. This separately checks a valid proof, unsafe and false
proof rejection, the PROOF/LAWS symlink guard, protected existing outputs,
paths containing spaces, and byte-identical tiny native outputs from the
ordinary and sequential compiler paths. It does not replace the aggregate run.
