# Codex GitHub Skill Watchlist — 2026-04-14

Policy: official sources first, third-party skills as on-demand candidates only. Do not install these globally without a focused review and smoke test.

## Official baseline

- `openai/skills`: source of truth for curated Codex skills. Keep using the official `frontend-skill`, `playwright`, `figma-*`, `gh-fix-ci`, `gh-address-comments`, `security-best-practices`, and `openai-docs` patterns where they match local needs.
- `openai/codex`: stable CLI source. Current selected stable release is `rust-v0.120.0`; do not follow `0.121.0-alpha.*` unless the stability policy changes.

## Third-party candidates

| Source | Candidate focus | Decision |
|---|---|---|
| `Dimillian/Skills` | `react-component-performance`, `review-and-simplify-changes`, `project-skill-audit` | Strong candidate for vendored-on-demand review; do not global-install. |
| `Dimillian/Skills` | `review-swarm`, `bug-hunt-swarm` | Useful for deep reviews, but multi-agent cost is high; only use for explicit large reviews. |
| `ComposioHQ/awesome-codex-skills` | `create-plan`, `webapp-testing`, `mcp-builder` | Candidate references; avoid duplicates with local planning, browser, and MCP skills. |
| `ComposioHQ/awesome-codex-skills` | `connect/*`, app-action skills | Defer by default because they expand external write/action surface. |
| `blader/schematic` | Reverse-engineer product and technical spec from a branch | Good on-demand candidate for branch documentation and PR/spec handoff. |
| `serejaris/justdoit` | Convert vague tasks into execution pack files | Candidate only; overlaps with current planning-with-files and task-card rules. |
| `am-will/codex-skills` | planning, hooks, Context7/OpenAI docs, browser automation | Reference only for now; many capabilities already exist locally. |
| `Dimillian/CodexSkillManager` | macOS GUI skill manager | Evaluate separately as a tool, not as a default Codex capability. |

## 2026-04-14 focused intake result

Read-only review clone location used during intake: `/tmp/codex-third-party-skill-review`.

| Candidate | Intake result | Reasoning | Adoption rule |
|---|---|---|---|
| `Dimillian/Skills/review-and-simplify-changes` | Keep as reviewed candidate, not activated | Good review rubric for reuse/quality/efficiency/clarity, but it has optional safe-fix modes and assumes sub-agents; overlaps with local `/review` and `docs/code_review.md`. | Vendor only as explicit-only when a large diff needs simplification review; default mode must be review-only unless the user asks for fixes. |
| `Dimillian/Skills/project-skill-audit` | Keep as reviewed candidate, not activated | Useful for evidence-based skill recommendations; read-only by design, but overlaps with local `skill-audit.sh`, `skills-lock.json`, and Codex maintenance docs. | Vendor only if repeated project skill audits need session-memory analysis beyond current scripts. |
| `ComposioHQ/awesome-codex-skills/webapp-testing` | Reference only for now | Includes a helpful Playwright server helper, but duplicates local `frontend-design-review`, `playwright`, `agent-browser`, and `scripts/agent-browser-smoke.sh`; helper uses `shell=True` for server commands, so it should not become a default global skill. | Do not vendor unless a repo specifically needs the helper; prefer local browser tooling first. |
| `blader/schematic` | Keep as reviewed candidate, not activated | Useful for reverse-engineering specs from branches; depends on git/optional `gh` and 2-4 parallel agents, so it should remain on-demand under resource guardrails. | Vendor only for explicit branch/spec handoff work; keep disabled by default and document base-branch assumptions. |

No new third-party skill was activated by default in this pass. If one is later vendored, add `allow_implicit_invocation: false`, update `skills-lock.json`, and run `scripts/skill-audit.sh` plus `scripts/skill-smoke.sh`.

## 2026-04-14 Codex / OpenClaw / Hermes external channel intake

Source of record: `/Users/yangshu/Codex/docs/codex-openclaw-external-channel-intake-2026-04-14.md`. This pass used review-routing only: no install, no credential write, no crawler execution, and no OpenClaw config edit. Hermes-Agent exists at `/Users/yangshu/.local/src/Hermes-Agent`, but it is outside this workspace and dirty; this pass treats Hermes as a read-only supervision / quality-control lane and does not edit that checkout.

| Candidate | Verdict | Risk | Recommended landing zone | Next gate |
|---|---|---|---|---|
| `Panniantong/Agent-Reach` | Reference only | High | Docs/channel-matrix inspiration | Do not run `agent-reach install`; review installer, upstream CLIs, Cookie handling, and exec requirements before any future install. |
| `jackwener/opencli` | Keep existing read-only route | Medium | `/Users/yangshu/Codex/scripts/opencli-readonly.sh` | Keep live browser, `eval`, `explore/generate/synthesize`, and external auto-install behavior denied unless separately approved. |
| `epiral/bb-browser` | Reviewed candidate, not activated | High | Future isolated browser sandbox only | ClawHub `bb-browser` skill scan flagged suspicious OpenClaw/adapter-provenance mismatch; do not use logged-in browser state or `site update` yet. |
| `eze-is/web-access` | Strategy reference only | High | Routing/CDP/site-pattern design notes | Translate the three-channel routing idea; do not start its CDP proxy or write site-pattern files from Codex by default. |
| `klin-h/wechat_articles_spider` | Reject default route | Extreme | Isolated lab only | Requires WeChat login plus token/cookie persistence and warns about account bans; needs disposable account and legal/TOS review. |
| `jina-ai/reader` | Low-risk public URL route | Low | Public URL-to-Markdown preprocessor | Use only public URLs; do not forward Cookie headers; keep source URL and extraction-loss caveat. |
| `infra403/opentwitter-mcp` + `infra403/opennews-mcp` | Explicit-only API candidate | Medium | OpenClaw API lane with Hermes supervision | Use only scoped 6551 service tokens; disclose third-party provider and never fall back to X/Twitter Cookie scraping. |
| `NanmiCoder/MediaCrawler` | Reject default route | Extreme | Isolated non-commercial learning lab only | License/disclaimer limit use to learning/research and forbid large-scale/commercial crawling; do not route production work here. |
| `xcrawl-api/xcrawl-skills` | Explicit-only API candidate | Medium | Future OpenClaw API skill set | Requires approved `XCRAWL_API_KEY`; do not create `~/.xcrawl/config.json` or clone skills in this pass. |
| `obsidianmd/obsidian-clipper` | Human-operated capture route | Low | UX/knowledge-capture guidance | Keep as manual browser extension workflow; Codex should not silently drive the extension or mutate vault notes from this intake. |
| `HKUDS/CLI-Anything` | Reviewed harness-methodology candidate, not activated | Medium-High | Codex/Hermes harness methodology; future OpenClaw explicit-only candidate | Use `codex-skill/SKILL.md`, `openclaw-skill/SKILL.md`, and `cli-anything-plugin/HARNESS.md` as references; do not run `cli-hub install`, global skill installers, publish workflows, or generated real-app control without isolated review and `CLI_HUB_NO_ANALYTICS=1`. |


### CLI-Anything / CLI-Hub notes

`HKUDS/CLI-Anything` is useful as a Codex/Hermes harness-generation methodology: build/refine/test/validate a `cli-anything-<software>` wrapper around a real backend, require JSON output, and verify with subprocess tests. It is not enabled by default because CLI-Hub is a pip-based installer, writes `~/.cli-hub`, has analytics unless `CLI_HUB_NO_ANALYTICS=1`, and generated harnesses may control real desktop apps or external services. The local Hermes-Agent checkout is dirty and outside this workspace, so this pass does not edit it; if later adopted, vendor only a narrow explicit-only skill subset and keep install/publish/app-control steps behind manual approval.

All new entries added to `skills-lock.json` must remain `defaultEnabled:false` and `implicitInvocation:false` until a later focused review explicitly promotes them.

## Review checklist before adopting a candidate

1. Read `SKILL.md` and any scripts for write actions, network calls, daemon use, secrets, and hidden dependencies.
2. Prefer extracting a small local subset over vendoring an entire repo.
3. Set `allow_implicit_invocation: false` for broad or expensive skills.
4. Add an entry to `skills-lock.json` with source, path, hash, install layer, and default-enabled state.
5. Run `scripts/skill-audit.sh` and `scripts/skill-smoke.sh` before using it in normal work.
