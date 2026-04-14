#!/usr/bin/env bash
set -euo pipefail

SKILLS_ROOT="${SKILLS_ROOT:-$HOME/.agents/skills}"
DISABLED_ROOT="${DISABLED_ROOT:-$HOME/.agents/skills-disabled}"
WORKSPACE_SKILLS_ROOT="${WORKSPACE_SKILLS_ROOT:-/Users/yangshu/Codex/.agents/skills}"

if [[ ! -d "$SKILLS_ROOT" ]]; then
  echo "error: skills root not found: $SKILLS_ROOT" >&2
  exit 1
fi

python3 - "$SKILLS_ROOT" "$DISABLED_ROOT" "$WORKSPACE_SKILLS_ROOT" <<'PY'
from __future__ import annotations
import json
import re
import sys
from pathlib import Path

skills_root = Path(sys.argv[1]).expanduser()
disabled_root = Path(sys.argv[2]).expanduser()
workspace_root = Path(sys.argv[3]).expanduser()


def extract_frontmatter(skill_md: Path) -> dict:
    text = skill_md.read_text(encoding="utf-8")
    lines = text.splitlines()
    out = {"name": "", "description": ""}
    if len(lines) < 3 or lines[0].strip() != "---":
        return out
    i = 1
    while i < len(lines):
        line = lines[i].strip()
        i += 1
        if line == "---":
            break
        if ":" not in line:
            continue
        k, v = line.split(":", 1)
        k = k.strip()
        v = v.strip().strip('"').strip("'")
        if k in out:
            out[k] = v
    return out


def classify(name: str, description: str, has_openclaw_path: bool) -> str:
    lower = name.lower()
    if lower.startswith("007-"):
        return "migrate-to-project"
    if lower.startswith("openclaw-") or has_openclaw_path:
        return "migrate-to-openclaw-workspace"
    return "keep-global"

active = []
symlinks = []

for child in sorted(skills_root.iterdir(), key=lambda p: p.name.lower()):
    if not child.is_dir() and not child.is_symlink():
        continue
    if child.is_symlink():
        symlinks.append({"name": child.name, "target": str(child.resolve())})
        continue

    skill_md = child / "SKILL.md"
    has_skill = skill_md.exists()
    fm = extract_frontmatter(skill_md) if has_skill else {"name": "", "description": ""}
    desc = fm.get("description", "")
    has_openclaw_path = ".openclaw/workspace" in desc
    active.append(
        {
            "name": child.name,
            "path": str(child),
            "has_skill_md": has_skill,
            "frontmatter_name": fm.get("name", ""),
            "description_starts_with_use_when": desc.startswith("Use when"),
            "contains_openclaw_workspace_path": has_openclaw_path,
            "suggestion": classify(child.name, desc, has_openclaw_path),
        }
    )

workspace_names = set()
if workspace_root.exists():
    for p in workspace_root.iterdir():
        if p.is_dir():
            workspace_names.add(p.name)

for item in active:
    item["name_conflict_with_workspace_skill"] = item["name"] in workspace_names

archives = []
if disabled_root.exists():
    for d in sorted([p for p in disabled_root.iterdir() if p.is_dir()], key=lambda p: p.name):
        names = [x.name for x in sorted(d.iterdir(), key=lambda p: p.name.lower()) if x.is_dir()]
        archives.append({"archive": d.name, "skills": names})

keep = [x["name"] for x in active if x["suggestion"] == "keep-global"]
migrate = [x["name"] for x in active if x["suggestion"].startswith("migrate-")]

print("Skill Audit Report")
print("==================")
print(f"Skills root:        {skills_root}")
print(f"Disabled root:      {disabled_root}")
print(f"Workspace skills:   {workspace_root}")
print("")
print(f"Active custom dirs: {len(active)}")
print(f"Symlinked skills:   {len(symlinks)}")
print("")

if active:
    print("Active custom skill checks:")
    for item in active:
        checks = []
        checks.append("SKILL.md" if item["has_skill_md"] else "MISSING-SKILL.md")
        checks.append("desc:Use when" if item["description_starts_with_use_when"] else "desc:needs-trigger-phrase")
        if item["name_conflict_with_workspace_skill"]:
            checks.append("name-conflict-workspace")
        print(f"- {item['name']}: {', '.join(checks)} -> {item['suggestion']}")
    print("")

if symlinks:
    print("Symlinked skills (kept as-is):")
    for s in symlinks:
        print(f"- {s['name']} -> {s['target']}")
    print("")

print("Suggested split:")
print(f"- keep-global: {', '.join(keep) if keep else '(none)'}")
print(f"- migrate:     {', '.join(migrate) if migrate else '(none)'}")
print("")

if archives:
    print("Disabled archives:")
    for ar in archives:
        print(f"- {ar['archive']}: {', '.join(ar['skills']) if ar['skills'] else '(empty)'}")
else:
    print("Disabled archives: (none)")

print("\nJSON summary:")
print(json.dumps({
    "skills_root": str(skills_root),
    "disabled_root": str(disabled_root),
    "active_custom": active,
    "symlinked": symlinks,
    "archives": archives,
}, ensure_ascii=False, indent=2))
PY
