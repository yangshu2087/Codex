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

## Review checklist before adopting a candidate

1. Read `SKILL.md` and any scripts for write actions, network calls, daemon use, secrets, and hidden dependencies.
2. Prefer extracting a small local subset over vendoring an entire repo.
3. Set `allow_implicit_invocation: false` for broad or expensive skills.
4. Add an entry to `skills-lock.json` with source, path, hash, install layer, and default-enabled state.
5. Run `scripts/skill-audit.sh` and `scripts/skill-smoke.sh` before using it in normal work.
