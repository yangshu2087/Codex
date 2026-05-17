#!/usr/bin/env bash
set -euo pipefail

TS="$(date +%Y%m%d-%H%M%S)"
OUT_ROOT="${CODEX_AUTO_REVIEW_AUDIT_OUT:-/tmp/codex-auto-review-safety-audit-${TS}}"
CONFIG="${CODEX_CONFIG_PATH:-$HOME/.codex/config.toml}"
mkdir -p "$OUT_ROOT"
STATUS=0

section() { printf '\n== %s ==\n' "$1" | tee -a "$OUT_ROOT/auto-review-audit.log"; }
pass() { printf '[PASS] %s\n' "$1" | tee -a "$OUT_ROOT/auto-review-audit.log"; }
warn() { printf '[WARN] %s\n' "$1" | tee -a "$OUT_ROOT/auto-review-audit.log"; }
fail() { STATUS=1; printf '[FAIL] %s\n' "$1" | tee -a "$OUT_ROOT/auto-review-audit.log" >&2; }

section "Config source"
printf 'config=%s\n' "$CONFIG" | tee -a "$OUT_ROOT/auto-review-audit.log"
if [[ -f "$CONFIG" ]]; then
  pass "config exists"
else
  fail "config not found"
fi

section "Feature posture"
if command -v codex >/dev/null 2>&1 && codex features list > "$OUT_ROOT/features.txt" 2>&1; then
  for feature in guardian_approval hooks; do
    grep -E "^${feature}[[:space:]]" "$OUT_ROOT/features.txt" | tee -a "$OUT_ROOT/feature-summary.txt" || true
  done
  if awk '$1 == "guardian_approval" && $NF == "true" { found=1 } END { exit found ? 0 : 1 }' "$OUT_ROOT/features.txt"; then
    pass "guardian_approval feature is enabled"
  else
    warn "guardian_approval feature not confirmed enabled"
  fi
else
  warn "codex features list failed or codex missing"
fi

section "Top-level policy"
if [[ -f "$CONFIG" ]]; then
  TOP_APPROVAL="$(awk -F= '/^\[/ { exit } /^approval_policy[[:space:]]*=/ { gsub(/[ \t\"]/, "", $2); print $2 }' "$CONFIG" | tail -1)"
  TOP_SANDBOX="$(awk -F= '/^\[/ { exit } /^sandbox_mode[[:space:]]*=/ { gsub(/[ \t\"]/, "", $2); print $2 }' "$CONFIG" | tail -1)"
  TOP_REVIEWER="$(awk -F= '/^\[/ { exit } /^approvals_reviewer[[:space:]]*=/ { gsub(/[ \t\"]/, "", $2); print $2 }' "$CONFIG" | tail -1)"
  printf 'top_level.approval_policy=%s\n' "${TOP_APPROVAL:-unset}" | tee -a "$OUT_ROOT/policy-summary.txt"
  printf 'top_level.sandbox_mode=%s\n' "${TOP_SANDBOX:-unset}" | tee -a "$OUT_ROOT/policy-summary.txt"
  printf 'top_level.approvals_reviewer=%s\n' "${TOP_REVIEWER:-unset}" | tee -a "$OUT_ROOT/policy-summary.txt"

  if [[ "${TOP_APPROVAL:-}" == "never" ]]; then
    fail "top-level approval_policy=never; auto-review cannot help when approvals never surface"
  else
    pass "top-level approval policy is not never"
  fi
  if [[ "${TOP_SANDBOX:-}" =~ ^(danger-full-access|full-access|unrestricted)$ ]]; then
    fail "top-level sandbox mode appears too broad for auto-review-centered safety: ${TOP_SANDBOX}"
  else
    pass "top-level sandbox is not obviously full-access"
  fi
  if [[ "${TOP_REVIEWER:-}" == "auto_review" ]]; then
    warn "auto_review is set at top level; consider keeping it in an explicit guarded profile unless intentional"
  else
    pass "auto_review is not forced at top level"
  fi
fi

section "Guarded profile"
if [[ -f "$CONFIG" ]]; then
  python3 - "$CONFIG" "$OUT_ROOT/guarded-profile.txt" <<'PY'
from __future__ import annotations
import re, sys
from pathlib import Path
config = Path(sys.argv[1]).read_text(encoding='utf-8')
out = Path(sys.argv[2])
current = None
values: dict[str, dict[str, str]] = {}
for raw in config.splitlines():
    line = raw.strip()
    if not line or line.startswith('#'):
        continue
    m = re.match(r'\[(.+)]$', line)
    if m:
        current = m.group(1)
        values.setdefault(current, {})
        continue
    if '=' in line and current:
        k, v = line.split('=', 1)
        values.setdefault(current, {})[k.strip()] = v.strip().strip('"')
guarded = values.get('profiles.guarded', {})
for key in ['model','model_reasoning_effort','approval_policy','approvals_reviewer','sandbox_mode']:
    out.write_text('', encoding='utf-8') if False else None
with out.open('w', encoding='utf-8') as fh:
    for key in ['model','model_reasoning_effort','approval_policy','approvals_reviewer','sandbox_mode']:
        fh.write(f'{key}={guarded.get(key, "unset")}\n')
PY
  cat "$OUT_ROOT/guarded-profile.txt" | tee -a "$OUT_ROOT/auto-review-audit.log"
  if grep -q '^approvals_reviewer=auto_review$' "$OUT_ROOT/guarded-profile.txt"; then
    pass "guarded profile routes approvals to auto_review"
  else
    warn "guarded profile does not route approvals to auto_review"
  fi
  if grep -q '^approval_policy=on-request$' "$OUT_ROOT/guarded-profile.txt"; then
    pass "guarded profile uses approval_policy=on-request"
  else
    warn "guarded profile should generally use approval_policy=on-request"
  fi
  if grep -q '^sandbox_mode=workspace-write$' "$OUT_ROOT/guarded-profile.txt"; then
    pass "guarded profile uses workspace-write sandbox"
  else
    warn "guarded profile sandbox is not workspace-write"
  fi
fi

section "Broad rule scan"
if [[ -f "$CONFIG" ]]; then
  if grep -nE 'prefix_rule|approval_rule|writable_roots|danger-full-access|approval_policy[[:space:]]*=[[:space:]]*"never"' "$CONFIG" > "$OUT_ROOT/rule-scan.txt"; then
    cat "$OUT_ROOT/rule-scan.txt" | tee -a "$OUT_ROOT/auto-review-audit.log"
    if grep -q 'danger-full-access\|approval_policy[[:space:]]*=[[:space:]]*"never"' "$OUT_ROOT/rule-scan.txt"; then
      fail "found high-risk policy strings in config"
    else
      warn "found custom rules/roots; review that they are narrow and intentional"
    fi
  else
    pass "no obvious broad approval rules or writable_roots found in config"
  fi
fi

section "summary"
{
  echo "CODEX_AUTO_REVIEW_AUDIT_STATUS=$STATUS"
  echo "out_root=$OUT_ROOT"
  echo "policy=auto-review is a reviewer swap, not a permission expansion; keep sandbox boundaries narrow"
} | tee "$OUT_ROOT/summary.txt"
exit "$STATUS"
