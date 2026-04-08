#!/usr/bin/env bash
set -euo pipefail

LOAD_RAW="$(uptime)"
LOAD_1M="$(python3 - <<'PY'
import re,subprocess
s=subprocess.check_output(['uptime'], text=True)
m=re.search(r'load averages?:\s*([0-9]+\.?[0-9]*)', s)
print(m.group(1) if m else '0')
PY
)"

SWAP_USED_MIB="$(python3 - <<'PY'
import re,subprocess
s=subprocess.check_output(['sysctl','vm.swapusage'], text=True)
m=re.search(r'used\s*=\s*([0-9.]+)([MG])', s)
if not m:
    print('0')
else:
    n=float(m.group(1)); u=m.group(2)
    if u == 'G':
        n *= 1024
    print(f'{n:.2f}')
PY
)"

STATUS="normal"
if python3 - <<PY
load=float('${LOAD_1M}')
swap=float('${SWAP_USED_MIB}')
raise SystemExit(0 if (load > 8.0 or swap > 2048.0) else 1)
PY
then
  STATUS="high-pressure"
fi

echo "Codex Runtime Health"
echo "===================="
printf 'Timestamp:            %s\n' "$(date)"
printf 'Host load (1m):       %s\n' "$LOAD_1M"
printf 'Swap used (MiB):      %s\n' "$SWAP_USED_MIB"
printf 'Current directory:    %s\n' "$PWD"
printf 'Codex CLI:            %s\n' "$(codex --version 2>/dev/null || echo unavailable)"
printf 'Codex path:           %s\n' "$(command -v codex 2>/dev/null || echo unavailable)"

echo ""
echo "Uptime snapshot:"
echo "$LOAD_RAW"

echo ""
echo "Top CPU processes:"
ps -Ao pid,pcpu,pmem,etime,command -r \
  | awk '
      NR==1 { print; next }
      {
        line=$0
        if (length(line) > 220) line=substr(line,1,220) "..."
        print line
        if (NR >= 16) exit
      }
    '

echo ""
echo "Codex/OpenClaw process snapshot:"
ps -Ao pid,pcpu,pmem,etime,command \
  | grep -Ei 'Codex\.app|/Resources/codex|openclaw|\.openclaw/' \
  | grep -v grep \
  | awk '
      {
        line=$0
        if (length(line) > 260) line=substr(line,1,260) "..."
        print line
        if (NR >= 40) exit
      }
    ' || true

echo ""
echo "Suggested mode:"
if [[ "$STATUS" == "high-pressure" ]]; then
  echo "- System pressure is high (load>8 or swap>2GB)."
  echo "- Use single-agent workflow temporarily."
  echo "- Prefer: codex --profile quick"
  echo "- Defer heavy OpenClaw gateway fanout or multi-agent jobs."
else
  echo "- System pressure is acceptable."
  echo "- Daily default: gpt-5.4/high"
  echo "- Parallel subagents: up to 4"
fi
