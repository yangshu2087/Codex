# Codex Code Review Checklist

Use this checklist for local `/review`, GitHub PR review, and final pre-merge review in this workspace.

## Review scope

- Confirm the diff matches the task card: Goal, Constraints, Non-goals, Done criteria, and Verification commands.
- Identify the real repository root before reviewing; do not review child-repo changes from the meta-workspace root by accident.
- Separate product behavior changes, config changes, generated artifacts, vendored skills, and local-only user config changes.
- Treat untracked files as reviewable if they are part of the intended change; explicitly call out unrelated untracked files.

## Correctness and maintainability

- Check for broken control flow, missing error handling, stale assumptions, race conditions, and hidden global state.
- Prefer small, repo-native changes over broad rewrites.
- Verify new code follows existing architecture, naming, data flow, and dependency boundaries.
- For migrations or architecture work, require a rollback path and operational risk note.
- For scripts, check strict mode, quoting, path safety, idempotency, and helpful failure output.

## Front-end and design quality

- Read the nearest `DESIGN.md` and relevant `design/` docs before judging UI choices.
- Require visual thesis, content plan, and interaction thesis for visually led work.
- Confirm states are covered when relevant: default, hover, focus-visible, active, loading, empty, error, disabled.
- Require at least one real browser, Playwright, agent-browser, screenshot, or manual page verification pass before accepting a UI completion claim.
- Reject generic card grids, weak hierarchy, inaccessible contrast, clipped/overflowing content, and motion that does not improve affordance or hierarchy.

## Tests and evidence

- Prefer fresh evidence over confidence. A review cannot mark work complete without current verification output.
- Confirm the narrowest relevant tests, type checks, lint checks, build checks, or script smoke tests were run.
- If a command cannot run locally, record the exact blocker and the smallest follow-up needed.
- For external-fact-dependent work, verify with official docs or live sources, then cite the source.

## Review output format

Return findings in priority order:

1. Blocking correctness or safety issues.
2. Missing verification or incomplete done criteria.
3. Maintainability/design issues that should be fixed before merge.
4. Non-blocking suggestions.

For each finding include: file path, tight line range when possible, why it matters, and the smallest safe fix.
