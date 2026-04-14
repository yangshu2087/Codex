#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${1:-text}"
if [[ "$MODE" != "text" && "$MODE" != "--json" ]]; then
  echo "Usage: codex-commit-boundary-plan.sh [--json]" >&2
  exit 2
fi

python3 - "$REPO_ROOT" "$MODE" <<'PY'
from __future__ import annotations
import json
import subprocess
import sys
from collections import OrderedDict
from pathlib import Path

repo = Path(sys.argv[1])
mode = sys.argv[2]

proc = subprocess.run(['git', '-C', str(repo), 'status', '--porcelain=v1'], text=True, stdout=subprocess.PIPE, check=True)
entries = []
for raw in proc.stdout.splitlines():
    if not raw:
        continue
    status = raw[:2]
    path = raw[3:]
    # Basic rename handling. This repo state currently has no renames, but keep output readable.
    if ' -> ' in path:
        path = path.split(' -> ', 1)[1]
    entries.append({'status': status, 'path': path})

def group_for(path: str) -> tuple[str, str]:
    if path.startswith('.agents/skills/opencli-readonly-probe/') or path == 'scripts/opencli-readonly.sh':
        return ('opencli-readonly-eval', 'OpenCLI read-only wrapper/skill draft; keep separate from Codex quality work.')
    if path.startswith('vendor/skills/skilltrust-curated/') or path == 'docs/skilltrust-codex-skill-audit-2026-04-11.md':
        return ('skilltrust-curation-restore', 'SkillTrust curated/vendored-on-demand skill restoration and audit artifacts.')
    if path in {'DESIGN.md', 'docs/awesome-design-md-assessment.md', 'docs/design-reference-shortlist.md'}:
        return ('design-md-restore', 'Design reference and DESIGN.md restoration artifacts.')
    if path in {'docs/codex-quality-regression-scorecard.md', 'docs/codex-task-card-and-acceptance.md'}:
        return ('quality-regression-restore', 'Prior quality regression/task-card documentation restoration.')
    if path in {'docs/worktree-governance.md', 'scripts/worktree-create.sh', 'scripts/worktree-close.sh', 'scripts/worktree-weekly-clean.sh'}:
        return ('worktree-governance-restore', 'Worktree lifecycle governance restoration.')
    if path in {'docs/code_review.md', 'docs/codex-capability-governance.md', 'docs/skills-governance-2026-04-08.md'}:
        return ('capability-governance-restore', 'Capability governance/code review checklist restoration.')
    if path.startswith('.agents/skills/agent-handoff-governor/'):
        return ('handoff-governor-restore', 'Agent handoff governor skill restoration.')
    if path in {'scripts/backup-ai-dev-2t.sh', 'scripts/verify-project-docs-integrity.sh'}:
        return ('backup-integrity-utilities', 'Backup/integrity utilities; review separately before committing.')
    if path in {
        'AGENTS.md',
        'skills-lock.json',
        'docs/codex-capability-registry.md',
        'docs/codex-github-skill-watchlist-2026-04-14.md',
        'docs/codex-latest-practices-2026-04-14.md',
        'docs/codex-quality-lanes.md',
        'scripts/codex-capability-audit.sh',
        'scripts/codex-quality-lane-smoke.sh',
        'scripts/codex-quality-regression.sh',
        'scripts/codex-session-archive-plan.sh',
        'scripts/codex-commit-boundary-plan.sh',
        'docs/codex-commit-boundary-plan-2026-04-14.md',
        'scripts/codex-maint-weekly.sh',
        'scripts/skill-audit.sh',
        'scripts/skill-smoke.sh',
        'scripts/agent-browser-smoke.sh',
        'scripts/codex-run-guarded.sh',
        'scripts/codex-runtime-health.sh',
    } or path.startswith('.agents/skills/architecture-decision-review/') or path.startswith('.agents/skills/backend-api-contract-review/') or path.startswith('.agents/skills/product-ux-flow-review/') or path.startswith('.agents/skills/frontend-design-review/') or path.startswith('.agents/skills/repo-') or path.startswith('.agents/skills/requesting-code-review/') or path.startswith('.agents/skills/systematic-debugging/') or path.startswith('.agents/skills/webpage-capture-markdown/') or path.startswith('.agents/skills/worktree-safety/'):
        return ('codex-quality-capability-upgrade', 'Codex quality lanes, regression, maintenance, and capability audit work from this iteration.')
    return ('needs-manual-review', 'Unclassified path; inspect before staging.')

groups: OrderedDict[str, dict] = OrderedDict()
for entry in entries:
    name, note = group_for(entry['path'])
    groups.setdefault(name, {'note': note, 'files': []})['files'].append(entry)

report = {
    'repo': str(repo),
    'branch': subprocess.run(['git', '-C', str(repo), 'branch', '--show-current'], text=True, stdout=subprocess.PIPE, check=True).stdout.strip(),
    'groups': groups,
}

if mode == '--json':
    print(json.dumps(report, ensure_ascii=False, indent=2))
    raise SystemExit(0)

print('Codex Commit Boundary Plan')
print('==========================')
print(f"Repo:   {report['repo']}")
print(f"Branch: {report['branch']}")
print('Mode:   dry-run; no staging, no commit, no push')
print('')
for idx, (name, data) in enumerate(groups.items(), 1):
    files = data['files']
    print(f'[{idx}] {name}')
    print(f"    Note: {data['note']}")
    print(f'    Files: {len(files)}')
    for item in files:
        print(f"      {item['status']} {item['path']}")
    quoted = ' '.join("'" + item['path'].replace("'", "'\\''") + "'" for item in files)
    print('    Suggested dry-run review:')
    print(f"      git -C '{repo}' diff --stat -- {quoted}")
    print('    Suggested staging command only after manual review:')
    print(f"      git -C '{repo}' add -- {quoted}")
    print('')

if 'needs-manual-review' in groups:
    print('WARNING: Some paths need manual review before staging.')
else:
    print('No unclassified paths detected.')
PY
