> 公開版では追加raw観測・候補dumpを除外しています。完全な証拠と過去履歴は納品済みアーカイブに保持されています。 [公開範囲](../cloud-20261003/PUBLICATION.md)を参照。

# Reproduce the ten experiments on CachyOS

Baseline commit: 343bf98cd6d2b128882bc4dcd8300df0cd2b55c6.
Do this in a fresh local clone/branch, since experiments restore production files.
No tests or fixed inputs are removed. See PROTOCOL.md for predeclared criteria.

```sh
# Fixed compiler setup; local runtime packages required on CachyOS.
./setup.sh  # On CachyOS this initially fails until shared libraries below exist.
python3 qa/perf-20261003/runtime_setup.py
./setup.sh
./build.sh
cp bin/bend-sudoku ../baseline
python3 qa/perf-20261001/prepare_corpus.py ../corpora
./verify.sh --skip-benchmark
python3 qa/perf-20261003/experiments.py
# Individual idea; number refers to ledger.json, does not increase idea count:
python3 qa/perf-20261003/experiments.py 2
# All ten trials rejected: production sources restored by the harness.
./build.sh
./verify.sh
python3 qa/perf-20261001/differential.py \
 --base ../baseline --candidate bin/bend-sudoku --repo . \
 --corpora ../corpora --out qa/perf-20261003/final-differential.json
python3 qa/perf-20261001/measure.py \
 --base ../baseline --candidate bin/bend-sudoku \
 --cases qa/perf-20261001/cases.json --corpora ../corpora \
 --out qa/perf-20261003/final-measurement.json --reps 21
python3 qa/perf-20261003/analyze.py qa/perf-20261003/final-measurement.json \
 --out qa/perf-20261003/final-aggregate.json
```

Avoid other builds/tests during timing. Each trial stores the exact source patch,
locked native build log, native output comparisons for three fixed corpus files
and three generation seeds, 6,060 state/fuel golden checks, and nine paired timing
repetitions after two warmups. Raw measurements are gzip JSON. Ignored native
binaries remain locally in results/01..10/binary. Applying change.patch to the
baseline reproduces each candidate. No idea was adopted; confirmation of an
accepted candidate was therefore unnecessary. The final run uses the complete
suite and reports difficulty-separated cases and all slower medians as well.

Only BENCH timer fields are normalized for output comparison. Native and Bend
lanes cover seven commands; Node covers five (Bun unavailable for file IO).
