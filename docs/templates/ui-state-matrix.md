# UI state matrix

Use this template for frontend/UI changes before claiming visual completion. Copy it into the target repository or PR notes when a page, component, or product flow changes.

## Task context

- Target repo:
- Branch / PR:
- Page / route / component:
- Design source: DESIGN.md / Figma / screenshot / product spec / other
- Visual thesis:
- Content plan:
- Interaction thesis:

## State matrix

| Surface | default | hover | focus-visible | active | loading | empty | error | disabled | success | Evidence path / note |
|---|---|---|---|---|---|---|---|---|---|---|
| Primary CTA | n/a | n/a | n/a | n/a | n/a | n/a | n/a | n/a | n/a | |
| Form input | n/a | n/a | n/a | n/a | n/a | n/a | n/a | n/a | n/a | |
| Data/list area | n/a | n/a | n/a | n/a | n/a | n/a | n/a | n/a | n/a | |
| Modal/menu/popover | n/a | n/a | n/a | n/a | n/a | n/a | n/a | n/a | n/a | |
| Page shell/nav | n/a | n/a | n/a | n/a | n/a | n/a | n/a | n/a | n/a | |

Legend:

- `pass`: verified in browser/test/screenshot.
- `n/a`: not relevant to this surface.
- `gap`: relevant but not yet verified.
- `blocked`: cannot verify locally; explain why in the evidence column.

## Responsive checks

| Width | Result | Evidence / notes |
|---:|---|---|
| 375 | gap | |
| 768 | gap | |
| 1024 | gap | |
| 1440 | gap | |

## Accessibility checks

- Semantic structure:
- Keyboard navigation:
- Focus visibility:
- Color contrast:
- Tap/click targets:
- Reduced motion / motion purpose:

## Browser / visual evidence

- Tool: browser / Playwright / agent-browser / screenshot / manual page check
- Command:
- Screenshot path:
- Console errors:
- Network failures:
- Remaining visual gaps:

## Completion decision

- Product shell status: Product Shell Ready / Core Flow Ready / Skeleton Only / Mock or Stubs Remaining
- Done criteria met? yes / no
- If no, what is the narrow next verification step?
