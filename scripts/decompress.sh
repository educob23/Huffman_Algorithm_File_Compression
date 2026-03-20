#!/usr/bin/env sh
set -eu

if [ "$#" -ne 1 ]; then
  echo "Usage: ./scripts/decompress.sh <file.hf>"
  exit 1
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROJECT_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
INPUT_FILE=$1

case "$INPUT_FILE" in
  *.hf) ;;
  *)
    echo "Error: expected a .hf file"
    exit 1
    ;;
esac

echo "Decompressing: $INPUT_FILE"
dune exec --root "$PROJECT_ROOT" ./huff.exe -- "$INPUT_FILE"
echo "Decompression done."
