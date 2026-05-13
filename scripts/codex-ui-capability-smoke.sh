#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
TS="$(date +%Y%m%d-%H%M%S)"
OUT_ROOT="${CODEX_UI_CAPABILITY_SMOKE_OUT:-/tmp/codex-ui-capability-smoke-${TS}}"
STATUS=0

section() { printf '\n== %s ==\n' "$1"; }
pass() { printf '[PASS] %s\n' "$1"; }
warn() { printf '[WARN] %s\n' "$1"; }
fail() { printf '[FAIL] %s\n' "$1"; STATUS=1; }

feature_enabled() {
  local name="$1"
  if codex features list 2>/dev/null | awk -v feature="$name" '$1 == feature && $NF == "true" { found=1 } END { exit found ? 0 : 1 }'; then
    pass "feature enabled: ${name}"
  else
    warn "feature not confirmed enabled: ${name}"
  fi
}

file_present() {
  local path="$1"
  if [[ -e "$path" ]]; then
    pass "present: ${path}"
  else
    fail "missing: ${path}"
  fi
}

mkdir -p "$OUT_ROOT"

section "Codex UI capability smoke"
printf 'repo_root=%s\n' "$REPO_ROOT"
printf 'out_root=%s\n' "$OUT_ROOT"

section "Codex runtime"
if command -v codex >/dev/null 2>&1; then
  codex --version
  pass "codex CLI available"
else
  fail "codex CLI not found"
fi

for feature in apps plugins tool_search image_generation workspace_dependencies shell_tool multi_agent codex_hooks browser_use in_app_browser computer_use; do
  feature_enabled "$feature"
done

section "MCP and app connectors"
if codex mcp list >/tmp/codex-ui-mcp-list.$$ 2>&1; then
  cat /tmp/codex-ui-mcp-list.$$
  for mcp in chrome-devtools computer-use openaiDeveloperDocs context7 cloudflare-api sentry; do
    if grep -q "^${mcp}[[:space:]]" /tmp/codex-ui-mcp-list.$$; then
      pass "MCP listed: ${mcp}"
    else
      warn "MCP not listed: ${mcp}"
    fi
  done
  rm -f /tmp/codex-ui-mcp-list.$$
else
  warn "codex mcp list failed"
fi

section "Workspace UI governance files"
file_present "/Users/yangshu/Codex/.agents/skills/frontend-design-review/SKILL.md"
file_present "/Users/yangshu/Codex/.agents/skills/product-ux-flow-review/SKILL.md"
file_present "/Users/yangshu/Codex/.agents/skills/repo-ui-postcheck-summary/SKILL.md"
file_present "/Users/yangshu/Codex/docs/templates/frontend-ui-verification.md"
file_present "/Users/yangshu/Codex/docs/templates/ui-state-matrix.md"
file_present "/Users/yangshu/Codex/docs/codex-quality-lanes.md"
file_present "/Users/yangshu/Codex/docs/codex-development-capability-roadmap.md"

section "Design and creative capabilities"
file_present "$HOME/.codex/skills/figma/SKILL.md"
file_present "$HOME/.codex/skills/figma-implement-design/SKILL.md"
file_present "$HOME/.codex/skills/playwright/SKILL.md"
file_present "$HOME/.codex/skills/playwright-interactive/SKILL.md"
file_present "$HOME/.agents/skills/product-shell-first/SKILL.md"
file_present "$HOME/.agents/skills/skilltrust-stitch-ui-prompt-architect/SKILL.md"
file_present "$HOME/.agents/skills/logo-generator/SKILL.md"
file_present "/Users/yangshu/Codex/.agents/skills/gpt-image-cn-router/SKILL.md"
file_present "/Users/yangshu/Codex/projects/awesome-design-md-portal/public/index.html"

section "Browser and screenshot tools"
if command -v agent-browser >/dev/null 2>&1; then
  printf 'agent_browser_bin=%s\n' "$(command -v agent-browser)"
  agent-browser --version
  pass "agent-browser available"
else
  fail "agent-browser not found"
fi

if command -v screencapture >/dev/null 2>&1; then
  pass "macOS screencapture available"
else
  warn "macOS screencapture not available"
fi

section "Playwright availability"
if [[ -f "$REPO_ROOT/package.json" ]] && grep -q '"@playwright/test"\|"playwright"' "$REPO_ROOT/package.json"; then
  pass "target repo declares Playwright dependency"
elif command -v playwright >/dev/null 2>&1; then
  playwright --version || true
  pass "global playwright command available"
elif command -v npx >/dev/null 2>&1 && (cd "$REPO_ROOT" && npx --no-install playwright --version >/tmp/codex-ui-playwright.$$ 2>&1); then
  cat /tmp/codex-ui-playwright.$$
  rm -f /tmp/codex-ui-playwright.$$
  pass "project-local Playwright available through npx --no-install"
else
  warn "Playwright not confirmed for target; add project-local @playwright/test for visual regression"
fi

section "UI state matrix lint"
if grep -q 'default.*hover.*focus-visible.*active.*loading.*empty.*error.*disabled.*success' /Users/yangshu/Codex/docs/templates/ui-state-matrix.md; then
  pass "state matrix covers required UI states"
else
  fail "state matrix missing required UI states"
fi

section "Optional visual smoke"
if [[ "${CODEX_UI_CAPABILITY_VISUAL_SMOKE:-1}" == "1" ]]; then
  SITE_DIR="$OUT_ROOT/site"
  mkdir -p "$SITE_DIR"
  cat > "$SITE_DIR/index.html" <<'HTML'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Codex UI Capability Smoke</title>
  <style>
    :root { color-scheme: light dark; --accent:#4f46e5; --ok:#16a34a; --warn:#b45309; }
    body { font-family: ui-sans-serif, system-ui, -apple-system, sans-serif; margin: 24px; line-height: 1.5; }
    .shell { max-width: 960px; margin: auto; border: 1px solid color-mix(in srgb, CanvasText 14%, transparent); border-radius: 20px; padding: 24px; }
    .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; }
    .card { border: 1px solid color-mix(in srgb, CanvasText 12%, transparent); border-radius: 14px; padding: 14px; background: color-mix(in srgb, Canvas 96%, CanvasText 4%); }
    .state { display:inline-flex; align-items:center; min-height: 32px; padding: 6px 10px; border-radius: 999px; background: color-mix(in srgb, var(--accent) 16%, transparent); color: CanvasText; margin: 4px; }
    button { border: 0; border-radius: 10px; padding: 10px 14px; background: var(--accent); color: white; font-weight: 700; }
    button:hover { filter: brightness(1.08); }
    button:focus-visible { outline: 3px solid color-mix(in srgb, var(--accent) 35%, white); outline-offset: 2px; }
    button:active { transform: translateY(1px); }
    button:disabled { opacity: .5; cursor: not-allowed; }
  </style>
</head>
<body>
  <main class="shell">
    <p>Visual thesis: compact governance dashboard for Codex frontend/UI capability readiness.</p>
    <h1>Codex UI Capability Smoke</h1>
    <div class="grid" aria-label="Capability checks">
      <section class="card"><strong>Design inputs</strong><p>DESIGN.md, Figma, screenshots, tokens.</p></section>
      <section class="card"><strong>State coverage</strong><p>default / hover / focus / active / loading / empty / error / disabled / success.</p></section>
      <section class="card"><strong>Browser evidence</strong><p>agent-browser screenshot required before UI completion.</p></section>
    </div>
    <p>
      <span class="state">default</span><span class="state">hover</span><span class="state">focus-visible</span><span class="state">active</span>
      <span class="state">loading</span><span class="state">empty</span><span class="state">error</span><span class="state">disabled</span><span class="state">success</span>
    </p>
    <button>Primary action</button> <button disabled>Disabled action</button>
  </main>
</body>
</html>
HTML
  PORT="$(python3 - <<'PY'
import socket
s=socket.socket(); s.bind(('127.0.0.1',0)); print(s.getsockname()[1]); s.close()
PY
)"
  python3 -m http.server "$PORT" --bind 127.0.0.1 --directory "$SITE_DIR" >/tmp/codex-ui-capability-http.$$ 2>&1 &
  SERVER_PID=$!
  cleanup_server() {
    kill "$SERVER_PID" >/dev/null 2>&1 || true
    wait "$SERVER_PID" 2>/dev/null || true
    rm -f /tmp/codex-ui-capability-http.$$
  }
  trap cleanup_server EXIT
  sleep 1
  if /Users/yangshu/Codex/scripts/agent-browser-smoke.sh "http://127.0.0.1:${PORT}/index.html" "$OUT_ROOT"; then
    pass "agent-browser visual smoke passed"
  else
    fail "agent-browser visual smoke failed"
  fi
else
  warn "visual smoke skipped; set CODEX_UI_CAPABILITY_VISUAL_SMOKE=1 to run"
fi

section "Summary"
if [[ "$STATUS" -eq 0 ]]; then
  printf 'CODEX_UI_CAPABILITY_SMOKE=pass\n'
else
  printf 'CODEX_UI_CAPABILITY_SMOKE=fail\n'
fi
printf 'out_root=%s\n' "$OUT_ROOT"
exit "$STATUS"
