# Codex Workspace Guide

## Workspace layout

- `/Users/yangshu/Codex` is now a meta-workspace Git repository, but it tracks workspace metadata only.
- Use root-level git commands here only for workspace files such as `.codex/`, `.agents/skills/`, `docs/`, `scripts/`, `README.md`, and `skills-lock.json`.
- Real repositories currently live in `/Users/yangshu/Codex/codex-worktree-base` and `/Users/yangshu/Codex/projects/codex-main`.
- `/Users/yangshu/Codex/codex-worktree-head` and `/Users/yangshu/Codex/projects/codex-head` are worktree/gitdir pointer directories, not normal standalone repos.

## What to edit where

- Personal Codex defaults belong in `~/.codex/config.toml` and `~/.codex/AGENTS.md`.
- Personal custom skills belong in `~/.agents/skills`.
- Team-shared workspace skills belong in `/Users/yangshu/Codex/.agents/skills`.
- Workspace-specific Codex behavior belongs in `/Users/yangshu/Codex/.codex/config.toml` and this file.
- When a task targets one repo, `cd` into that repo before running git status, diff, branch, or test commands.
- Do not treat changes in child repositories as changes to the root workspace repository.
- When you need live web research from this workspace, prefer the global `research` profile instead of forcing `web_search = "live"` at the workspace default layer.

## Codex maintenance workflow

- For local Codex upgrade work, always capture:
  - `codex --version`
  - desktop app version from `/Applications/Codex.app/Contents/Info.plist`
  - official desktop installer version from `https://persistent.oaistatic.com/codex-app-prod/Codex.dmg`
  - npm package latest and alpha tags for `@openai/codex`
  - latest GitHub release for `openai/codex`
- Prefer the custom skill `codex-local-ops` for repeated local Codex audit and upgrade tasks.
- Prefer the team skills `repo-codex-bootstrap` and `worktree-safety` when rolling out Codex files across repositories in this workspace.
- Use the team skill `repo-postcheck-summary` after bootstrap-style repo changes to keep verification narrow and summaries consistent.
- Use the team skill `webpage-capture-markdown` when a webpage should be preserved as a local markdown artifact instead of only summarized in chat.
- Use `systematic-debugging` before proposing fixes for bugs, failures, or unexpected behavior.
- Use `requesting-code-review` before merge or after major implementation work.
- Use `playwright-best-practices` when writing or stabilizing Playwright tests beyond basic browser automation.
- Keep `skills-lock.json` in sync with installed repo-level marketplace skills.
- Prefer preparing a safe upgrade plan and verification steps before changing binaries under `/Applications`.
- Keep changes reproducible: if a version check or migration step is useful twice, put it into `scripts/`.

## Verification

- After changing Codex config or skills, verify with `codex --version`, `codex features list`, `codex mcp list`, and `scripts/check-codex-upgrade.sh`.
- If behavior depends on project instructions, confirm Codex is launched from the intended directory so the nearest `AGENTS.md` wins.
