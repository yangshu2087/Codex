#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TS="$(date +%Y%m%d-%H%M%S)"
OUT_ROOT="${CODEX_FAST_SMOKE_OUT:-/tmp/codex-quality-smoke-fast-${TS}}"
STATUS=0

mkdir -p "$OUT_ROOT"

log() { printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
section() { printf '\n== %s ==\n' "$*" | tee -a "$OUT_ROOT/fast-smoke.log"; }
mark_fail() { STATUS=1; printf '[FAIL] %s\n' "$*" | tee -a "$OUT_ROOT/fast-smoke.log" >&2; }

run_required() {
  local name="$1"; shift
  section "$name"
  log "running: $*" | tee -a "$OUT_ROOT/fast-smoke.log"
  if "$@" > >(tee "$OUT_ROOT/${name}.log") 2> >(tee "$OUT_ROOT/${name}.err" >&2); then
    log "passed: $name" | tee -a "$OUT_ROOT/fast-smoke.log"
  else
    mark_fail "failed: $name; see $OUT_ROOT/${name}.err"
  fi
}

section "codex version"
if command -v codex >/dev/null 2>&1; then
  codex --version | tee "$OUT_ROOT/codex-version.log"
else
  mark_fail "codex CLI not found"
fi

run_required "mcp-list" codex mcp list
run_required "skill-audit" "$REPO_ROOT/scripts/skill-audit.sh"
run_required "challenge-smoke" "$REPO_ROOT/scripts/codex-challenge-smoke.sh"
run_required "memory-audit" "$REPO_ROOT/scripts/codex-memory-audit.sh"

section "summary"
{
  echo "repo_root=$REPO_ROOT"
  echo "output=$OUT_ROOT"
  echo "status=$STATUS"
  echo "codex_version=$(codex --version 2>/dev/null || echo unavailable)"
} | tee "$OUT_ROOT/summary.txt"

if [[ "$STATUS" -eq 0 ]]; then
  log "Codex fast quality smoke passed: $OUT_ROOT"
else
  log "Codex fast quality smoke failed: $OUT_ROOT"
fi

exit "$STATUS"
