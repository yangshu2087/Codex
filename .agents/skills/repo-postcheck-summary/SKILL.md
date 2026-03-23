---
name: repo-postcheck-summary
description: Run the minimum useful verification after repository bootstrap or small setup changes, then produce a concise change summary. Use when a repo has just been initialized or had Codex scaffolding added and the user wants a quick verification-and-summary pass.
---

# Repo Postcheck Summary

Use this skill after repository bootstrap, setup-file changes, or other small structural edits where a full test suite would be excessive.

## Workflow

1. Run the smallest checks that prove the setup is coherent:
   - `git status --short`
   - inspect the changed files
   - one repo-specific validation command if the repo guidance calls for it
2. Do not invent heavyweight validation for a minimal repository.
3. Summarize changes in three parts:
   - what files were added or changed
   - what was verified
   - what remains unverified
4. If the repo has no meaningful test or build surface yet, say that explicitly instead of pretending validation was comprehensive.
5. If the repo is about Git behavior, prefer replaying the exact Git commands relevant to the scenario over generic tooling.

## Output standard

- Keep the summary short and operational.
- Include exact repo path.
- Include exact verification commands run.
- Call out any remaining risk in one sentence.
