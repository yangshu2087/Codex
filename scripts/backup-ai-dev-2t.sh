#!/usr/bin/env bash
set -euo pipefail

SOURCE="/Volumes/AI_DEV_2T/"
SNAPSHOT_ROOT="/Volumes/AI_BACKUP_8T/ai-dev-2t-snapshots"
EXCLUDES="/Volumes/AI_BACKUP_8T/backup-excludes.txt"
MODE="snapshot"

usage() {
  cat <<'USAGE'
Usage: backup-ai-dev-2t.sh [--dry-run]

Creates a dated AI_DEV_2T snapshot under /Volumes/AI_BACKUP_8T/ai-dev-2t-snapshots.
Use --dry-run to print the rsync plan without copying files.
USAGE
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

if [[ "${1:-}" == "--dry-run" ]]; then
  MODE="dry-run"
elif [[ $# -gt 0 ]]; then
  usage >&2
  exit 2
fi

for path in "$SOURCE" "$SNAPSHOT_ROOT" "$EXCLUDES"; do
  if [[ ! -e "$path" ]]; then
    echo "Missing required path: $path" >&2
    exit 1
  fi
done

if [[ "$MODE" == "dry-run" ]]; then
  TARGET="$SNAPSHOT_ROOT/ai-dev-2t-dry-run/"
  echo "Dry-run only; no files or directories will be created." >&2
  exec rsync -ani --exclude-from="$EXCLUDES" "$SOURCE" "$TARGET"
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
TARGET="$SNAPSHOT_ROOT/ai-dev-2t-$STAMP"
mkdir -p "$TARGET"
rsync -a --exclude-from="$EXCLUDES" "$SOURCE" "$TARGET/"
{
  echo "snapshot=$TARGET"
  echo "created_at=$STAMP"
  echo "source=$SOURCE"
  echo "excludes=$EXCLUDES"
} > "$TARGET/BACKUP-MANIFEST.txt"

echo "$TARGET"
