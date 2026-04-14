# Worktree Governance (Permanent Worktrees)

This document defines naming and lifecycle rules for persistent Git worktrees on this machine.

## Goals

- Keep parallel Codex/Cursor/OpenClaw work isolated.
- Avoid branch/path confusion in a multi-repo environment.
- Make create/use/archive/cleanup operations repeatable and auditable.

## Naming standard

### Branch

Use:

`codex/<type>/<repo>/<ticket>-<slug>`

- `type`: `feat | fix | chore | refactor | spike | review | hotfix`
- `repo`: short repository name (for example `007`, `codex-main`)
- `ticket`: issue id or date (for example `LIN-123`, `20260408`)
- `slug`: lowercase kebab-case short description

Examples:

- `codex/feat/007/20260408-seo-cluster-v2`
- `codex/fix/codex-main/20260408-handoff-timezone`

### Worktree path

Use:

`/Users/yangshu/worktrees/<repo>/<ticket>-<slug>`

Examples:

- `/Users/yangshu/worktrees/007/20260408-seo-cluster-v2`
- `/Users/yangshu/worktrees/codex-main/20260408-handoff-timezone`

## Lifecycle

### 1) Create

- Confirm real repo root first (`git rev-parse --show-toplevel`).
- Fetch latest remote refs.
- Create one branch and one worktree per task.

Use:

```bash
/Users/yangshu/Codex/scripts/worktree-create.sh \
  --repo /absolute/repo/path \
  --repo-short 007 \
  --type feat \
  --ticket 20260408 \
  --slug seo-cluster-v2
```

### 2) Use

- One active owner/tool writes to one dirty worktree at a time.
- Before switching tools, refresh handoff:

```bash
/Users/yangshu/Codex/scripts/update-agent-handoff.sh /absolute/repo/path
```

- Keep each worktree scoped to a single task and PR.

### 3) Archive / Close

Close worktree only after merge or explicit force-close decision.

Use:

```bash
/Users/yangshu/Codex/scripts/worktree-close.sh \
  --repo /absolute/repo/path \
  --worktree /Users/yangshu/worktrees/007/20260408-seo-cluster-v2
```

Optional remote branch deletion:

```bash
/Users/yangshu/Codex/scripts/worktree-close.sh \
  --repo /absolute/repo/path \
  --worktree /Users/yangshu/worktrees/007/20260408-seo-cluster-v2 \
  --delete-remote
```

### 4) Weekly cleanup

Run weekly in audit mode first:

```bash
/Users/yangshu/Codex/scripts/worktree-weekly-clean.sh \
  --repo /absolute/repo/path
```

Apply auto-close for stale+merged worktrees:

```bash
/Users/yangshu/Codex/scripts/worktree-weekly-clean.sh \
  --repo /absolute/repo/path \
  --apply --yes
```

## Guardrails

- Do not use ambiguous names like `head`, `base`, `tmp`, `final` for worktree directories.
- Prefer max 3 active task worktrees per repository.
- Always run cleanup in audit mode before `--apply`.
- Do not run project-level Git operations from unrelated meta-workspace roots.
