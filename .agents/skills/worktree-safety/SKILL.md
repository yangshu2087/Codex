---
name: worktree-safety
description: Safely operate in repositories that use Git worktrees or live inside a meta-workspace with multiple repos. Use when a task involves git roots, linked worktrees, pointer directories, or avoiding the wrong repository context.
---

# Worktree Safety

Use this skill when the user task touches Git worktrees, multiple adjacent repositories, or a meta-workspace that is not itself a repo.

## Workflow

1. Identify the real repository before running Git commands:
   - `git rev-parse --show-toplevel`
   - `git worktree list` when relevant
2. Distinguish normal repos from pointer directories and wrapper workspaces.
3. Do not run root-level Git commands from `/Users/yangshu/Codex`; it is a meta-workspace, not a repository.
4. When a linked worktree exists, assume branch and checkout operations can affect another active checkout.
5. If the task is only about Codex config or AGENTS files, edit the intended repo directly and avoid unrelated branch manipulation.
6. Verify with repository-local Git commands after edits.

## Local context

- `/Users/yangshu/Codex/codex-worktree-base` is a real repo that hosts a persistent worktree.
- `/Users/yangshu/Codex/projects/codex-main` is a normal local repo.
- `/Users/yangshu/Codex/projects/codex-head` and `/Users/yangshu/Codex/codex-worktree-head` are worktree-related locations and should not be treated like independent repos without checking first.
