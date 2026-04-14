# Global Skill Slimming Report (2026-04-08)

## Scope

- Goal: reduce global first-turn routing overhead while keeping high-signal cross-project skills active.
- Operator: Codex local ops workflow.
- Machine: `/Users/yangshu`.

## Actions applied

### 1) Global active set slimmed

Moved project-specific custom skills out of active global folder:

- From: `/Users/yangshu/.agents/skills`
- To: `/Users/yangshu/.agents/skills-disabled/2026-04-08-global-slimming`

Moved skill directories:

- `007-attribution-analyst`
- `007-competitor-gap-miner`
- `007-distribution-operator`
- `007-gsc-opportunity-miner`
- `007-internal-link-operator`
- `007-page-publisher`
- `openclaw-wechat-draft-publisher`

### 2) New governance tooling

Added scripts:

- `/Users/yangshu/Codex/scripts/skill-audit.sh`
- `/Users/yangshu/Codex/scripts/skill-smoke.sh`

### 3) New team skill

Added:

- `/Users/yangshu/Codex/.agents/skills/agent-handoff-governor/SKILL.md`

Purpose: enforce reliable Codex/Cursor/agent handoff refresh via `docs/agent-handoff.md`.

## Keep / Migrate / Deprecate

### Keep (global active)

- `codex-local-ops` — cross-project local Codex maintenance.
- `product-shell-first` — cross-project product-shell workflow guardrail.
- Existing symlinked superpowers skills (kept unchanged).

### Migrate (from global active to project/workspace scope)

- `007-*` family → migrate to 007 project-local skill scope when actively used.
- `openclaw-wechat-draft-publisher` → migrate to OpenClaw workspace-local scope when actively used.

### Deprecate (current round)

- None hard-deleted.
- Strategy is **deactivate-by-default** via `skills-disabled` archive for reversible rollback.

## Rollback / Re-enable

To restore one disabled skill globally:

```bash
mv \
  /Users/yangshu/.agents/skills-disabled/2026-04-08-global-slimming/<skill-name> \
  /Users/yangshu/.agents/skills/
```

## Recommended weekly routine

```bash
/Users/yangshu/Codex/scripts/skill-audit.sh
/Users/yangshu/Codex/scripts/skill-smoke.sh
```

If repeated routing noise appears, migrate another project-specific global skill to disabled archive or repo-local scope.
