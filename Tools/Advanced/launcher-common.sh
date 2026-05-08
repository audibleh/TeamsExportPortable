#!/bin/sh

set -eu

find_bundle_root() {
  search_dir="$1"
  while [ "$search_dir" != "/" ]; do
    if [ -d "$search_dir/src" ] && [ -d "$search_dir/runtime/python" ] && [ -f "$search_dir/Doc/PORTABLE_QUICKSTART.md" ]; then
      printf '%s\n' "$search_dir"
      return 0
    fi
    search_dir="$(dirname "$search_dir")"
  done
  return 1
}

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
ROOT="$(find_bundle_root "$SCRIPT_DIR" || true)"

if [ -z "$ROOT" ]; then
  echo "Could not locate the portable bundle root from '$SCRIPT_DIR'."
  echo "Expected to find 'src/', 'runtime/python/' and 'Doc/PORTABLE_QUICKSTART.md'."
  exit 1
fi

PYTHON_EXE=""
if [ -x "$ROOT/runtime/python/bin/python3" ]; then
  PYTHON_EXE="$ROOT/runtime/python/bin/python3"
elif [ -x "$ROOT/runtime/python/python3" ]; then
  PYTHON_EXE="$ROOT/runtime/python/python3"
fi

if [ -z "$PYTHON_EXE" ]; then
  echo "Missing bundled runtime under '$ROOT/runtime/python'."
  echo "See Doc/PORTABLE_QUICKSTART.md for the expected portable layout."
  exit 1
fi

export PYTHONPATH="$ROOT/src"
export PYTHONUTF8=1
