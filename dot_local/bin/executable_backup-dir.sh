#!/usr/bin/env bash
# Zips a directory into ~/<name>-<timestamp>.zip, leaving out everything that
# can be regenerated: dependencies, build output, caches, agent worktrees.
# Git history (.git) is kept, so unpushed branches and stashes survive.
#
#   backup-dir.sh <directory> [--exclude <glob>]...
#   backup-dir.sh ~/Developer --exclude '*.tar'
set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") <directory> [--exclude <glob>]..." >&2
  exit 2
}

[[ $# -ge 1 ]] || usage
SRC="$1"
shift

EXTRA=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --exclude) [[ $# -ge 2 ]] || usage; EXTRA+=("$2"); shift 2 ;;
    *) usage ;;
  esac
done

if [[ ! -d "$SRC" ]]; then
  echo "Katalog $SRC nie istnieje" >&2
  exit 1
fi

SRC_ABS="$(cd "$SRC" && pwd)"
NAME="$(basename "$SRC_ABS")"
DEST="$HOME/${NAME}-$(date +%Y%m%d-%H%M%S).zip"

# Directory names dropped wherever they appear.
SKIP_DIRS=(
  node_modules .pnpm-store bower_components
  .venv venv __pycache__ .mypy_cache .pytest_cache .ruff_cache .tox
  dist build out .next .nuxt .svelte-kit .turbo .parcel-cache .vite .cache
  target .gradle
  coverage test-results playwright-report blob-report .playwright-cli
  vendor
  DerivedData
)

EXCLUDES=()
for dir in "${SKIP_DIRS[@]}"; do
  EXCLUDES+=("*/$dir/*" "*/$dir")
done
# Agent worktrees: their branches live in the main repository's .git.
EXCLUDES+=("$NAME/worktrees/*" "*/.claude/worktrees/*" "*/.codex/worktrees/*")
EXCLUDES+=("*.DS_Store")
for glob in "${EXTRA[@]+"${EXTRA[@]}"}"; do
  EXCLUDES+=("$glob")
done

cd "$(dirname "$SRC_ABS")"
# -y stores symlinks as links instead of following them into other trees.
zip -r -y -q "$DEST" "$NAME" -x "${EXCLUDES[@]}"

echo "Utworzono archiwum: $DEST ($(du -h "$DEST" | cut -f1))"
