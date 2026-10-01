#!/bin/sh
set -eu
cd "$(dirname "$0")"
: "${BEND:=bend}"
export BEND_NO_TELEMETRY=1
./build.sh
"$BEND" PROOF.bend --verdict
"$BEND" qa/run.bend --check-only
"$BEND" qa_run.bend -o bin/qa-run
./bin/qa-run --threads 1
"$BEND" qa/optimization.bend -o bin/qa-optimization
./bin/qa-optimization --threads 1
"$BEND" qa/rating-cache.bend -o bin/qa-rating-cache
./bin/qa-rating-cache --threads 1
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
python3 qa/benchmark.py
