# Vendored Skills

## Why this exists

Some third-party skills are too large to keep live in `.agents/skills` all the time.

For this workspace, the policy is:
- keep small, high-frequency skills active in `.agents/skills`
- keep large third-party skills mirrored under `vendor/skills`
- activate vendored skills on demand into `~/.agents/skills` using a symlink

Codex supports symlinked skills, so this keeps the repository reproducible without forcing every heavy skill into every session.

## Current vendored skills

- `playwright-best-practices`

## Commands

```bash
# List vendored skills
/Users/yangshu/Codex/scripts/manage-vendored-skill.sh list

# Check whether a vendored skill is active
/Users/yangshu/Codex/scripts/manage-vendored-skill.sh status playwright-best-practices

# Activate for current user
/Users/yangshu/Codex/scripts/manage-vendored-skill.sh activate playwright-best-practices

# Deactivate when no longer needed
/Users/yangshu/Codex/scripts/manage-vendored-skill.sh deactivate playwright-best-practices
```

## What stays active by default

- `systematic-debugging`
- `requesting-code-review`
- custom workspace skills such as `repo-codex-bootstrap`, `repo-postcheck-summary`, `worktree-safety`, and `webpage-capture-markdown`
