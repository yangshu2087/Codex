---
name: webpage-capture-markdown
description: Capture an external webpage into a reusable local markdown note. Use when the user wants a rendered page saved locally, preserved for later reference, or turned into a markdown source artifact rather than only summarized in chat.
---

# Webpage Capture Markdown

Use this skill when a webpage should become a local working artifact, not just a one-off answer.

## Workflow

1. Decide whether capture is necessary:
   - if the user only needs a factual answer, use normal web research
   - if the user wants a reusable file, local note, or preserved source snapshot, continue
2. Choose the lightest capture method that will work:
   - simple public page: use web tools first
   - JavaScript-heavy or interaction-heavy page: use `playwright`
   - authenticated or manually prepared page: ask the user before attempting interactive capture
3. Save output as markdown with minimal frontmatter:
   - `url`
   - `title`
   - `captured_at`
   - optional `source_method`
4. Default output location, unless the user specifies another path:
   - `web-captures/<domain>/<slug>.md`
5. Preserve the important content, headings, links, and any notes about capture limitations.
6. Do not auto-download images or media unless the user explicitly asks.
7. In the final report, include:
   - saved file path
   - capture method used
   - anything that could not be captured cleanly

## Team fit

- This skill is the current Codex-workspace adaptation of a useful workflow seen in `baoyu-url-to-markdown`.
- Keep it toolchain-native to this workspace; do not assume `bun` or Claude-specific plugin behavior.
