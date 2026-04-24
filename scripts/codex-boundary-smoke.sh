#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATUS=0

section() { printf '\n== %s ==\n' "$1"; }
pass() { printf '[PASS] %s\n' "$1"; }
warn() { printf '[WARN] %s\n' "$1"; }
fail() { printf '[FAIL] %s\n' "$1"; STATUS=1; }

section "Codex version"
if command -v codex >/dev/null 2>&1; then
  VERSION="$(codex --version 2>&1 || true)"
  echo "$VERSION"
  if [[ "$VERSION" == "codex-cli 0.124.0" ]]; then
    pass "stable CLI 0.124.0 active"
  else
    fail "expected codex-cli 0.124.0, got: $VERSION"
  fi
else
  fail "codex not found"
fi

section "Config boundary"
CONFIG="$HOME/.codex/config.toml"
[[ -f "$CONFIG" ]] || fail "missing $CONFIG"
grep -q '^model = "gpt-5.5"' "$CONFIG" && pass "default model gpt-5.5" || fail "default model is not gpt-5.5"
grep -q '^model_reasoning_effort = "high"' "$CONFIG" && pass "default reasoning high" || fail "default reasoning is not high"
grep -q '^review_model = "gpt-5.5"' "$CONFIG" && pass "review model gpt-5.5" || fail "review model is not gpt-5.5"
grep -q '^\[profiles.frontier\]' "$CONFIG" && pass "frontier profile present" || fail "frontier profile missing"
grep -q '^\[profiles.guarded\]' "$CONFIG" && pass "guarded profile present" || fail "guarded profile missing"
grep -q '^approvals_reviewer = "auto_review"' "$CONFIG" && pass "guarded auto_review configured" || fail "auto_review not configured"
grep -q '^memories = false' "$CONFIG" && pass "experimental memories explicitly disabled" || warn "memories flag not explicit"

section "Feature load"
if codex features list > /tmp/codex-boundary-features.txt 2>&1; then
  grep -E '^(codex_hooks|multi_agent|plugins|apps|shell_snapshot|unified_exec)[[:space:]]' /tmp/codex-boundary-features.txt || true
  for feature in codex_hooks multi_agent plugins apps shell_snapshot unified_exec; do
    grep -E "^${feature}[[:space:]]+.*[[:space:]]true$" /tmp/codex-boundary-features.txt >/dev/null \
      && pass "feature true: $feature" \
      || fail "feature not true: $feature"
  done
else
  cat /tmp/codex-boundary-features.txt || true
  fail "codex features list failed"
fi

section "Custom agents"
for agent in pr-explorer reviewer docs-researcher browser-debugger ui-fixer; do
  path="$REPO_ROOT/.codex/agents/${agent}.toml"
  if [[ -f "$path" ]] && grep -q '^name = ' "$path" && grep -q '^description = ' "$path" && grep -q '^developer_instructions = ' "$path"; then
    pass "agent present: $agent"
  else
    fail "agent missing or incomplete: $agent"
  fi
done

section "MCP list"
if codex mcp list > /tmp/codex-boundary-mcp.txt 2>&1; then
  grep -E '^(openaiDeveloperDocs|context7|cloudflare-api|notion|sentry|chrome-devtools)[[:space:]]' /tmp/codex-boundary-mcp.txt || true
  pass "mcp list command completed"
else
  cat /tmp/codex-boundary-mcp.txt || true
  fail "codex mcp list failed"
fi

section "Upgrade script"
if [[ -x "$REPO_ROOT/scripts/check-codex-upgrade.sh" ]]; then
  "$REPO_ROOT/scripts/check-codex-upgrade.sh" > /tmp/codex-boundary-upgrade.txt 2>&1 || STATUS=1
  grep -E '^(Installed CLI:|npm latest:|GitHub latest:|Desktop app:|Official app build:)' /tmp/codex-boundary-upgrade.txt || true
  if grep -q 'installed CLI matches the latest stable' /tmp/codex-boundary-upgrade.txt; then
    pass "upgrade script confirms latest stable"
  else
    warn "upgrade script did not emit exact latest-stable confirmation; inspect /tmp/codex-boundary-upgrade.txt"
  fi
else
  fail "missing check-codex-upgrade.sh"
fi

section "Summary"
if [[ "$STATUS" -eq 0 ]]; then
  echo "CODEX_BOUNDARY_SMOKE=pass"
else
  echo "CODEX_BOUNDARY_SMOKE=fail"
fi
exit "$STATUS"
