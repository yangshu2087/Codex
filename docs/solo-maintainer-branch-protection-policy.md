# Solo-maintainer branch protection policy

Purpose: define a narrow, auditable exception for `yangshu2087/Codex` when GitHub branch protection requires a pull request review but the repository has only one maintainer / code owner: `@yangshu2087`.

This policy exists to prevent a temporary unblock from becoming an undocumented default bypass.

## Scope

This policy applies only to this repository:

- Repository: `yangshu2087/Codex`
- Default branch: `main`
- Current solo maintainer / code owner: `@yangshu2087`

Do **not** copy this exception to multi-maintainer repositories or production/business repositories without a separate governance decision.

## Real problem

The repository intentionally uses branch protection, CODEOWNERS, and pull requests to avoid direct pushes to `main`. However, when the only collaborator and code owner is also the pull request author, GitHub cannot satisfy required review approval:

- GitHub does not allow pull request authors to approve their own pull request.
- Current CODEOWNERS maps all files to `@yangshu2087`.
- Current collaborators list only `@yangshu2087`.

With `required_approving_review_count = 1` and `require_code_owner_reviews = true`, solo-maintainer PRs can become structurally blocked even after local verification passes.

## Decision

For this repository while it remains solo-maintained, branch protection may use the following solo-maintainer profile:

- Keep `enforce_admins = true`.
- Keep `required_linear_history = true`.
- Keep force pushes disabled.
- Keep branch deletion disabled.
- Keep pull-request based workflow as the expected path.
- Set required approving review count to `0` for solo-maintainer operation.
- Disable required code-owner review while no second code owner exists.

This does **not** authorize direct pushes to `main` as the normal workflow. Work should still be prepared on feature branches and merged through pull requests with evidence recorded in the PR.

## Required evidence before solo-maintainer merge

Before merging a solo-maintainer PR under this policy, the PR must include:

1. Summary of intent and changed scope.
2. Verification commands and observed output.
3. Known gaps or skipped checks.
4. Risk assessment for governance, credentials, external services, or production impact when relevant.
5. Rollback path, at minimum `git revert <merge-commit-or-commit>` or file-level rollback instructions.
6. A note that the PR is being merged under this solo-maintainer policy because no independent reviewer is available.

## Challenge gate

If a change touches any of the following, Codex must challenge before merge and suggest a safer path:

- Branch protection, repository permissions, CODEOWNERS, or GitHub settings.
- Secrets, OAuth credentials, browser cookies, or production credentials.
- Deployment, domain, billing, or provider settings.
- Broad deletes or irreversible migrations.
- Global skill/plugin installation or external write-capable tools.

The challenge must include:

- Real goal.
- Steel-man / why the request is understandable.
- Concrete risk.
- Better option and conservative fallback.
- Execution boundary.

## Preferred path when a second reviewer exists

Once a second trusted collaborator or code owner is added, restore the normal review profile:

- `required_approving_review_count = 1`
- `require_code_owner_reviews = true`

The second reviewer should be added to `CODEOWNERS` or a relevant ownership rule so review routing is explicit.

## Rollback

To roll back this exception:

1. Restore required pull request reviews on `main`:
   - `required_approving_review_count = 1`
   - `require_code_owner_reviews = true`
2. Confirm `enforce_admins = true` remains enabled.
3. Confirm force pushes and branch deletion remain disabled.
4. Update this document with the date and reason for returning to the stricter review profile.

## Review cadence

Review this policy whenever one of these changes occurs:

- A second collaborator is added.
- CODEOWNERS changes.
- The repo begins storing production code, secrets, deployment workflows, or business-critical automation.
- A solo-maintainer merge causes a regression or policy concern.
