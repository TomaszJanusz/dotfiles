#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $(basename "$0") <directory>" >&2
  exit 2
fi

SRC="$1"

if [[ ! -d "$SRC" ]]; then
  echo "Katalog $SRC nie istnieje" >&2
  exit 1
fi

SRC_ABS="$(cd "$SRC" && pwd)"
NAME="$(basename "$SRC_ABS")"
DEST="$HOME/${NAME}-$(date +%Y%m%d-%H%M%S).zip"

cd "$(dirname "$SRC_ABS")"
zip -r "$DEST" "$NAME" -x "*/node_modules/*" "*/node_modules"

echo "Utworzono archiwum: $DEST"
