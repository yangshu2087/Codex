---
name: repo-ui-postcheck-summary
description: Use when finishing or reviewing a frontend, UI, design-system, product-shell, or visual-polish change in a repository and the result needs state coverage, browser evidence, responsive notes, accessibility notes, and PR-ready handoff.
---

# Repo UI Postcheck Summary

Use this skill after UI implementation or review, before claiming that a frontend or UX change is complete.

## Required inputs

Collect the strongest available design context:

1. nearest `DESIGN.md`;
2. repo components, tokens, or design-system docs;
3. Figma node, screenshot, product spec, or acceptance criteria;
4. changed routes/components;
5. local dev URL or preview URL.

If a source is missing, state the gap rather than inventing design intent.

## Postcheck flow

1. State the visual thesis, content plan, and interaction thesis for visually led work.
2. Fill or summarize `/Users/yangshu/Codex/docs/templates/ui-state-matrix.md` for relevant surfaces.
3. Run the narrowest real browser or visual check available:
   - project Playwright test;
   - `agent-browser` smoke;
   - browser screenshot;
   - manual page check with exact URL and observation.
4. Check responsive behavior where relevant: 375, 768, 1024, and 1440 widths.
5. Check accessibility basics: semantics, keyboard reachability, focus-visible, contrast, tap targets, and motion purpose.
6. Report console/network errors if browser tooling exposes them.

## Required summary format

Include these sections in the final handoff or PR notes:

- Design inputs used
- Visual thesis
- UI layers checked: layout, components, states, responsive behavior
- State coverage: default, hover, focus-visible, active, loading, empty, error, disabled, success
- Browser / visual evidence: command, URL, screenshot path, and observed result
- Accessibility notes
- Remaining gaps
- Product shell status: `Product Shell Ready`, `Core Flow Ready`, `Skeleton Only`, or `Mock / Stubs Remaining`

## Hard rules

- Do not claim visual completion without browser, Playwright, screenshot, agent-browser, or explicit manual page evidence.
- Do not treat a static code diff as visual verification.
- Do not copy external brand references directly; translate them into repo-native components, tokens, spacing, density, hierarchy, and interaction rules.
- If runtime pressure is high, prefer one targeted browser pass over broad concurrent agent exploration.

## Useful commands

```bash
/Users/yangshu/Codex/scripts/codex-ui-capability-smoke.sh /path/to/repo
/Users/yangshu/Codex/scripts/agent-browser-smoke.sh http://127.0.0.1:3000 /tmp/ui-check
```
