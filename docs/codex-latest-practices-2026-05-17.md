# Codex latest practices — 2026-05-17

Purpose: keep the local Codex workspace aligned with current official guidance while preserving the stability-first policy for this 16GB M4 machine.

## Local baseline

- CLI: `codex-cli 0.130.0`, latest stable at the time of this review.
- Desktop: `26.513.31313`, matching the current official installer checked by `scripts/check-codex-upgrade.sh`.
- MCP/OAuth: Cloudflare, Notion, Context7, and Sentry are configured through MCP OAuth; use `scripts/codex-mcp-oauth-refresh.sh --check` after auth changes.
- Feature posture: stable features can be used normally; under-development or experimental features require a smoke check before promotion.

## Model and routing decisions

- Default model: `gpt-5.5` with top-level `model_reasoning_effort = "high"` for daily work.
- Heavy work: use `--profile deep` or `--profile frontier` for `gpt-5.5/xhigh` only when the task is architecture-heavy, ambiguous, or long-horizon.
- Light work and subagents: use `--profile quick` or `--profile fast` with `gpt-5.4-mini/low/fast`.
- Stable fallback: keep `--profile codex53` for explicit legacy complex-coding regression only.
- Do not preconfigure `gpt-5.3-codex-spark`; add it only if the account model picker confirms availability and a separate smoke passes.

## Task contract and planning

Use the official-style task contract for non-trivial work:

1. Goal — what should change or be built.
2. Context — relevant files, docs, errors, screenshots, examples, or external facts.
3. Constraints — standards, architecture, safety, resource, or repo rules.
4. Non-goals — what is intentionally out of scope.
5. Done when / Done criteria — observable stopping condition.
6. Verification — exact commands, browser checks, screenshots, or review evidence.

For complex or ambiguous work, start in Plan mode and keep implementation blocked until the contract is complete.

## `/goal` policy

- Use `/goal` for long-running migrations, refactors, retry loops, or experiments with a verifiable stopping condition.
- `/goal` supplements the task contract; it does not replace Done criteria, verification evidence, review, or branch policy.
- Useful commands: `/goal <objective>`, `/goal`, `/goal pause`, `/goal resume`, `/goal clear`.
- Avoid `/goal` for high-risk external writes, broad deletes, credential work, or tasks whose success condition is vague.

## Skills, plugins, and MCP decisions

- Turn repeated local workflows into narrow skills or scripts rather than adding long prompt text.
- Use MCP/plugins when the needed context is external, OAuth-protected, fast-changing, or shared across tools.
- Do not batch-install third-party skill packs. Candidate skills must stay `defaultEnabled:false` / explicit-only until reviewed and smoked.
- Official `openai/skills` items already covered locally include review, CI, security, docs, Playwright, and browser-oriented workflows. `create-plan` remains a candidate only because it overlaps with local planning-with-files and task-card governance.

## `remote-control` posture

- `codex remote-control` exists in CLI `0.130.0`, but the feature is still under-development locally.
- Default: do not start a persistent remote-control app-server.
- Allowed check: `scripts/codex-remote-control-smoke.sh`, which validates help text and feature status without starting a daemon.

## Frontend/browser posture

- `js_repl` is now removed in local feature output, so do not treat Playwright Interactive as the default frontend path.
- Default browser verification path: Browser/Chrome plugin, `agent-browser`, screenshots, or project-local Playwright where available.
- UI completion still requires real browser, screenshot, Playwright, agent-browser, or explicit blocker evidence.

## Sources

- OpenAI Codex Best Practices: https://developers.openai.com/codex/learn/best-practices
- OpenAI Codex Models: https://developers.openai.com/codex/models
- OpenAI Codex CLI Features: https://developers.openai.com/codex/cli/features
- OpenAI Codex Slash Commands: https://developers.openai.com/codex/cli/slash-commands
- OpenAI Codex Follow a goal: https://developers.openai.com/codex/use-cases/follow-goals
- OpenAI Codex Skills: https://developers.openai.com/codex/skills
- OpenAI Codex Plugins: https://developers.openai.com/codex/plugins
- openai/codex 0.130.0 release: https://github.com/openai/codex/releases/tag/rust-v0.130.0
- openai/skills: https://github.com/openai/skills

## Round 2 refresh — 2026-05-17

This addendum reflects a second pass over recent official Codex docs and the open-source release notes. It does not change the stable-first model defaults from the first 2026-05-17 pass.

### New high-signal findings

1. Remote connections are now a first-class Codex workflow. A connected Mac host supplies the same projects, files, credentials, plugins, MCP servers, skills, browser access, Computer Use, sandboxing, and approvals to mobile/remote sessions. This is useful, but only if the host stays awake and app-server listeners are not exposed publicly.
2. Auto-review documentation is now clearer: auto-review is a reviewer swap at the sandbox boundary, not a permission expansion. It only matters when approval prompts can surface; with `approval_policy = "never"`, there is nothing to review.
3. Automations can use worktrees, plugins, and skills. They are powerful but risky under full access; recurring automation should use isolated worktrees and narrow prompts first.
4. Browser routing should be explicit: use the in-app Browser for unauthenticated local/public pages; use Chrome when signed-in profile, cookies, extensions, or existing tabs are required.
5. Iterative repair loops work best when each iteration records baseline evidence, the smallest repair, validation output, remaining delta, and a stop condition.
6. Repo-local skills remain the highest-leverage form of Codex customization for repeatable engineering tasks. The useful pattern is narrow skills with clear trigger, inputs, outputs, and optional scripts.

### Local actions from this pass

- Added `scripts/codex-remote-readiness.sh` for read-only remote host readiness checks.
- Added `scripts/codex-auto-review-safety-audit.sh` for sandbox/approval/auto-review posture checks.
- Added `/Users/yangshu/.codex/prompts/iterative-repair-loop-template.md` for evidence-driven retry loops.
- Wired remote readiness and auto-review audit into `scripts/codex-quality-smoke-fast.sh` and `scripts/codex-quality-regression.sh`.
- Updated AGENTS rules so future agents do not treat remote connections, automations, or auto-review as default permission expansion.

### Decision table

| Capability | Decision | Why |
|---|---|---|
| Remote connections / mobile Codex | Prepare, do not force-enable | Useful for long-running work, but host sleep/network/listener posture matters. |
| `codex remote-control` | Keep smoke-only | CLI entrypoint exists, but local feature remains under-development/false. |
| Auto-review | Keep as explicit guarded profile | It can reduce approval friction without widening sandbox boundaries. |
| Automations | Use only with durable prompts and isolated worktrees | Unattended runs can mutate files; first runs should be reviewed. |
| Browser vs Chrome | Route by auth/profile need | In-app Browser is safer for local/public pages; Chrome is needed for signed-in pages. |
| Iterative repair loop | Add reusable prompt template | Prevents broad rewrites and makes convergence measurable. |

### Additional sources used in Round 2

- OpenAI Codex Remote connections: https://developers.openai.com/codex/remote-connections
- OpenAI Codex Auto-review: https://developers.openai.com/codex/concepts/sandboxing/auto-review
- OpenAI Codex Automations: https://developers.openai.com/codex/app/automations
- OpenAI Codex In-app browser: https://developers.openai.com/codex/app/browser
- OpenAI blog, Using skills to accelerate OSS maintenance: https://developers.openai.com/blog/skills-agents-sdk
- OpenAI blog, Building frontend UIs with Codex and Figma: https://developers.openai.com/blog/building-frontend-uis-with-codex-and-figma
- OpenAI cookbook, Build iterative repair loops with Codex: https://developers.openai.com/cookbook/examples/codex/build_iterative_repair_loops_with_codex
