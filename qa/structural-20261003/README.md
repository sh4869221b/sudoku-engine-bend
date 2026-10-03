> 公開版では追加raw観測・候補dumpを除外しています。完全な証拠と過去履歴は納品済みアーカイブに保持されています。 [公開範囲](../cloud-20261003/PUBLICATION.md)を参照。

# Structural optimization experiments (local only)

Start:343bf98cd6d2b128882bc4dcd8300df0cd2b55c6, branch perf/structural-optimization.
Original fixed input/binary manifest: ../perf-20261001/corpus-manifest.json and
../perf-20261003/PROTOCOL.md. Follow PROTOCOL.md and CONTRACTS.md here.

The previous ten micro experiments remain in qa/perf-20261003, unchanged.
This phase follows explicit permission to redesign implementation and tests,
while preserving final resolved design contracts. No push or merge performed.

results/ledger.json records adoption and reasons. Every NN-change.patch preserves
a candidate, including rejected source. NN-differential.json contains the
1931-case frozen-output and independent correctness result; failed comparisons
are preserved as logs. Each measurement has raw samples in matching .raw.json.gz.
Screens are incremental versus the immediately preceding accepted binary.
Confirmations and final measurement compare to the original baseline. Time sums
are sums of per-case wall-time medians, not the time for one invocation.

Reproduce after restoring locked tools and runtime (same commands/flags):

```sh
. ./toolchain-env.sh
./build.sh
./verify.sh
python3 qa/perf-20261001/differential.py --base ../baseline --candidate bin/bend-sudoku --repo . --corpora ../corpora --out /tmp/differential.json
python3 qa/perf-20261001/measure.py --base ../baseline --candidate bin/bend-sudoku --cases qa/perf-20261001/cases.json --corpora ../corpora --reps 21 --out /tmp/measurement.json
python3 qa/perf-20261003/analyze.py /tmp/measurement.json
```

The saved baseline binary is local/ignored; rebuild source343bf98 using identical
pinned tools if it is missing. The fixed corpora can be regenerated with
qa/perf-20261001/prepare_corpus.py. Never use newly generated random samples to
replace the registered cases. REPORT.md will contain final conclusions.

Idea04 semantic-differential.py is a diagnostic only: it validates changed
individual answers but intentionally retains exact batch comparison and failed
there. Neither04 diagnostic log is a full correctness PASS. Idea04 was rejected
for violating the resolved first-NS/otherwise-MRV search selection contract.
