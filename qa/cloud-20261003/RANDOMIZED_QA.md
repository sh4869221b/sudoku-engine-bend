> 公開版では追加raw観測・候補dumpを除外しています。完全な証拠と過去履歴は納品済みアーカイブに保持されています。 [公開範囲](PUBLICATION.md)を参照。

# Independent randomized Sudoku correctness suite

`randomized_correctness.py` is a Python-standard-library-only correctness harness.
It does not import any production solver or existing reference implementation,
and it never reads or changes the fixed 35-case performance definition or corpus.

## Fixed sample

Seed: `0x20261003d1ff` (`35347849531903`). The sample is declared before execution,
with no filtering by solver results, running time, solution-count uniqueness, or difficulty:

- 768 distinct completed grids made from a canonical valid grid using independent
  random digit, band, stack, within-band row, and within-stack column permutations
  and optional transpose. These transformations cover one Sudoku equivalence class,
  not every possible completed-grid class.
- 48 random clue-removal cases at each clue count
  `0, 1, 4, 8, 12, 16, 20, 24, 28, 32, 40, 48, 60, 72, 80, 81`.
  All 768 have a saved valid completion. Some resulting sparse/empty inputs repeat;
  the summary states the number of distinct serialized puzzles.
- 96 two-clue contradictions, 32 each isolating one duplicate row, column, or box.
- 32 transformed, constraint-valid but unsatisfiable puzzles. Their construction
  leaves a row missing its final digit while that digit is blocked by its column.
- 48 malformed mutations: six each of short length, long length, ASCII letter,
  full-width Unicode digit, interior space, tab, minus sign, and colon.

Total: 944 cases. Zeroes, periods, and mixed zero/period blanks occur.

## Checks and limits

For every case, `solve`, `count`, and `check` run against both the immutable
original binary and the candidate. Exit status, stdout bytes, and stderr bytes
must agree exactly. There is no output normalization. Each standalone process
has a 20-second timeout; timeouts fail the suite and remain in the raw results.

An independent Python row/column/box occupancy backtracker counts to two using
MRV selection and descending candidate enumeration. It scans all remaining cells,
including after discovering a singleton. Its default budget is 50,000 visited
nodes or 0.25 seconds per case. Time is checked at entry and every 128 nodes.
Budget exhaustion records `unknown`, its reason, and a solutions-found lower
bound. Unknown is never presented as an oracle pass and never removes a case
from baseline comparisons. Invalid inputs are separately classified, not counted.

All successful direct and batch solutions from both binaries are independently
checked for all 27 units and preservation of every clue. Independent syntax/unit
checks also verify `check`'s exit verdict. Counts are compared against the oracle
where known. Production fuel exits are explicitly reported; they are not treated
as solved or independently verified count results.

All 944 cases also run in a fixed shuffled batch at threads 1, 8, and 16 for
each of the three modes. Comments, empty physical lines, and mixed LF/CRLF endings
are included. Both binaries' batch output must match in full and must match the
ordered physical-index/payload sequence derived from their standalone results.
Each batch process has a 120-second timeout.

These are 2,832 standalone and 9 batch differential comparisons, comprising
5,682 binary invocations. It is finite randomized testing, not an exhaustive
proof or a performance measurement.

## Run and replay

From the main repository:

```sh
flock -x /tmp/bend-cloud-cpu.lock python3 -u \
  qa/cloud-20261003/randomized_correctness.py --lock-held \
  --base ../cloud-baseline --candidate ../cloud-accepted54 \
  --out qa/cloud-20261003/results/randomized-accepted54.json \
  > qa/cloud-20261003/results/randomized-accepted54.log 2>&1
```

For the final candidate, replace `--candidate` and `--out`, and pass
`--cases qa/cloud-20261003/results/randomized-accepted54.json.cases.json`.
That reuses and verifies the exact archived inputs. Without `--lock-held`, the
script obtains the same exclusive advisory lock itself.

The result JSON links and hashes four sidecars:

- `.cases.json`: all puzzles, case identifiers, hashes, valid completed witnesses,
  seed, generation method, category counts, and a canonical manifest digest.
- `.oracle.json`: every independent count outcome, node count, elapsed time,
  and explicitly unknown/invalid results.
- `.batch.txt`: exact batch input bytes and physical line layout.
- `.raw.json.gz`: every baseline/candidate stdout and stderr as lossless Base64,
  a readable UTF-8 rendering, byte count, digest, exit status, timeout flag, and
  process elapsed time. Elapsed time is diagnostic only.

The summary also records both binary hashes, the harness hash, checks performed,
fuel cases, unknown cases, and all failures. Binaries are rehashed after execution
to detect modification during the run. Existing result files are preserved by
using a new output prefix for each candidate.

## Accepted54 result

`results/randomized-accepted54.json`: **PASS**. All 2,841 exact differential
comparisons passed, as did all 18 independent batch-order/payload checks. The
suite independently validated 6,144 successful solution outputs, 1,598 known
count outputs, and 1,888 `check` verdicts. No process timed out and neither
production binary exhausted its fuel.

Of the 800 syntax/unit-valid cases, 799 counts were independently established:
513 had at least two solutions, 254 had exactly one, and 32 had none. The other
144 cases were independently classified as invalid. `valid-03-20` exhausted the
50,000-node oracle budget and remains **unknown to this oracle**. Both binaries'
outputs still agreed for that case in every standalone and batch comparison.

The 768 saved completed grids are distinct; the full 944-case suite contains
914 distinct serialized puzzle inputs. The canonical case-manifest digest is
`7c18a5d023119f91adef4c237e54c0bdbc5e8dce8a44d56243cca8d00c2bfcbc`.
