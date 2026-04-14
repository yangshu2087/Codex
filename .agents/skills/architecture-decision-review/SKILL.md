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
- Known failure modes or rollback needs

## Workflow

1. Write the task card: Goal, Constraints, Non-goals, Done criteria, Verification commands.
2. Compare at least two options unless only one is technically viable.
3. For each option, evaluate correctness, complexity, migration cost, operational risk, observability, and rollback path.
4. Recommend one option and explain why it best fits the constraints.
5. Only then propose implementation steps, ordered by lowest-risk milestone.
6. For changes that touch data, auth, queues, external APIs, or deployment, include a rollback note before implementation.

## Output standard

- Task card
- Option comparison table
- Recommendation
- Migration / rollout plan
- Rollback plan
- Verification plan
- Residual risks

## Common mistakes

- Treating a refactor as architecture without stating migration cost.
- Selecting an option without rollback or observability.
- Coding first and justifying the design afterward.
