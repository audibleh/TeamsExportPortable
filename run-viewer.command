#!/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
TARGET="$ROOT/Tools/Advanced/run-viewer.sh"

if [ ! -x "$TARGET" ]; then
  echo "Missing launcher at '$TARGET'."
  echo "See Doc/PORTABLE_QUICKSTART.md for the expected portable layout."
  exit 1
fi

exec "$TARGET" "$@"
