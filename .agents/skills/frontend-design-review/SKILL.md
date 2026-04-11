---
name: frontend-design-review
description: Use when the task involves front-end page or component design quality, Figma or screenshot translation, spacing or typography refinement, responsive behavior, UI state validation, or visual polish before merge.
---

# Frontend Design Review

Use this skill when Codex should behave like a design-aware front-end implementer instead of a generic code editor.

## Inputs to gather first

Read the highest-signal design inputs available before changing code:

1. Repository `DESIGN.md`
2. Workspace or repo design shortlist docs when present
3. Figma links or node IDs
4. Repository design files under `design/`
5. Screenshots or reference images
6. Existing component library and tokens
7. Product spec or acceptance notes in repo docs, Notion, or Google Drive

If a design source is missing, say so explicitly and continue with the strongest remaining source instead of pretending the design is fully specified.

## Working rules

1. Start from system constraints, not ad hoc CSS:
   - identify framework, styling approach, component library, and token source
   - prefer existing components and tokens over one-off values
2. Break UI work into four layers:
   - layout
   - components
   - states
   - responsive behavior
3. Cover non-happy paths by default:
   - loading
   - empty
   - error
   - hover
   - focus-visible
   - active
   - disabled
4. Keep accessibility in scope:
   - semantic HTML first
   - keyboard reachability
   - visible focus states
   - contrast awareness
5. When implementing from Figma, preserve intent rather than copying every raw pixel token if that would fight the local design system.
6. If using an external inspiration reference, state it explicitly and translate it into local rules rather than copying the original brand.

## Verification loop

Do not stop at “the code compiles.” Run a real browser or visual loop when possible:

1. Launch the narrowest relevant preview or dev server.
2. Inspect the page in a browser using the available browser automation skill, Playwright, or agent-browser.
3. Explore the target UI like a user:
   - identify 3-5 core flows or visible states for the changed page
   - interact with primary buttons, inputs, tabs, menus, dialogs, and navigation
   - record relevant locators or user-visible anchors when useful
4. Capture evidence:
   - screenshot or visual observation for the changed page
   - browser console errors and obvious network failures
   - responsive checks for 375, 768, 1024, and 1440 widths when the UI is responsive
5. Check design quality:
   - overflow or clipped content
   - spacing inconsistency
   - typography hierarchy issues
   - broken alignment
   - awkward empty/loading/error states
   - missing hover, focus-visible, active, or disabled states
6. Re-verify after fixes. Do not claim the visual issue is fixed until the same page or flow is checked again.
7. If visual verification is not possible, state the exact gap and what would be needed to close it.

For work sourced from SkillTrust candidates, treat `web-design-reviewer`, `webapp-testing`, and `playwright-explore-website` as inspiration only; use this workspace's local browser tooling and repo design system instead of installing duplicate global skills.

## Preferred local workflow

In repositories that follow the workspace conventions:

- inspect `DESIGN.md` first
- inspect `docs/design-reference-shortlist.md` when present
- inspect `design/design-system.md` if present
- inspect `design/tokens.example.json` or the real token file if present
- inspect `docs/ui-acceptance-checklist.md`
- update `docs/agent-handoff.md` before pausing if design work is in progress

## Output standard

When summarizing work, include:

1. what design inputs were used
2. what external inspirations were chosen, if any
3. what UI layers changed
4. what states and breakpoints were checked
5. what remains visually unverified
