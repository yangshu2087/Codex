# Codex Latest Practices — 2026-04-14

This note records the stable Codex guidance selected for this local workspace after checking OpenAI official docs, GitHub release metadata, npm package tags, and the OpenAI skills repository. X/Twitter posts were treated as discovery hints only because the public page content could not be reliably extracted in this environment.

## Selected stable baseline

- CLI channel: stable only.
- Installed target: `codex-cli 0.120.0` from `openai/codex` release `rust-v0.120.0`.
- Not selected: `0.121.0-alpha.6`, because the workspace policy is stable-first.
- Default model: `gpt-5.4`.
- Default reasoning: `high`; omit explicit `service_tier = "flex"` on this ChatGPT login path because smoke testing rejected it after the 0.120.0 upgrade.
- Deep profile: keep `xhigh` for architecture-heavy, long-running, or difficult debugging tasks.
- Quick/fast profiles: use `gpt-5.4-mini` with `low` reasoning for simple edits, short explanations, and lightweight subagent tasks; keep `fast` service tier only for these fast paths.
- Legacy fallback: keep `gpt-5.3-codex` as an explicit `codex53` profile only.

## Official practices to encode locally

- Use `AGENTS.md` as durable workflow memory, not chat history. Keep it short and update it when the same mistake repeats.
- For complex work, require a task card before execution: Goal, Constraints, Non-goals, Done criteria, Verification commands.
- Use `/review` before merge or after major implementation work. Reference `docs/code_review.md` from `AGENTS.md` so reviewer behavior is stable across threads.
- Use skills for repeatable workflows, but keep global skills few and narrow. Repo/workspace skills belong under `.agents/skills`; personal skills belong under `~/.agents/skills`.
- Use plugins and MCP only when they remove a real manual loop. Prefer on-demand invocation for GitHub, Google Drive, Slack, Gmail, and other external tools.
- Use web search mode intentionally: cached by default, `research` profile for live information.
- Use subagents for bounded parallel sidecar work only; keep `agents.max_threads = 4` and `max_depth = 1` on this 16GB M4 machine.
- Use Codex Cloud/PR review when GitHub workflow needs remote review, but keep GitHub as the system of record for branch policy and PR state.
- Use `codex exec` only for stable, scriptable workflows; capture outputs and avoid turning ambiguous work into automation too early.

## Local decisions

- Keep `/Applications/Codex.app` unchanged unless the user explicitly requests a desktop binary replacement.
- Keep standalone CLI independent at `/Users/yangshu/.local/bin/codex`.
- Restore workspace governance docs, runtime scripts, skill audit/smoke scripts, worktree lifecycle scripts, and `frontend-design-review` as the local ability layer.
- Keep SkillTrust-derived third-party skills mirrored as vendored-on-demand subsets, not global catch-all skills.
- Strengthen front-end workflow with OpenAI `frontend-skill` ideas: visual thesis, content plan, interaction thesis, first-viewport composition checks, restrained typography/color, purposeful motion, and mandatory visual/browser verification.

## Sources

- OpenAI Codex Best Practices: https://developers.openai.com/codex/learn/best-practices
- OpenAI Codex CLI Features: https://developers.openai.com/codex/cli/features
- OpenAI Codex Models: https://developers.openai.com/codex/models
- OpenAI Codex Skills: https://developers.openai.com/codex/skills
- OpenAI Codex Plugins: https://developers.openai.com/codex/plugins
- OpenAI Codex Config Reference: https://developers.openai.com/codex/config-reference
- OpenAI Codex Automations: https://developers.openai.com/codex/app/automations
- OpenAI Codex GitHub Integration: https://developers.openai.com/codex/integrations/github
- OpenAI AGENTS.md Guide: https://developers.openai.com/codex/guides/agents-md
- OpenAI Codex GitHub release 0.120.0: https://github.com/openai/codex/releases/tag/rust-v0.120.0
- OpenAI skills repository: https://github.com/openai/skills

## 2026-04-14 quality expansion addendum

This addendum records the second-pass quality plan after searching OpenAI official docs, `openai/codex`, `openai/skills`, and high-signal GitHub skill repositories. Twitter/X public pages were not reliable enough to use as evidence, so they remain discovery hints only.

### Answer quality lanes

- Requirements and product tasks should start as a product contract before implementation: user goal, business goal, non-goals, assumptions, edge cases, acceptance criteria, verification method, and open questions.
- Architecture tasks should include option comparison, tradeoffs, migration or rollout plan, rollback path, operational risk, and a recommendation before code changes.
- Backend/API tasks should state the API contract, error semantics, permission/auth behavior, data consistency expectations, observability impact, and the smallest regression checks.
- Front-end and UX tasks should use repository design inputs, define a visual or UX thesis, cover default/hover/focus/loading/empty/error/disabled states when relevant, and include a real browser or visual verification pass before completion.
- Code quality tasks should verify the diff against done criteria and use `/review` or `docs/code_review.md` for non-trivial changes.
- Research tasks should prefer official sources, GitHub releases, npm/package registries, and primary docs; X/Twitter should be cited only as an unverified lead unless the content is directly readable.

### GitHub skill expansion policy

- Official first: prefer `openai/skills` and official plugin skills when a capability already exists there.
- Third-party skills are candidates, not defaults. Record them in `docs/codex-github-skill-watchlist-2026-04-14.md` and install only after a scoped review.
- Avoid duplicate global skills when the current workspace already has the capability, such as Context7/OpenAI docs, agent-browser, Figma, Playwright, and GitHub CI/comment handling.
- Multi-agent swarm skills are useful only for bounded review/triage with clear cost controls; keep them on-demand because this machine is 16GB RAM and already uses a 4-thread agent cap.

### Local implementation selected

- Add three explicit workspace skills: `architecture-decision-review`, `backend-api-contract-review`, and `product-ux-flow-review`.
- Keep their implicit invocation disabled through `agents/openai.yaml`; trigger them explicitly or through AGENTS guidance for high-signal tasks.
- Add user prompt templates for backend/API, UX flow, and code quality.
- Extend Stop-hook quality checks so architecture/backend/frontend/UX completion claims include lane-specific evidence rather than only a generic “done”.

### Multi-channel capability layer implementation

- Keep the selected model/plugin baseline unchanged and enhance capability through prompts, workspace skills, docs, and hybrid Stop-hook evidence gates.
- Treat architecture, backend/API, front-end/UI, UX/product-flow, design humanization, code review, handoff, and regression smoke as separate evidence channels.
- Keep third-party skill candidates reviewed and vendored-on-demand only; do not promote broad review, browser, or branch-spec skills into global implicit routing without a focused review and smoke.
