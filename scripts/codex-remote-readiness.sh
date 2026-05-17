#!/usr/bin/env bash
set -euo pipefail

TS="$(date +%Y%m%d-%H%M%S)"
OUT_ROOT="${CODEX_REMOTE_READINESS_OUT:-/tmp/codex-remote-readiness-${TS}}"
mkdir -p "$OUT_ROOT"
STATUS=0

section() { printf '\n== %s ==\n' "$1" | tee -a "$OUT_ROOT/remote-readiness.log"; }
pass() { printf '[PASS] %s\n' "$1" | tee -a "$OUT_ROOT/remote-readiness.log"; }
warn() { printf '[WARN] %s\n' "$1" | tee -a "$OUT_ROOT/remote-readiness.log"; }
fail() { STATUS=1; printf '[FAIL] %s\n' "$1" | tee -a "$OUT_ROOT/remote-readiness.log" >&2; }

section "Codex runtime"
if command -v codex >/dev/null 2>&1; then
  codex --version | tee "$OUT_ROOT/codex-version.txt"
  pass "codex CLI available"
else
  fail "codex CLI not found"
fi

APP_PLIST="/Applications/Codex.app/Contents/Info.plist"
if [[ -f "$APP_PLIST" ]]; then
  /usr/bin/defaults read /Applications/Codex.app/Contents/Info CFBundleShortVersionString > "$OUT_ROOT/desktop-version.txt" 2>/dev/null || true
  /usr/bin/defaults read /Applications/Codex.app/Contents/Info CFBundleVersion >> "$OUT_ROOT/desktop-version.txt" 2>/dev/null || true
  pass "Codex.app installed at /Applications/Codex.app"
else
  warn "Codex.app not found at /Applications/Codex.app"
fi

section "Feature posture"
if codex features list > "$OUT_ROOT/features.txt" 2>&1; then
  for feature in goals hooks plugins browser_use in_app_browser computer_use remote_control; do
    grep -E "^${feature}[[:space:]]" "$OUT_ROOT/features.txt" | tee -a "$OUT_ROOT/feature-summary.txt" || true
  done
  if awk '$1 == "remote_control" && $NF == "true" { found=1 } END { exit found ? 0 : 1 }' "$OUT_ROOT/features.txt"; then
    warn "remote_control is enabled; keep it smoke-only unless you intentionally set up remote access"
  else
    pass "remote_control is not enabled by default"
  fi
else
  fail "codex features list failed"
fi

section "remote-control command smoke"
if codex remote-control --help > "$OUT_ROOT/remote-control-help.txt" 2>&1; then
  pass "codex remote-control --help works without starting a daemon"
else
  fail "codex remote-control --help failed"
fi
if ps -axo command | grep -E '[c]odex remote-control' > "$OUT_ROOT/remote-control-processes.txt" 2>&1; then
  fail "codex remote-control process is running; this readiness check should not start or require a daemon"
else
  pass "no codex remote-control process is running"
fi

section "Host availability"
if pgrep -fl 'Codex(\.app|$)|/Applications/Codex\.app' > "$OUT_ROOT/codex-processes.txt" 2>&1; then
  pass "Codex app/process is running"
  cat "$OUT_ROOT/codex-processes.txt" | sed -n '1,12p' | tee -a "$OUT_ROOT/remote-readiness.log"
else
  warn "Codex app process not detected; mobile/remote host access requires the Codex app host to stay running"
fi

if command -v pmset >/dev/null 2>&1; then
  pmset -g custom > "$OUT_ROOT/pmset-custom.txt" 2>&1 || true
  pmset -g assertions > "$OUT_ROOT/pmset-assertions.txt" 2>&1 || true
  if awk '/ sleep[[:space:]]+[1-9][0-9]*/ { found=1 } END { exit found ? 0 : 1 }' "$OUT_ROOT/pmset-custom.txt"; then
    warn "Mac sleep timer appears non-zero; remote Codex sessions stop if the host sleeps"
  else
    pass "Mac sleep timer did not show an obvious non-zero sleep setting"
  fi
else
  warn "pmset unavailable; cannot inspect Mac sleep posture"
fi

section "Network exposure check"
if command -v lsof >/dev/null 2>&1; then
  if lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null | grep -i 'codex' > "$OUT_ROOT/codex-listeners.txt"; then
    warn "Codex-related TCP listeners found; verify they are localhost-only or behind SSH/VPN"
    cat "$OUT_ROOT/codex-listeners.txt" | tee -a "$OUT_ROOT/remote-readiness.log"
  else
    pass "no obvious Codex TCP listener found"
  fi
else
  warn "lsof unavailable; cannot inspect listeners"
fi

section "SSH host aliases"
SSH_CONFIG="$HOME/.ssh/config"
if [[ -f "$SSH_CONFIG" ]]; then
  awk 'tolower($1)=="host" { for (i=2; i<=NF; i++) if ($i !~ /[*?]/) print $i }' "$SSH_CONFIG" | sort -u > "$OUT_ROOT/ssh-host-aliases.txt" || true
  COUNT="$(wc -l < "$OUT_ROOT/ssh-host-aliases.txt" | tr -d ' ')"
  if [[ "$COUNT" -gt 0 ]]; then
    pass "found ${COUNT} concrete SSH host alias(es) for possible remote projects"
  else
    warn "no concrete SSH host aliases found; SSH remote projects require ~/.ssh/config aliases"
  fi
else
  warn "~/.ssh/config not found; SSH remote projects require an SSH config alias"
fi

section "summary"
{
  echo "CODEX_REMOTE_READINESS_STATUS=$STATUS"
  echo "out_root=$OUT_ROOT"
  echo "policy=read-only readiness; no daemon started; no config changed"
} | tee "$OUT_ROOT/summary.txt"
exit "$STATUS"
