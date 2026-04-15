# Codex Outcome Scorecard

Purpose: measure whether Codex work produced the intended user outcome, not just files or text.

## Metrics

| Metric | Definition | Target |
|---|---|---|
| One-pass completion rate | User does not need a correction in the same task | trending up |
| Evidence coverage | Completed tasks include verification output or explicit blocker | 100% for complex work |
| Final contract compliance | Replies contain `已完成`, `完成证据`, `还缺什么`, `后续建议` | 100% when claiming done |
| Memory hit rate | Stable preferences are applied without repeated reminders | trending up |
| Feedback closure rate | Feedback events lead to a rule/skill/script/doc decision | 100% for major misses |
| Challenge accuracy | Pushback appears only for high-risk/unclear/low-leverage requests | high signal, low noise |
| Repeated-error rate | Same root cause recurs after being captured | trending down |

## Outcome evidence by lane

- Requirements/product: product contract, assumptions, done criteria, open questions.
- Architecture: option comparison, tradeoffs, rollout, rollback, risks.
- Backend/API: API contract, error semantics, permissions, data consistency, observability, targeted regression.
- Frontend/UI/UX: state coverage, design source, browser/screenshot/Playwright/agent-browser evidence.
- Codex maintenance: exact config/skill/script paths, version/features/MCP checks, regression scripts.

## Retro prompt

After a major task, ask:

1. Did the user outcome become possible or verified?
2. What evidence proves it?
3. What remains unverified?
4. Did any feedback or repeated friction deserve memory?
5. What smoke would catch this next time?

## Review cadence

- Run the quality regression script after modifying Codex hooks, skills, or config.
- Run memory audit weekly or before trusting long-lived memory in a new major task.
- Promote feedback to memory only after confirmation or recurrence.
