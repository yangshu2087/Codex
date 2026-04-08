# Codex Capability Governance

This document defines how Codex capabilities are added, routed, measured, and retired in this workspace.

## Goals

- Keep default Codex behavior stable, predictable, and fast enough for daily work.
- Make heavy or domain-specific capabilities explicit instead of accidental.
- Ensure every capability change is auditable, reversible, and measured against real work.

## Governance principles

1. **Default-first**
   - Govern the default stack first: default model, reasoning tier, global AGENTS rules, enabled global skills, enabled MCP/plugin set, and execution guardrails.
   - Anything not needed by most tasks should not live in the default layer.

2. **Layered capability model**
   - **L0 Core stable**: defaults that shape nearly every session. Changes here require the highest caution.
   - **L1 Workspace standard**: team-shared skills and scripts used across repositories in this workspace.
   - **L2 Project-local**: repository- or product-specific capabilities. Keep them inside the target repo instead of `~/.agents/skills`.
   - **L3 Experimental / on-demand**: vendored third-party skills, alpha/preview paths, and anything that may help but should not influence routing by default.

3. **Explicit routing beats implicit magic**
   - A capability should have a clear trigger, a clear non-trigger, and a clear owner.
   - If a skill/plugin cannot explain when it must be used and when it must not be used, it should not enter L0.

4. **Single-source guardrails**
   - Personal defaults: `~/.codex/config.toml`
   - Personal guardrails: `~/.codex/AGENTS.md`
   - Workspace policy: this repo's `AGENTS.md` and `docs/`
   - Runtime pressure decision: `/Users/yangshu/Codex/scripts/codex-runtime-health.sh`

5. **Capability changes must be reversible**
   - Prefer disable/archive over delete.
   - Document rollback path before promoting a capability into the default stack.

## Capability lifecycle

### 1) Propose

For any new skill, plugin, MCP, routing rule, or default model change, first answer:

- What repeated problem does it solve?
- Is it default-worthy or only useful in a subset of tasks?
- What is its trigger boundary?
- What is the rollback path?

### 2) Classify

Assign the capability to one layer before rollout:

- L0 if nearly every session benefits and wrong activation cost is low.
- L1 if it is team-shared but not global-default critical.
- L2 if it belongs to a product, repo, or business workflow.
- L3 if it is exploratory, vendored, or cost/risk sensitive.

### 3) Validate

Before promoting a change into L0/L1, validate with:

- `codex --version`
- `codex features list`
- `codex mcp list`
- `/Users/yangshu/Codex/scripts/check-codex-upgrade.sh`
- representative real tasks, not only synthetic checks

### 4) Measure

Track at least these quality signals:

- one-pass completion rate
- done-criteria pass rate
- verification evidence rate
- profile/skill routing correctness
- high-pressure downgrade correctness

Record these on a recurring scorecard or task sample set so capability changes are measured against real work.

### 5) Retire

Move a capability out of the default path if any of these are true:

- repeated misrouting or accidental activation
- high overlap with another capability
- low usage over time
- it reduces task quality or creates extra process noise

Retirement order:

1. remove from default path
2. move to disabled/archive or project-local scope
3. delete only when clearly obsolete

## Operating rules by layer

### L0 Core stable

Examples:

- default model + reasoning
- default profiles (`quick`, `fast`, `deep`, `research`, `codex53`)
- personal AGENTS rules
- runtime guardrails

Rules:

- keep small
- change rarely
- always verify locally after edits

### L1 Workspace standard

Examples:

- workspace shared skills under `.agents/skills`
- handoff / upgrade / governance scripts in `scripts/`
- docs that define collaboration rules

Rules:

- every item needs an owner and a narrow purpose
- keep names and triggers stable
- prefer curated subsets over full third-party skill dumps

### L2 Project-local

Examples:

- 007 analytics/publishing skills
- OpenClaw-specific publishing flows
- repo-specific UI or release skills

Rules:

- keep inside the relevant repo under `.agents/skills`
- do not reactivate as global skills unless reuse is proven across projects

### L3 Experimental / on-demand

Examples:

- vendored third-party skills under `vendor/skills`
- preview workflows or high-cost browser/tool chains
- alpha model paths and exploratory plugins

Rules:

- opt-in only
- keep behind explicit activation or explicit profile/tool choice
- never silently influence default routing

## Weekly governance cadence

Run:

```bash
/Users/yangshu/Codex/scripts/codex-capability-audit.sh
/Users/yangshu/Codex/scripts/check-codex-upgrade.sh
```

Review and act on:

- default model/reasoning drift
- global skill creep
- disabled archive growth
- duplicate or overlapping plugin entries
- stale experimental capabilities that should be promoted or retired
