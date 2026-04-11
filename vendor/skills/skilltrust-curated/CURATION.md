# SkillTrust Curated Codex Skills

This directory contains a small, on-demand subset selected from the local SkillTrust catalog. These skills are mirrored for review and selective activation only; they are not part of the default Codex routing layer.

## Policy

- Keep this directory L3 / on-demand.
- Do not symlink or copy the full third-party repos into global skills.
- Promote only narrow, Codex-native distilled skills into `~/.agents/skills` after a separate audit.
- Prefer existing workspace skills when an equivalent already exists.

## Included subsets

- `codex-workflows/`: task analysis, documentation criteria, testing, and frontend review recipe.
- `stitch-kit/`: Stitch prompt, DESIGN.md, design-system, React, and Next.js conversion workflows.
- `terrashark/`: Terraform/OpenTofu failure-mode workflow and references.
