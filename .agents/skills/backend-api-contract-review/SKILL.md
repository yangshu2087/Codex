---
name: backend-api-contract-review
description: Use when a task involves backend services, API routes, database writes, auth, permissions, error semantics, or service contracts.
---

# Backend API Contract Review

Use this skill when backend correctness depends on contracts, state, permissions, or compatibility.

## Required inputs

- Endpoint, service, job, or module under change
- Request/response contract or caller expectations
- Auth and permission model
- Data persistence, cache, queue, transaction, and migration behavior
- Existing tests, logs, and route smoke checks relevant to the path

## Workflow

1. Write the task card: Goal, Constraints, Non-goals, Done criteria, Verification commands.
2. State the API contract: inputs, outputs, errors/status codes, side effects, and compatibility constraints.
3. State permissions separately from validation; do not assume type safety proves authorization.
4. State data consistency expectations: transaction boundary, idempotency, concurrency, cache invalidation, and migration/rollback notes when relevant.
5. Identify observability needs: logs, metrics, traces, audit events, user-visible error messages, or explicit none.
6. Implement minimal contract-compatible changes; do not silently change schema, auth, or error semantics.
7. Verify with the narrowest relevant checks: route/unit/integration tests, type checks, migration dry-run, focused smoke, or a targeted regression command.

## Evidence requirements

- API contract / 接口契约
- Error semantics / 错误语义
- Auth and permissions / 权限
- Data consistency / 数据一致性
- Observability impact
- Targeted regression checks / 回归测试

## Output standard

- Contract summary
- Data flow and side effects
- Auth/permission notes
- Error semantics
- Data consistency expectations
- Observability notes
- Verification evidence
- Remaining contract risks

## Common mistakes

- Returning a new shape without updating callers or tests.
- Changing auth behavior without calling it out.
- Treating a passing build as proof of API behavior.
- Skipping error and empty-result semantics.
