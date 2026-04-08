# Stitch / AI Studio / Codex Workflow

## Purpose

This workflow turns Google design and prototype tools into repository-native code without losing traceability.

## Stage 1: Stitch

Use Stitch to explore UI direction, layout, and interaction ideas.

Before prompting Stitch, choose 1-2 approved visual references from the workspace shortlist:

- `/Users/yangshu/Codex/docs/design-reference-shortlist.md`

Translate those references into a project-specific `DESIGN.md` direction first instead of asking Stitch to copy a brand literally.

Check the source artifacts into the target repository under:

- `design/stitch/`

Recommended contents:

- exported HTML or CSS mockups
- screenshots
- prompt notes
- short README explaining what the export represents
- the reference inspirations used (for example `vercel + mintlify`)

## Stage 2: Google AI Studio

Use Google AI Studio to create a runnable prototype after the design direction is clear.

Check prototype artifacts into the target repository under:

- `prototypes/ai-studio/`

Recommended contents:

- exported ZIP contents or selected generated source files
- prompt notes
- known limitations such as missing backend, placeholder secrets, or demo-only logic
- short README explaining how the prototype was produced

## Stage 3: Codex

Use Codex to convert the prototype into maintainable repository code.

Codex responsibilities:

- confirm or create the repository `DESIGN.md` before implementation when UI direction matters
- move generated code into the real project structure
- replace placeholder logic with repository-native integrations
- connect configuration, environment variables, and production services
- add narrow verification and review notes
- route the result through GitHub review

## Repository conventions

When a repository uses this workflow, it should contain:

- `DESIGN.md`
- `design/stitch/`
- `prototypes/ai-studio/`
- `docs/agent-handoff.md`

## Handoff expectations

Before switching between Stitch, AI Studio, Codex, or Cursor:

- update `docs/agent-handoff.md`
- record source artifact paths
- record the `DESIGN.md` reference or shortlist inspirations in use
- record current branch
- record changed files
- record verification
- state the smallest safe next step

Use the local wrapper when available:

```bash
./scripts/handoff-refresh.sh --verify "git status --short"
```
