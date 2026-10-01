#!/bin/sh
set -eu
cd "$(dirname "$0")"
. ./toolchain-env.sh
export BEND_NO_TELEMETRY=1
mkdir -p bin
"$BEND" main.bend --check-only
"$BEND" main.bend -o bin/bend-sudoku
