#!/bin/sh
# Same-host 2.0.37 (legacy runtime ABI) versus 2.0.40 (RTS blocks).
set -eu
if [ "$#" -ne 4 ]; then
  echo "usage: $0 OLD_BINARY NEW_BINARY CORPORA_DIRECTORY EMPTY_OUTPUT_DIRECTORY" >&2
  exit 2
fi
export BEND_LEGACY_BINARY=$(realpath "$1")
export BENDRTS=
exec sh "$(dirname "$0")/../compiler-20261004/compare.sh" "$@"
