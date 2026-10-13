# Bend 2.0.36 upgrade smoke checks

Run serially after the complete verification, from the project root:

```sh
python3 qa/compiler-20261013/check_real.py --out /new/path/upgrade-smoke.json
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
python3 -m unittest discover -s qa/compiler-20261013 -p 'test_check_real.py' -v
```

The two files in `fixtures/` reproduce the upstream Bend tests identified in
their attribution comments at commit `ae1101ca7d15364f9274fa6b1367d175884a7da7`.
Their bodies are unchanged; only source-attribution comments were added. Their
upstream Apache 2.0 license is included in `UPSTREAM-LICENSE` and is also copied
with the retained run fixtures. Harness unit tests verify both original Git
blob hashes.
