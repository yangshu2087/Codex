# Contributing

This repository is the Codex meta workspace. It tracks shared configuration, workspace-level skills, and maintenance scripts.

## Branching

- Keep `main` stable.
- Prefer short-lived branches with the `codex/` prefix.
- Keep each pull request focused on one change area.

## Changes

- Update only workspace-level files in this repository.
- Do not add nested project repositories under `projects/`, `codex-worktree-base/`, or `external/`.
- When modifying skills, prefer trimming or vendoring large third-party assets instead of expanding the always-loaded path.

## Verification

Before opening or merging a pull request:

- run `git status --short`
- review the changed files directly
- run the smallest relevant validation for the change
- summarize any residual risk or skipped verification in the pull request body

## Pull Requests

- Use the pull request template.
- Prefer squash merge for workspace changes.
- Delete merged branches.
