# skills.sh Codex Shortlist

## Screening basis

A skill is treated as a good Codex candidate only when most of the following are true:

- it uses a normal `SKILL.md` structure that Codex can understand
- the `skills` CLI can install it for multiple agents, not only Claude-specific packaging
- the skill page shows real Codex adoption, or the workflow is obviously agent-agnostic
- it does not duplicate a stronger local skill we already have
- it does not rely on brittle or high-risk integrations by default

## Important caution

`skills.sh` itself says it runs security audits, but it does **not** guarantee the quality or safety of every listed skill. Treat it as a discovery directory, not a trust boundary.

## Good Codex candidates now

| Skill | Why it fits Codex now | Notes |
|---|---|---|
| `obra/superpowers@systematic-debugging` | Strong general debugging process, high Codex adoption, no obvious Claude-only lock-in | Best process skill in the current shortlist |
| `obra/superpowers@requesting-code-review` | Good review workflow for agent-based development, high Codex adoption | More workflow-oriented than code-specific |
| `currents-dev/playwright-best-practices-skill@playwright-best-practices` | Good reference skill for Playwright test authoring/debugging, explicitly used on Codex | Complements our existing local Playwright skill |
| `trailofbits/skills@variant-analysis` | High-value security analysis workflow for repeated bug/vuln pattern hunting | Best when a known issue already exists |
| `trailofbits/skills@audit-prep-assistant` | Useful for structured pre-audit preparation | More situational than daily-use |
| `sergiodxa/agent-skills@owasp-security-check` | Clear OWASP-oriented review checklist, general enough for Codex | Good when the task is explicitly a web/API security audit |

## Conditional candidates

| Skill | When it is worth using | Why not default |
|---|---|---|
| `microsoft/playwright-cli@playwright-cli` | If we want command-centric browser control separate from our current wrappers | Overlaps with local `playwright` skill |
| `vercel-labs/agent-browser@agent-browser` | If we need long-lived browser sessions, profile reuse, or auth-state heavy automation | Overlaps with Playwright flow and the page shows a `Snyk Fail` audit result |
| `squirrelscan/skills@audit-website` | If website SEO/perf/security audits become a repeated workflow | Requires external `squirrel` CLI and has `Snyk Warn` |
| `evgyur/find-skills@find-skills` | If we want an agent-facing marketplace discovery helper inside Codex | Useful, but `npx skills find` already exists directly |

## Low priority or not needed now

| Skill family | Reason |
|---|---|
| Narrow code-review skills such as SQL/PostgreSQL/App Store reviewers | Too specialized for our current shared Codex workspace |
| Alternate browser automation stacks like `browser-use` | Overlaps with our existing Playwright/browser stack without a clear new advantage |
| Generic security-auditor repos with weak provenance or no visible `SKILL.md` | Lower trust than Trail of Bits / clearer audit-focused options |

## Current recommendation

If we install anything from `skills.sh` into this Codex workspace, install in this order:

1. `obra/superpowers@systematic-debugging`
2. `obra/superpowers@requesting-code-review`
3. `currents-dev/playwright-best-practices-skill@playwright-best-practices`
4. One of the security skills only when the task actually needs it:
   - `trailofbits/skills@variant-analysis`
   - `trailofbits/skills@audit-prep-assistant`
   - `sergiodxa/agent-skills@owasp-security-check`
