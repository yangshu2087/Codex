#!/usr/bin/env bash
set -euo pipefail

TS="$(date +%Y%m%d-%H%M%S)"
OUT_ROOT="${CODEX_REMOTE_CONTROL_SMOKE_OUT:-/tmp/codex-remote-control-smoke-${TS}}"
mkdir -p "$OUT_ROOT"
STATUS=0

section() { printf '\n== %s ==\n' "$1" | tee -a "$OUT_ROOT/remote-control-smoke.log"; }
pass() { printf '[PASS] %s\n' "$1" | tee -a "$OUT_ROOT/remote-control-smoke.log"; }
warn() { printf '[WARN] %s\n' "$1" | tee -a "$OUT_ROOT/remote-control-smoke.log"; }
fail() { STATUS=1; printf '[FAIL] %s\n' "$1" | tee -a "$OUT_ROOT/remote-control-smoke.log" >&2; }

section "codex version"
if command -v codex >/dev/null 2>&1; then
  codex --version | tee "$OUT_ROOT/version.txt"
  pass "codex CLI available"
else
  fail "codex CLI not found"
fi

section "feature state"
if codex features list > "$OUT_ROOT/features.txt" 2>&1; then
  grep -E '^remote_control[[:space:]]' "$OUT_ROOT/features.txt" | tee "$OUT_ROOT/remote-control-feature.txt" || true
  if awk '$1 == "remote_control" && $NF == "true" { found=1 } END { exit found ? 0 : 1 }' "$OUT_ROOT/features.txt"; then
    warn "remote_control is enabled; keep it experimental and do not run as a default daemon"
  else
    pass "remote_control is not enabled by default"
  fi
else
  fail "codex features list failed"
fi

section "help only"
if codex remote-control --help > "$OUT_ROOT/help.txt" 2>&1; then
  if grep -q 'Start a headless app-server' "$OUT_ROOT/help.txt"; then
    pass "remote-control command is present; help text captured"
  else
    fail "remote-control help did not contain expected text"
  fi
else
  fail "codex remote-control --help failed"
fi

section "no daemon started"
if ps -axo command | grep -E '[c]odex remote-control' >/dev/null 2>&1; then
  fail "codex remote-control process is running; smoke should not start a daemon"
else
  pass "no codex remote-control process is running"
fi

section "summary"
if [[ "$STATUS" -eq 0 ]]; then
  echo "CODEX_REMOTE_CONTROL_SMOKE=pass" | tee "$OUT_ROOT/summary.txt"
else
  echo "CODEX_REMOTE_CONTROL_SMOKE=fail" | tee "$OUT_ROOT/summary.txt"
fi
printf 'out_root=%s\n' "$OUT_ROOT" | tee -a "$OUT_ROOT/summary.txt"
exit "$STATUS"
