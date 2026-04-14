# Codex Quality Lanes

Use this document as the local routing standard for higher-quality Codex work. It complements `AGENTS.md`, prompt templates, and the Stop hook.

## 1) Requirements / Product lane

- Inputs: raw user request, existing product docs, constraints, known users, business rules, and explicit non-goals.
- Plan before build: rewrite into a product contract with user goal, business goal, assumptions, edge cases, acceptance criteria, verification method, and open questions.
- Implementation rule: do not code until ambiguity is either resolved or recorded as an assumption.
- Evidence: accepted contract, done criteria, verification commands, and remaining open questions.
- Final reply: include `已完成`, `完成证据`, `还缺什么`, and `后续建议`.

## 2) Architecture lane

- Inputs: repo layout, current architecture, integration boundaries, constraints, migration pressure, and failure/rollback expectations.
- Plan before build: compare at least two viable options unless only one is technically possible.
- Implementation rule: state tradeoffs, migration or rollout plan, rollback path, operational risk, observability, and recommended option before code changes.
- Evidence: option comparison, selected approach, rollout/rollback, tests or dry-run checks, and risk notes.
- Final reply must mention architecture lane evidence such as `方案比较`, `tradeoff`, `rollout`, `回滚`, or `风险`.

## 3) Front-end lane

- Inputs: nearest `DESIGN.md`, design system/tokens, screenshots, Figma links, existing components, and product acceptance notes.
- Plan before build: write visual thesis, content plan, and interaction thesis for visually led work.
- Implementation rule: reuse local components/tokens; cover default, hover, focus-visible, active, loading, empty, error, and disabled states when relevant.
- Evidence: browser, screenshot, Playwright, agent-browser, or manual page verification; include console/network observations when useful.
- Final reply must mention real visual/browser evidence and what remains visually unverified.

## 4) Backend / API lane

- Inputs: API routes, service boundaries, data model, auth/permissions, persistence, queue/background jobs, and existing tests.
- Plan before build: define API contract, data flow, error semantics, permission model, consistency expectations, and observability needs.
- Implementation rule: keep changes minimal and contract-compatible; avoid silent schema or auth changes without a migration/rollback note.
- Evidence: targeted tests, type checks, route smoke tests, migration dry-runs, or explicit blocker notes.
- Final reply must mention backend lane evidence such as `API contract`, `接口契约`, `错误语义`, `权限`, `数据一致性`, or `回归测试`.

## 5) Code quality / Review lane

- Inputs: task card, diff, changed files, tests, and repo review checklist.
- Plan before build: identify correctness, maintainability, performance, security, and compatibility risks.
- Implementation rule: use `/review` or `docs/code_review.md` for non-trivial diffs; keep findings prioritized and actionable.
- Evidence: review output, test/lint/type/build results, and any accepted residual risks.
- Final reply must separate blocking findings from non-blocking suggestions.

## 6) Research lane

- Inputs: official docs, release notes, package registries, GitHub repos/issues, primary source articles, and only then social/web discussion.
- Plan before build: decide which claims require live verification and which sources are authoritative.
- Implementation rule: cite official or primary sources for volatile facts; do not rely on X/Twitter unless the content is directly readable and corroborated.
- Evidence: source URLs, dates, exact versions, and unsupported/uncertain findings.
- Final reply must distinguish verified facts from inference or unverified leads.

## Operational smoke test

Run `/Users/yangshu/Codex/scripts/codex-quality-lane-smoke.sh` after changing Codex hooks, prompt templates, or quality-lane skills. The smoke verifies:

- user-prompt guard context injection for architecture, backend/API, and UX/product-flow tasks;
- Stop-hook blocking behavior when lane evidence is missing;
- Stop-hook pass behavior when architecture, backend/API, front-end, and UX evidence are all present;
- required prompt templates and explicit-only workspace skill policies.

For broader maintenance, `/Users/yangshu/Codex/scripts/skill-smoke.sh` now calls the same quality-lane smoke so the check stays part of the regular skill regression path.

Weekly maintenance entrypoint:

- Lightweight weekly audit: `/Users/yangshu/Codex/scripts/codex-maint-weekly.sh`
- Full weekly quality regression: `/Users/yangshu/Codex/scripts/codex-maint-weekly.sh --with-quality-regression`
- Weekly large-session archive plan: `/Users/yangshu/Codex/scripts/codex-maint-weekly.sh --session-archive-plan`
- Direct session archive plan: `/Users/yangshu/Codex/scripts/codex-session-archive-plan.sh`
- Direct full regression: `/Users/yangshu/Codex/scripts/codex-quality-regression.sh`
