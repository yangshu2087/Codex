---
name: frontend-design-review
description: Use when the task involves front-end page or component design quality, Figma or screenshot translation, spacing or typography refinement, responsive behavior, UI state validation, or visual polish before merge.
---

# Frontend Design Review

Use this skill when Codex should behave like a design-aware front-end implementer instead of a generic code editor.

## Inputs to gather first

Read the highest-signal design inputs available before changing code:

1. Nearest repository `DESIGN.md`
2. Workspace or repo design shortlist docs when present
3. Figma links, node IDs, screenshots, or reference images
4. Repository design files under `design/`
5. Existing component library and tokens
6. Product spec, UX flow, or acceptance notes in repo docs, Notion, or Google Drive

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
3. Cover non-happy paths by default when relevant:
   - default
   - hover
   - focus-visible
   - active
   - loading
   - empty
   - error
   - disabled
   - success
4. Keep accessibility in scope:
   - semantic HTML first
   - keyboard reachability
   - visible focus states
   - contrast awareness
   - sufficient tap targets
5. Preserve intent rather than copying every raw pixel token if that would fight the local design system.
6. If using an external inspiration reference, state it explicitly and translate it into local rules rather than copying the original brand.

## Visual thesis gate

For visually led pages, landing pages, prototypes, demos, or any UI where design quality matters, write these before coding:

- visual thesis: one sentence describing mood, material, hierarchy, and energy
- content plan: the role of each major section or surface
- interaction thesis: 2-3 motion or interaction ideas that improve hierarchy, affordance, or atmosphere

Use those notes as a design contract. If the code starts drifting into generic components, return to the thesis before adding more UI.

## Humane product defaults

- The first screen should make the product, user location, and next action obvious.
- Empty/error/loading/success states should help users recover or continue.
- Copy should orient before it persuades; CTAs should describe the action.
- Decorative motion, gradients, glow, or chrome must clarify hierarchy, feedback, trust, or conversion.
- Dashboards/admin/ops UI should prioritize status, navigation, task completion, and recovery over campaign-style hero copy.

## Premium composition defaults

- Start with composition, not component count.
- Prefer one dominant visual idea per section.
- Use whitespace, alignment, scale, cropping, and contrast before adding borders, shadows, gradients, or chrome.
- Keep the type system restrained: two typefaces max and one accent color by default unless the repo design system says otherwise.
- Default to cardless layouts. Use sections, columns, dividers, media blocks, and clear workspace regions before adding card grids.
- Treat the first viewport of a branded page as a poster: unmistakable product or brand, one strong visual anchor, short copy, and one clear action.
- For app surfaces, default to calm product utility: navigation, primary workspace, secondary context or inspector, and one clear accent for state or action.

## Landing page and first-viewport checks

When the target is a landing page, website, or public marketing surface:

1. Hero: brand or product, promise, CTA, and one dominant visual.
2. Support: one concrete feature, proof point, or offer.
3. Detail: workflow, product depth, atmosphere, or story.
4. Final CTA: convert, start, visit, contact, or continue.

Hard checks:

- The hero has one composition only.
- Full-bleed briefs get full-bleed heroes; constrain the inner text/action column, not the whole hero.
- Brand/product is louder than decorative UI.
- Headlines are short enough to scan in one glance.
- Text over imagery has strong contrast and clear tap targets.
- Sticky/fixed headers count against first-viewport budget.
- Motion is purposeful: entrance, scroll/depth, or hover/reveal should clarify hierarchy rather than add noise.

Reject generic SaaS card grids, stat-strip-first impressions, ornamental icon clutter, weak brand presence, filler copy, and motion that cannot be explained in terms of hierarchy or affordance.

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
   - awkward empty/loading/error/success states
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
3. visual thesis, content plan, and interaction thesis when the task is visually led
4. what UI layers changed
5. what states and breakpoints were checked
6. what real browser, screenshot, Playwright, or agent-browser verification was performed
7. what remains visually unverified

## Completion contract

Before claiming front-end or UX work is complete, include browser or visual verification evidence and the standard final report headings: `已完成`, `完成证据`, `还缺什么`, and `后续建议`. If no real page was checked, state the blocker instead of implying visual quality.
