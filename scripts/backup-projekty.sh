#!/usr/bin/env bash
set -euo pipefail

SRC="$HOME/Projekty"
DEST="$HOME/projekty-$(date +%Y%m%d-%H%M%S).zip"

if [[ ! -d "$SRC" ]]; then
  echo "Katalog $SRC nie istnieje" >&2
  exit 1
fi

cd "$HOME"
zip -r "$DEST" "Projekty" -x "*/node_modules/*" "*/node_modules"

echo "Utworzono archiwum: $DEST"
