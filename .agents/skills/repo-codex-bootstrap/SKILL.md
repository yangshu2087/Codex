---
name: repo-codex-bootstrap
description: Add or refresh repository-level Codex scaffolding such as .codex/config.toml and AGENTS.md. Use when a repo needs lightweight Codex defaults, repo-specific instructions, or a repeatable project bootstrap.
---

# Repo Codex Bootstrap

Use this skill when a repository is missing Codex project scaffolding or its local instructions have drifted.

## Workflow

1. Inspect the repository before writing anything:
   - `git status --short`
   - top-level files and directories
   - existing `.codex/` or `AGENTS.md`
2. Infer the repository purpose from local files, not from the directory name alone.
3. Add the smallest useful project config:
   - usually `approval_policy = "on-request"`
   - usually `sandbox_mode = "workspace-write"`
   - only add extra keys when the repo clearly needs them
4. Write `AGENTS.md` with repo-specific rules:
   - what the repo is for
   - what not to do here
   - how to verify changes in this repo
5. Avoid copying a generic wall of text into every repo. A short, accurate repo guide is better than a long template.
6. After changes, rerun the narrowest relevant verification commands and report the exact files added or updated.

## Team conventions

- Shared team skills live in `/Users/yangshu/Codex/.agents/skills`.
- Project-level instructions should complement ancestor instructions, not restate them verbatim.
- When a rule applies to every repo, prefer the shared ancestor `AGENTS.md`. Use repo `AGENTS.md` only for local specifics.
