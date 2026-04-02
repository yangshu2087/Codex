---
name: frontend-design-review
description: Review or implement front-end UI work with a design-first workflow. Use when the task involves page or component design quality, translating Figma or screenshot references into code, refining spacing or typography or responsive behavior, validating UI states, or checking visual polish before merge.
---

# Frontend Design Review

Use this skill when Codex should behave like a design-aware front-end implementer instead of a generic code editor.

## Inputs to gather first

Read the highest-signal design inputs available before changing code:

1. Figma links or node IDs
2. Repository design files under `design/`
3. Screenshots or reference images
4. Existing component library and tokens
5. Product spec or acceptance notes in repo docs, Notion, or Google Drive

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

## Verification loop

Do not stop at “the code compiles.” Run a visual loop when possible:

1. Launch the narrowest relevant preview or dev server.
2. Inspect the page in a browser using the available browser automation skill.
3. Check at least these widths when the UI is responsive:
   - 375
   - 768
   - 1024
   - 1440
4. Look for:
   - overflow or clipped content
   - spacing inconsistency
   - typography hierarchy issues
   - broken alignment
   - console errors
   - missing interactive states
5. If visual verification is not possible, state that gap explicitly.

## Preferred local workflow

In repositories that follow the workspace conventions:

- inspect `design/design-system.md` if present
- inspect `design/tokens.example.json` or the real token file if present
- inspect `docs/ui-acceptance-checklist.md`
- update `docs/agent-handoff.md` before pausing if design work is in progress

## Output standard

When summarizing work, include:

1. what design inputs were used
2. what UI layers changed
3. what states and breakpoints were checked
4. what remains visually unverified
