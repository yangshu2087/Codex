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
- Large third-party skills should be mirrored under `/Users/yangshu/Codex/vendor/skills` and activated on demand via `scripts/manage-vendored-skill.sh`.
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
- When running local `/review` or preparing PR review, use `/Users/yangshu/Codex/docs/code_review.md` as the review checklist and cite any deviations explicitly.
- Activate vendored `playwright-best-practices` only when writing or stabilizing Playwright tests beyond basic browser automation.
- Keep `skills-lock.json` in sync with installed or vendored marketplace skills.
- Prefer preparing a safe upgrade plan and verification steps before changing binaries under `/Applications`.
- Keep changes reproducible: if a version check or migration step is useful twice, put it into `scripts/`.
- Keep `/Users/yangshu/Codex/docs/codex-latest-practices-2026-04-14.md` as the local record of the current stable Codex model/config/plugin/skill decisions.
- Keep `/Users/yangshu/Codex/docs/codex-github-skill-watchlist-2026-04-14.md` as the on-demand third-party skill candidate list; do not global-install those candidates without a focused review.
- Use explicit workspace skills for high-stakes lanes when needed: `architecture-decision-review`, `backend-api-contract-review`, and `product-ux-flow-review`.
- Use `/Users/yangshu/Codex/docs/codex-quality-lanes.md` to route requirements, architecture, front-end, backend/API, code review, and research tasks through the correct quality lane.
- For repositories in this workspace, prefer the GitHub flow: create a short-lived branch, run `requesting-code-review`, open a pull request, and merge only after the required review gate is satisfied or intentionally bypassed as the repository admin.
- Treat `CODEOWNERS` as the routing layer for review responsibility. When a repository needs owner-based review, update `CODEOWNERS` rather than relying on chat memory.

## Multi-tool workflow

- GitHub is the system of record for repository history, protected branches, pull requests, and review state.
- Codex is the highest-autonomy tool for repository changes, repo-local verification, and structured code review before or during a PR.
- Cursor is best used for fast interactive editing, local inspection, and smaller in-editor iterations; keep its changes inside feature branches that still flow through GitHub review.
- OpenClaw is operating as a local multi-agent gateway and fallback orchestrator. Use it for cross-provider routing and automation, not as a replacement for GitHub branch policy or repository truth.
- Keep one source of truth for each layer:
  - repository policy: GitHub settings and checked-in `.github/` files
  - Codex behavior: `~/.codex/` plus repo `.codex/` and `AGENTS.md`
  - Cursor behavior: local Cursor settings and project state
  - OpenClaw orchestration: `~/.openclaw/openclaw.json` and its workspace

## Stitch / AI Studio / Codex workflow

- Use Google Stitch for design intent and UI exploration first, not for production-ready repository structure.
- Store Stitch prompts, screenshots, and exports inside the target repository under `design/stitch/` so Codex and Cursor can inspect the exact source artifact instead of relying on chat memory.
- Use Google AI Studio for runnable prototype generation second, and keep generated app exports, prompt notes, and integration caveats under `prototypes/ai-studio/`.
- Use Codex third to turn the exported prototype into repository-native code: move logic into the real app structure, wire production dependencies, add tests, and align to local `AGENTS.md` and GitHub review rules.
- Do not merge raw Stitch or AI Studio output straight to `main` without an explicit Codex or human cleanup pass.
- When work starts from Stitch or AI Studio, record the artifact paths and intended next step in `docs/agent-handoff.md` before switching tools or opening a PR.

## Codex and Cursor shared protocol

- Treat checked-in repository files as the shared baton between Codex and Cursor. Do not rely on chat memory to transfer state.
- Repository `AGENTS.md` is the shared workflow contract. Keep any repo-level Cursor rule in `.cursor/rules/` aligned with the nearest `AGENTS.md`.
- When a repository has `docs/agent-handoff.md`, update it before pausing, switching tools, or asking another agent to continue.
- Use `/Users/yangshu/Codex/scripts/update-agent-handoff.sh <repo-path>` to refresh `docs/agent-handoff.md` branch, changed-file, and verification sections without overwriting the human summary sections.
- Before taking over existing work in either Codex or Cursor, read:
  - the nearest `AGENTS.md`
  - `docs/agent-handoff.md` when present
  - `git branch --show-current`
  - `git status --short`
  - `git diff --stat`
- If Codex and Cursor need to work in parallel, keep them on separate branches or separate worktrees. Do not let both tools edit the same dirty working tree at once.
- Use GitHub PRs and checked-in `.github/` files as the durable record of what changed, why it changed, and what review gate applies.


## Final response contract

- When finishing workspace maintenance or repository changes, final replies must include:
  - `已完成`: the concrete files, configs, scripts, commits, pushes, or settings changed.
  - `完成证据`: exact verification commands and observed outputs, or browser/screenshot evidence when UI is involved.
  - `还缺什么`: remaining risks, skipped checks, uncommitted files, or `无`.
  - `后续建议`: the next actionable step, or `无，等待你的下一步指令`.
- If a final reply says a task is done but lacks these sections, treat it as incomplete and revise the reply before stopping.

## Verification

- After changing Codex config or skills, verify with `codex --version`, `codex features list`, `codex mcp list`, and `scripts/check-codex-upgrade.sh`.
- If behavior depends on project instructions, confirm Codex is launched from the intended directory so the nearest `AGENTS.md` wins.
