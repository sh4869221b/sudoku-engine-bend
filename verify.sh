#!/bin/sh
set -eu
cd "$(dirname "$0")"
. ./toolchain-env.sh
exec python3 qa/verify_isolated.py "$@"
