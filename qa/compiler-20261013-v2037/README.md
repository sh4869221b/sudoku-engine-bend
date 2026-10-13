# Bend 2.0.37 upgrade smoke checks

Run serially after the complete verification, from the project root:

```sh
python3 qa/compiler-20261013-v2037/check_real.py --out /new/path/upgrade-smoke.json
```

The output's parent directory must already exist. The JSON path must be fresh,
including no existing directory or dangling symlink. Set `BEND_TOOLCHAIN_DIR`
when the matching locked installation is outside the project's `.toolchains/`.

The harness runs ordinary and low-memory verdicts on valid, false, unsafe-kind,
and quantity-polymorphic dependent-pair fixtures. It also compares tiny native
output and binary hashes, and checks existing-output protection. Compiler calls
have 60-second timeouts; tiny native execution has a 10-second timeout. Failed
reports and the adjacent work directory are retained. Acceptance checks work
with optimized Python. This smoke test does not replace the full project gates.

Harness-only regressions, using mocks and Python without running any compiler:

```sh
python3 -m unittest discover -s qa/compiler-20261013-v2037 -p 'test_check_real.py' -v
```

The two files in `fixtures/` reproduce the upstream Bend tests identified in
their attribution comments at commit `ae1101ca7d15364f9274fa6b1367d175884a7da7`.
Their bodies are unchanged; only source-attribution comments were added. Their
upstream Apache 2.0 license is included in `UPSTREAM-LICENSE` and is also copied
with the retained run fixtures. Harness unit tests verify both original Git
blob hashes.

This is the version-locked 2.0.37 harness, requiring commit
`4ff8545f19b09b7d2b8ca2303668100eac8efd66`. The 2.0.36 harness and its historical
results remain in `qa/compiler-20261013/`. The inherited fixtures retain
their original 2.0.36 attribution and exact bodies.

## JavaScript host ABI and engine regression

```sh
python3 qa/compiler-20261013-v2037/check_js.py --self-test
python3 qa/compiler-20261013-v2037/check_js.py --out /new/path/js-host-and-engine.json
```

Build `bin/bend-sudoku` first. The real run emits a Nat library and the complete
Sudoku engine, then uses Node to check 13 distinct host-boundary outcomes,
13 exact native/Node CLI comparisons (including six seeded generated boards),
and the generated `bench --generate 10` path in both lanes. Each recorded
process is bounded; existing reports are refused and failure evidence retained.
The host boundary accepts whole Number values from 0 through 2^53 inclusive
and rejects BigInt, fractions, negative/nonfinite values, and values above that
bound. This does not claim that arbitrary Nat arithmetic is exact at every
host boundary value. Bend literals such as `5n` retain their syntax.

The generated benchmark exercises `IO.now` without File effects. Node File
effects remain outside this coverage because they require Bun. Twelve embedded
Python-only harness tests run without Node/Bend, including optimized Python.
