# Reproduce the 2026-10-01 optimization checks

Use official Bend 2.0.34, Clang 19.1.7 and Lean 4.34.0 with the matching, unmodified independent BendTT kernel. Set `CC` to Clang 19 and `BENDTT` to that kernel; disable telemetry with `BEND_NO_TELEMETRY=1`. The report records compiler versions and the pinned baseline commit. No compiler, C runtime, FFI, unsafe code, or CPU-specific optimization flags were changed.

From this repository, preserve the original implementation in a separate worktree:

```sh
git worktree add /tmp/bend-before-648cd0c 648cd0cf65e7e3cc48c2f063dddc377f947481f2
(cd /tmp/bend-before-648cd0c && ./build.sh)
./verify.sh
python3 qa/perf-20261001/prepare_corpus.py /tmp/bend-corpus-20261001
python3 qa/perf-20261001/differential.py \
  --base /tmp/bend-before-648cd0c/bin/bend-sudoku \
  --candidate bin/bend-sudoku --repo . --corpora /tmp/bend-corpus-20261001 \
  --out /tmp/bend-differential.json
python3 qa/perf-20261001/measure.py \
  --base /tmp/bend-before-648cd0c/bin/bend-sudoku \
  --candidate bin/bend-sudoku --cases qa/perf-20261001/cases.json \
  --corpora /tmp/bend-corpus-20261001 --out /tmp/bend-performance.json --reps 21
```

Run measurement only after all builds and correctness checks finish. Keep other CPU-heavy work off the host. The harness runs one process at a time, uses two warmups per variant/case, and randomizes pair order with a fixed seed. It records fresh-process wall time, child-specific user/system CPU time, raw launch RSS, output hashes, and BENCH's separate internal timer. Every pair must preserve exit status/stdout/stderr; only BENCH's measured timing fields are normalized.

The gzip corpora are lossless fixed inputs from the published six-language benchmark, with exact selection and hashes in `corpus-manifest.json`. They are decompressed and verified before timing. `cases.json` covers all seven commands and threads 1/8/16. Rejected-screen details are summarized in the report; only the final selected-release case file is published.

`differential.py` additionally checks 347 distinct puzzles, seed boundaries, generated outputs, malformed arguments, physical-line handling, the 16 MiB limit, batch order and chunk-size boundaries. Successful solutions are checked independently for units and clues; rating uses the existing independent Python technique oracle. It does not read the original Sudoku source repository.

The full `verify.sh` includes a frozen-baseline golden hash for 6,060 exact search/fuel observations. To regenerate a comparison without changing that golden:

```sh
python3 qa/empty_search_state.py /tmp/bend-before-648cd0c
```

The laws remain finite/scoped executable laws and structural properties, not a proof of the entire Sudoku solver. Native and Bend-invocation lanes cover all seven commands; the existing Node lane covers five, while JS file effects still require Bun.

For reliable engine peak RSS, use the dedicated tiny C launcher to exclude inherited Python pre-exec high-water marks (the raw wall-harness RSS is not an engine-footprint metric):

```sh
python3 qa/perf-20261001/memory.py \
  --base /tmp/bend-before-648cd0c/bin/bend-sudoku \
  --candidate bin/bend-sudoku --corpora /tmp/bend-corpus-20261001 \
  --out /tmp/bend-memory.json
```
