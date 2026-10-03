#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
. ./toolchain-env.sh
export BEND_NO_TELEMETRY=1
./build.sh
"$BEND" PROOF.bend --verdict
"$BEND" qa/run.bend --check-only
"$BEND" qa_run.bend -o bin/qa-run
./bin/qa-run --threads 1
"$BEND" qa/optimization.bend -o bin/qa-optimization
./bin/qa-optimization --threads 1
python3 qa/generate_count_table.py --check
"$BEND" qa/row-bitmap.bend -o bin/qa-row-bitmap
./bin/qa-row-bitmap --threads 1
"$BEND" qa/queued-candidates.bend -o bin/qa-queued-candidates
./bin/qa-queued-candidates --threads 1
BEND="$BEND" python3 qa/adaptive_trace.py --lock-held
"$BEND" qa/singleton-predicate.bend -o bin/qa-singleton-predicate
./bin/qa-singleton-predicate --threads 1
"$BEND" qa/bitmap-arithmetic.bend -o bin/qa-bitmap-arithmetic
./bin/qa-bitmap-arithmetic --threads 1
"$BEND" qa/peer-equivalence.bend -o bin/qa-peer-equivalence
./bin/qa-peer-equivalence --threads 1
"$BEND" qa/validation-reason.bend -o bin/qa-validation-reason
./bin/qa-validation-reason --threads 1
"$BEND" qa/output-tail.bend -o bin/qa-output-tail
./bin/qa-output-tail --threads 1
"$BEND" qa/orderstat.bend -o bin/qa-orderstat
./bin/qa-orderstat --threads 1
"$BEND" qa/arithmetic.bend -o bin/qa-arithmetic
./bin/qa-arithmetic --threads 1
"$BEND" qa/rating-cache.bend -o bin/qa-rating-cache
./bin/qa-rating-cache --threads 1
"$BEND" qa/rating-index.bend -o bin/qa-rating-index
./bin/qa-rating-index --threads 1
"$BEND" qa/rating-array.bend -o bin/qa-rating-array
./bin/qa-rating-array --threads 1
"$BEND" qa/array-techniques.bend -o bin/qa-array-techniques
./bin/qa-array-techniques --threads 1
"$BEND" qa/candidate-digits.bend -o bin/qa-candidate-digits
./bin/qa-candidate-digits --threads 1
"$BEND" qa/bench-direct.bend -o bin/qa-bench-direct
./bin/qa-bench-direct --threads 1
BEND="$BEND" python3 qa/empty_search_state.py
python3 qa/integration.py > qa/integration-result.json
cat qa/integration-result.json
python3 qa/rate_reference.py > qa/rate-reference-result.json
cat qa/rate-reference-result.json
python3 qa/cli.py
"$BEND" qa/fuel_cli.bend -o bin/qa-fuel
python3 qa/fuel.py
BEND="$BEND" python3 qa/mutation.py
"$BEND" main.bend -o bin/bend-sudoku.js
BEND="$BEND" python3 qa/lanes.py
if [ "${BEND_SKIP_BENCHMARK:-0}" != 1 ]; then
  python3 qa/benchmark.py
else
  echo "NOT RUN: timing benchmark (explicit --skip-benchmark)"
fi
