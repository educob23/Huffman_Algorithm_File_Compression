#!/usr/bin/env sh
set -eu

if [ "$#" -ne 1 ]; then
  echo "Usage: ./scripts/stats.sh <file>"
  exit 1
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROJECT_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
INPUT_FILE=$1

echo "Computing compression statistics for: $INPUT_FILE"
dune exec --root "$PROJECT_ROOT" ./huff.exe -- --stats "$INPUT_FILE"
