---
name: product-ux-flow-review
description: Use when a task involves user experience, product flow, onboarding, conversion, user journeys, friction points, or UI acceptance criteria.
---

# Product UX Flow Review

Use this skill when the product outcome depends on whether a real user can understand and complete the flow.

## Required inputs

- User goal, business goal, and business rules
- Primary user path and secondary/failure states
- Current screen, flow, screenshot, prototype, or acceptance artifact
- Known constraints, non-goals, edge cases, and friction points
- Design system, copy tone, accessibility expectations, and state coverage needs

## Workflow

1. Rewrite the request into a product contract before implementation: user goal, business rules, constraints, non-goals, assumptions, edge cases, acceptance criteria, verification method, and open questions.
2. Identify the primary journey, 2-3 failure/friction paths, and the point where users can get stuck.
3. Cover states when relevant: default, hover, focus-visible, active, loading, empty, error, disabled, and success.
4. Check copy for orientation, action clarity, recovery guidance, and unnecessary friction.
5. Keep accessibility in scope: semantic structure, keyboard reachability, visible focus, contrast, and tap targets.
6. Use repository components and tokens; do not invent a new design language without a requirement.
7. Verify in a real browser, screenshot, Playwright, agent-browser, accessibility/state check, or manual page check before claiming completion.

## Evidence requirements

- Product contract
- UX flow / user journey
- Friction or failure paths
- State coverage
- Copy and accessibility notes
- Browser, screenshot, accessibility/state evidence, or explicit blocker

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
- Hiding poor copy or unclear flow behind visual polish.
