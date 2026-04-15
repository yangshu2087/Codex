# Codex Feedback Loop

Purpose: turn user dissatisfaction, repeated corrections, and task misses into concrete Codex improvements instead of one-off apologies.

## Trigger conditions

Run the feedback loop when any of these appear:

- The user says Codex misunderstood the task, became worse, did not execute to completion, or missed intent.
- The same correction appears twice in a short period.
- A task finishes without required evidence, browser verification, or final report sections.
- A high-risk request required pushback or a safer alternative.
- A PR/review/check failure reveals a reusable prevention rule.

## Feedback event workflow

1. **Restate the failure**: what the user expected versus what Codex did.
2. **Root cause**: classify as requirements, memory, skill routing, resource pressure, verification, external facts, or execution discipline.
3. **Immediate repair**: what should be done in the current task.
4. **Long-term prevention**: whether to update `AGENTS.md`, a skill, a hook, a script, or a repo doc.
5. **Memory decision**: mark as no-memory, candidate, or promote-now.
6. **Regression check**: add or run the narrowest smoke that would catch the issue next time.

## Storage

- Append structured events with `/Users/yangshu/Codex/scripts/codex-feedback-capture.sh`.
- Store user-wide feedback in `~/.codex/memories/feedback-log.jsonl`.
- Store repo-specific decisions in repo docs, not global memory.

## Root-cause taxonomy

| Category | Symptom | Typical fix |
|---|---|---|
| Requirements | implemented literal request but missed real goal | strengthen product contract / intake challenge |
| Memory | forgot stable preference or prior decision | promote to memory with scope and expiry |
| Skill routing | did not load the right skill | tighten skill description or AGENTS trigger |
| Verification | claimed done without evidence | hook/regression update |
| Resource pressure | skipped thoroughness or subagent use was unstable | use runtime guardrails |
| External facts | stale or unverified information | require official docs or research profile |
| Execution discipline | stopped before planned endpoint | outcome-driven delivery gate |

## Completion standard

A feedback loop is complete only when the final reply includes:

- what was captured;
- where it was stored or why it was not stored;
- what local rule/skill/script should change;
- what command or smoke verifies the prevention rule.
