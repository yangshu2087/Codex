---
name: architecture-decision-review
description: Use when a task involves architecture decisions, migrations, rollout planning, system boundaries, technical tradeoffs, or rollback risk.
---

# Architecture Decision Review

Use this skill when the cost of a wrong design decision is higher than the cost of planning first.

## Required inputs

- Current repository or service boundary
- Existing architecture facts and constraints
- Target behavior or decision to make
- Compatibility, migration, and operational limits
- Known failure modes, observability needs, and rollback requirements

## Workflow

1. Write the task card: Goal, Constraints, Non-goals, Done criteria, Verification commands.
2. Compare at least two viable options unless only one is technically viable.
3. For each option, evaluate correctness, compatibility, complexity, migration cost, operational risk, observability, and rollback path.
4. Call out API, auth/permission, data consistency, deployment, queue, or external-service impact when any of those boundaries are touched.
5. Recommend one option and explain why it best fits the constraints.
6. Propose implementation milestones in lowest-risk order; prefer reversible checkpoints over broad rewrites.
7. For changes that touch data, auth, queues, external APIs, or deployment, include rollout and rollback notes before implementation.

## Evidence requirements

- Option comparison and selected approach
- Tradeoffs and rejected alternatives
- Rollout or migration path
- Rollback path or explicit reason rollback is not applicable
- Observability / operational risk notes
- Verification plan with dry-run, tests, smoke, or targeted regression checks

## Output standard

- Task card
- Option comparison table
- Recommendation
- Migration / rollout plan
- Rollback plan
- API/data/auth impact
- Observability and risk notes
- Verification plan
- Residual risks

## Common mistakes

- Treating a refactor as architecture without stating migration cost.
- Selecting an option without rollback or observability.
- Coding first and justifying the design afterward.
- Calling a design “done” when it only describes the happy path.
