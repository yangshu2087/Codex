#!/usr/bin/env bash
set -euo pipefail

URL="${1:-https://example.com}"
OUT_DIR="${2:-/tmp}"
TS="$(date +%Y%m%d-%H%M%S)"
OUT_FILE="${OUT_DIR%/}/agent-browser-smoke-${TS}.png"

if ! command -v agent-browser >/dev/null 2>&1; then
  cat >&2 <<'MSG'
[FAIL] agent-browser not found in PATH.
Install first:
  npm install -g agent-browser
  agent-browser install
MSG
  exit 127
fi

mkdir -p "$OUT_DIR"

cleanup() {
  # Keep cleanup best-effort so we don't mask the original failure.
  agent-browser close --all >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "[INFO] agent-browser version: $(agent-browser --version)"
echo "[INFO] opening: ${URL}"

agent-browser open "$URL"
TITLE="$(agent-browser get title)"
CURRENT_URL="$(agent-browser get url)"
agent-browser screenshot "$OUT_FILE"

echo "[PASS] smoke check passed"
echo "[INFO] title: ${TITLE}"
echo "[INFO] final_url: ${CURRENT_URL}"
echo "[INFO] screenshot: ${OUT_FILE}"
