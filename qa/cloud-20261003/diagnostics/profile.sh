#!/bin/bash
# Diagnostic-only instrumented build. Never used in speedup measurements.
set -eu
. ./toolchain-env.sh
out="$PWD/qa/cloud-20261003/diagnostics"
"$BEND" main.bend -o "$out/accepted52.c" >"$out/emit.log" 2>&1
"$CC" -O3 -pg -pthread "$out/accepted52.c" -lm -o "$out/profile-only" >"$out/profile-build.log" 2>&1
for i in $(seq 1 30); do GMON_OUT_PREFIX="$out/gmon" "$out/profile-only" --threads 1 -- batch ../bend-transfer/cloud-handoff-20261003/corpora/easy-10000.txt solve >/dev/null; done
cd "$out"
gprof -s ./profile-only ./gmon.*
gprof ./profile-only gmon.sum >gprof.txt
head -50 gprof.txt
