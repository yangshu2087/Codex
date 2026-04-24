# Codex capability boundary upgrade — 2026-04-23

Purpose: record the latest Codex usage findings and local capability changes applied to this machine/workspace after checking OpenAI docs, openai/codex release notes, npm tags, X/OpenAIDevs public signals, and high-signal GitHub skill catalogs.

## Source summary

- OpenAI Codex best practices: use task context, `AGENTS.md`, config, MCP, skills, automations, session controls, and test/review loops.
- OpenAI Codex customization docs: build in this order — `AGENTS.md`, plugins/skills, MCP, then subagents.
- OpenAI Codex skills docs: keep skills focused, use progressive disclosure, prefer `$HOME/.agents/skills` for personal skills and `.agents/skills` for repo skills, set `allow_implicit_invocation: false` for explicit-only skills.
- OpenAI Codex models docs: start with `gpt-5.5` when available; use `gpt-5.4` if not; use `gpt-5.4-mini` for light tasks and subagents.
- OpenAI Codex subagents docs: custom agents now support role-specific TOML files; use subagents only when explicitly asked and keep depth/concurrency bounded.
- OpenAI Codex release `rust-v0.124.0`: stable hooks, quick reasoning controls, multi-environment app-server sessions, Bedrock support, better MCP/plugin behavior, Fast service tier default for eligible ChatGPT plans.
- GitHub skill catalogs reviewed as discovery signals only: `openai/skills`, `ComposioHQ/awesome-codex-skills`, and `shinpr/awesome-codex-workflows`.
- X/OpenAIDevs public signal: Codex is expanding beyond code into Mac apps, tools, image creation, memory, and repeatable tasks; this repo keeps high-risk features gated until validated locally.

## Local baseline before this pass

- Active CLI: `/Users/yangshu/.local/bin/codex`
- Installed CLI before upgrade: `codex-cli 0.122.0-alpha.5`
- Latest stable checked via npm/GitHub: `0.124.0`
- Desktop app: `26.422.21637`, matching the official installer at the time of the check.
- Existing repo had unrelated dirty changes for creative/UI and local storage scripts; this pass avoids staging those unless explicitly requested.

## Applied changes

1. Upgraded standalone Codex CLI from alpha `0.122.0-alpha.5` to stable `0.124.0`.
2. Updated user config for current official model guidance:
   - default `model = "gpt-5.5"`
   - default `model_reasoning_effort = "high"`
   - `/review` model now `gpt-5.5`
   - `deep`, `research`, and new `frontier` profile use `gpt-5.5`
   - `frontier` profile keeps `xhigh` reasoning for maximum-depth tasks
   - `guarded` profile enables `approvals_reviewer = "auto_review"` for high-risk approval review workflows
   - `features.memories = false` is explicit because Memories are still experimental locally; manual audited memory remains the default.
3. Added project-scoped custom agents in `.codex/agents/`:
   - `pr_explorer`: read-only codebase mapping
   - `reviewer`: read-only correctness/security/test reviewer
   - `docs_researcher`: read-only official docs verifier
   - `browser_debugger`: browser/UI evidence collector
   - `ui_fixer`: small targeted UI fixer after evidence exists
4. Added `scripts/codex-boundary-smoke.sh` to verify the version/config/agent boundary in one command.

## Recommended routing after this pass

| Task | Default route | Escalation |
|---|---|---|
| Simple explanation or small edit | `--profile quick` | default if quality drops |
| Normal engineering | default `gpt-5.5/high` | `--profile frontier` for hard reasoning |
| Architecture / product planning | Plan mode + task card | `--profile frontier` |
| Current external facts | `--profile research` | docs_researcher subagent when explicitly asked |
| PR review / quality gate | `/review` + `docs/code_review.md` | pr_explorer + reviewer + docs_researcher subagents |
| UI bug / frontend regression | frontend-design-review + browser evidence | browser_debugger + ui_fixer subagents |
| High-risk shell/MCP/app action | default approvals | `--profile guarded` with auto-review |
| Long-term memory | audited Markdown/JSONL | enable official Memories only after a separate privacy review |

## Skill adoption decisions

- Adopt now: no broad third-party skill install.
- Keep using existing curated/plugin skills: OpenAI curated `playwright`, `figma`, `gh-fix-ci`, `gh-address-comments`, `security-*`, and existing Vercel/Cloudflare/GitHub plugin skills.
- Watchlist only: Composio `create-plan`, `webapp-testing`, `mcp-builder`, `sentry-triage`, `codebase-migrate`, `developer-growth-analysis`.
- Reject default global install for broad packs or toolkits that add large action surfaces, app connectors, or crawler/browser-cookie behavior.

## Rollback

- CLI: restore the backup under `/Users/yangshu/.local/bin/codex-backups/`.
- Config: restore `/Users/yangshu/.codex/config.toml.bak-20260423-capability-boundary`.
- Custom agents: remove `.codex/agents/*.toml` added in this pass.
- Repo docs/scripts: revert this document and `scripts/codex-boundary-smoke.sh`.

## Verification commands

```bash
codex --version
codex features list
codex mcp list
/Users/yangshu/Codex/scripts/check-codex-upgrade.sh
/Users/yangshu/Codex/scripts/codex-boundary-smoke.sh
git diff --check
```
