#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AUDIT_SCRIPT="$REPO_ROOT/scripts/skill-audit.sh"
HANDOFF_SCRIPT="$REPO_ROOT/scripts/update-agent-handoff.sh"
HANDOFF_SKILL="$REPO_ROOT/.agents/skills/agent-handoff-governor/SKILL.md"

printf 'Skill smoke started at %s\n' "$(date)"
printf 'Repo root: %s\n\n' "$REPO_ROOT"

for f in "$AUDIT_SCRIPT" "$HANDOFF_SCRIPT" "$REPO_ROOT/scripts/skill-smoke.sh" "$REPO_ROOT/scripts/codex-runtime-health.sh" "$REPO_ROOT/scripts/codex-maint-weekly.sh"; do
  if [[ ! -f "$f" ]]; then
    echo "missing required file: $f" >&2
    exit 1
  fi
  bash -n "$f"
done

echo "[1/4] shell syntax checks passed"

if [[ ! -f "$HANDOFF_SKILL" ]]; then
  echo "missing skill: $HANDOFF_SKILL" >&2
  exit 1
fi

python3 - "$HANDOFF_SKILL" <<'PY'
import sys
from pathlib import Path
p = Path(sys.argv[1])
text = p.read_text(encoding='utf-8')
if not text.startswith('---\n'):
    raise SystemExit(f'invalid frontmatter start: {p}')
if 'name:' not in text.split('---', 2)[1] or 'description:' not in text.split('---', 2)[1]:
    raise SystemExit(f'missing name/description frontmatter: {p}')
print('[2/4] skill frontmatter check passed')
PY

"$AUDIT_SCRIPT" >/tmp/skill-audit.out
if ! grep -q "Skill Audit Report" /tmp/skill-audit.out; then
  echo "skill-audit output missing expected header" >&2
  exit 1
fi
echo "[3/4] skill-audit smoke passed"

tmp_repo="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_repo"
}
trap cleanup EXIT

git -C "$tmp_repo" init -q
echo "# smoke" > "$tmp_repo/README.md"
git -C "$tmp_repo" add README.md
git -C "$tmp_repo" -c user.name='Codex Smoke' -c user.email='codex-smoke@example.com' commit -q -m 'init'

"$HANDOFF_SCRIPT" "$tmp_repo" --verify "echo smoke-ok"

handoff_file="$tmp_repo/docs/agent-handoff.md"
[[ -f "$handoff_file" ]] || { echo "handoff file not created" >&2; exit 1; }
grep -q "## Branch" "$handoff_file"
grep -q "## Changed files" "$handoff_file"
grep -q "## Verification" "$handoff_file"
grep -q "smoke-ok" "$handoff_file"

echo "[4/4] agent handoff refresh smoke passed"
echo ""
echo "All skill smoke checks passed."
