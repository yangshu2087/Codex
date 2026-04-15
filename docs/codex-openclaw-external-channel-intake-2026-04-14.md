# Codex / OpenClaw / Hermes external channel intake — 2026-04-14

Purpose: record a reviewed routing layer for external web, browser, social, news, WeChat, domestic-media, XCrawl, Obsidian capture, and CLI-harness candidates. This is an intake document, not an installation record.

## Task card

- Goal: bring the initial 10 external candidates plus the CLI-Anything / CLI-Hub harness candidate into a safety-first, explicit-only, trackable capability layer for Codex, OpenClaw, and the Hermes supervision lane.
- Constraints: review-route only; do not install tools; do not write credentials; do not run crawlers; do not edit `~/.openclaw/openclaw.json`; avoid Cookie and real-browser-login defaults; run low-concurrency because runtime health reports swap above 2 GiB.
- Non-goals: no full Agent-Reach / MediaCrawler / `wechat_articles_spider` installation; no default bb-browser or OpenCLI live login-state browser control; no main-account Cookie storage; no ToS bypass or commercial/bulk crawling from learning-only crawlers.
- Done criteria: each candidate has verdict, risk, recommended landing zone, activation gate, API/permission notes, error semantics, and regression checks; `skills-lock.json` records candidates as disabled reviewed entries.
- Verification commands:
  - `git status --short --branch`
  - `/Users/yangshu/Codex/scripts/codex-runtime-health.sh`
  - `/Users/yangshu/Codex/scripts/skill-audit.sh`
  - `/Users/yangshu/Codex/scripts/skill-smoke.sh`
  - `/Users/yangshu/Codex/scripts/codex-capability-audit.sh`
  - `git diff --stat`

## Architecture decision

| Option | Tradeoff | Rollout | Rollback | Decision |
|---|---|---|---|---|
| Advisory only | Lowest friction, but future agents can forget the risk boundaries. | Docs only. | Revert docs. | Not enough structure. |
| Full install | Maximum reach, but combines Cookie tools, real browser login state, crawler behavior, third-party APIs, and OpenClaw's public Telegram ingress. | Install tools and credentials. | Uninstall many moving parts and rotate credentials. | Rejected. |
| Reviewed routing layer | Adds durable decision records and explicit gates without expanding privileges. | Docs + lock entries only; later full review per tool before activation. | Revert workspace docs/lock entries. | Recommended and used. |

Implementation recommendation: keep these candidates as a routing matrix first. Only promote a candidate after a focused review of `SKILL.md` / scripts / install behavior / credential use, and only with `defaultEnabled:false` plus `implicitInvocation:false` unless a later task explicitly changes the policy.

## Source snapshot

Review date: 2026-04-14.

Local facts checked:

- Codex workspace: `/Users/yangshu/Codex`, branch `codex/restore-codex-archive-state`.
- OpenClaw config exists at `/Users/yangshu/.openclaw/openclaw.json`; this intake does not edit it.
- OpenClaw version probe: `OpenClaw 2026.4.8 (9ece252)`.
- OpenClaw security note says Telegram DM and group policy are currently open, so new network/action tools must be treated as exposed to public ingress unless separately gated.
- Hermes-Agent exists at `/Users/yangshu/.local/src/Hermes-Agent`, but it is outside this workspace, currently dirty, and behind `origin/main`; this intake does not edit it. The Hermes landing zone for this pass remains a read-only supervision / quality-control lane recorded from the Codex workspace.
- Existing Codex wrapper: `/Users/yangshu/Codex/scripts/opencli-readonly.sh` provides a read-only OpenCLI allowlist and denies browser control, installs beyond isolated temp prefix, and write-capable targets.

## Candidate matrix

| # | Candidate | Source | Verdict | Risk | Landing zone | Activation gate |
|---|---|---|---|---|---|---|
| 1 | Agent-Reach | <https://github.com/Panniantong/Agent-Reach> | Reference only | High | Codex/OpenClaw docs, not runtime | Extract the channel matrix idea only; do not run `agent-reach install` without a separate full install review. |
| 2 | OpenCLI | <https://github.com/jackwener/opencli> | Keep existing read-only route | Medium | Codex wrapper only | Use `/Users/yangshu/Codex/scripts/opencli-readonly.sh`; keep `browser`, `eval`, `explore`, `generate`, `synthesize`, and external auto-install routes denied by default. |
| 3 | bb-browser | <https://github.com/epiral/bb-browser> and ClawHub `bb-browser` scan | Review candidate, not activated | High | Future isolated sandbox only | ClawHub scan flagged the OpenClaw skill as suspicious; do not use logged-in browser state or `site update` until adapters and OpenClaw binary assumptions are reviewed. |
| 4 | web-access | <https://github.com/eze-is/web-access> | Strategy reference only | High | Design notes, not runtime scripts | Translate its three-channel routing and site-pattern idea; do not start its CDP proxy or write site patterns from Codex by default. |
| 5 | wechat_articles_spider | <https://github.com/klin-h/wechat_articles_spider> | Reject default route | Extreme | Isolated lab only | Requires WeChat login, token/cookie persistence, and warns about account bans; use only with disposable account and explicit legal/TOS review. |
| 6 | Jina Reader | <https://github.com/jina-ai/reader> | Low-risk reference route | Low | Codex/OpenClaw public URL markdown preprocessor | Use only public URLs; do not forward Cookie headers; preserve original URL and note possible extraction loss. |
| 7 | 6551 opentwitter/opennews | <https://clawhub.ai/infra403/opentwitter-mcp>, <https://clawhub.ai/infra403/opennews-mcp> | Explicit-only API candidate | Medium | OpenClaw API lane, Hermes-reviewed | Requires scoped service token; output must disclose third-party provider and never fall back to Twitter/X Cookie scraping. |
| 8 | MediaCrawler | <https://github.com/NanmiCoder/MediaCrawler> | Reject default route | Extreme | Isolated learning lab only | Non-commercial learning license and crawler disclaimer; do not use for production, commercial, or large-scale collection. |
| 9 | XCrawl OpenClaw skills | <https://docs.xcrawl.com/zh/doc/developer-guides/openclaw/>, <https://github.com/xcrawl-api/xcrawl-skills> | Explicit-only API candidate | Medium | OpenClaw API lane, optional future skill clone | Requires `~/.xcrawl/config.json` with `XCRAWL_API_KEY`; do not create the file or clone skills in this pass. |
| 10 | Obsidian Web Clipper | <https://obsidian.md/clipper>, <https://github.com/obsidianmd/obsidian-clipper> | Human-operated capture route | Low | UX / knowledge-capture lane | Keep as browser-extension/manual capture guidance; Codex should not silently drive the extension or mutate vault notes from this intake. |
| 11 | CLI-Anything / CLI-Hub | <https://github.com/HKUDS/CLI-Anything>, `codex-skill/SKILL.md`, `openclaw-skill/SKILL.md`, `cli-anything-plugin/HARNESS.md` | Reviewed harness-methodology candidate, not activated | Medium-High | Codex harness methodology + Hermes supervision lane; future OpenClaw explicit-only skill candidate | Use the skill and HARNESS docs as a build/refine/test/validate reference only; do not run the global skill installer, `cli-hub install`, publish workflow, or generated app-control harness without isolated review, explicit approval, and `CLI_HUB_NO_ANALYTICS=1` if runtime install is later approved. |


## CLI-Anything / CLI-Hub addendum

Review date: 2026-04-14. Source snapshot: the GitHub API reported `HKUDS/CLI-Anything` as active, default branch `main`, repository license `Apache-2.0`, and recently pushed on 2026-04-14. The root README positions CLI-Anything as an agent-native harness system, while the repo also ships Codex and OpenClaw skills plus a Claude Code plugin workflow.

Verdict: useful, but not safe as a default installation. Use it in Codex/Hermes as a reviewed methodology and routing candidate for turning a local source repo or GUI app into a tested `cli-anything-<software>` harness. Because the local Hermes-Agent checkout is dirty and outside this workspace, do not edit Hermes files in this pass; keep the integration as Codex workspace docs/lock plus Hermes supervision rules. Do not install `cli-anything-hub`, run the skill installer, publish generated harnesses, or execute a generated harness against real desktop software without a focused per-target review.

Safe usage pattern for Codex/Hermes:

1. Treat `codex-skill/SKILL.md`, `openclaw-skill/SKILL.md`, and `cli-anything-plugin/HARNESS.md` as the reference workflow for **build / refine / test / validate** work.
2. For a future target app or repo, create an isolated worktree or throwaway repo-local virtualenv before any install command.
3. Require a `TEST.md` before implementation, then verify with `pytest`, `python -m pytest`, and subprocess checks of the installed `cli-anything-<software>` console script.
4. Hermes supervision must check subprocess safety (`shell=True` denied), path traversal boundaries, backend dependency truthfulness, JSON output behavior, undo/redo/session-state claims, and whether the harness touches real files or external services.
5. If a future task explicitly approves CLI-Hub runtime use, set `CLI_HUB_NO_ANALYTICS=1`, keep the install inside an isolated environment, log the package/source hash, and keep `cli-hub install|update|uninstall` behind a manual approval gate.

Architecture lane:

- Option A — full CLI-Hub install: broadest access, but it runs `pip install` flows from registry entries, writes `~/.cli-hub`, and can install harnesses that control real applications; rejected for default Codex/OpenClaw use.
- Option B — global Codex skill install: easy trigger, but upstream installer writes to `${CODEX_HOME:-$HOME/.codex}/skills`, while this workspace prefers narrow workspace skills and explicit routing; rejected for this pass.
- Option C — reviewed routing layer: keep source facts, risks, and activation gates in docs/lock, then vendor only a narrow skill subset later if a target project needs it; selected.

Backend/API lane:

- Contract: `cli-hub list|search|info` are registry/metadata commands; `cli-hub install|update|uninstall` are package-management commands and denied by default. Generated harnesses should expose a Click CLI named `cli-anything-<software>`, a REPL default, one-shot commands, `--json` output, backend wrappers, and tests that call the real backend where safe.
- Error semantics: `external_install_denied`, `analytics_opt_out_required`, `backend_missing`, `unsafe_subprocess_blocked`, `path_traversal_blocked`, `credential_or_desktop_state_blocked`, `manual_review_required`.
- Permissions: no Cookie import, no browser profile access, no desktop app control, no PyPI publish, no global skill install, no arbitrary `pip install` until an explicit target review approves a sandboxed environment.
- Data consistency: every future CLI-Anything harness activation must record target repo/app, source commit or package hash, generated command name, backend dependency, install environment, verification commands, and whether output came from real software or a mocked backend.
- Regression: after this docs/lock intake, run `python3 -m json.tool skills-lock.json`, `scripts/skill-audit.sh`, `scripts/skill-smoke.sh`, `scripts/codex-capability-audit.sh`, and `git diff --check`.

UX / product-flow lane:

- Primary future journey: user names a target app/repo → Codex classifies whether a harness is appropriate → Hermes blocks unsafe install/control by default → isolated harness worktree/venv is created only after approval → tests verify command behavior and JSON output → the result is documented as an explicit-only capability.
- State coverage: default/reference-only, missing backend, missing approval, install blocked, analytics opt-out required, unsafe subprocess blocked, empty/no suitable target commands, test failure, and success with evidence.
- Browser/screenshot evidence: not applicable to this docs-only intake; a future GUI harness must add real app or browser evidence only after an isolated execution plan is approved.

## Backend / API lane contract

| Provider route | Contract | Credentials | Allowed default | Error semantics |
|---|---|---|---|---|
| Jina Reader | `GET https://r.jina.ai/<absolute-public-url>` returning Markdown-like content. | None by default. | Public pages only. | `provider_untrusted`, `rate_limited`, `empty_result`, `extraction_loss`, `manual_review_required`. |
| XCrawl | `POST /v1/scrape`, `/v1/map`, `/v1/crawl`, `/v1/search`; async routes must be polled using their result endpoints. | `XCRAWL_API_KEY` from an explicit local config reference only after approval. | Not enabled in this pass. | `missing_credentials`, `rate_limited`, `provider_untrusted`, `async_timeout`, `scope_too_broad`. |
| 6551 opentwitter/opennews | Bearer-token `POST` calls to the documented 6551 API endpoints. | Dedicated `TWITTER_TOKEN` / `OPENNEWS_TOKEN`; no primary account credentials. | Not enabled in this pass. | `missing_credentials`, `provider_untrusted`, `rate_limited`, `token_scope_unknown`, `manual_review_required`. |
| OpenCLI read-only | `/Users/yangshu/Codex/scripts/opencli-readonly.sh` allowlist: `hackernews`, local `gh --version|version|auth status`, and `codex status|probe|model|read`. | No Cookie import; isolated temp HOME/prefix for OpenCLI. | Allowed as existing local wrapper only. | `command_denied`, `cdp_not_reachable`, `external_install_denied`, `write_action_denied`. |
| Browser/CDP candidates | Real browser / CDP / login-state access. | Login-state or Cookie, normally not allowed. | Deny by default. | `login_state_required_blocked`, `browser_control_blocked`, `manual_review_required`. |
| WeChat / domestic crawler candidates | Selenium/Playwright crawler workflows with token/cookie or saved login state. | Account login / token / Cookie. | Deny by default. | `tos_or_license_blocked`, `login_state_required_blocked`, `account_ban_risk`, `commercial_use_blocked`. |
| CLI-Anything / CLI-Hub | `cli-hub list|search|info` as registry metadata; `cli-hub install|update|uninstall` denied by default; generated harness contract is `cli-anything-<software>` with Click CLI, REPL default, one-shot commands, `--json`, backend wrapper, and tests. | None by default; target backend credentials only after separate approval. | Docs/reference only in this pass. | `external_install_denied`, `analytics_opt_out_required`, `backend_missing`, `unsafe_subprocess_blocked`, `path_traversal_blocked`, `credential_or_desktop_state_blocked`, `manual_review_required`. |

Data consistency expectations:

- Preserve `source_url`, `provider`, `review_date`, `query`, `timestamp`, and `credential_mode` for each external result.
- Separate `fact`, `opinion`, and `inference`; mark unsupported claims as `[UNVERIFIED]`.
- Do not merge third-party API results with scraped browser results without labeling the route.
- For async crawl/search tasks, store request ID and final result ID together if a future implementation enables them.

Permissions and privacy:

- Do not read browser profile directories, browser cookies, `~/.ssh`, unrelated credential stores, or arbitrary OpenClaw secrets.
- Do not create `~/.xcrawl/config.json`, `~/.agent-reach`, or WeChat credential files in this pass.
- Do not run `cli-hub install`, upstream skill installers, publish workflows, generated desktop-app control commands, or global `pip install` routes in this pass.
- If a future task supplies a token, use service-specific, rotatable credentials and document revocation steps.

Observability:

- Each future activation should produce a short evidence record: candidate name, command/API route, timestamp, credential mode, provider response status, and whether Hermes supervision approved it.
- OpenClaw's public Telegram ingress means every newly enabled write/network tool needs an approval story before it is exposed to OpenClaw agents.

## UX / product-flow lane

Primary user journey for a future external lookup:

1. User asks for information or capture.
2. Codex/OpenClaw route classifier selects the safest route: Jina/public URL first, official/API route second, browser/Cookie/crawler routes blocked unless explicitly authorized.
3. Credential gate checks whether a scoped token is present and approved.
4. Tool returns result with route metadata and error semantics.
5. Hermes supervision lane checks provider trust, credential mode, ToS/license boundary, and evidence quality.
6. Result is summarized, optionally handed to Obsidian or OpenClaw content workflow with source metadata intact.

State coverage for future UI/browser automation tasks:

- default: safe route available without credentials.
- hover/focus-visible/active: not applicable to this docs-only change, but any future UI should use repo-native tokens and visible focus states.
- loading: async crawl/search is in progress and exposes request ID.
- empty: provider returns no usable content.
- error: provider or route fails with one of the explicit error codes above.
- disabled: route blocked by credential, ToS/license, public-ingress, or manual-review gate.
- success: result includes source metadata and credential mode.

UX evidence for this pass: docs-only route records were added; no product UI or browser flow was changed, so no screenshot is expected or fabricated.

## Rollout and rollback

Rollout:

1. Batch 1: add this intake matrix and watchlist entries.
2. Batch 2: add disabled reviewed-candidate entries to `skills-lock.json`.
3. Batch 3: run health/audit/smoke/capability checks; do not enable OpenClaw routes until a future focused review.

Rollback:

- Revert this document, the watchlist section, and the new `skills-lock.json` entries.
- No OpenClaw config, credential file, installed package, browser profile, or crawler state should need cleanup because this pass does not touch them.

## Recommended next gates

- Low friction: use Jina Reader only for public URL Markdown capture when regular web fetch is insufficient.
- Medium risk: review XCrawl skills and 6551 API docs with token scopes before any explicit-only OpenClaw installation.
- High risk: review OpenCLI live-browser, bb-browser, and web-access in a throwaway browser profile before any login-state access.
- Extreme risk: keep WeChat and domestic platform crawlers in an isolated, non-commercial lab with disposable accounts, rate limits, and explicit legal/TOS acceptance.
- Harness work: use CLI-Anything as a build/test/validate methodology only until a specific target repo/app is approved for isolated venv/worktree execution with analytics disabled.
