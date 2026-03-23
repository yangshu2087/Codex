# Local Codex Upgrade Notes

## Audited on 2026-03-23

- Active CLI path: `/Users/yangshu/.local/bin/codex`
- Active CLI version: `codex-cli 0.116.0`
- Bundled desktop CLI path: `/Applications/Codex.app/Contents/Resources/codex`
- Bundled desktop CLI version: `codex-cli 0.116.0-alpha.10`
- Desktop app bundle version: `26.318.11754`
- Official desktop installer URL: `https://persistent.oaistatic.com/codex-app-prod/Codex.dmg`
- Latest stable npm release for `@openai/codex`: `0.116.0`
- Latest alpha npm tag for `@openai/codex`: `0.117.0-alpha.8`
- Latest GitHub release for `openai/codex`: `0.116.0`
- Latest GitHub release publish time: `2026-03-19T17:51:35Z`

## What the second-pass review changed

- Tuned `~/.codex/config.toml` for a stronger default operating mode:
  - changed default reasoning from `high` to `medium` for better day-to-day latency and iteration speed
  - added `review_model = "gpt-5.4"` so `/review` stays on a strong model even if the active session profile is lighter
  - added `project_doc_fallback_filenames` and `project_doc_max_bytes` to improve instruction discovery when `AGENTS.md` is absent or large
  - added MCP startup and tool timeouts for Notion and OpenAI docs to reduce false timeout failures
  - added `tui.notifications = true`
  - explicitly enabled the custom user skill path for local Codex maintenance
- Updated `~/.codex/AGENTS.md` to codify:
  - `~/.agents/skills` as the custom user skill location
  - the rule that global skills should stay narrow and low-count
  - a stricter local Codex verification loop after config changes
- Updated `/Users/yangshu/Codex/.codex/config.toml` so this maintenance workspace can safely write both `~/.codex` and `~/.agents`
- Updated `/Users/yangshu/Codex/AGENTS.md` to include:
  - official desktop installer checks in the maintenance workflow
  - the custom `codex-local-ops` skill as the preferred repeated-maintenance path
- Added a custom user skill at `~/.agents/skills/codex-local-ops/SKILL.md`
  - this skill standardizes local Codex audits, upgrade checks, config tuning, and post-change verification
- Upgraded `/Users/yangshu/Codex/scripts/check-codex-upgrade.sh`
  - it now reports active CLI versus bundled CLI, compares the installed app against the official desktop installer, and summarizes config and skill-layer presence

## High-signal findings from official docs and public discussion

- Official guidance is increasingly explicit about layered customization:
  - personal defaults in `~/.codex/config.toml`
  - project overrides in `.codex/config.toml`
  - repeated repo guidance in `AGENTS.md`
  - repeated workflows in skills
- Official current skill guidance points custom skills to `.agents/skills` rather than keeping everything under `.codex/skills`
- `/review` can use its own `review_model`, which is worth pinning separately from the default interactive model
- Config keys now expose instruction fallbacks, skill enablement, and MCP timeout controls that are useful for a daily-driver setup
- Community feedback is directionally consistent on two practical points:
  - multi-agent work helps when subtasks are independent and parallelizable, not when the next step is blocked on one answer
  - too many global skills can slow first-turn routing, so global skills should stay few and specific

## Current practical operating policy

- Keep the desktop app on the stable build unless there is a clear reason to test preview binaries
- Keep the standalone CLI on PATH so CLI upgrades are decoupled from the app bundle
- Use default `medium` reasoning for normal work
- Use `quick` for lowest-latency local runs
- Use `research` when the task genuinely needs live web search
- Use `/review` for code review tasks so findings stay explicit and the review model stays strong
- Add a new custom skill only when the workflow repeats and cannot be expressed cleanly with AGENTS plus a small script

## Compatibility notes

- In this environment, `gpt-5.4` with `reasoning.effort = "minimal"` cannot be combined with the `web_search` tool.
- In this environment, the routed `gpt-5.4` coding model does not accept `reasoning.effort = "minimal"`; use `none`, `low`, `medium`, `high`, or `xhigh` instead.
- The global `quick` profile intentionally uses `model_reasoning_effort = "none"` with `web_search = "disabled"` to stay compatible.

## Sources

- [Codex best practices](https://developers.openai.com/codex/learn/best-practices/)
- [Codex customization concepts](https://developers.openai.com/codex/concepts/customization/)
- [Codex skills](https://developers.openai.com/codex/skills/)
- [Codex config reference](https://developers.openai.com/codex/config-reference/)
- [Running local code review](https://developers.openai.com/codex/cli/features/#running-local-code-review)
- [OpenAI Codex GitHub release 0.116.0](https://github.com/openai/codex/releases/tag/rust-v0.116.0)
- [npm package: @openai/codex](https://www.npmjs.com/package/@openai/codex)
