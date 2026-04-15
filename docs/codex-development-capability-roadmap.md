# Codex development capability roadmap

Purpose: define a reusable, safety-first capability router for Codex project development across code, architecture, backend/API, frontend/UI, UX/product-flow, review, deployment, handoff, and external-channel skills.

This is a routing and verification document. It does not install tools, write credentials, promote third-party skills, or modify OpenClaw/Hermes configuration.

## Task card

- Goal: make Codex project-development work repeatable across implementation, architecture, backend/API, frontend/UI, UX, review, deploy, handoff, and external capability channels.
- Constraints: use official/local capabilities first; keep third-party capabilities `reviewed-candidate` or explicit-only; do not rely on browser login state, main-account cookies, or unreviewed package installs; respect local resource pressure and prefer single-agent when `codex-runtime-health.sh` reports high pressure.
- Non-goals: no global installation of broad skill packs; no automatic deployment or external writes; no OpenClaw public-ingress expansion; no replacement for GitHub branch/review policy.
- Done criteria: each lane has an entrypoint, required evidence, default tools, escalation path, rollback story, and verification command.
- Verification commands:
  - `codex --version`
  - `codex features list`
  - `codex mcp list`
  - `/Users/yangshu/Codex/scripts/codex-runtime-health.sh`
  - `/Users/yangshu/Codex/scripts/codex-dev-capability-smoke.sh`
  - `/Users/yangshu/Codex/scripts/skill-smoke.sh`
  - `/Users/yangshu/Codex/scripts/codex-capability-audit.sh`

## Architecture decision

| Option | Tradeoff | Rollout | Rollback | Decision |
|---|---|---|---|---|
| Advisory-only docs | Low friction, but completion quality still depends on memory and chat discipline. | Add docs only. | Revert docs. | Useful but insufficient alone. |
| Full install / enable every channel | Maximum apparent capability, but high supply-chain, credential, browser, and OpenClaw exposure risk. | Install tools and widen permissions. | Uninstall tools, rotate credentials, clear caches. | Rejected. |
| Layered capability router | Slightly more process, but safe, testable, and reversible. | Keep local/official channels default; add reviewed explicit-only candidates; verify with smoke scripts. | Revert individual docs/scripts/lock entries. | Recommended. |

Recommendation: use a layered router. Prompts and skills guide the work; scripts verify local capability; Stop hooks block only missing completion evidence; third-party tools stay explicit-only until a focused review promotes them.

## Lane matrix

| Lane | Primary entrypoints | Required evidence | Default tools | Escalation / external channel | Rollback |
|---|---|---|---|---|---|
| Code implementation | `systematic-debugging`, repo `AGENTS.md`, local tests | Changed files, narrow tests, failure analysis when relevant | shell, project test scripts, Context7 for library docs | Add language-specific skill only after repo need is clear | Revert patch or branch; rerun tests |
| Architecture | `architecture-decision-review`, this roadmap | Option comparison, tradeoffs, rollout, rollback, risks, observability | docs, diagrams, ADR notes | Read-only subagents for exploration when resource health allows | Revert ADR/docs; keep code unchanged until decision accepted |
| Backend/API | `backend-api-contract-review`, `docs/templates/api-contract-checklist.md` | API contract, error semantics, permissions, data consistency, observability, targeted regression | OpenAI docs, Context7, Cloudflare API MCP, Vercel MCP, route/unit tests | External APIs only with scoped credentials and explicit permission | Revert route/schema changes; roll back migrations using documented plan |
| Frontend/UI | `frontend-design-review`, `DESIGN.md`, `docs/templates/frontend-ui-verification.md` | Visual thesis, design source, state coverage, browser/screenshot evidence, responsive notes | Figma tools, agent-browser, screenshot, project dev server | Canva/Figma generation only when explicitly requested | Revert component/CSS changes; retain screenshots as evidence |
| UX/product flow | `product-ux-flow-review`, product contract | User goal, primary journey, friction paths, accessibility/copy expectations, state coverage | browser/visual pass, screenshot, accessibility/state notes | Notion/Google docs for product context when supplied | Revert UX copy/flow changes; preserve contract notes |
| Code review | `/review`, `requesting-code-review`, `docs/code_review.md` | Findings or no-findings statement, lane evidence, targeted retest | Codex review mode, GitHub PR review, local diff | Reviewer subagents for read-heavy large diffs only | Apply/revert fix commits; rerun `/review` |
| Deploy/ops | Vercel MCP, Cloudflare API MCP, deploy skills | Environment contract, rollback, logs, healthcheck, domain/permission notes | Vercel/Cloudflare docs and MCPs | Provider-specific deployment only after explicit request | Provider rollback, previous deployment promotion, config revert |
| Handoff | `agent-handoff-governor`, `update-agent-handoff.sh` | Branch, changed files, verification, open risks, next step | `docs/agent-handoff.md`, GitHub PR summary, Notion if requested | Slack/Notion writes only with explicit target | Revert handoff doc or add correction note |
| External channel / third-party skills | `skills-lock.json`, watchlist docs, intake docs | Source, hash, license/risk, credential policy, defaultEnabled/implicitInvocation=false | reviewed-candidate docs and lock entries | Vendored-on-demand only after reading `SKILL.md` and scripts | Remove lock/doc/vendor entry; no credential cleanup if not activated |

## Backend / API capability contract

Every backend/API task should state this before implementation:

- Contract: route/module/job, inputs, outputs, status/error shape, side effects, compatibility expectations.
- Error semantics: named errors and user-visible behavior, not just exception types.
- Permissions: auth, roles, ownership checks, external scopes, and what validation does not prove.
- Data consistency: transaction boundary, idempotency, concurrency, cache invalidation, migrations, rollback.
- Observability: logs, metrics, traces, audit events, request IDs, explicit none if not applicable.
- Targeted regression: route/unit/integration tests, schema diff, migration dry-run, smoke command.

Use `/Users/yangshu/Codex/docs/templates/api-contract-checklist.md` for the detailed checklist.

## Frontend / UX capability contract

Every frontend/UX task should start from local design sources:

1. Nearest `DESIGN.md`.
2. `docs/design-reference-shortlist.md` if present.
3. Figma links, screenshots, prototypes, or product acceptance notes.
4. Existing repo components and tokens.

Required state coverage when relevant:

- default
- hover
- focus-visible
- active
- loading
- empty
- error
- disabled
- success

Required verification when a page or component changes:

- Browser, Playwright, agent-browser, screenshot, responsive check, or explicit blocker.
- Console/network observations when relevant.
- Accessibility/copy notes for user-facing flows.

Use `/Users/yangshu/Codex/docs/templates/frontend-ui-verification.md` for the detailed checklist.

## External capability policy

Third-party skills and tools must remain reviewed-on-demand unless a future task explicitly promotes them.

Promotion gate:

1. Read `SKILL.md`, install scripts, package metadata, license, and network/write behavior.
2. Record source and hash in `skills-lock.json`.
3. Keep `defaultEnabled:false` and `implicitInvocation:false` for broad or risky tools.
4. Avoid Cookie, browser profile, and main-account credential routes by default.
5. Run `skill-audit.sh`, `skill-smoke.sh`, and `codex-capability-audit.sh` after changes.

## Rollout plan

1. Batch 0: keep this roadmap and templates as docs-only guidance.
2. Batch 1: run `/Users/yangshu/Codex/scripts/codex-dev-capability-smoke.sh` before major local Codex maintenance.
3. Batch 2: add repo-local `AGENTS.md` references only in repositories that need this router.
4. Batch 3: promote narrow explicit-only skills or scripts only when repeated work proves the value.

## Rollback plan

- Docs/templates: revert the changed Markdown files.
- Scripts: remove or revert the script and rerun `skill-smoke.sh` / `codex-capability-audit.sh`.
- Skills: remove the vendored or workspace skill and its `skills-lock.json` entry.
- Config/hooks: disable the specific hook or profile change; do not remove unrelated guardrails.
- External tools: uninstall package, revoke token, clear provider-specific config/cache, and document cleanup evidence.

## Observability and risk notes

- Resource pressure: when `codex-runtime-health.sh` reports `STATUS=high-pressure`, use single-agent or at most one read-only sidecar.
- Hook limitation: lifecycle hooks are guardrails, not a complete sandbox; they cannot replace scoped credentials and explicit approvals.
- Browser limitation: screenshots/browser checks prove rendered behavior for one route/state; they do not prove every breakpoint or accessibility path.
- External-source limitation: search results and GitHub popularity are discovery signals, not trust proof.
- Completion rule: do not claim done without the relevant lane evidence and the final response contract.
