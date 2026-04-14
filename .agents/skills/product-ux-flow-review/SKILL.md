---
name: product-ux-flow-review
description: Use when a task involves user experience, product flow, onboarding, conversion, user journeys, friction points, or UI acceptance criteria.
---

# Product UX Flow Review

Use this skill when the product outcome depends on whether a real user can understand and complete the flow.

## Required inputs

- User goal and business goal
- Primary user path and secondary states
- Current screen or flow artifacts
- Known constraints, non-goals, and edge cases
- Design system, copy tone, and accessibility expectations

## Workflow

1. Rewrite the request into a product contract before implementation.
2. Identify the primary path, failure paths, and the point where users can get stuck.
3. Cover states: default, hover, focus-visible, loading, empty, error, disabled, and success when relevant.
4. Check copy for orientation, action clarity, and unnecessary friction.
5. Use repository components and tokens; do not invent a new design language without a requirement.
6. Verify in a real browser, screenshot, Playwright, agent-browser, or manual page check before claiming completion.

## Output standard

- Product contract
- Primary and secondary flows
- State coverage
- Copy / accessibility notes
- Browser or visual verification evidence
- Remaining UX risks

## Common mistakes

- Optimizing UI aesthetics while ignoring the user's next action.
- Skipping empty/error/disabled states.
- Claiming UX quality without checking a real page or screenshot.
