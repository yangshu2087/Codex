# Codex Quality Regression Scorecard (10 tasks)

Goal: validate “一次到位” recovery after routing + guardrail changes.

## How to use

- Run 10 real tasks: understanding/design/code/frontend/architecture each 2 tasks.
- For each task, fill one row.
- "One-pass" means no major rework request in the same round.

## Scorecard

| # | Domain | Task summary | Profile used | One-pass (Y/N) | Done criteria met (Y/N) | Verification evidence | User satisfaction (1-5) | Notes |
|---|---|---|---|---|---|---|---|---|
| 1 | Understanding |  |  |  |  |  |  |  |
| 2 | Understanding |  |  |  |  |  |  |  |
| 3 | Design |  |  |  |  |  |  |  |
| 4 | Design |  |  |  |  |  |  |  |
| 5 | Code |  |  |  |  |  |  |  |
| 6 | Code |  |  |  |  |  |  |  |
| 7 | Front-end |  |  |  |  |  |  |  |
| 8 | Front-end |  |  |  |  |  |  |  |
| 9 | Architecture |  |  |  |  |  |  |  |
| 10 | Architecture |  |  |  |  |  |  |  |

## Aggregate metrics

- One-pass rate = `Y count / 10`
- Done criteria pass rate = `Y count / 10`
- Avg satisfaction = `sum(score) / 10`
- Front-end real-page verification pass = task #7 + #8 both have evidence

## Pass threshold (default)

- One-pass rate >= 70%
- Done criteria pass rate >= 90%
- Avg satisfaction >= 4.0
