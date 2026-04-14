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
- Data persistence, cache, queue, or transaction behavior
- Existing tests and logs relevant to the path

## Workflow

1. Write the task card: Goal, Constraints, Non-goals, Done criteria, Verification commands.
2. State the API contract: inputs, outputs, errors, status codes, side effects, and compatibility constraints.
3. State the permission model and data consistency expectations.
4. Identify observability needs: logs, metrics, traces, audit events, or user-visible error messages.
5. Implement minimal contract-compatible changes; do not silently change schema, auth, or error semantics.
6. Verify with the narrowest relevant checks: route/unit/integration tests, type checks, migration dry-run, or a focused smoke command.

## Output standard

- Contract summary
- Data flow and side effects
- Auth/permission notes
- Error semantics
- Observability notes
- Verification evidence
- Remaining contract risks

## Common mistakes

- Returning a new shape without updating callers or tests.
- Changing auth behavior without calling it out.
- Treating a passing build as proof of API behavior.
