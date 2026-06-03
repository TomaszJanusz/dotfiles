#!/bin/bash
set -euo pipefail

AGE_DAYS=30
TRASH_BIN="$(command -v trash 2>/dev/null || true)"

if [ -z "$TRASH_BIN" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] trash not in PATH, aborting" >&2
  exit 1
fi

cleanup_dir() {
  local dir="$1"
  [ -d "$dir" ] || return 0
  local count=0
  while IFS= read -r -d '' f; do
    "$TRASH_BIN" -- "$f" && count=$((count + 1))
  done < <(find "$dir" -maxdepth 1 -type f -mtime "+${AGE_DAYS}" \
    -not -name '.*' \
    -not -name '*.crdownload' \
    -not -name '*.part' \
    -not -name '*.partial' \
    -not -name '*.download' \
    -print0)
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $dir: trashed $count files older than ${AGE_DAYS} days"
}

cleanup_dir "$HOME/Downloads"
cleanup_dir "$HOME/Screenshots"
