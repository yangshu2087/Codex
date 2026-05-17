# Codex Creative / UI Capability Playbook

Purpose: make Codex useful for UI and brand-asset creation without using OpenAI API billing by default. Codex prepares briefs, SVG/logo directions, HTML showcases, ChatGPT UI prompts, and verification evidence; the human uses ChatGPT UI manually for final bitmap image generation.

This playbook is workspace-level guidance. It does not write API keys, install image dependencies, call Gemini/OpenAI image APIs, automate ChatGPT UI, read browser cookies, or modify child repositories.

## Product contract

- User goal: quickly turn a product or brand idea into reusable creative artifacts that can support UI design, logo exploration, marketing visuals, and handoff.
- Business rules:
  - ChatGPT UI image generation is a manual human step.
  - Codex may generate prompts, SVG, HTML showcase pages, and verification checklists.
  - Codex must not claim visual completion until a generated asset or showcase is checked with browser, screenshot, Playwright, or agent-browser evidence.
  - API-key-backed image generation is out of scope unless a later task explicitly changes the policy.
- Non-goals: no OpenAI Image API live calls, no Gemini/Nano Banana calls, no ChatGPT browser automation, no Cookie/profile reuse, no automatic external writes.
- Edge cases:
  - `OPENAI_API_KEY` missing is expected and should not block prompt/SVG/HTML handoff.
  - If `OPENAI_API_KEY` is present, smoke scripts must report presence but still avoid live calls.
  - If the final bitmap is not returned to the workspace, record `manual_chatgpt_required` and do not claim visual completion.
  - If system pressure is high, use single-agent and avoid batch generation.
- Acceptance criteria: every creative task has a brief, prompt/handoff artifact, output path, verification evidence or explicit blocker, and known licensing/source notes.

## Architecture decision

| Option | Tradeoff | Rollout | Rollback | Decision |
|---|---|---|---|---|
| ChatGPT UI only | Cheapest and uses existing subscription, but lacks reproducible workspace artifacts unless Codex writes handoff notes. | User manually prompts ChatGPT. | Delete handoff notes. | Useful but incomplete alone. |
| OpenAI/Gemini API automation | Fully automatable, but introduces API billing, secrets, quota/rate failures, and higher governance burden. | Add key, dependencies, scripts. | Remove key, revoke token, delete outputs. | Rejected for default path. |
| Manual ChatGPT UI handoff plus Codex artifacts | Preserves subscription-only generation while making prompts, SVGs, showcases, and verification reproducible. | Add playbook/templates/smoke. | Revert docs/scripts/lock entries. | Recommended. |

## Standard workflow

1. **Brief**: fill `docs/templates/creative-asset-brief.md` or create a repo-local copy under `design/creative-briefs/`.
2. **Concept**: use `logo-generator` only for SVG/logo directions, design rationale, and local HTML showcases by default.
3. **Handoff prompt**: fill `docs/templates/chatgpt-image-handoff.md` with a copy-ready prompt for ChatGPT UI.
4. **Manual generation**: user pastes the prompt into ChatGPT UI and downloads or screenshots the generated image.
5. **Asset return**: place returned assets under the target repo, normally `output/creative/` or project-specific `design/` paths.
6. **Verification**: run browser/screenshot/agent-browser checks against the returned image or showcase and record evidence.
7. **Handoff**: record prompt, source, timestamp, output path, manual-generation note, and remaining visual gaps in PR or handoff docs.

## Recommended workspace directories

- `design/creative-briefs/`: reusable briefs and brand decisions in the target repo.
- `output/creative/`: returned image files, screenshots, and exported SVG/PNG assets.
- `output/imagegen-prompts/`: ChatGPT UI prompt handoffs and dry-run previews.
- `tmp/creative-ui-smoke/`: temporary smoke artifacts; do not commit.

Create these directories only in the target repo when a real creative task needs them. The workspace playbook defines the pattern but does not bulk-create child-repo folders.

## API / permissions contract

- API contract: default mode is `no_live_image_api`; only `imagegen --dry-run` is allowed for request preview.
- Error semantics:
  - `missing_api_key_allowed`: no API key is acceptable for the default ChatGPT UI handoff flow.
  - `manual_chatgpt_required`: final bitmap generation remains a human ChatGPT UI step.
  - `browser_evidence_missing`: visual completion is blocked until a screenshot/browser/agent-browser check exists.
  - `provider_key_present_not_used`: an API key exists, but scripts intentionally avoid live calls.
- Permissions:
  - Do not read browser cookies, ChatGPT login state, or Chrome profiles.
  - Do not write `.env` files or API keys.
  - Do not call OpenAI/Gemini image APIs unless a future task explicitly changes the policy.
  - Do not install image dependencies globally as part of this default flow.
- Data consistency:
  - Keep source prompt, date, author/agent, target project, intended use, output path, and verification screenshot together.
  - Separate repo-native SVG/HTML sources from AI-generated PNG/JPG outputs.
  - Mark prompts as instructions, not proof of final visual output.
- Observability:
  - Smoke scripts report feature status, skill presence, dry-run success, browser screenshot path, and whether any API key was present but unused.

## Creative/UI quality contract

For each generated asset, state:

- Visual thesis: mood, material, hierarchy, and energy.
- Content plan: what the asset communicates and where it will be used.
- Interaction or usage thesis: how it supports a UI, brand mark, hero, card, or empty state.
- State coverage when relevant: default, hover, focus-visible, active, loading, empty, error, disabled, success.
- Accessibility notes: contrast, text legibility, focus/tap target impact if embedded in UI.
- Verification evidence: browser/screenshot/agent-browser path or exact blocker.

## Rollout and rollback

- Rollout: add this playbook, templates, smoke script, and `skills-lock.json` record; then run smoke locally.
- Rollback: revert the docs/templates/script/lock entries and rerun `skill-smoke.sh` plus `codex-capability-audit.sh`.
- Promotion: if API-backed generation is later approved, add a new plan with billing, key storage, rate limits, and live-call regression tests.
