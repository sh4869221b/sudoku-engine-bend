#!/bin/sh
# Compare identical production source built by Bend 2.0.34 and 2.0.35.
# Run after full normal or documented equivalent staged verification passes.
set -eu
if [ "$#" -ne 4 ]; then
  echo "usage: $0 OLD_BINARY NEW_BINARY CORPORA_DIRECTORY EMPTY_OUTPUT_DIRECTORY" >&2
  exit 2
fi
old=$(realpath "$1"); new=$(realpath "$2"); corpora=$(realpath "$3")
mkdir -p "$4"; out=$(realpath "$4")
if [ -n "$(ls -A "$out")" ]; then echo "Output must be empty" >&2; exit 2; fi
cd "$(dirname "$0")/../.."
exec 9>/tmp/bend-cloud-cpu.lock
flock 9
python3 qa/compiler-20261004/provenance.py preflight --base "$old" --candidate "$new" --corpora "$corpora" --out "$out/input-provenance.json"
finish() {
  code=$?
  trap - 0 HUP INT TERM
  final_code=0
  python3 qa/compiler-20261004/provenance.py postflight --out "$out/input-provenance.json" --exit-code "$code" || final_code=$?
  if [ "$code" -eq 0 ]; then code=$final_code; fi
  exit "$code"
}
trap finish 0
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM
python3 qa/compiler-20261004/scheduling.py --base "$old" --candidate "$new" --corpora "$corpora" --out "$out/scheduling.json"
python3 qa/perf-20261001/differential.py --base "$old" --candidate "$new" --repo . --corpora "$corpora" --out "$out/differential.json"
python3 qa/deadline-20261003/file_differential.py --base "$old" --candidate "$new" --out "$out/file-differential.json"
python3 qa/cloud-20261003/randomized_correctness.py --base "$old" --candidate "$new" --cases qa/cloud-20261003/results/randomized-accepted54.json.cases.json --out "$out/randomized.json" --lock-held
python3 qa/cloud-20261003/memory.py --base "$old" --candidate "$new" --corpora "$corpora" --out "$out/memory.json"
for block in 1 2; do
  python3 qa/perf-20261001/measure.py --base "$old" --candidate "$new" --cases qa/perf-20261001/cases.json --corpora "$corpora" --out "$out/block$block.json" --reps 21
  python3 qa/perf-20261003/analyze.py "$out/block$block.json" --out "$out/block$block-aggregate.json"
done
python3 qa/deadline-20261003/combine_measurements.py "$out/block1.json" "$out/block2.json" --out "$out/pooled.json"
python3 qa/perf-20261003/analyze.py "$out/pooled.json" --out "$out/pooled-aggregate.json"
python3 qa/cloud-20261003/paired_case_ci.py "$out/pooled.json" --out "$out/hard-count-ci.json"
