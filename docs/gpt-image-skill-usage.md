# gpt-image skill usage

Purpose: provide a Chinese-first operating guide for the vendored `gpt-image` skill in `/Users/yangshu/Codex`, and define how Codex / Hermes should route image requests across prompt drafting, ChatGPT UI handoff, and OpenAI API execution.

This document is a workspace playbook. It does not write API keys, automate ChatGPT UI, read cookies, or enable live image calls by default.

## Task card

- Goal: make `wuyoscar/gpt_image_2_skill` usable in the current Codex / Hermes workflow through a Chinese instruction layer and a clear operating contract.
- Constraints: keep the upstream skill reviewed and explicit-only; do not assume `OPENAI_API_KEY`; do not default to live API calls; stay inside `/Users/yangshu/Codex`.
- Non-goals: no ChatGPT login-state reuse, no cookie handling, no automatic billing enablement, no child-repo rollout.
- Done criteria: Chinese usage doc exists, a Chinese router skill exists, the route contract is clear, and local skill smoke passes.
- Verification commands:
  - `test -f /Users/yangshu/Codex/docs/gpt-image-skill-usage.md`
  - `test -f /Users/yangshu/Codex/.agents/skills/gpt-image-cn-router/SKILL.md`
  - `python3 -m json.tool /Users/yangshu/Codex/skills-lock.json >/dev/null`
  - `/Users/yangshu/Codex/scripts/skill-smoke.sh`
  - `/Users/yangshu/Codex/scripts/codex-capability-audit.sh`

## Product contract

- User goal: ask for GPT Image 2 capabilities in Chinese without needing to remember the raw CLI flags.
- Primary journeys:
  1. **Prompt-only**: use the gallery and craft references to draft or improve prompts without API usage.
  2. **ChatGPT UI handoff**: convert the prompt into a copy-ready handoff for manual generation in ChatGPT UI.
  3. **Live OpenAI API call**: only when the user explicitly allows API billing and `OPENAI_API_KEY` is present.
- Hermes role: act as the supervision and quality lane, checking whether the request should stay in prompt mode, switch to manual UI handoff, or proceed to the vendored `gpt-image` CLI.
- Completion rule: do not claim an image was generated unless an output file path or screenshot exists.

## Architecture decision

| Option | Tradeoff | Rollout | Rollback | Decision |
|---|---|---|---|---|
| Document only | Easy to maintain, but no reusable Chinese trigger surface for future sessions. | Add one markdown file. | Delete the file. | Not enough alone. |
| Rewrite upstream `gpt-image` skill into Chinese | Fewer entrypoints, but pollutes the vendored upstream and makes upgrades harder. | Edit vendored skill heavily. | Revert vendored files. | Not recommended. |
| Add a Chinese router skill that delegates to vendored `gpt-image` | Clear local workflow, easy to roll back, preserves upstream semantics, and fits Codex / Hermes supervision. | Add doc + wrapper skill + lock entry. | Remove wrapper skill + revert lock/doc. | **Recommended** |

## Where the actual skill lives

- Vendored upstream skill: `/Users/yangshu/Codex/vendor/skills/gpt-image`
- Active symlink: `/Users/yangshu/.agents/skills/gpt-image`
- Chinese router skill: `/Users/yangshu/Codex/.agents/skills/gpt-image-cn-router`

## Route selection for Codex / Hermes

### Route A — prompt-only / gallery mode

Use this when:
- the user says “先写 prompt” / “只给提示词” / “不要调用 API” / “先做风格探索”;
- `OPENAI_API_KEY` is missing;
- the user only wants style references, Chinese typography guidance, UI mockup prompt ideas, poster prompt ideas, or reference-image edit planning.

What to do:
- read only the relevant reference files under `vendor/skills/gpt-image/references/`;
- draft a prompt in Chinese or bilingual format;
- optionally produce a ChatGPT UI handoff block;
- do **not** claim that the image already exists.

### Route B — ChatGPT UI handoff mode

Use this when:
- the user wants a final image but does not want OpenAI API billing;
- the user prefers manual generation inside ChatGPT UI;
- the user already uses the workspace creative playbook.

What to do:
- draft a copy-ready prompt;
- record intended output path;
- point to `/Users/yangshu/Codex/docs/templates/chatgpt-image-handoff.md` when needed;
- require a returned asset path or screenshot before claiming visual completion.

### Route C — live OpenAI API mode

Use this only when all of the following are true:
- the user explicitly allows API-backed generation/editing;
- `OPENAI_API_KEY` is present;
- the user accepts that this is separate API billing from a ChatGPT monthly subscription;
- an output file path is chosen.

Canonical command:

```bash
uv run /Users/yangshu/Codex/vendor/skills/gpt-image/scripts/generate.py \
  -p "PROMPT" \
  --quality medium \
  -f /absolute/path/to/output.png
```

## Chinese instruction patterns

### 1. Only generate prompts

```text
使用 gpt-image-cn-router，只读取 gpt-image 的 references/gallery.md 和相关分类，帮我写 3 套中文 prompt，不要做 live 调图。
```

### 2. Create a ChatGPT UI handoff

```text
使用 gpt-image-cn-router，先参考 gpt-image 的 typography / poster / ui mockup 图库，帮我生成一份可直接粘贴到 ChatGPT UI 的图片提示词，不要调用 API。
```

### 3. Live API generation

```text
使用 gpt-image-cn-router，我允许使用 OpenAI 图片 API。请用 gpt-image 生成 1 张 3:4 海报，质量 medium，输出到 /absolute/path/poster.png。
```

### 4. Reference-image edit

```text
使用 gpt-image-cn-router，我允许使用 OpenAI 图片 API。请基于 /absolute/path/photo.png 做改图，目标是冬季夜景风格，输出到 /absolute/path/photo-winter.png。
```

### 5. Inpaint with mask

```text
使用 gpt-image-cn-router，我允许使用 OpenAI 图片 API。请基于 /absolute/path/photo.png 和 /absolute/path/mask.png 做局部重绘，保留主体，只替换背景天空。
```

## Quality / cost policy

Use `--quality` deliberately:

- `low`: cheap draft mode, many variants, rough composition.
- `medium`: normal exploration and one-off creative work.
- `high`: posters, typography, diagrams, Chinese text accuracy, or shipping-facing assets.

Use `--size` deliberately:

- `square` / `1k`: default exploration.
- `portrait`: posters, magazine covers, UI marketing cards.
- `landscape`: screenshots, product scenes, hero banners.
- `2k` / `4k`: print-like or presentation-ready outputs when the user accepts the cost.

## Backend / API contract

- Generate: `POST /v1/images/generations`
- Edit / multi-reference / inpaint: `POST /v1/images/edits`
- Auth source: `OPENAI_API_KEY` from env or `~/.env`, but this workspace does not write it automatically.
- Runtime: the local Python on PATH may be 3.9, so use `uv run` to satisfy the upstream `>=3.11` requirement.

## Error semantics

- `missing_api_key`: `OPENAI_API_KEY` is not set; stay in prompt-only or ChatGPT UI handoff mode.
- `missing_image_path`: the user asked for edit/inpaint without a valid `-i` input file.
- `missing_mask_path`: the user asked for mask-based inpainting without a valid `-m` file.
- `api_rejected`: OpenAI returned a non-2xx response.
- `browser_evidence_missing`: the user asked for a final visual result but no output path or screenshot was returned.

## Permissions boundary

- Do not write `OPENAI_API_KEY`.
- Do not read browser cookies or ChatGPT login state.
- Do not automate ChatGPT UI clicks.
- Do not fall back from missing API credentials to a hidden browser-login path.

## Data consistency rules

For each task, keep these together:
- user intent;
- route used (prompt-only / ChatGPT UI handoff / live API);
- prompt text;
- input image and mask paths when relevant;
- output file path or screenshot path;
- quality / size selection;
- whether the image is only proposed, manually generated, or actually written to disk.

## Verification

### No-key smoke

```bash
uv run /Users/yangshu/Codex/vendor/skills/gpt-image/scripts/generate.py -p 'Codex gpt-image smoke check'
```

Expected result without a key:

```text
error: OPENAI_API_KEY not set. Add it to ~/.env or `export OPENAI_API_KEY=...`.
```

### Workspace verification

```bash
/Users/yangshu/Codex/scripts/manage-vendored-skill.sh status gpt-image
/Users/yangshu/Codex/scripts/skill-smoke.sh
/Users/yangshu/Codex/scripts/codex-capability-audit.sh
```

## When not to use this skill

- When the user only wants a repo-native SVG/logo workflow — use `logo-generator` first.
- When the user wants subscription-only image generation inside ChatGPT UI without API billing — use the creative/UI handoff flow.
- When the task is ordinary OpenAI image generation and you do not specifically need the upstream prompt atlas — prefer the existing `imagegen` route.

## Rollout and rollback

- Rollout: keep the vendored skill activated, use the Chinese router skill as the human-facing entrypoint, and document examples here.
- Rollback:
  - `rm /Users/yangshu/.agents/skills/gpt-image`
  - remove `/Users/yangshu/Codex/.agents/skills/gpt-image-cn-router`
  - revert `/Users/yangshu/Codex/skills-lock.json`
- Promotion path: if this becomes a common workflow, add task-specific prompt wrappers rather than widening the base `gpt-image` trigger.
