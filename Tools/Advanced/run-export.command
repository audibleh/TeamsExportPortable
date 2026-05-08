#!/bin/sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
TARGET="$SCRIPT_DIR/run-export.sh"

if [ ! -x "$TARGET" ]; then
  echo "Missing launcher at '$TARGET'."
  exit 1
fi

exec "$TARGET" "$@"
