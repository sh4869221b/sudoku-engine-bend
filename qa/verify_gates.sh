#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
. ./toolchain-env.sh
export BEND_NO_TELEMETRY=1
./build.sh
"$BEND" PROOF.bend --verdict
"$BEND" qa/run.bend --check-only
"$BEND" qa_run.bend -o bin/qa-run
./bin/qa-run +RTS --threads 1 -RTS
"$BEND" qa/optimization.bend -o bin/qa-optimization
./bin/qa-optimization +RTS --threads 1 -RTS
python3 qa/generate_count_table.py --check
"$BEND" qa/row-bitmap.bend -o bin/qa-row-bitmap
./bin/qa-row-bitmap +RTS --threads 1 -RTS
"$BEND" qa/queued-candidates.bend -o bin/qa-queued-candidates
./bin/qa-queued-candidates +RTS --threads 1 -RTS
BEND="$BEND" python3 qa/adaptive_trace.py --lock-held
"$BEND" qa/singleton-predicate.bend -o bin/qa-singleton-predicate
./bin/qa-singleton-predicate +RTS --threads 1 -RTS
"$BEND" qa/bitmap-arithmetic.bend -o bin/qa-bitmap-arithmetic
./bin/qa-bitmap-arithmetic +RTS --threads 1 -RTS
"$BEND" qa/peer-equivalence.bend -o bin/qa-peer-equivalence
./bin/qa-peer-equivalence +RTS --threads 1 -RTS
"$BEND" qa/validation-reason.bend -o bin/qa-validation-reason
./bin/qa-validation-reason +RTS --threads 1 -RTS
"$BEND" qa/output-tail.bend -o bin/qa-output-tail
./bin/qa-output-tail +RTS --threads 1 -RTS
"$BEND" qa/orderstat.bend -o bin/qa-orderstat
./bin/qa-orderstat +RTS --threads 1 -RTS
"$BEND" qa/arithmetic.bend -o bin/qa-arithmetic
./bin/qa-arithmetic +RTS --threads 1 -RTS
"$BEND" qa/rating-cache.bend -o bin/qa-rating-cache
./bin/qa-rating-cache +RTS --threads 1 -RTS
"$BEND" qa/rating-index.bend -o bin/qa-rating-index
./bin/qa-rating-index +RTS --threads 1 -RTS
"$BEND" qa/rating-array.bend -o bin/qa-rating-array
./bin/qa-rating-array +RTS --threads 1 -RTS
"$BEND" qa/array-techniques.bend -o bin/qa-array-techniques
./bin/qa-array-techniques +RTS --threads 1 -RTS
"$BEND" qa/candidate-digits.bend -o bin/qa-candidate-digits
./bin/qa-candidate-digits +RTS --threads 1 -RTS
"$BEND" qa/bench-direct.bend -o bin/qa-bench-direct
./bin/qa-bench-direct +RTS --threads 1 -RTS
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
