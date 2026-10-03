#!/bin/bash
# Diagnostic-only accepted52 -pg binary; never used in speedup comparisons.
set -eu
out="$PWD/qa/cloud-20261003/diagnostics"
for i in $(seq 1 60); do GMON_OUT_PREFIX="$out/hard52/gmon" "$out/profile-only" --threads 1 -- batch ../bend-transfer/cloud-handoff-20261003/corpora/hard-100.txt count >/dev/null; done
cd "$out/hard52"
gprof -s ../profile-only ./gmon.*
gprof ../profile-only gmon.sum >gprof-hard.txt
head -28 gprof-hard.txt
