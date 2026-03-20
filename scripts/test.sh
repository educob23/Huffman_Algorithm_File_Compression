#!/usr/bin/env sh
set -eu

# Run Dune tests with an explicit workspace root to avoid root-detection warnings.
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROJECT_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)

echo "Running tests..."
dune runtest -f --root "$PROJECT_ROOT" "$@"
echo "Tests passed."
