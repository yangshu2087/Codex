# Codex Meta Workspace

This repository tracks the Codex workspace itself rather than the nested project repositories.

## What belongs here

- workspace-level Codex configuration in `.codex/`
- shared team skills in `.agents/skills/`
- workspace guidance in `AGENTS.md`
- maintenance scripts and operational docs

## What does not belong here

- nested repositories under `projects/`
- the persistent worktree repository under `codex-worktree-base/`
- worktree pointer directories such as `codex-worktree-head/`

Those repositories keep their own Git history and must be managed separately.
