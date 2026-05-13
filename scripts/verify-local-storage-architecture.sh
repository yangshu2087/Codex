#!/usr/bin/env bash
set -euo pipefail

STATUS=0

ok() { echo "ok $*"; }
fail() { echo "missing_or_bad $*" >&2; STATUS=1; }
warn() { echo "warning $*" >&2; }

expect_dir() {
  local path="$1"
  [[ -d "$path" ]] && ok "$path" || fail "$path"
}

expect_file() {
  local path="$1"
  [[ -f "$path" ]] && ok "$path" || fail "$path"
}

expect_symlink_target() {
  local link="$1"
  local target="$2"
  if [[ -L "$link" && "$(readlink "$link")" == "$target" ]]; then
    ok "$link -> $target"
  else
    fail "$link expected -> $target; actual=$(readlink "$link" 2>/dev/null || echo not-a-symlink)"
  fi
}

for volume in /Volumes/AI_DEV_2T /Volumes/AI_BACKUP_8T /Volumes/AI_ARCHIVE_8T; do
  expect_dir "$volume"
done

TM_DEST_INFO="$(tmutil destinationinfo 2>/dev/null || true)"
TM_MOUNT="$(printf "%s\n" "$TM_DEST_INFO" | awk -F: '/Mount Point[[:space:]]*:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}')"
if printf "%s\n" "$TM_DEST_INFO" | grep -q "Name[[:space:]]*: TM_MACMINI_8T"; then
  ok "Time Machine destination includes TM_MACMINI_8T"
  if [[ -n "$TM_MOUNT" ]]; then
    expect_dir "$TM_MOUNT"
  else
    warn "TM_MACMINI_8T destination has no Mount Point in tmutil destinationinfo"
  fi
else
  fail "Time Machine destination missing TM_MACMINI_8T"
fi

expect_symlink_target "/Users/yangshu/.openclaw/workspace" "/Volumes/AI_DEV_2T/01-projects/active/openclaw-workspace"
expect_symlink_target "/Users/yangshu/.ollama/models" "/Volumes/AI_DEV_2T/03-models/ollama"

required_dirs=(
  /Volumes/AI_DEV_2T/00-recovery-staging
  /Volumes/AI_DEV_2T/01-projects/active
  /Volumes/AI_DEV_2T/01-projects/incubating
  /Volumes/AI_DEV_2T/01-projects/archived-index
  /Volumes/AI_DEV_2T/02-docs/project-index
  /Volumes/AI_DEV_2T/02-docs/templates
  /Volumes/AI_DEV_2T/03-models/ollama
  /Volumes/AI_DEV_2T/03-models/gguf
  /Volumes/AI_DEV_2T/03-models/huggingface-cache
  /Volumes/AI_DEV_2T/03-models/staging
  /Volumes/AI_DEV_2T/04-rag/source-docs
  /Volumes/AI_DEV_2T/04-rag/chunks
  /Volumes/AI_DEV_2T/04-rag/embeddings
  /Volumes/AI_DEV_2T/04-rag/indexes
  /Volumes/AI_DEV_2T/04-rag/outputs
  /Volumes/AI_DEV_2T/05-runs/reports
  /Volumes/AI_DEV_2T/05-runs/artifacts
  /Volumes/AI_DEV_2T/05-runs/screenshots
  /Volumes/AI_DEV_2T/99-transfer
  /Volumes/AI_BACKUP_8T/ai-dev-2t-snapshots
  /Volumes/AI_ARCHIVE_8T/old-projects
  /Volumes/AI_ARCHIVE_8T/project-snapshots
  /Volumes/AI_ARCHIVE_8T/cold-models
  /Volumes/AI_ARCHIVE_8T/raw-datasets
  /Volumes/AI_ARCHIVE_8T/recovery-evidence
  /Volumes/AI_ARCHIVE_8T/long-term-docs
)

for dir in "${required_dirs[@]}"; do
  expect_dir "$dir"
done

required_files=(
  /Users/yangshu/.openclaw/workspace/docs/MAC-MINI-AI-STORAGE-OPERATING-SYSTEM.md
  /Users/yangshu/.openclaw/workspace/docs/WHERE-TO-PUT-NEW-PROJECTS-AND-DOCS.md
  /Volumes/AI_DEV_2T/README.md
  /Volumes/AI_DEV_2T/01-projects/README.md
  /Volumes/AI_DEV_2T/03-models/README.md
  /Volumes/AI_DEV_2T/04-rag/README.md
  /Volumes/AI_DEV_2T/05-runs/README.md
  /Volumes/AI_DEV_2T/02-docs/project-index/README.md
  /Volumes/AI_DEV_2T/02-docs/templates/NEW-PROJECT-BOOTSTRAP-CHECKLIST.md
  /Volumes/AI_BACKUP_8T/README.md
  /Volumes/AI_BACKUP_8T/backup-excludes.txt
  /Volumes/AI_ARCHIVE_8T/README.md
)

for file in "${required_files[@]}"; do
  expect_file "$file"
done


exit "$STATUS"
