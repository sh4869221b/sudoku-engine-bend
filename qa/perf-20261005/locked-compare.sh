#!/bin/bash
# Run from a fresh checkout with the unchanged locked toolchain installed.
set -euo pipefail
cd "$(dirname "$0")/../.."
repo=$PWD
base=06b49c06e07b447f2a077183515570695592a3b4
work=${BEND_PERF_WORK:-$(mktemp -d)}
mkdir -p "$work/results" "$work/corpora"
export BEND_TOOLCHAIN_DIR="$repo/.toolchains"
export BEND_NO_TELEMETRY=1 BUN_JSC_forceRAMSize=67108864
python3 qa/toolchain.py check > "$work/results/toolchain.json"
git rev-parse HEAD > "$work/results/candidate-commit.txt"
git rev-parse "$base" "$base^{tree}" > "$work/results/baseline-commit.txt"
git status --porcelain > "$work/results/worktree-status.txt"
test ! -s "$work/results/worktree-status.txt"
python3 qa/perf-20261001/prepare_corpus.py "$work/corpora"
for variant in baseline encode rating parser; do
  mkdir -p "$work/$variant"
  git archive "$base" | tar -x -C "$work/$variant"
  case "$variant" in
    encode) cp sudoku/queuedcandidates.bend "$work/$variant/sudoku/" ;;
    rating) cp sudoku/arrayrating.bend sudoku/ratingindex.bend "$work/$variant/sudoku/" ;;
    parser) cp sudoku/parser.bend "$work/$variant/sudoku/" ;;
  esac
  (cd "$work/$variant"; BEND_LOW_MEMORY=1 ./build.sh) > "$work/results/$variant-build.log" 2>&1
done
BEND_LOW_MEMORY=1 ./build.sh > "$work/results/candidate-build.log" 2>&1
./verify.sh --low-memory --skip-benchmark > "$work/results/verify.log" 2>&1
python3 qa/perf-20261001/differential.py --base "$work/baseline/bin/bend-sudoku" --candidate bin/bend-sudoku --repo . --corpora "$work/corpora" --out "$work/results/differential.json"
python3 - "$work/screen-cases.json" <<'PY'
import json,pathlib,sys
cases=json.loads(pathlib.Path('qa/perf-20261001/cases.json').read_text())
names={'generate100_clues36','batch_easy-10000_solve_t1','batch_mixed-1000_solve_t1','batch_hard-100_count_t1','batch_rate-300_rate_t1','bench_easy-10000_t1','batch_hard-100_count_t8'}
selected=[c for c in cases if c['name'] in names]
assert len(selected)==7
pathlib.Path(sys.argv[1]).write_text(json.dumps(selected,indent=2)+'\n')
PY
# All compiler/tests have exited before the serial paired measurements.
for variant in encode rating parser; do
  python3 qa/perf-20261001/measure.py --base "$work/baseline/bin/bend-sudoku" --candidate "$work/$variant/bin/bend-sudoku" --cases "$work/screen-cases.json" --corpora "$work/corpora" --reps 21 --out "$work/results/$variant-screen.json" > "$work/results/$variant-screen.log"
  python3 qa/perf-20261003/analyze.py "$work/results/$variant-screen.json" --out "$work/results/$variant-screen-summary.json"
done
python3 qa/perf-20261001/measure.py --base "$work/baseline/bin/bend-sudoku" --candidate bin/bend-sudoku --cases qa/perf-20261001/cases.json --corpora "$work/corpora" --reps 21 --out "$work/results/combined.json" > "$work/results/combined.log"
python3 qa/perf-20261003/analyze.py "$work/results/combined.json" --out "$work/results/combined-summary.json"
