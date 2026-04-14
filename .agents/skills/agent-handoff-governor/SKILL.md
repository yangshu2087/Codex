---
name: agent-handoff-governor
description: Use when handing work between Codex, Cursor, or other agents, before pausing or switching tools, to refresh docs/agent-handoff.md with branch, changed files, verification evidence, and an explicit next step.
---

# Agent Handoff Governor

Use this skill whenever execution is about to move across tools or agents.

## When to use

Trigger this skill when you are:
- pausing work for later,
- handing work from Codex to Cursor (or reverse),
- asking another agent to continue,
- opening a PR after multi-tool edits and you want a clean baton file.

## Required workflow

1. Confirm the target repository root first (`git rev-parse --show-toplevel`).
2. Refresh handoff with:
   - `/Users/yangshu/Codex/scripts/update-agent-handoff.sh <repo-path>`
3. If verification was run, record it in the same refresh call:
   - `--verify "<command>"`
   - optional context with `--note "<reason or caveat>"`
4. Re-open `docs/agent-handoff.md` and ensure these sections are updated:
   - `Branch`
   - `Changed files`
   - `Verification`
5. Preserve human-authored sections (`Current goal`, `Done`, `Next step`, `Blockers`) and make sure `Next step` is concrete and executable.

## Command patterns

```bash
/Users/yangshu/Codex/scripts/update-agent-handoff.sh /absolute/repo/path
/Users/yangshu/Codex/scripts/update-agent-handoff.sh /absolute/repo/path --verify "npm test"
/Users/yangshu/Codex/scripts/update-agent-handoff.sh --repo . --verify "pnpm -C web test" --note "UI snapshot update pending review"
```

## Guardrails

- Never claim handoff complete without a refreshed `docs/agent-handoff.md`.
- Never overwrite human summary sections with generated boilerplate.
- If no verification was run, explicitly keep that fact in `Verification` instead of inventing results.
