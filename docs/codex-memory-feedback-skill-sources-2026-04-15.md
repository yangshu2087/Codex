# Codex Memory / Feedback / Challenge Skill Source Review — 2026-04-15

Purpose: record which third-party skill ideas were used as references for the local Codex memory, feedback, challenge, and outcome layer. No broad third-party skill was globally installed in this pass.

## Adopted as Codex-native ideas

| Source | Useful idea | Local landing | Default activation |
|---|---|---|---|
| `SametEge/claude-memory-bank` | Structured memory files for project context | `docs/codex-memory-governance.md`, `codex-memory-curator` | Narrow, explicit/implicit by focused trigger only |
| `OthmanAdi/planning-with-files` | File-based working memory for complex tasks | Existing `planning-with-files` remains available | Already installed; no new install |
| `notmanas/claude-code-skills/devils-advocate` | Steel-man, pre-mortem, inversion, Socratic challenge | `codex-intake-challenge`, challenge protocol | Narrow high-risk trigger only |
| `Dimillian/Skills/project-skill-audit` | Use real session history and recurring workflows before creating skills | `codex-feedback-retrospective`, future skill audits | Reference only |
| `ComposioHQ/awesome-codex-skills/create-plan` | Read-only plan, small number of follow-up questions, validation/risk in plan | Existing task-card and quality lanes | Reference only |
| `blader/schematic` | Reverse-generate product/technical spec from branch | Future on-demand candidate for PR/spec docs | Not enabled |

## Rejected defaults

- Broad global memory that auto-reads/writes every session: rejected due privacy, bloat, and stale-memory risk.
- Full third-party skill packs: rejected due route pollution and supply-chain risk.
- Cookie/logged-in browser based research skills: rejected by default due credential and ToS risk.
- Emotionally aggressive “challenge” styles: rejected; local protocol must be evidence-driven and actionable.

## Promotion gate for future candidates

Before promoting any candidate:

1. Read `SKILL.md`, scripts, package metadata, and license.
2. Identify file writes, network calls, daemon behavior, credentials, and browser-state use.
3. Keep `defaultEnabled:false` and `implicitInvocation:false` unless the trigger is narrow and safe.
4. Add or update a smoke script that proves the behavior without external writes.
5. Record the decision in docs and, if vendored, in `skills-lock.json`.
