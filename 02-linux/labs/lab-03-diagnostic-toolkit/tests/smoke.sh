#!/usr/bin/env bash
# tests/smoke.sh: confirms all scripts at least run and exit 0.
set -euo pipefail

# Resolve the bin directory relative to this test file, so it works from anywhere
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../bin" && pwd)"

echo "Running shellcheck on all scripts..."
shellcheck "$SCRIPT_DIR"/*

echo "Testing sysnap..."
"$SCRIPT_DIR/sysnap" --no-color >/dev/null

echo "Testing diskmap..."
"$SCRIPT_DIR/diskmap" /tmp --top 5 >/dev/null

echo "Testing netcheck..."
"$SCRIPT_DIR/netcheck" >/dev/null

echo "Smoke OK"
