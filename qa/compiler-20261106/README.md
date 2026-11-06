# Reproduce Bend 2.0.37 → 2.0.40

Run Linux x86_64 with the prerequisites listed in the root README. Use two
checkouts on the same host: baseline commit `42ed83a` and this PR's commit.
Install each checkout's own lock with `./setup.sh`, then run `./build.sh` and
`./verify.sh --skip-benchmark`. Also run the candidate's
`./verify.sh --low-memory --skip-benchmark`.

From the candidate root, after both builds and correctness checks finish:

```sh
python3 -m unittest discover -s qa -p 'test_*.py' -v
python3 -m unittest discover -s qa/compiler-20261106 -p 'test_*.py' -v
python3 qa/compiler-20261106/check_js.py --self-test
mkdir -p .verification/upgrade
python3 qa/compiler-20261106/check_real.py --out .verification/upgrade/kernel.json
python3 qa/compiler-20261106/check_js.py --out .verification/upgrade/js.json
python3 qa/perf-20261001/prepare_corpus.py /tmp/sudoku-corpora
sh qa/compiler-20261106/compare.sh \
  /absolute/baseline/bin/bend-sudoku "$PWD/bin/bend-sudoku" \
  /tmp/sudoku-corpora /tmp/fresh-empty-comparison
```

The comparison entrypoint explicitly selects only the old binary for the legacy
runtime arguments. The new binary uses `+RTS --threads N -RTS`. Both run the
unchanged 35-case workload with two warmups and 21 randomized serial pairs in
each of two blocks; the same frozen corpora and actual binary hashes are
checked before and after. It also runs scheduling, CLI, file and independent
randomized differential gates. The exact known runtime-help sentence change is
the only additional CLI normalization; benchmark elapsed-time fields are
normalized as before. Exit codes and all other output bytes remain checked.
The helper adds no probing process to the measured interval.

`results/` contains this run's evidence, including compressed raw samples.
Do not combine the historical 2.0.37 results with new timings: those used a
different host and measurement window. Environment, variation, unsuccessful
attempts and unverified scope are listed in `REPORT.ja.md`.

The smoke and JS boundary harnesses derive from the 2.0.37 harnesses. They reuse
the original attributed fixtures and Apache license in
`qa/compiler-20261013-v2037/`. They target the exact 2.0.40 source pin, and retain
failed output rather than silently replacing it. No historical evidence is
rewritten.
