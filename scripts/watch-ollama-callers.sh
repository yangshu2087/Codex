#!/usr/bin/env bash
set -euo pipefail
INTERVAL="${1:-0.2}"
DURATION="${2:-0}"
START=$(date +%s)
echo "Watching Ollama callers on TCP 11434. interval=${INTERVAL}s duration=${DURATION}s(0=infinite)"
echo "Tip: run this before triggering a task that may load Ollama. Stop with Ctrl-C."
while true; do
  NOW=$(date '+%Y-%m-%d %H:%M:%S')
  ESTABLISHED=$(lsof -nP -iTCP:11434 -sTCP:ESTABLISHED 2>/dev/null || true)
  if [[ -n "$ESTABLISHED" ]]; then
    echo "=== $NOW ESTABLISHED ==="
    echo "$ESTABLISHED"
    echo "$ESTABLISHED" | awk 'NR>1 {print $2}' | sort -u | while read -r pid; do
      [[ -n "$pid" ]] || continue
      ps -o pid,ppid,etime,pcpu,pmem,rss,args -p "$pid" || true
    done
  fi
  if [[ "$DURATION" != "0" ]]; then
    ELAPSED=$(( $(date +%s) - START ))
    [[ "$ELAPSED" -ge "$DURATION" ]] && exit 0
  fi
  sleep "$INTERVAL"
done
