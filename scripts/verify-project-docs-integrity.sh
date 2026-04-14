#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="/Users/yangshu/.openclaw/workspace"
PROJECTS="$WORKSPACE/projects"
STATUS=0

usage() {
  cat <<'USAGE'
Usage: verify-project-docs-integrity.sh [--help]

Read-only audit for project documentation scaffold files and stale /Volumes/AI_SSD references.
USAGE
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
elif [[ $# -gt 0 ]]; then
  usage >&2
  exit 2
fi

required_files=(
  "README.md"
  "AGENTS.md"
  "docs/INDEX.md"
  "docs/recovery/RECOVERY.md"
  "output/reports/README.md"
  "artifacts/README.md"
  "data/README.md"
)

if [[ ! -d "$PROJECTS" ]]; then
  echo "Missing projects directory: $PROJECTS" >&2
  exit 1
fi

for project in "$PROJECTS"/*; do
  [[ -d "$project" ]] || continue
  name="$(basename "$project")"
  echo "== $name =="
  for rel in "${required_files[@]}"; do
    if [[ -f "$project/$rel" ]]; then
      echo "ok $rel"
    else
      echo "missing $name/$rel" >&2
      STATUS=1
    fi
  done
done

if command -v rg >/dev/null 2>&1; then
  legacy_hits="$(rg -n --hidden \
    --glob '!node_modules/**' \
    --glob '!.git/**' \
    --glob '!.pnpm-store/**' \
    --glob '!**/.Spotlight-V100/**' \
    --glob '!**/recovery-evidence/**' \
    --glob '!**/docs/recovery/**' \
    --glob '!**/output/**' \
    --glob '!**/artifacts/**' \
    --glob '!**/RECOVERY-SOURCE.md' \
    '/Volumes/AI_SSD' "$WORKSPACE" /Volumes/AI_DEV_2T/02-docs /Volumes/AI_DEV_2T/04-rag 2>/dev/null || true)"
  if [[ -n "$legacy_hits" ]]; then
    echo "Legacy AI_SSD references outside recovery allowlist:" >&2
    echo "$legacy_hits" >&2
    STATUS=1
  else
    echo "ok no legacy AI_SSD writable references outside recovery allowlist"
  fi
else
  echo "warning rg not found; skipped legacy path scan" >&2
fi

exit "$STATUS"
