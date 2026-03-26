# GitHub and Local Agent Workflow

## Purpose

This workspace uses GitHub as the repository control plane and uses local agents as execution surfaces with different strengths.

## Source of truth

- GitHub owns protected branches, pull requests, review state, and merge policy.
- Codex owns high-autonomy implementation, repo-local verification, and structured review prompts.
- Cursor owns fast IDE iteration and local editing convenience.
- OpenClaw owns multi-provider routing, automation, fallback orchestration, and cross-agent session management.

## Recommended flow

1. Start from the target repository, not from the meta-workspace by accident.
2. Create a short-lived branch for any change that should land on `main`.
3. Implement locally with the right tool:
   - Codex for heavier repo changes, review-minded work, and scripted verification
   - Cursor for tight edit loops and interactive inspection
   - OpenClaw when you need provider routing, automation, or orchestrated multi-agent tasks
4. Before opening a PR, run the narrowest verification and use the `requesting-code-review` skill against the actual diff.
5. Open a GitHub PR, let branch protection and `CODEOWNERS` drive the merge gate, and keep `main` as the stable branch.

## Local observations on this machine

- Codex is configured as the most structured local coding surface, with repo-level `AGENTS.md`, `.codex/config.toml`, and review-oriented skills.
- Cursor is configured as a permissive local editor surface. Its current CLI config shows allowlist approvals, disabled sandboxing, and commit/PR attribution enabled.
- OpenClaw is configured as a local orchestration layer with mixed providers, including `openai-codex`, `cursor-cli`, `anthropic`, `openrouter`, and local `ollama`.
- OpenClaw's default workspace is `/Users/yangshu/.openclaw/workspace`, which means it should not be treated as the source of truth for repository policy. GitHub and checked-in repo files should stay authoritative.
- OpenClaw's Telegram channel is intentionally exposed in open mode on this machine. Treat Telegram as a public ingress path unless the channel policy is explicitly tightened again.

## Coordination rules

- Do not encode branch policy only in a chat prompt. Mirror it in GitHub settings and checked-in `.github/` files.
- Do not let Cursor or OpenClaw bypass repository review expectations just because they can edit locally.
- If a workflow needs a review gate, prefer GitHub protection plus `CODEOWNERS` over tool-specific memory.
- If a workflow repeats across tools, document the shared sequence once and keep the tools aligned to it.
- Keep external channel exposure documented near both the OpenClaw config and the Codex workspace docs, so repository work does not silently assume a private bot surface.

## Current collaboration baseline

- `Codex` repository: public, branch-protected, `CODEOWNERS` present
- `codex-worktree-base`, `codex-main`, `git-init-check`: private, branch-protected, `CODEOWNERS` added
- All four repositories should use the same branch-to-PR-to-merge flow even if the local editing surface varies
