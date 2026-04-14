# Codex Global Local Layer — 2026-04-14

This document records the user-level Codex files changed as part of the multi-channel project-development capability layer. The files live under `/Users/yangshu/.codex`, which is intentionally outside this workspace Git repository, so this note provides the PR-auditable trace.

## Product contract

- User goal: make Codex route project-development work through architecture, backend/API, front-end/UI, UX/product, design, review, and verification channels.
- Business rule: use hybrid gates — prompts and skills guide normal work, Stop hooks block only completion claims with missing evidence.
- Non-goals: do not upgrade Codex binaries, do not switch to alpha, do not add external write permissions, and do not globally install broad third-party skills.
- Acceptance criteria: global prompts and hooks request task cards, product contracts, API contracts, design/UX state coverage, and verification evidence before implementation or completion claims.

## User-level files changed

| File | Purpose | SHA-256 |
|---|---|---|
| `/Users/yangshu/.codex/AGENTS.md` | Adds multi-channel project development routing guidance. | `db2c75bc1a933eab289dae16bfab56f399a7f23a69ac59b23a9e9171d93ee3dd` |
| `/Users/yangshu/.codex/hooks/common.py` | Expands lane evidence markers for observability, data consistency, state coverage, responsive checks, and UX friction/copy/accessibility. | `a8c2dc2c5e1222885289cb251af54faa201bacc57fc99d3d293a0a905f7b3e01` |
| `/Users/yangshu/.codex/hooks/user_prompt_submit_guard.py` | Strengthens injected guidance for architecture, front-end/UI, backend/API, and UX/product-flow tasks. | `c8590e4e64d021b455cbea861813636ca7018f954d5addee6e53c84ab52091ad` |
| `/Users/yangshu/.codex/prompts/architecture-template.md` | Requires option comparison, rollout, rollback, observability, risk, and API/data/auth impact. | `16f51df85bc9dabcfb7ead8a38e4b322a4febd090ed8e5dc043c74773263f16d` |
| `/Users/yangshu/.codex/prompts/backend-template.md` | Requires API contract, error semantics, permissions, data consistency, observability, and targeted regression checks. | `10e70155257fad952ab465bb1abcaa3eb900399297e101510958c7dbd9b72db4` |
| `/Users/yangshu/.codex/prompts/frontend-template.md` | Requires DESIGN.md usage, visual thesis, content plan, interaction thesis, state coverage, responsive checks, and browser/visual evidence. | `148e899bcf50f1ae9537f825d98107c2009abc48dcd8c511091f3e450fc05171` |
| `/Users/yangshu/.codex/prompts/requirements-clarification-template.md` | Adds product contract plus quality-lane routing for ambiguous or product-facing requests. | `068f2e277adc0d6d94cdd8133d925ce70cb2b9b6455f92eea35fe9923ac7f3e2` |
| `/Users/yangshu/.codex/prompts/ux-flow-template.md` | Requires user journey, friction/failure paths, state coverage, copy/accessibility, and browser/screenshot evidence or blocker. | `347597bf2d298600b7a73ec7c309a0341636dfdbcea437a80d70af4c989e3809` |
| `/Users/yangshu/.codex/prompts/code-quality-template.md` | Adds lane-aware review checks for architecture, backend/API, front-end/UI, and UX/product evidence. | `f356472ade5ccb2bf5d9e18d38aee8a5497be318154790c82928d676906b5756` |

## API / hook contract

The changed hooks are local Codex lifecycle hooks only:

- Input: Codex prompt/transcript JSON on stdin.
- Output: `UserPromptSubmit` additional context or `Stop` blocking reason.
- Error semantics: missing evidence is reported as explicit text, such as `API contract`, `错误语义`, `browser verification`, `product contract`, `Done criteria`, or `Verification`.
- Permissions: hooks do not write project files, do not call external APIs, and do not access business data.
- Data consistency: `skills-lock.json` in this repository tracks workspace skill hashes; this document tracks non-repo user-level file hashes.

## Verification evidence

Commands run after the global/workspace update:

```bash
codex --version
codex features list
codex mcp list
/Users/yangshu/Codex/scripts/check-codex-upgrade.sh
/Users/yangshu/Codex/scripts/codex-runtime-health.sh
/Users/yangshu/Codex/scripts/codex-quality-lane-smoke.sh
/Users/yangshu/Codex/scripts/skill-audit.sh
/Users/yangshu/Codex/scripts/skill-smoke.sh
/Users/yangshu/Codex/scripts/codex-capability-audit.sh
git diff --check
python3 -m json.tool /Users/yangshu/Codex/skills-lock.json
python3 -m py_compile /Users/yangshu/.codex/hooks/common.py /Users/yangshu/.codex/hooks/user_prompt_submit_guard.py /Users/yangshu/.codex/hooks/stop_quality_gate.py
```

Observed evidence:

- `codex-cli 0.120.0`.
- CLI/npm/GitHub stable releases match `0.120.0`; desktop app matches official build `26.409.20454`.
- `codex-quality-lane-smoke.sh`: all checks passed.
- `skill-smoke.sh`: all checks passed.
- `git diff --check`: clean.
- Runtime health reported `STATUS=high-pressure` due to swap usage, so continue using single-agent or low-concurrency workflows until memory pressure drops.
