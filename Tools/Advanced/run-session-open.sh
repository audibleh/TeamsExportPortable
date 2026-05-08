#!/bin/sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/launcher-common.sh"

if [ "$#" -eq 0 ]; then
  exec "$PYTHON_EXE" -m msteams_export session-open --browser auto
else
  exec "$PYTHON_EXE" -m msteams_export session-open "$@"
fi
