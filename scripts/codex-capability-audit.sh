#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="text"
if [[ "${1:-}" == "--json" ]]; then
  MODE="json"
fi

python3 - "$REPO_ROOT" "$MODE" <<'PY'
from __future__ import annotations
import json
import re
import sys
from pathlib import Path
from collections import defaultdict

repo_root = Path(sys.argv[1])
mode = sys.argv[2]
user_config = Path('/Users/yangshu/.codex/config.toml')
user_skills_root = Path('/Users/yangshu/.agents/skills')
disabled_root = Path('/Users/yangshu/.agents/skills-disabled')
project_root = Path('/Users/yangshu/.openclaw/workspace/projects')
skills_lock = repo_root / 'skills-lock.json'
workspace_skills_root = repo_root / '.agents' / 'skills'
quality_lane_smoke = repo_root / 'scripts' / 'codex-quality-lane-smoke.sh'
quality_lanes_doc = repo_root / 'docs' / 'codex-quality-lanes.md'

text = user_config.read_text(encoding='utf-8') if user_config.exists() else ''

TOP_KEYS = {
    'model', 'model_reasoning_effort', 'plan_mode_reasoning_effort', 'review_model',
    'service_tier', 'web_search', 'approval_policy', 'sandbox_mode'
}
PROFILE_KEYS = {
    'model', 'model_reasoning_effort', 'plan_mode_reasoning_effort', 'service_tier',
    'web_search', 'approval_policy', 'sandbox_mode'
}

def strip_quotes(v: str) -> str:
    v = v.strip()
    if len(v) >= 2 and v[0] == v[-1] == '"':
        return v[1:-1]
    return v

section = None
current_profile = None
current_plugin = None
current_mcp = None

top = {}
profiles = defaultdict(dict)
plugins = {}
mcp_servers = []

for raw in text.splitlines():
    line = raw.strip()
    if not line or line.startswith('#'):
        continue
    m = re.match(r'^\[(.+)\]$', line)
    if m:
        inner = m.group(1)
        section = inner
        current_profile = None
        current_plugin = None
        current_mcp = None
        pm = re.match(r'^profiles\.(.+)$', inner)
        if pm:
            current_profile = pm.group(1)
        mm = re.match(r'^mcp_servers\.(.+)$', inner)
        if mm:
            current_mcp = mm.group(1)
            mcp_servers.append(current_mcp)
        pl = re.match(r'^plugins\."(.+)"$', inner)
        if pl:
            current_plugin = pl.group(1)
            plugins.setdefault(current_plugin, {'enabled': None})
        continue

    if '=' not in line:
        continue
    key, value = [x.strip() for x in line.split('=', 1)]
    value = strip_quotes(value)

    if current_profile:
        if key in PROFILE_KEYS:
            profiles[current_profile][key] = value
        continue
    if current_plugin:
        if key == 'enabled':
            plugins[current_plugin]['enabled'] = value
        continue
    if current_mcp:
        continue
    if key in TOP_KEYS:
        top[key] = value

def skill_name_from_dir(p: Path) -> str:
    return p.name

custom_global_dirs = []
symlinked_global = []
if user_skills_root.exists():
    for child in sorted(user_skills_root.iterdir(), key=lambda p: p.name.lower()):
        if child.is_symlink():
            symlinked_global.append({'name': child.name, 'target': str(child.resolve())})
        elif child.is_dir() and (child / 'SKILL.md').exists():
            custom_global_dirs.append(child.name)

workspace_skills = []
if workspace_skills_root.exists():
    for p in sorted(workspace_skills_root.glob('*/SKILL.md')):
        workspace_skills.append(p.parent.name)

project_local = []
if project_root.exists():
    for p in sorted(project_root.glob('*/.agents/skills/*/SKILL.md')):
        project_local.append({
            'project': p.parents[3].name,
            'skill': p.parent.name,
            'path': str(p.parent),
        })

disabled_archives = []
if disabled_root.exists():
    for archive in sorted([p for p in disabled_root.iterdir() if p.is_dir()], key=lambda p: p.name):
        skills = [p.name for p in sorted(archive.iterdir(), key=lambda p: p.name.lower()) if p.is_dir()]
        disabled_archives.append({'archive': archive.name, 'skills': skills})

locked_skills = {}
locked_skills_by_layer = defaultdict(dict)
if skills_lock.exists():
    try:
        locked_skills = json.loads(skills_lock.read_text(encoding='utf-8')).get('skills', {})
    except Exception:
        locked_skills = {}

for name, meta in sorted(locked_skills.items()):
    if not isinstance(meta, dict):
        locked_skills_by_layer['unknown'][name] = meta
        continue
    layer = meta.get('installLayer') or ('workspace-vendored-on-demand' if meta.get('sourceType') in {'github', 'github-vendored-subset'} else 'unknown')
    locked_skills_by_layer[str(layer)][name] = meta

vendored = {
    name: meta
    for name, meta in locked_skills.items()
    if isinstance(meta, dict)
    and (meta.get('installLayer') == 'workspace-vendored-on-demand' or meta.get('defaultEnabled') is False)
}

normalized_plugins = defaultdict(list)
for name in plugins:
    normalized_plugins[re.sub(r'[^a-z0-9]', '', name.lower())].append(name)
plugin_alias_collisions = [names for names in normalized_plugins.values() if len(names) > 1]

suggestions = []
if top.get('model_reasoning_effort') == 'xhigh':
    suggestions.append('Review top-level default reasoning: xhigh is heavy for everyday use; consider high as the default and keep xhigh in deep only.')
if len(custom_global_dirs) > 4:
    suggestions.append('Global custom skill dirs are growing; migrate project-specific skills back into repo-local .agents/skills.')
if plugin_alias_collisions:
    suggestions.append('Review plugin alias duplication: ' + '; '.join(', '.join(group) for group in plugin_alias_collisions))
if disabled_archives:
    suggestions.append('Disabled archives exist; periodically decide whether to restore, migrate, or delete archived skills.')
if vendored:
    suggestions.append('Keep vendored skills opt-in only; do not silently promote them into the default routing layer.')
if not quality_lane_smoke.exists():
    suggestions.append('Quality lane smoke script is missing; add scripts/codex-quality-lane-smoke.sh to keep hooks/templates/skills verifiable.')
if not quality_lanes_doc.exists():
    suggestions.append('Quality lane governance doc is missing; add docs/codex-quality-lanes.md.')
if not suggestions:
    suggestions.append('Capability surface looks reasonably bounded; keep auditing before adding new default behavior.')

report = {
    'repo_root': str(repo_root),
    'top_level_defaults': top,
    'profiles': dict(profiles),
    'mcp_servers': mcp_servers,
    'enabled_plugins': sorted([k for k, v in plugins.items() if str(v.get('enabled', '')).lower() == 'true']),
    'custom_global_skill_dirs': custom_global_dirs,
    'symlinked_global_skills': symlinked_global,
    'workspace_skills': workspace_skills,
    'quality_lane_smoke': str(quality_lane_smoke),
    'quality_lanes_doc': str(quality_lanes_doc),
    'quality_lane_smoke_present': quality_lane_smoke.exists(),
    'quality_lanes_doc_present': quality_lanes_doc.exists(),
    'project_local_skills': project_local,
    'disabled_archives': disabled_archives,
    'locked_skills': locked_skills,
    'locked_skills_by_layer': dict(locked_skills_by_layer),
    'vendored_skills': vendored,
    'suggestions': suggestions,
}

if mode == 'json':
    print(json.dumps(report, ensure_ascii=False, indent=2))
    raise SystemExit(0)

print('Codex Capability Audit')
print('======================')
print(f'Repo root:              {repo_root}')
print(f'User config:            {user_config}')
print('')
print('Top-level defaults:')
for key in ['model', 'model_reasoning_effort', 'plan_mode_reasoning_effort', 'review_model', 'service_tier', 'web_search', 'approval_policy', 'sandbox_mode']:
    print(f'- {key}: {top.get(key, "<unset>")}')

print('\nProfiles:')
for name in ['quick', 'fast', 'deep', 'research', 'codex53', 'safe']:
    data = profiles.get(name)
    if not data:
        continue
    summary = ', '.join(f'{k}={data[k]}' for k in ['model', 'model_reasoning_effort', 'service_tier', 'web_search'] if k in data)
    print(f'- {name}: {summary}')

print('\nEnabled MCP servers:')
for name in mcp_servers:
    print(f'- {name}')

print('\nEnabled plugins:')
for name in report['enabled_plugins']:
    print(f'- {name}')

print('\nGlobal custom skill dirs:')
if custom_global_dirs:
    for name in custom_global_dirs:
        print(f'- {name}')
else:
    print('- (none)')

print('\nGlobal symlinked skills:')
if symlinked_global:
    for item in symlinked_global:
        print(f"- {item['name']} -> {item['target']}")
else:
    print('- (none)')

print('\nWorkspace skills:')
for name in workspace_skills:
    print(f'- {name}')

print('\nQuality lane governance:')
print(f"- doc: {quality_lanes_doc} ({'present' if quality_lanes_doc.exists() else 'missing'})")
print(f"- smoke: {quality_lane_smoke} ({'present' if quality_lane_smoke.exists() else 'missing'})")

print('\nProject-local skills:')
if project_local:
    by_project = defaultdict(list)
    for item in project_local:
        by_project[item['project']].append(item['skill'])
    for project, names in sorted(by_project.items()):
        print(f"- {project}: {', '.join(names)}")
else:
    print('- (none found)')

print('\nDisabled archives:')
if disabled_archives:
    for archive in disabled_archives:
        print(f"- {archive['archive']}: {', '.join(archive['skills']) if archive['skills'] else '(empty)'}")
else:
    print('- (none)')

print('\nLocked skills by layer:')
if locked_skills_by_layer:
    for layer, items in sorted(locked_skills_by_layer.items()):
        print(f'- {layer}:')
        for name, meta in sorted(items.items()):
            if isinstance(meta, dict):
                enabled = meta.get('defaultEnabled')
                suffix = '' if enabled is None else f" defaultEnabled={enabled}"
                print(f"  - {name}: {meta.get('source')}{suffix}")
            else:
                print(f"  - {name}")
else:
    print('- (none)')

print('\nVendored/on-demand skills:')
if vendored:
    for name, meta in sorted(vendored.items()):
        print(f"- {name}: {meta.get('source')}")
else:
    print('- (none)')

print('\nGovernance suggestions:')
for s in suggestions:
    print(f'- {s}')
PY
