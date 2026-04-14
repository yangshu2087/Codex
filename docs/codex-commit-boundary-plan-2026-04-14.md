# Codex Commit Boundary Plan — 2026-04-14

This document keeps the current `/Users/yangshu/Codex` recovery branch commit history reviewable. It is intentionally a **dry-run plan**: do not stage or commit from this document without re-running the helper script and reviewing the diff.

## Current context

- Repo: `/Users/yangshu/Codex`
- Branch: `codex/restore-codex-archive-state`
- Reason: the workspace contains restored files plus new Codex quality/regression/session-governance work. These should not be mixed into one opaque commit.

## Helper

Run:

```bash
/Users/yangshu/Codex/scripts/codex-commit-boundary-plan.sh
```

Optional JSON:

```bash
/Users/yangshu/Codex/scripts/codex-commit-boundary-plan.sh --json
```

The helper does **not** stage, commit, push, delete, or move files. It only groups the current dirty tree and prints review/staging commands.

## Recommended commit batches

### 1. Codex quality and capability upgrade

Intent: capture the main quality-lane, prompt, hook, skill, smoke, weekly-maintenance, quality-regression, and session-archive planning work.

Expected paths include:

- `AGENTS.md`
- `skills-lock.json`
- `.agents/skills/architecture-decision-review/`
- `.agents/skills/backend-api-contract-review/`
- `.agents/skills/frontend-design-review/`
- `.agents/skills/product-ux-flow-review/`
- `docs/codex-capability-registry.md`
- `docs/codex-github-skill-watchlist-2026-04-14.md`
- `docs/codex-latest-practices-2026-04-14.md`
- `docs/codex-quality-lanes.md`
- `scripts/agent-browser-smoke.sh`
- `scripts/codex-capability-audit.sh`
- `scripts/codex-commit-boundary-plan.sh`
- `scripts/codex-maint-weekly.sh`
- `scripts/codex-quality-lane-smoke.sh`
- `scripts/codex-quality-regression.sh`
- `scripts/codex-run-guarded.sh`
- `scripts/codex-runtime-health.sh`
- `scripts/codex-session-archive-plan.sh`
- `scripts/skill-audit.sh`
- `scripts/skill-smoke.sh`

Suggested commit message:

```text
codex: add quality regression and session governance
```

Minimum verification before committing:

```bash
bash -n /Users/yangshu/Codex/scripts/*.sh
python3 -m json.tool /Users/yangshu/Codex/skills-lock.json >/tmp/skills-lock.pretty.json
/Users/yangshu/Codex/scripts/codex-quality-lane-smoke.sh
/Users/yangshu/Codex/scripts/codex-quality-regression.sh
git -C /Users/yangshu/Codex diff --check
```

### 2. Agent handoff governor restore

Intent: keep handoff workflow restoration separate from broader quality-lane work.

Expected paths:

- `.agents/skills/agent-handoff-governor/`

Suggested commit message:

```text
codex: restore agent handoff governor skill
```

### 3. OpenCLI read-only evaluation draft

Intent: keep OpenCLI wrapper/skill work isolated because it is an external-tool integration with a stricter read-only threat model.

Expected paths:

- `.agents/skills/opencli-readonly-probe/`
- `scripts/opencli-readonly.sh`

Suggested commit message:

```text
codex: add opencli read-only evaluation draft
```

### 4. Design reference restore

Intent: keep DESIGN.md and design reference documents separate from maintenance tooling.

Expected paths:

- `DESIGN.md`
- `docs/awesome-design-md-assessment.md`
- `docs/design-reference-shortlist.md`

Suggested commit message:

```text
codex: restore design reference docs
```

### 5. Capability governance restore

Expected paths:

- `docs/code_review.md`
- `docs/codex-capability-governance.md`
- `docs/skills-governance-2026-04-08.md`

Suggested commit message:

```text
codex: restore capability governance docs
```

### 6. SkillTrust curation restore

Expected paths:

- `docs/skilltrust-codex-skill-audit-2026-04-11.md`
- `vendor/skills/skilltrust-curated/`

Suggested commit message:

```text
codex: restore skilltrust curated skill mirror
```

### 7. Worktree governance restore

Expected paths:

- `docs/worktree-governance.md`
- `scripts/worktree-close.sh`
- `scripts/worktree-create.sh`
- `scripts/worktree-weekly-clean.sh`

Suggested commit message:

```text
codex: restore worktree governance scripts
```

### 8. Backup/integrity utilities

Expected paths:

- `scripts/backup-ai-dev-2t.sh`
- `scripts/verify-project-docs-integrity.sh`

Suggested commit message:

```text
codex: add backup and docs integrity utilities
```

## Rules

- Re-run `/Users/yangshu/Codex/scripts/codex-commit-boundary-plan.sh` immediately before staging.
- If the helper reports `needs-manual-review`, do not commit until the path is classified or intentionally excluded.
- Commit one batch at a time.
- Do not include `/tmp` regression outputs or copied session archives.
- Do not include personal secrets or session transcript contents beyond the already existing local session archive manifests.
