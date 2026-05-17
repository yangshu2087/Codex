---
name: gpt-image-cn-router
description: Use when the user asks in Chinese for GPT Image 2 prompt-atlas patterns, poster or UI mockup prompt drafting, reference-image edit planning, or an explicitly approved `gpt-image` live call within the current Codex or Hermes workflow.
---

# gpt-image 中文路由器

## Overview

This workspace skill is the Chinese entrypoint for the vendored `gpt-image` capability.

Use it to decide among three routes:
1. prompt-only / reference mode;
2. ChatGPT UI manual handoff mode;
3. live OpenAI API generation/edit mode through the vendored `gpt-image` CLI.

Read the full operating guide here:

`/Users/yangshu/Codex/docs/gpt-image-skill-usage.md`

## Route selection

### A. Prompt-only / reference mode

Choose this when any of the following is true:
- the user says not to call the API;
- `OPENAI_API_KEY` is missing;
- the user only wants inspiration, prompt drafting, style exploration, UI mockup prompt patterns, poster prompt patterns, or reference-image edit planning.

What to use:
- `/Users/yangshu/Codex/vendor/skills/gpt-image/references/gallery.md`
- the relevant category files under `references/`
- `/Users/yangshu/Codex/vendor/skills/gpt-image/references/craft.md`

### B. ChatGPT UI manual handoff mode

Choose this when the user wants the final bitmap image but does not want API billing.

What to do:
- write a copy-ready prompt;
- point to `/Users/yangshu/Codex/docs/templates/chatgpt-image-handoff.md` when useful;
- require a returned asset path or screenshot before claiming visual completion.

### C. Live OpenAI API mode

Choose this only when:
- the user explicitly approves OpenAI image API usage;
- `OPENAI_API_KEY` is present;
- an output path is defined or agreed;
- the task actually benefits from the upstream prompt atlas or edit workflow.

Canonical command:

```bash
uv run /Users/yangshu/Codex/vendor/skills/gpt-image/scripts/generate.py -p "PROMPT" [-f OUT] [-i REF...] [-m MASK] [options]
```

## Hard rules

- Do not assume `OPENAI_API_KEY` exists.
- Do not write `.env` files or API keys.
- Do not use browser cookies, ChatGPT login state, or hidden browser automation as a fallback.
- Do not claim an image exists unless an output file path or screenshot exists.
- Do not widen this skill into a default image route; it is an explicit Chinese router for `gpt-image` workflows.
- If the user only wants general OpenAI image generation and does not need the upstream prompt atlas, prefer the existing `imagegen` route.

## Quality and cost guidance

- `low`: cheap drafts, many variants, rough exploration.
- `medium`: normal exploration.
- `high`: exact text, posters, Chinese typography, diagrams, final assets.

If the user asks for many variants or cheap exploration, steer to `low` or `medium`.
If the user asks for a final shipping-facing asset, steer to `high`.

## Error reporting

Use these terms consistently:
- `missing_api_key`
- `missing_image_path`
- `missing_mask_path`
- `api_rejected`
- `browser_evidence_missing`

## Verification

```bash
uv run /Users/yangshu/Codex/vendor/skills/gpt-image/scripts/generate.py -p 'Codex gpt-image smoke check'
/Users/yangshu/Codex/scripts/manage-vendored-skill.sh status gpt-image
```

Without `OPENAI_API_KEY`, the expected result is a missing-key error rather than an import/path failure.
