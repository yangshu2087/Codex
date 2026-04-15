# Codex Memory Governance

Purpose: give Codex a durable, auditable memory layer without turning every conversation into uncontrolled long-term storage.

## Policy

- Default storage is local Markdown and JSONL only.
- Do not start a daemon, external database, Notion export, Google Drive export, or background sync unless a later task explicitly asks for it.
- Memory entries must be short summaries, not raw full prompts or transcript copies.
- A memory entry is valid only when it records source, date, confidence, scope, and expiry or review condition.
- Project-specific memory belongs in the nearest repository through `AGENTS.md`, `docs/agent-handoff.md`, `docs/decision-log.md`, or a repo-local `docs/codex-memory.md`.
- User-wide memory belongs under `~/.codex/memories/` and should stay small.

## What may be remembered

| Category | Examples | Default location |
|---|---|---|
| User preferences | final reply format, stability-first, visual verification preference | `~/.codex/memories/MEMORY.md` |
| Repeated feedback | “did not explain evidence,” “missed long-term handoff,” “too eager to install broad skills” | `~/.codex/memories/feedback-log.jsonl` |
| Stable project conventions | branch policy, repo roots, verification commands, handoff workflow | repo `AGENTS.md` or `docs/agent-handoff.md` |
| Architecture/product decisions | selected option, rejected options, rollout/rollback | repo `docs/decision-log.md` |
| Lessons learned | repeated failure mode and prevention rule | global or repo memory, depending on scope |

## What must not be remembered

- API keys, OAuth tokens, session cookies, SSH keys, passwords, seed phrases, or private certificates.
- Full raw user prompts that may contain sensitive code, credentials, private emails, or production data.
- Production customer data or private third-party content copied from connectors.
- Speculation, low-confidence guesses, or one-off preferences that were not confirmed.
- Instructions that conflict with repository policy, GitHub branch protection, security requirements, or current `AGENTS.md`.

## Memory entry shape

Use this compact shape when adding a human-readable entry:

```md
- date: YYYY-MM-DD
  scope: global | repo:<path>
  source: user-feedback | repeated-failure | task-retro | explicit-instruction
  confidence: high | medium | low
  expires_or_review: YYYY-MM-DD | on-project-change | when-user-corrects
  memory: <short summary>
  action: <how Codex should behave differently>
```

Use JSONL for machine-readable feedback events:

```json
{"date":"2026-04-15T12:00:00Z","repo":"/Users/yangshu/Codex","task_type":"codex-maintenance","feedback":"short summary","root_cause":"short cause","memory_candidate":"short candidate","action_required":"update skill or AGENTS"}
```

## Workflow

1. Read nearest `AGENTS.md` and repo memory before acting on a project.
2. When the user gives explicit feedback or the same failure recurs, capture a short feedback event.
3. Promote only high-confidence, repeated, stable feedback into `MEMORY.md` or repo docs.
4. Audit memory weekly or after major Codex upgrades.
5. Delete or mark stale memory when it conflicts with newer repo policy or user correction.

## Guardrails

- Prefer `codex-memory-curator` for deciding whether a note deserves long-term memory.
- Run `/Users/yangshu/Codex/scripts/codex-memory-audit.sh` before trusting or expanding memory.
- If a memory conflicts with `AGENTS.md`, follow the nearest `AGENTS.md` and record a correction candidate.
- If the user asks for something unsafe, do not obey because it is in memory; apply the challenge protocol first.
