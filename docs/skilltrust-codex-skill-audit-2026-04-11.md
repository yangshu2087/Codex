# SkillTrust → Codex Skill Audit (2026-04-11)

## Source snapshot

Read-only local query against `skilltrust-prod-postgres` / database `skilltrust`.

| Metric | Value |
|---|---:|
| Total skills | 16,058 |
| Sample skills | 10 |
| Skills with `Codex` compatibility flag | 1,009 |
| Skills mentioning `Codex` in searchable text | 1,947 |
| Skills mentioning `OpenAI` in searchable text | 914 |
| Skills mentioning `Claude` in searchable text | 4,258 |
| Skills mentioning `Cursor` in searchable text | 1,955 |

## Codex-compatible source distribution

| Source | Count | Avg quality | Newest local update |
|---|---:|---:|---|
| ClawHub | 402 | 63.7 | 2026-04-11 |
| Smithery | 358 | 72.3 | 2026-03-06 |
| skills.sh | 210 | 78.1 | 2026-04-11 |
| GitHub | 27 | 78.5 | 2026-04-11 |
| ClawHub CN Mirror | 12 | 77.4 | 2026-04-10 |

## Selection policy

Chosen policy: **small global activation + workspace enhancement + L3 vendored-on-demand**.

Filters:

- Prefer actual `SKILL.md` or concise workflow docs over large app/daemon systems.
- Prefer clear Codex portability and low routing ambiguity.
- Prefer skills that target current local pain points: requirement understanding, UI prompt/design, browser verification, and JS/TS code health.
- Exclude full marketplace directories, heavy daemon/MCP systems, and skills that force broad subagent spawning or file-writing audits by default.

## Activated globally

These were written as Codex-native distilled skills under `/Users/yangshu/.agents/skills`.

| Skill | Source reference | Reason | Layer |
|---|---|---|---|
| `skilltrust-codex-task-analyzer` | `shinpr/codex-workflows/.agents/skills/task-analyzer` | Reinforces intent parsing, task scale, risk, and skill selection before implementation. | Personal global |
| `skilltrust-stitch-ui-prompt-architect` | `gabelul/stitch-kit/skills/stitch-ui-prompt-architect` | Improves Google Stitch prompt quality and bridges Stitch artifacts into Codex workflows. | Personal global |
| `skilltrust-js-codebase-health` | `fallow-rs/fallow-skills/fallow` | Adds narrow JS/TS code-health audit flow without making it a default linter/formatter. | Personal global |

## Workspace skill enhanced

| Skill / script | Change |
|---|---|
| `frontend-design-review` | Added SkillTrust-derived browser verification rules: 3-5 core flows, screenshots/visual evidence, console/network checks, responsive widths, and re-verification after fixes. |
| `scripts/codex-capability-audit.sh` | Updated reporting to group lockfile entries by install layer so personal-global distilled skills are not mislabeled as vendored/on-demand. |

## Vendored on-demand only

Mirrored under `/Users/yangshu/Codex/vendor/skills/skilltrust-curated`. Source `LICENSE` files are preserved for each mirrored upstream repo.

| Subset | Source | Reason |
|---|---|---|
| `codex-workflows/task-analyzer` | `shinpr/codex-workflows` | Reference for task analysis and skill selection. |
| `codex-workflows/documentation-criteria` | `shinpr/codex-workflows` | Reference for PRD/ADR/UI spec/design/work-plan criteria. |
| `codex-workflows/testing` | `shinpr/codex-workflows` | Reference for testing guidance. |
| `codex-workflows/recipe-front-review` | `shinpr/codex-workflows` | Reference for frontend review recipe; not directly enabled because it assumes custom agent orchestration. |
| `stitch-kit/stitch-ui-prompt-architect` | `gabelul/stitch-kit` | Reference for Stitch prompt generation. |
| `stitch-kit/stitch-design-md` | `gabelul/stitch-kit` | Reference for DESIGN.md synthesis from Stitch. |
| `stitch-kit/stitch-design-system` | `gabelul/stitch-kit` | Reference for code-level design token conversion. |
| `stitch-kit/stitch-react-components` | `gabelul/stitch-kit` | Reference for React conversion. |
| `stitch-kit/stitch-nextjs-components` | `gabelul/stitch-kit` | Reference for Next.js conversion. |
| `terrashark` | `LukasNiessen/terrashark` | Terraform/OpenTofu specialty skill; useful but too domain-specific for default activation. |

## Deferred / not enabled

| Candidate | Decision | Reason |
|---|---|---|
| `everything-claude-code` | Do not enable | Huge broad directory; likely routing noise and duplicate workflow content. |
| `antigravity-awesome-skills` | Do not enable | Marketplace/list-style pack; too broad for global default. |
| `awesome-agent-skills` | Do not enable | Curation source, not a narrow Codex skill. |
| `SaneProcess` critic/docs-audit | Defer | Original workflow forces 7/11 subagents and writes audit files; too heavy for default Codex. |
| `gobby` | Defer | Daemon/MCP/session system; needs separate ops/security evaluation. |
| `memorix` | Defer | Cross-agent memory/MCP; needs separate data retention and privacy review. |
| `autocontext` | Defer | Recursive harness/research system; too heavy for direct default install. |
| `pro-workflow` | Defer | Useful ideas already overlap with existing handoff/workflow skills; cherry-pick later if repeated need appears. |
| `dotpilot` | Defer | Config sync overlaps with existing Codex/Cursor shared protocol; shell/write behavior needs separate safety review. |

## Rollback

- Remove personal global skills:
  - `/Users/yangshu/.agents/skills/skilltrust-codex-task-analyzer`
  - `/Users/yangshu/.agents/skills/skilltrust-stitch-ui-prompt-architect`
  - `/Users/yangshu/.agents/skills/skilltrust-js-codebase-health`
- Revert this workspace commit to restore:
  - `/Users/yangshu/Codex/.agents/skills/frontend-design-review/SKILL.md`
  - `/Users/yangshu/Codex/vendor/skills/skilltrust-curated`
  - `/Users/yangshu/Codex/skills-lock.json`

## Verification plan

Run:

```bash
find /Users/yangshu/.agents/skills -maxdepth 2 -name SKILL.md | sort
/Users/yangshu/Codex/scripts/codex-capability-audit.sh
codex features list
codex mcp list
git -C /Users/yangshu/Codex status --short
```

Restart Codex after this change so the newly added personal global skills are loaded into future sessions.
