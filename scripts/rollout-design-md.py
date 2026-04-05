#!/usr/bin/env python3
from __future__ import annotations
from pathlib import Path
from datetime import datetime

ROOT = Path('/Users/yangshu/Codex')
OPENCLAW_PROJECTS_ROOT = Path('/Users/yangshu/.openclaw/workspace/projects')

# Some active local projects are not initialized as git repositories yet but
# should still inherit the same DESIGN.md workflow files.
NON_GIT_PROJECTS = [
    Path('/Users/yangshu/.openclaw/workspace/projects/019-SkillTrust'),
]

ROOT_DESIGN_TEMPLATE = """# DESIGN.md

> Design contract for AI-assisted front-end implementation.

## 1) Visual Theme & Atmosphere

- Product mood: {{MOOD}}
- Density: {{DENSITY}}
- Tone: {{TONE}}
- Brand personality keywords: {{KEYWORDS}}

## 2) Color Palette & Roles

| Token | Value | Role |
|---|---|---|
| `--color-bg-page` | `{{BG_PAGE}}` | page background |
| `--color-bg-surface` | `{{BG_SURFACE}}` | cards/panels |
| `--color-text-primary` | `{{TEXT_PRIMARY}}` | primary text |
| `--color-text-secondary` | `{{TEXT_SECONDARY}}` | secondary text |
| `--color-border` | `{{BORDER}}` | default border |
| `--color-brand` | `{{BRAND}}` | primary CTA/accent |
| `--color-success` | `{{SUCCESS}}` | success state |
| `--color-warning` | `{{WARNING}}` | warning state |
| `--color-danger` | `{{DANGER}}` | error/destructive |

## 3) Typography Rules

- Heading font: {{HEADING_FONT}}
- Body font: {{BODY_FONT}}
- Mono font: {{MONO_FONT}}
- Scale: {{TYPE_SCALE}}
- Weight policy: {{WEIGHT_POLICY}}

## 4) Component Stylings

- Buttons: {{BUTTON_RULES}}
- Inputs/forms: {{INPUT_RULES}}
- Cards/panels: {{CARD_RULES}}
- Navigation: {{NAV_RULES}}
- Data tables/lists: {{TABLE_RULES}}

## 5) Layout Principles

- Spacing scale: {{SPACING_SCALE}}
- Container/grid: {{GRID_RULES}}
- Radius policy: {{RADIUS_RULES}}
- Whitespace philosophy: {{WHITESPACE_RULES}}

## 6) Depth & Elevation

- Border/shadow system: {{DEPTH_RULES}}
- Focus treatment: {{FOCUS_RULES}}

## 7) Do's and Don'ts

### Do
- Reuse tokens/components before adding one-off values.
- Keep loading, empty, error, hover, focus-visible, and disabled states complete.
- Keep responsive behavior explicit.

### Don't
- Don't copy brand palettes/typography from third-party websites without product decision.
- Don't ship visual changes that were never verified in a browser.
- Don't introduce inconsistent spacing/typography “exceptions” without documenting why.

## 8) Responsive Behavior

- Required checks: 375 / 768 / 1024 / 1440 widths
- Collapse strategy: {{RESPONSIVE_RULES}}

## 9) Agent Prompt Guide

Use this for implementation prompts:

- "Read `DESIGN.md` first, then implement this UI with tokenized values and complete states (loading/empty/error/hover/focus/disabled)."
- "Before completion, verify in browser at 375/768/1024/1440 and summarize visual gaps."

## 10) Project-specific constraints

- Framework/UI stack: {{STACK}}
- Accessibility baseline: semantic HTML + keyboard nav + visible focus + acceptable contrast
- Verification baseline: run the narrowest lint/test/build + browser validation for UI changes

---

Last updated: {{DATE}}
"""

WEB_DESIGN_TEMPLATE = """# DESIGN.md (Web)

> Web UI design contract for agent-driven implementation.

## Visual direction

- Feel: trustworthy, product-grade, readable
- Avoid: random style drift, one-off values, unverified visual changes

## Tokens and components

- Prefer existing theme variables, Tailwind/shadcn tokens, and shared components.
- Add new tokens/components only when reuse is impossible.

## Required UI states

- loading
- empty
- error
- hover
- focus-visible
- active/disabled where relevant

## Responsive baseline

- Verify at 375 / 768 / 1024 / 1440
- Avoid accidental horizontal scrolling
- Keep CTA placement and information hierarchy stable

## Accessibility baseline

- semantic structure first
- keyboard reachability
- visible focus states
- acceptable contrast for content and controls

## Agent workflow

1. Read this file and the repo root `DESIGN.md`
2. Implement with existing tokens/components
3. Run narrow code checks
4. Run browser visual checks
5. Summarize what is verified and what remains unverified

---

Last updated: {{DATE}}
"""

UI_CHECKLIST = """# UI Acceptance Checklist

Use this checklist before marking a front-end task complete.

## Design inputs

- [ ] Read repo `DESIGN.md`
- [ ] Read web `DESIGN.md`
- [ ] Reviewed existing tokens/components before introducing new values

## Visual quality

- [ ] Typography hierarchy is clear
- [ ] Spacing and alignment are consistent
- [ ] No clipping or unexpected overflow

## States

- [ ] loading
- [ ] empty
- [ ] error
- [ ] hover
- [ ] focus-visible
- [ ] disabled (where relevant)

## Responsive

- [ ] 375
- [ ] 768
- [ ] 1024
- [ ] 1440

## Accessibility

- [ ] semantic HTML
- [ ] keyboard navigation
- [ ] visible focus
- [ ] acceptable contrast

## Verification

- [ ] browser verification run
- [ ] console errors checked
- [ ] remaining visual gaps documented
"""

AGENTS_BLOCK = """
## DESIGN.md workflow

- Keep repository-level `DESIGN.md` as the source of truth for look-and-feel constraints used by AI agents.
- For front-end tasks, read `DESIGN.md` before implementation and follow its token, component, state, and responsive rules.
- If the repo has a web app (for example `web/` or `apps/web/`), also read that web app's `DESIGN.md` and `docs/ui-acceptance-checklist.md`.
- Do not clone third-party brand styles directly from public references; adapt with project-approved tokens and product intent.
- Before finalizing UI work, run narrow code checks and at least one browser visual verification pass.
""".strip()

CURSOR_BULLET = "- For front-end work, read repository `DESIGN.md` (and web `DESIGN.md` when present) before implementation."

DEFAULT_AGENTS = """# Repository Guide

## Working rules

- Prefer small, verifiable changes.
- Use short-lived branches for meaningful changes.
- Check `git status --short` before and after edits.

## Verification

- Run the smallest relevant checks for the files you changed.
"""


def is_git_repo(path: Path) -> bool:
    return (path / '.git').exists()


def discover_git_repos() -> list[Path]:
    repos: list[Path] = []

    # Meta workspace repo itself.
    if is_git_repo(ROOT):
        repos.append(ROOT)

    # Known local workspace repo locations.
    for candidate in [ROOT / 'codex-worktree-base']:
        if is_git_repo(candidate):
            repos.append(candidate)

    for parent in [ROOT / 'projects', OPENCLAW_PROJECTS_ROOT]:
        if not parent.exists():
            continue
        for child in sorted(parent.iterdir()):
            if child.is_dir() and is_git_repo(child):
                repos.append(child)

    # Dedupe while preserving order.
    seen: set[Path] = set()
    ordered: list[Path] = []
    for repo in repos:
        if repo not in seen:
            ordered.append(repo)
            seen.add(repo)
    return ordered


def ensure_file(path: Path, content: str):
    if not path.exists():
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)


def ensure_agents(path: Path):
    if not path.exists():
        path.write_text(DEFAULT_AGENTS + "\n\n" + AGENTS_BLOCK + "\n")
        return
    text = path.read_text()
    if "## DESIGN.md workflow" not in text:
        if not text.endswith("\n"):
            text += "\n"
        text += "\n" + AGENTS_BLOCK + "\n"
        path.write_text(text)


def ensure_cursor_rule(path: Path):
    if not path.exists():
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text("""---
description: Shared Codex/Cursor workflow with DESIGN.md-first UI guidance.
alwaysApply: true
---

- Read `AGENTS.md` before substantial changes.
- If `docs/agent-handoff.md` exists, read it before continuing previous work.
- Start with: `git branch --show-current`, `git status --short`, `git diff --stat`.
- Keep meaningful changes on short-lived branches and route via PR.
- Do not let multiple agents edit one dirty working tree in parallel.
""" + "\n" + CURSOR_BULLET + "\n")
        return
    text = path.read_text()
    if CURSOR_BULLET not in text:
        if not text.endswith("\n"):
            text += "\n"
        text += CURSOR_BULLET + "\n"
        path.write_text(text)


def render(template: str) -> str:
    return template.replace("{{DATE}}", datetime.now().strftime("%Y-%m-%d")) \
        .replace("{{MOOD}}", "pragmatic, trustworthy, product-focused") \
        .replace("{{DENSITY}}", "medium") \
        .replace("{{TONE}}", "clear, calm, technical") \
        .replace("{{KEYWORDS}}", "clarity, consistency, reliability") \
        .replace("{{BG_PAGE}}", "#0b1020") \
        .replace("{{BG_SURFACE}}", "#11172a") \
        .replace("{{TEXT_PRIMARY}}", "#f8fafc") \
        .replace("{{TEXT_SECONDARY}}", "#cbd5e1") \
        .replace("{{BORDER}}", "#263247") \
        .replace("{{BRAND}}", "#4f46e5") \
        .replace("{{SUCCESS}}", "#22c55e") \
        .replace("{{WARNING}}", "#f59e0b") \
        .replace("{{DANGER}}", "#ef4444") \
        .replace("{{HEADING_FONT}}", "project standard sans") \
        .replace("{{BODY_FONT}}", "project standard sans") \
        .replace("{{MONO_FONT}}", "project standard mono") \
        .replace("{{TYPE_SCALE}}", "12/14/16/18/20/24/30") \
        .replace("{{WEIGHT_POLICY}}", "400 body, 500 UI, 600 headings") \
        .replace("{{BUTTON_RULES}}", "consistent radius + token colors + clear focus states") \
        .replace("{{INPUT_RULES}}", "tokenized borders/backgrounds, explicit error/help states") \
        .replace("{{CARD_RULES}}", "tokenized surfaces, borders/shadows, predictable spacing") \
        .replace("{{NAV_RULES}}", "clear active state, keyboard friendly, responsive collapse") \
        .replace("{{TABLE_RULES}}", "readable row density, clear alignment, stable headers") \
        .replace("{{SPACING_SCALE}}", "4/8-based") \
        .replace("{{GRID_RULES}}", "container + responsive columns, avoid accidental overflow") \
        .replace("{{RADIUS_RULES}}", "small set of radius tokens only") \
        .replace("{{WHITESPACE_RULES}}", "favor readability and stable hierarchy") \
        .replace("{{DEPTH_RULES}}", "use tokenized border/shadow layers, avoid arbitrary shadows") \
        .replace("{{FOCUS_RULES}}", "visible focus ring and keyboard-visible states") \
        .replace("{{RESPONSIVE_RULES}}", "stack and collapse without losing action hierarchy") \
        .replace("{{STACK}}", "document each project stack in this section")


def apply_repo(repo: Path, require_git: bool = True):
    if require_git and not is_git_repo(repo):
        return

    ensure_file(repo / 'DESIGN.md', render(ROOT_DESIGN_TEMPLATE))
    ensure_agents(repo / 'AGENTS.md')
    ensure_cursor_rule(repo / '.cursor' / 'rules' / 'agent-workflow.mdc')

    # likely front-end roots
    web_roots = []
    for cand in [repo, repo / 'web', repo / 'apps' / 'web']:
        if (cand / 'package.json').exists() and ((cand / 'src').exists() or (cand / 'app').exists()):
            web_roots.append(cand)

    for web_root in web_roots:
        ensure_file(web_root / 'DESIGN.md', render(WEB_DESIGN_TEMPLATE))
        ensure_file(web_root / 'docs' / 'ui-acceptance-checklist.md', UI_CHECKLIST)
        ensure_agents(web_root / 'AGENTS.md')


def main():
    for repo in discover_git_repos():
        apply_repo(repo, require_git=True)
    for project in NON_GIT_PROJECTS:
        apply_repo(project, require_git=False)

if __name__ == '__main__':
    main()
