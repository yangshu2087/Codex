# Codex Capability Registry

Snapshot date: 2026-04-08  
Scope: personal defaults + this workspace + known project-local extensions

## L0 Core stable

| Capability | Source of truth | Current state | Owner | Notes |
|---|---|---|---|---|
| Default model + reasoning | `~/.codex/config.toml` | Active, needs review | user | Current default is `gpt-5.4` with top-level `xhigh` reasoning; governance should review whether default should stay this heavy. |
| Routing profiles (`quick`, `fast`, `deep`, `research`, `codex53`) | `~/.codex/config.toml` | Active | user | Use explicit profiles instead of one-size-fits-all routing. |
| Global guardrails | `~/.codex/AGENTS.md` | Active | user | Personal execution, verification, and maintenance rules. |
| Upgrade verification | `scripts/check-codex-upgrade.sh` | Active | workspace | Stable-channel and installer parity check. |
| Handoff refresh | `scripts/update-agent-handoff.sh` | Active | workspace | Shared baton between Codex and Cursor. |
| Vendored skill activation | `scripts/manage-vendored-skill.sh` | Active | workspace | Keeps third-party skills opt-in. |

## L1 Workspace standard

| Capability | Source of truth | Current state | Owner | Notes |
|---|---|---|---|---|
| `frontend-design-review` | `.agents/skills/frontend-design-review` | Active | workspace | UI/design-first implementation and polish. |
| `repo-codex-bootstrap` | `.agents/skills/repo-codex-bootstrap` | Active | workspace | Lightweight Codex repo bootstrap. |
| `repo-postcheck-summary` | `.agents/skills/repo-postcheck-summary` | Active | workspace | Narrow verification and concise summaries. |
| `requesting-code-review` | `.agents/skills/requesting-code-review` | Active | workspace | Review gate before merge or major completion. |
| `systematic-debugging` | `.agents/skills/systematic-debugging` | Active | workspace | Root-cause-first debugging flow. |
| `webpage-capture-markdown` | `.agents/skills/webpage-capture-markdown` | Active | workspace | Save external web context as local markdown. |
| `worktree-safety` | `.agents/skills/worktree-safety` | Active | workspace | Avoid wrong repo/worktree operations. |

## L2 Project-local

| Capability | Source of truth | Current state | Owner | Notes |
|---|---|---|---|---|
| 007 attribution/SEO/distribution skills (6) | `/Users/yangshu/.openclaw/workspace/projects/007-cryptorebate-restored/.agents/skills` | Active | 007 project | Correctly moved out of global user scope. |
| Product shell workflow | `~/.agents/skills/product-shell-first` | Active, candidate for project/workspace review | user | Cross-project today, but may belong in a narrower layer depending on reuse. |

## L3 Experimental / on-demand

| Capability | Source of truth | Current state | Owner | Notes |
|---|---|---|---|---|
| `playwright-best-practices` vendored skill | `vendor/skills/playwright-best-practices` + `skills-lock.json` | On-demand | workspace | Keep disabled by default; activate only for serious Playwright work. |
| Disabled archive: `openclaw-wechat-draft-publisher` | `~/.agents/skills-disabled/2026-04-08-global-slimming` | Archived | user | Good example of reversible retirement instead of deletion. |
| Superpowers symlink set in `~/.agents/skills` | user skill directory symlinks | Active, but not workspace-owned | user | Useful, but treat as personal layer rather than workspace policy. |

## Enabled MCP / plugin surface (current snapshot)

### MCP servers

- `notion`
- `openaiDeveloperDocs`
- `context7`
- `cloudflare-api`

### Plugins enabled in personal config

- `github@openai-curated`
- `notion@openai-curated`
- `googledrive@openai-curated`
- `gmail@openai-curated`
- `google-drive@openai-curated`
- `slack@openai-curated`
- `linear@openai-curated`
- `google-calendar@openai-curated`
- `vercel@openai-curated`
- `canva@openai-curated`
- `cloudflare@openai-curated`
- `figma@openai-curated`
- `stripe@openai-curated`

## Immediate governance watchlist

1. Review top-level default reasoning (`xhigh`) against daily latency/quality goals.
2. Review duplicate Google Drive plugin naming (`googledrive` vs `google-drive`).
3. Keep global user custom skills narrow; current active custom dirs are intentionally low.
4. Promote project-local skills into workspace/global layers only after repeated multi-project reuse.
