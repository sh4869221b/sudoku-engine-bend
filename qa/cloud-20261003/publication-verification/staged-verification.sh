#!/bin/sh
set -eu
cd /workspace/scratch/b81277eea609/sudoku-bend-publish-main/.verification/20261003T213650Z-fkr3seby/work
export BEND_TOOLCHAIN_DIR=/workspace/scratch/b81277eea609/sudoku-engine-bend-cloud/.toolchains
export BEND_SKIP_BENCHMARK=0
. ./toolchain-env.sh
export BEND_NO_TELEMETRY=1
set -x
date -u +STAGED_EMISSION_START=%Y-%m-%dT%H:%M:%SZ
"$BEND" qa_run.bend -o /workspace/scratch/b81277eea609/bend-publication/qa-run.c
date -u +STAGED_EMISSION_END=%Y-%m-%dT%H:%M:%SZ
python3 - /workspace/scratch/b81277eea609/bend-publication/qa-run.c <<'CHECK_C'
import pathlib,re,sys
c=pathlib.Path(sys.argv[1]).read_text()
assert re.search(r'^#define BANGS\s+0$', c, re.M), 'Unexpected GPU path'
assert '#include <X11/' not in c and '#include <alsa/' not in c, 'Unexpected extra link library'
CHECK_C
"$CC" -std=c11 -O3 /workspace/scratch/b81277eea609/bend-publication/qa-run.c -lpthread -lm -o /workspace/scratch/b81277eea609/sudoku-bend-publish-main/.verification/20261003T213650Z-fkr3seby/work/bin/qa-run
date -u +STAGED_NATIVE_END=%Y-%m-%dT%H:%M:%SZ
printf '%s  %s\n' 993a4b80761ac97e3d4b9269f767384e64bcd2ad442f23259f20bf59ccd06169 /workspace/scratch/b81277eea609/sudoku-bend-publish-main/.verification/20261003T213650Z-fkr3seby/work/bin/qa-run | sha256sum -c -
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

date -u +ALL_REMAINING_GATES_END=%Y-%m-%dT%H:%M:%SZ
