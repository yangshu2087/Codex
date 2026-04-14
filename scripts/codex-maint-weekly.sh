#!/usr/bin/env bash
set -euo pipefail

SCRIPTS_DIR="/Users/yangshu/Codex/scripts"
RUN_BROWSER_SMOKE=1
RUN_QUALITY_REGRESSION=0
RUN_SESSION_ARCHIVE_PLAN=0

usage() {
  cat <<'USAGE'
Usage: codex-maint-weekly.sh [--skip-browser] [--session-archive-plan] [--with-quality-regression]

Default behavior is audit-first and lightweight:
  - version/stable-channel check
  - release highlights
  - runtime pressure
  - session/sqlite footprint
  - one browser smoke unless --skip-browser is passed
  - suggested actions only; no deletion

Optional:
  --with-quality-regression  Run the full Codex quality regression suite at the end.
  --session-archive-plan     Generate a dry-run large-session archive plan at the end.
  --skip-browser             Skip the lightweight weekly browser smoke.
USAGE
}

for arg in "$@"; do
  case "$arg" in
    --skip-browser)
      RUN_BROWSER_SMOKE=0
      ;;
    --with-quality-regression)
      RUN_QUALITY_REGRESSION=1
      ;;
    --session-archive-plan)
      RUN_SESSION_ARCHIVE_PLAN=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      usage >&2
      exit 2
      ;;
  esac
done

echo "Codex Weekly Maintenance Audit (read-only)"
echo "=========================================="
printf 'Timestamp: %s\n' "$(date)"
printf 'Host:      %s\n' "$(hostname)"
printf 'PWD:       %s\n' "$PWD"
echo ""

echo "[1/8] Stable channel and installed version"
echo "------------------------------------------"
"$SCRIPTS_DIR/check-codex-upgrade.sh" || true

echo ""
echo "[2/8] Release highlights snapshot (stable + alpha)"
echo "---------------------------------------------------"
python3 - <<'PY'
import json, urllib.request

with urllib.request.urlopen('https://api.github.com/repos/openai/codex/releases/latest', timeout=20) as r:
    stable=json.load(r)
with urllib.request.urlopen('https://api.github.com/repos/openai/codex/releases?per_page=30', timeout=20) as r:
    rels=json.load(r)
alpha=next((r for r in rels if r.get('prerelease')), None)

print('Latest stable:', stable.get('tag_name') if stable else 'n/a', stable.get('published_at') if stable else '')
print('Latest alpha: ', alpha.get('tag_name') if alpha else 'n/a', alpha.get('published_at') if alpha else '')

if stable:
    body=stable.get('body') or ''
    lines=[ln.strip() for ln in body.splitlines() if ln.strip()]
    print('\nStable highlights (from GitHub release body):')
    shown=0
    in_focus=False
    for ln in lines:
        if ln.startswith('## New Features') or ln.startswith('## Bug Fixes'):
            in_focus=True
            print(ln)
            continue
        if ln.startswith('## ') and in_focus:
            break
        if in_focus and ln.startswith('- '):
            print(' ', ln)
            shown += 1
            if shown >= 8:
                break
    if shown == 0:
        print('  (No structured highlights found in body.)')

print('\nReference changelog URL: https://developers.openai.com/codex/changelog')
PY

echo ""
echo "[3/8] Runtime pressure and process health"
echo "-----------------------------------------"
"$SCRIPTS_DIR/codex-runtime-health.sh" || true
echo ""
echo "Guard decision (single source):"
"$SCRIPTS_DIR/codex-runtime-health.sh" --decision-only || true

echo ""
echo "[4/8] Session + SQLite footprint audit"
echo "---------------------------------------"
python3 - <<'PY'
from pathlib import Path
import subprocess

home=Path('/Users/yangshu/.codex')
sessions=home/'sessions'

du_line = subprocess.check_output(['du', '-sh', str(home)], text=True).strip()
print('~/.codex footprint:', du_line)

if sessions.exists():
    files=[]
    for p in sessions.rglob('*'):
        if p.is_file():
            files.append((p.stat().st_size,p))
    total=sum(s for s,_ in files)
    print(f'Sessions total: {total/1024/1024:.1f} MiB ({len(files)} files)')
    print('Largest session files:')
    for size,p in sorted(files, reverse=True)[:8]:
        print(f'  - {size/1024/1024:.1f} MiB  {p}')
else:
    print('Sessions directory not found.')

sqlite_files=[]
for patt in ('logs_*.sqlite','state_*.sqlite'):
    sqlite_files.extend(home.glob(patt))
print('\nSQLite files:')
if sqlite_files:
    for p in sorted(sqlite_files):
        print(f'  - {p.name}: {p.stat().st_size/1024/1024:.1f} MiB')
else:
    print('  (none found)')
PY

echo ""
echo "[5/8] Browser tool smoke"
echo "-------------------------"
if [[ "$RUN_BROWSER_SMOKE" -eq 1 ]]; then
  "$SCRIPTS_DIR/agent-browser-smoke.sh" "https://example.com" "/tmp" || true
else
  echo "Skipped (use without --skip-browser to run)."
fi

echo ""
echo "[6/8] Suggested actions (no deletion performed)"
echo "-----------------------------------------------"
python3 - <<'PY'
import re, subprocess
from pathlib import Path

load_out=subprocess.check_output(['uptime'], text=True)
load=float(re.search(r'load averages?:\s*([0-9]+\.?[0-9]*)', load_out).group(1))
swap_out=subprocess.check_output(['sysctl','vm.swapusage'], text=True)
m=re.search(r'used\s*=\s*([0-9.]+)([MG])', swap_out)
swap_mib=float(m.group(1))*(1024 if m.group(2)=='G' else 1)

sessions=Path('/Users/yangshu/.codex/sessions')
size_mib=0.0
if sessions.exists():
    size_mib=sum(p.stat().st_size for p in sessions.rglob('*') if p.is_file())/1024/1024

print('- This report is audit-only. It does not delete files.')
if load > 8 or swap_mib > 2048:
    print('- High runtime pressure detected: prefer --profile quick and single-agent mode temporarily.')
else:
    print('- Runtime pressure acceptable: keep default gpt-5.4/high and max 4 subagents.')

if size_mib > 2048:
    print('- Sessions exceed 2 GiB: schedule archive/cleanup during low-traffic hours.')
elif size_mib > 1024:
    print('- Sessions exceed 1 GiB: plan archival soon (manual confirmation window).')
else:
    print('- Session footprint is within expected weekly range.')

print('- Stay on stable channel by default; only test alpha in isolated canary windows.')
print('- Re-run this script weekly and log decisions in your maintenance notes.')
PY

echo ""
echo "[7/8] Optional session archive plan"
echo "-----------------------------------"
if [[ "$RUN_SESSION_ARCHIVE_PLAN" -eq 1 ]]; then
  "$SCRIPTS_DIR/codex-session-archive-plan.sh"
else
  echo "Skipped by default. Run with --session-archive-plan to generate a dry-run large-session archive plan."
fi

echo ""
echo "[8/8] Optional full quality regression"
echo "--------------------------------------"
if [[ "$RUN_QUALITY_REGRESSION" -eq 1 ]]; then
  REGRESSION_OUT="${CODEX_REGRESSION_OUT:-/tmp/codex-quality-regression-weekly-$(date +%Y%m%d-%H%M%S)}"
  echo "Running full quality regression. Output: $REGRESSION_OUT"
  CODEX_REGRESSION_OUT="$REGRESSION_OUT" "$SCRIPTS_DIR/codex-quality-regression.sh"
else
  echo "Skipped by default. Run with --with-quality-regression for full version/MCP/skill/quality-lane/browser/profile regression."
fi
