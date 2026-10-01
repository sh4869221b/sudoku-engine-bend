# Stable toolchain alignment — 2026-10-01

## Result

Bend remains **2.0.34**, the latest official stable release as checked on
2026-10-01. The native backend remains **Clang 19.1.7**. The independent proof
kernel now builds with latest stable **Lean 4.34.1** from unmodified release
source; **4.34.0** remains an explicit compatibility option.

The rebuilt Sudoku executable is **byte-for-byte identical** to the previous
optimized executable:

```
24bd34da85f9a663331696a685fb262f5e6dac6029e93fec46f587d436b0c2f6
```

Every production `.bend` source, proof and existing QA script is unchanged.
No solver, search, rating, RNG, fuel, output, exit-code or algorithm change was
made. The engine retains its standard-library-only implementation. A fresh
verification copy prevents old results or fixtures from being overwritten.

## Release provenance and reproduction

- [Bend 2.0.34](https://github.com/bendlang/bend/releases/tag/v2.0.34), released
  2026-09-29; release source commit `7d8a3eb036042c6549461054d25a10f26d361c5c`
- [Lean 4.34.1](https://github.com/leanprover/lean4/releases/tag/v4.34.1), released
  2026-09-24; compiler commit `5045d0056413266e57c625dcd7c365b10e377c52`
- [Lean 4.34.0 fallback](https://github.com/leanprover/lean4/releases/tag/v4.34.0)
- [Official Debian LLVM 19 packages](https://deb.debian.org/debian/pool/main/l/llvm-toolchain-19/),
  version `1:19.1.7-3+b1`, preserved compatible backend rather than a claim of
  latest Clang

The repository-root `toolchain.lock.json` contains exact artifact URLs and
SHA-256 checksums. `setup.sh` verifies archives before extraction and builds
BendTT with `lean -c bendtt.c bendtt.lean`, then
`leanc -O3 -DNDEBUG bendtt.c -o bendtt`, matching the upstream build commands.
The Bend executable and kernel source are additionally checked against pinned
hashes. Setup extracts the exact Clang/LLVM packages locally without modifying
the host installation. The restored local `libLLVM.so.19.1` also has the same
SHA-256 as the previously used host library.

```sh
./setup.sh
./build.sh
./verify.sh --skip-benchmark
# Full verification, including fresh CPU timing measurements:
./verify.sh
# Explicit previous proof-compiler fallback, if needed:
./setup.sh --lean-version 4.34.0
# Return to latest stable proof compiler:
./setup.sh
```

This setup is for Linux x86_64 and requires the host tools/libraries described
in the README and lockfile. `BEND_TOOLCHAIN_DIR` can select another installation
made from this same lockfile. Build and verification use its explicit compiler,
backend and kernel paths; ambient `BEND`, `CC` and `BENDTT` cannot override them.

## Verification

The full existing correctness/proof/lane gate sequence passed in the isolated
run recorded by `summary.json` and `verify.log`:

- Main source and QA type checks, project Lean-backed `--verdict`
- Native laws, board/peer/candidate/solver/count/generation/batch assertions
- Optimization, rating-cache/order, malformed-state and BENCH direct-board tests
- 6,060 exact search/fuel state observations matching the committed golden hash
- Independent Python solution/uniqueness/minimality and rating oracles
- All four rating techniques covered; 216 CLI cases passed
- Production fuel exhaustion exit 4 and valid-prefix generation tests
- Deliberately broken counter and false mirror-law mutation rejection
- All seven commands in native and Bend lanes; five Node-compatible commands
- Direct Lean 4.34.1 kernel acceptance of the emitted project proof
- False semantic proof and malformed proof rejected with exit 1
- Existing Lean 4.34.0-built kernel independently accepted the same project proof
- Ambient compiler override rejection, missing-installation failure, and a
  tampered compiler rejected by checksum before execution
- Python compilation and POSIX shell syntax checks for the new tooling

The restored BendTT source SHA-256 is
`61e0d2d9f4ddd7dd8bb1497fa612fb49a7274fcac647bf70702ba22321d7c292`.
Its Lean 4.34.1-built kernel SHA-256 is
`9f8f1ba8fd564b53438f9853a138979da7fcae867c9089043d2e5f82844c4501`.
See `toolchain-installed.json` for exact executable paths, hashes and version
outputs, and `source-preservation.json` for the complete production-source hash
set and native-byte equality check. Published paths are relative to the repository or use descriptive placeholders. Machine-specific locations and temporary identifiers have been removed; scripts resolve paths at runtime.

## Scope and limitations

- The native timing benchmark was explicitly omitted in this validation run;
  there are **no new performance claims**. The native binary is unchanged.
- Node cannot execute the existing Bend File effects for JavaScript batch and
  bench; those two lane cases remain explicitly not run without Bun, as before.
- The fallback kernel was checked directly using the prior verified 4.34.0
  restoration. The new setup's fallback download/build path was not rerun.
- Independent kernel acceptance concerns the project's existing formal laws and
  their scope. It is not a new proof of the entire Sudoku engine.
- This is not a fully hermetic OS image: the pinned native compiler still uses
  host C headers/linker and compatible system runtime libraries.
- Historical benchmark/correctness files remain separate. New results here are
  from this validation only; the four historical artifacts restored separately
  during repository recovery were not generated or overwritten by these tests.
