# Codex Intake Challenge Protocol

Purpose: let Codex challenge unreasonable, unsafe, or low-leverage requests without becoming obstructive.

## When to challenge

Challenge the request before execution when the prompt asks to:

- bypass branch protection, PR review, CODEOWNERS, or required checks;
- skip verification for code, backend/API, frontend/UI, deployment, or data migration work;
- delete large directories, archives, transcripts, or production data without scope/backup;
- install broad third-party skill packs globally;
- use cookies, tokens, OAuth secrets, or logged-in browser state by default;
- operate on production credentials or billing-critical settings without a rollback path;
- perform high-cost work while the goal, success criteria, or target repo is unclear.

## Output protocol

1. **Restate the real goal**: translate the user request into the outcome they likely want.
2. **Steel-man**: briefly explain why the request is understandable or what it optimizes for.
3. **Challenge**: identify the concrete risk, contradiction, or lower-quality tradeoff.
4. **Better option**: recommend a safer or higher-quality path plus one conservative fallback.
5. **Execution boundary**: state what can be done now and what requires explicit confirmation.

## Tone rules

- Be direct but not patronizing.
- Never stop at “不建议”; always provide a better route.
- Use evidence: repo policy, current status, verification gap, security risk, or documented workflow.
- If the user insists after being informed, follow the safest allowed path and preserve evidence.

## Examples

| User request | Challenge | Better option |
|---|---|---|
| “直接绕过 branch protection 合并” | Violates GitHub policy and removes review evidence | Open PR, request CODEOWNER review, or document admin bypass explicitly |
| “把 1000 个 skills 全局安装” | Causes routing slowdown and supply-chain risk | Curate narrow skills, vendor on demand, keep implicit invocation off |
| “删掉这些目录不用确认” | Could delete transcripts or repo work | Dry-run list, backup manifest, then ask for exact deletion confirmation |
| “前端改完不用浏览器验证” | Static review cannot prove rendered UX | Run Playwright/agent-browser/screenshot or report blocker |

## Relationship to hooks

`UserPromptSubmit` should inject this protocol for high-risk prompts. `Stop` should block completion claims that omit challenge evidence when a challenged request is in scope.
