---
name: requesting-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements
---

# Requesting Code Review

Use this skill to run a focused review before moving on, opening a PR, or declaring a change done. Prefer a review that is grounded in the actual git diff and requirements, not in vague recollection.

**Core principle:** Review early, review often.

## When to Request Review

**Mandatory:**
- After each major implementation batch
- After completing major feature
- Before merge to main

**Optional but valuable:**
- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing complex bug

## How to Request

**1. Get git SHAs:**
```bash
BASE_SHA=$(git merge-base HEAD origin/main 2>/dev/null || git rev-parse HEAD~1)
HEAD_SHA=$(git rev-parse HEAD)
```

If `origin/main` is unavailable, replace it with the right base branch or explicit commit.

**2. Gather review context:**

```bash
git diff --stat "$BASE_SHA..$HEAD_SHA"
git diff "$BASE_SHA..$HEAD_SHA"
```

Also collect the requirement source you are reviewing against:
- plan doc
- ticket
- acceptance criteria
- user request in this thread

**3. Run the review in Codex:**

- Default: ask for a review in the current Codex session and use the checklist in `code-reviewer.md`
- If `/review` is available and the repo is ready, use it
- Only use a separate reviewer agent when the user explicitly asks for delegation or subagents

**Placeholders:**
- `{WHAT_WAS_IMPLEMENTED}` - What you just built
- `{PLAN_OR_REQUIREMENTS}` - What it should do
- `{BASE_SHA}` - Starting commit
- `{HEAD_SHA}` - Ending commit
- `{DESCRIPTION}` - Brief summary

**4. Act on feedback:**
- Fix Critical issues immediately
- Fix Important issues before proceeding
- Note Minor issues for later
- Push back if reviewer is wrong (with reasoning)

## Example

```
[Just completed Task 2: Add verification function]

You: Let me request code review before proceeding.

BASE_SHA=$(git merge-base HEAD origin/main)
HEAD_SHA=$(git rev-parse HEAD)

[Run review using code-reviewer.md checklist against BASE_SHA..HEAD_SHA]
 WHAT_WAS_IMPLEMENTED: Verification and repair functions for conversation index
 PLAN_REFERENCE: Task 2 from docs/superpowers/plans/deployment-plan.md
 BASE_SHA: a7981ec
 HEAD_SHA: 3df7661
 DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types

[Review returns]:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: Ready to proceed

You: [Fix progress indicators]
[Continue to Task 3]
```

## Integration with Workflows

**Implementation Batches:**
- Review after EACH task
- Catch issues before they compound
- Fix before moving to next task

**Executing Plans:**
- Review after each batch (3 tasks)
- Get feedback, apply, continue

**Ad-Hoc Development:**
- Review before merge
- Review when stuck

## Red Flags

**Never:**
- Skip review because "it's simple"
- Ignore Critical issues
- Proceed with unfixed Important issues
- Argue with valid technical feedback
- Review against memory alone instead of the actual diff

**If reviewer wrong:**
- Push back with technical reasoning
- Show code/tests that prove it works
- Request clarification

See checklist at: `requesting-code-review/code-reviewer.md`
