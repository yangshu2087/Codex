#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_PROJECT="${1:-$PWD}"
RUN_VISUAL_SMOKE="${CODEX_DEV_CAPABILITY_VISUAL_SMOKE:-0}"
VISUAL_URL="${CODEX_DEV_CAPABILITY_VISUAL_URL:-https://example.com}"
STATUS=0

section() {
  printf '\n== %s ==\n' "$1"
}

pass() {
  printf '[PASS] %s\n' "$1"
}

warn() {
  printf '[WARN] %s\n' "$1"
}

fail() {
  printf '[FAIL] %s\n' "$1"
  STATUS=1
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

section "Codex version"
if have_cmd codex; then
  CODEX_BIN="$(command -v codex)"
  CODEX_VERSION="$(codex --version 2>&1 || true)"
  printf 'codex_bin=%s\n' "$CODEX_BIN"
  printf 'codex_version=%s\n' "$CODEX_VERSION"
  [[ -n "$CODEX_VERSION" ]] && pass "codex CLI available" || fail "codex --version returned empty output"
else
  fail "codex CLI not found in PATH"
fi

section "Codex MCP"
if have_cmd codex; then
  MCP_OUT="$(codex mcp list 2>&1 || true)"
  printf '%s\n' "$MCP_OUT"
  for server in openaiDeveloperDocs context7 notion cloudflare-api vercel; do
    if grep -q "^${server}[[:space:]]" <<<"$MCP_OUT" && grep -q "^${server}.*enabled" <<<"$MCP_OUT"; then
      pass "MCP enabled: ${server}"
    else
      warn "MCP not confirmed enabled: ${server}"
    fi
  done
else
  fail "cannot check MCP without codex CLI"
fi

section "Codex features"
if have_cmd codex; then
  FEATURES_OUT="$(codex features list 2>&1 || true)"
  printf '%s\n' "$FEATURES_OUT" | grep -E '^(apps|plugins|codex_hooks|fast_mode|multi_agent|shell_tool|skill_mcp_dependency_install|unified_exec)[[:space:]]' || true
  for feature in apps plugins fast_mode multi_agent shell_tool skill_mcp_dependency_install unified_exec; do
    if grep -E "^${feature}[[:space:]]" <<<"$FEATURES_OUT" | grep -q 'true$'; then
      pass "feature enabled: ${feature}"
    else
      warn "feature not confirmed true: ${feature}"
    fi
  done
  if grep -E '^codex_hooks[[:space:]]' <<<"$FEATURES_OUT" | grep -q 'true$'; then
    pass "feature enabled: codex_hooks"
  else
    warn "codex_hooks not confirmed enabled"
  fi
else
  fail "cannot check features without codex CLI"
fi

section "Runtime pressure"
if [[ -x "$REPO_ROOT/scripts/codex-runtime-health.sh" ]]; then
  HEALTH_OUT="$($REPO_ROOT/scripts/codex-runtime-health.sh 2>&1 || true)"
  printf '%s\n' "$HEALTH_OUT" | grep -E '^(Host load|Swap used|Codex CLI|STATUS=|RECOMMENDED_PROFILE=|RECOMMENDED_THREADS=)' || true
  if grep -q '^STATUS=high-pressure' <<<"$HEALTH_OUT"; then
    warn "runtime health is high-pressure; prefer single-agent / quick profile"
  elif grep -q '^STATUS=' <<<"$HEALTH_OUT"; then
    pass "runtime health emitted machine-readable status"
  else
    warn "runtime health did not emit STATUS"
  fi
else
  fail "missing codex-runtime-health.sh"
fi

section "Quality lane files"
for path in \
  "$REPO_ROOT/docs/codex-development-capability-roadmap.md" \
  "$REPO_ROOT/docs/codex-quality-lanes.md" \
  "$REPO_ROOT/docs/templates/api-contract-checklist.md" \
  "$REPO_ROOT/docs/templates/frontend-ui-verification.md" \
  "$REPO_ROOT/.agents/skills/architecture-decision-review/SKILL.md" \
  "$REPO_ROOT/.agents/skills/backend-api-contract-review/SKILL.md" \
  "$REPO_ROOT/.agents/skills/frontend-design-review/SKILL.md" \
  "$REPO_ROOT/.agents/skills/product-ux-flow-review/SKILL.md"; do
  if [[ -f "$path" ]]; then
    pass "present: ${path#$REPO_ROOT/}"
  else
    fail "missing: $path"
  fi
done

section "skills-lock"
if [[ -f "$REPO_ROOT/skills-lock.json" ]]; then
  if python3 -m json.tool "$REPO_ROOT/skills-lock.json" >/dev/null; then
    pass "skills-lock.json is valid JSON"
  else
    fail "skills-lock.json is invalid JSON"
  fi
  python3 - "$REPO_ROOT/skills-lock.json" <<'PY'
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
skills = data.get('skills', {})
violations = []
for name, meta in sorted(skills.items()):
    if not isinstance(meta, dict):
        continue
    layer = meta.get('installLayer', '')
    if layer == 'workspace-reviewed-candidate':
        if meta.get('defaultEnabled') is not False or meta.get('implicitInvocation') is not False:
            violations.append(name)
print('reviewed_candidate_count=' + str(sum(1 for v in skills.values() if isinstance(v, dict) and v.get('installLayer') == 'workspace-reviewed-candidate')))
if violations:
    print('reviewed_candidate_policy_violations=' + ','.join(violations))
    raise SystemExit(1)
print('reviewed_candidate_policy=ok')
PY
  if [[ $? -eq 0 ]]; then
    pass "reviewed candidates are disabled explicit-only"
  else
    fail "reviewed candidate policy violation"
  fi
else
  fail "missing skills-lock.json"
fi

section "Skill smoke"
if [[ -x "$REPO_ROOT/scripts/skill-smoke.sh" ]]; then
  if "$REPO_ROOT/scripts/skill-smoke.sh" >/tmp/codex-dev-capability-skill-smoke.out 2>&1; then
    tail -12 /tmp/codex-dev-capability-skill-smoke.out
    pass "skill-smoke.sh passed"
  else
    cat /tmp/codex-dev-capability-skill-smoke.out
    fail "skill-smoke.sh failed"
  fi
else
  fail "missing skill-smoke.sh"
fi

section "Capability audit"
if [[ -x "$REPO_ROOT/scripts/codex-capability-audit.sh" ]]; then
  if "$REPO_ROOT/scripts/codex-capability-audit.sh" >/tmp/codex-dev-capability-audit.out 2>&1; then
    grep -E '^(Enabled MCP servers:|Enabled plugins:|Workspace skills:|Locked skills by layer:|- workspace-reviewed-candidate:|- workspace-standard)' /tmp/codex-dev-capability-audit.out || true
    pass "codex-capability-audit.sh passed"
  else
    cat /tmp/codex-dev-capability-audit.out
    fail "codex-capability-audit.sh failed"
  fi
else
  fail "missing codex-capability-audit.sh"
fi

section "Browser and UI tools"
if have_cmd agent-browser; then
  printf 'agent_browser_bin=%s\n' "$(command -v agent-browser)"
  agent-browser --version || true
  pass "agent-browser available"
else
  warn "agent-browser not found; use Playwright or install/enable agent-browser before relying on this lane"
fi

if have_cmd screencapture; then
  pass "macOS screencapture available"
else
  warn "screencapture not found"
fi

section "Playwright availability"
printf 'target_project=%s\n' "$TARGET_PROJECT"
if have_cmd playwright; then
  playwright --version || true
  pass "global playwright available"
elif [[ -f "$TARGET_PROJECT/package.json" ]] && have_cmd npx && (cd "$TARGET_PROJECT" && npx --no-install playwright --version >/tmp/codex-dev-capability-playwright.out 2>&1); then
  cat /tmp/codex-dev-capability-playwright.out
  pass "project-local playwright available via npx --no-install"
else
  if [[ -f "$TARGET_PROJECT/package.json" ]]; then
    python3 - "$TARGET_PROJECT/package.json" <<'PY' || true
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
deps = {}
for key in ('dependencies', 'devDependencies', 'optionalDependencies'):
    deps.update(data.get(key, {}) or {})
found = {k: v for k, v in deps.items() if 'playwright' in k.lower()}
print('package_playwright_dependencies=' + (str(found) if found else 'none'))
PY
  fi
  warn "Playwright CLI not confirmed; prefer project-local npm scripts or npx --no-install playwright when a project provides it"
fi

section "Optional visual smoke"
if [[ "$RUN_VISUAL_SMOKE" == "1" ]]; then
  if [[ -x "$REPO_ROOT/scripts/agent-browser-smoke.sh" ]]; then
    "$REPO_ROOT/scripts/agent-browser-smoke.sh" "$VISUAL_URL" /tmp
    pass "agent-browser visual smoke passed"
  else
    fail "missing agent-browser-smoke.sh"
  fi
else
  warn "visual smoke skipped by default; set CODEX_DEV_CAPABILITY_VISUAL_SMOKE=1 to run agent-browser smoke"
fi

section "Summary"
if [[ "$STATUS" -eq 0 ]]; then
  echo "CODEX_DEV_CAPABILITY_SMOKE=pass"
else
  echo "CODEX_DEV_CAPABILITY_SMOKE=fail"
fi
exit "$STATUS"
