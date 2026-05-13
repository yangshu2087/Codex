#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
TS="$(date +%Y%m%d-%H%M%S)"
OUT_ROOT="${CODEX_CREATIVE_UI_SMOKE_OUT:-/tmp/codex-creative-ui-smoke-${TS}}"
IMAGE_GEN="${CODEX_IMAGE_GEN_CLI:-$HOME/.codex/skills/imagegen/scripts/image_gen.py}"
LOGO_SKILL="${CODEX_LOGO_GENERATOR_SKILL:-$HOME/.agents/skills/logo-generator/SKILL.md}"
STATUS=0

section() { printf '\n== %s ==\n' "$1"; }
pass() { printf '[PASS] %s\n' "$1"; }
warn() { printf '[WARN] %s\n' "$1"; }
fail() { printf '[FAIL] %s\n' "$1"; STATUS=1; }

mkdir -p "$OUT_ROOT"

section "Codex creative/UI smoke"
printf 'repo_root=%s\n' "$REPO_ROOT"
printf 'out_root=%s\n' "$OUT_ROOT"

section "Codex features"
if command -v codex >/dev/null 2>&1; then
  codex --version | tee "$OUT_ROOT/codex-version.txt"
  codex features list | tee "$OUT_ROOT/codex-features.txt"
  grep -qE '^image_generation[[:space:]]+stable[[:space:]]+true' "$OUT_ROOT/codex-features.txt" \
    && pass "image_generation feature is enabled" \
    || warn "image_generation feature not confirmed; this flow still uses manual ChatGPT UI"
  grep -qE '^tool_search[[:space:]]+stable[[:space:]]+true' "$OUT_ROOT/codex-features.txt" \
    && pass "tool_search feature is enabled" \
    || warn "tool_search feature not confirmed"
else
  fail "codex CLI not found"
fi

section "Runtime pressure"
if [[ -x "$REPO_ROOT/scripts/codex-runtime-health.sh" ]]; then
  "$REPO_ROOT/scripts/codex-runtime-health.sh" > "$OUT_ROOT/runtime-health.txt" || true
  grep -E 'STATUS=|RECOMMENDED_PROFILE=|RECOMMENDED_THREADS=' "$OUT_ROOT/runtime-health.txt" || true
  if grep -q 'STATUS=high-pressure' "$OUT_ROOT/runtime-health.txt"; then
    warn "runtime is high-pressure; keep creative work single-agent and avoid batch generation"
  else
    pass "runtime pressure is not high-pressure"
  fi
else
  warn "runtime health script missing"
fi

section "Skill presence"
if [[ -f "$LOGO_SKILL" ]]; then
  pass "logo-generator skill present: $LOGO_SKILL"
else
  fail "logo-generator skill missing: $LOGO_SKILL"
fi

if [[ -f "$IMAGE_GEN" ]]; then
  pass "imagegen CLI present: $IMAGE_GEN"
else
  fail "imagegen CLI missing: $IMAGE_GEN"
fi

section "API key boundary"
if [[ -n "${OPENAI_API_KEY:-}" ]]; then
  warn "OPENAI_API_KEY is set; smoke will not perform a live image API call"
  printf 'OPENAI_API_KEY=set-but-unused\n' > "$OUT_ROOT/api-key-status.txt"
else
  pass "OPENAI_API_KEY is not set; missing_api_key_allowed"
  printf 'OPENAI_API_KEY=not_set\n' > "$OUT_ROOT/api-key-status.txt"
fi

section "imagegen dry-run"
if [[ -f "$IMAGE_GEN" ]]; then
  python3 "$IMAGE_GEN" generate \
    --prompt "Codex creative UI smoke dry run. No live API call. Prepare a restrained product hero image prompt for manual ChatGPT UI generation." \
    --dry-run \
    --out "$OUT_ROOT/dry-run.png" > "$OUT_ROOT/imagegen-dry-run.json"
  cat "$OUT_ROOT/imagegen-dry-run.json"
  grep -q '"endpoint": "/v1/images/generations"' "$OUT_ROOT/imagegen-dry-run.json" \
    && pass "imagegen dry-run produced generations contract" \
    || fail "imagegen dry-run did not show generations endpoint"
else
  fail "skipping imagegen dry-run because CLI is missing"
fi

section "Manual ChatGPT UI handoff artifacts"
cat > "$OUT_ROOT/creative-asset-brief.md" <<'BRIEF'
# Creative asset brief smoke

- Goal: prove Codex can prepare a creative brief without API billing.
- Asset type: logo / hero prompt handoff
- Visual thesis: restrained geometric identity with high contrast and generous negative space.
- Manual ChatGPT UI step required: yes
- API live call allowed: no
- Done criteria: brief and prompt exist, browser showcase screenshot captured.
BRIEF

cat > "$OUT_ROOT/chatgpt-image-handoff.md" <<'HANDOFF'
# ChatGPT image handoff smoke

```text
Use case: product hero visual
Asset type: manual ChatGPT UI image prompt
Primary request: create a restrained geometric AI product identity hero image
Style/medium: premium editorial digital design
Composition/framing: centered mark, generous negative space, no fake UI chrome
Constraints: manual ChatGPT UI only; no API live call; no watermark
Avoid: clutter, copied brands, unreadable text, excessive glow
```
HANDOFF

[[ -s "$OUT_ROOT/creative-asset-brief.md" && -s "$OUT_ROOT/chatgpt-image-handoff.md" ]] \
  && pass "brief and ChatGPT UI handoff artifacts created" \
  || fail "handoff artifacts missing"

section "Browser / visual smoke"
if ! command -v agent-browser >/dev/null 2>&1; then
  fail "agent-browser not found"
elif [[ ! -x "$REPO_ROOT/scripts/agent-browser-smoke.sh" ]]; then
  fail "agent-browser-smoke.sh missing or not executable"
else
  SITE_DIR="$OUT_ROOT/site"
  mkdir -p "$SITE_DIR"
  cat > "$SITE_DIR/showcase.html" <<'HTML'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Codex Creative UI Smoke</title>
  <style>
    :root { color-scheme: dark; font-family: Inter, ui-sans-serif, system-ui, sans-serif; }
    body { margin: 0; min-height: 100vh; display: grid; place-items: center; background: #09090b; color: #f8fafc; }
    main { width: min(920px, calc(100vw - 32px)); display: grid; gap: 24px; }
    .hero { border: 1px solid rgba(255,255,255,.14); border-radius: 28px; padding: 40px; background: radial-gradient(circle at top right, rgba(125,92,255,.25), transparent 45%), #111113; }
    .mark { width: 112px; height: 112px; color: white; }
    h1 { font-size: clamp(32px, 7vw, 72px); line-height: .9; letter-spacing: -0.07em; margin: 24px 0 8px; }
    p { max-width: 620px; color: #cbd5e1; font-size: 18px; line-height: 1.6; }
    .states { display: flex; flex-wrap: wrap; gap: 10px; }
    .pill { border: 1px solid rgba(255,255,255,.14); border-radius: 999px; padding: 8px 12px; color: #d4d4d8; }
    @media (max-width: 560px) { .hero { padding: 28px; border-radius: 20px; } .mark { width: 84px; height: 84px; } }
  </style>
</head>
<body>
  <main>
    <section class="hero" aria-label="Creative UI smoke showcase">
      <svg class="mark" viewBox="0 0 100 100" role="img" aria-label="Geometric Codex creative mark">
        <circle cx="50" cy="50" r="34" fill="none" stroke="currentColor" stroke-width="4" />
        <path d="M28 58 C42 28 58 72 72 42" fill="none" stroke="currentColor" stroke-width="5" stroke-linecap="round" />
        <circle cx="28" cy="58" r="5" fill="currentColor" />
        <circle cx="72" cy="42" r="5" fill="currentColor" />
      </svg>
      <h1>Manual image handoff, verified visually.</h1>
      <p>Codex prepares briefs, SVG directions, and ChatGPT UI prompts without live image API billing. Final assets must be returned and checked before completion.</p>
      <div class="states" aria-label="State coverage">
        <span class="pill">default</span><span class="pill">hover</span><span class="pill">focus-visible</span><span class="pill">loading</span><span class="pill">empty</span><span class="pill">error</span><span class="pill">success</span>
      </div>
    </section>
  </main>
</body>
</html>
HTML
  PORT="$(python3 - <<'PY'
import socket
s=socket.socket(); s.bind(('127.0.0.1', 0)); print(s.getsockname()[1]); s.close()
PY
)"
  python3 -m http.server "$PORT" --bind 127.0.0.1 --directory "$SITE_DIR" > "$OUT_ROOT/http.log" 2>&1 &
  SERVER_PID=$!
  cleanup_server() { kill "$SERVER_PID" >/dev/null 2>&1 || true; }
  trap cleanup_server EXIT
  sleep 1
  "$REPO_ROOT/scripts/agent-browser-smoke.sh" "http://127.0.0.1:${PORT}/showcase.html" "$OUT_ROOT" | tee "$OUT_ROOT/agent-browser-smoke.log"
  grep -q '\[PASS\] smoke check passed' "$OUT_ROOT/agent-browser-smoke.log" \
    && pass "agent-browser visual smoke passed" \
    || fail "agent-browser visual smoke did not pass"
fi

section "Local screenshot tool"
command -v screencapture >/dev/null 2>&1 \
  && pass "macOS screencapture available" \
  || warn "screencapture not available"

section "Summary"
if [[ "$STATUS" -eq 0 ]]; then
  echo "CODEX_CREATIVE_UI_SMOKE=pass"
else
  echo "CODEX_CREATIVE_UI_SMOKE=fail"
fi
printf 'out_root=%s\n' "$OUT_ROOT"
exit "$STATUS"
