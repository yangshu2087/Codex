#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  worktree-create.sh --repo <repo-path> --type <type> --ticket <id> --slug <slug> [options]

Required:
  --repo <path>         Target git repository path
  --type <type>         feat|fix|chore|refactor|spike|review|hotfix
  --ticket <id>         Ticket/date segment (e.g. 20260408 or LIN-123)
  --slug <slug>         Lowercase kebab-case short summary

Optional:
  --repo-short <name>   Repository short name for branch/path (default: repo dir name)
  --base <ref>          Base ref for new branch (default: origin/main, fallback origin/master/main/master/HEAD)
  --worktrees-root <p>  Root for persistent worktrees (default: /Users/yangshu/worktrees)
  --no-fetch            Skip "git fetch origin --prune"
  --use-existing-branch Allow attaching to existing local branch instead of failing
  -h, --help            Show help

Creates:
  branch:   codex/<type>/<repo-short>/<ticket>-<slug>
  worktree: <worktrees-root>/<repo-short>/<ticket>-<slug>
USAGE
}

repo=""
repo_short=""
type=""
ticket=""
slug=""
base_ref=""
worktrees_root="/Users/yangshu/worktrees"
do_fetch=1
use_existing_branch=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) repo="$2"; shift 2 ;;
    --repo-short) repo_short="$2"; shift 2 ;;
    --type) type="$2"; shift 2 ;;
    --ticket) ticket="$2"; shift 2 ;;
    --slug) slug="$2"; shift 2 ;;
    --base) base_ref="$2"; shift 2 ;;
    --worktrees-root) worktrees_root="$2"; shift 2 ;;
    --no-fetch) do_fetch=0; shift ;;
    --use-existing-branch) use_existing_branch=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown arg: $1" >&2; usage >&2; exit 1 ;;
  esac
done

if [[ -z "$repo" || -z "$type" || -z "$ticket" || -z "$slug" ]]; then
  echo "error: missing required arguments" >&2
  usage >&2
  exit 1
fi

if [[ ! "$type" =~ ^(feat|fix|chore|refactor|spike|review|hotfix)$ ]]; then
  echo "error: unsupported --type '$type'" >&2
  exit 1
fi

if [[ ! "$slug" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "error: --slug must be lowercase kebab-case (got: $slug)" >&2
  exit 1
fi

repo_root="$(git -C "$repo" rev-parse --show-toplevel)"
if [[ -z "$repo_short" ]]; then
  repo_short="$(basename "$repo_root")"
fi

if [[ $do_fetch -eq 1 ]]; then
  git -C "$repo_root" fetch origin --prune >/dev/null 2>&1 || true
fi

if [[ -z "$base_ref" ]]; then
  if git -C "$repo_root" show-ref --verify --quiet refs/remotes/origin/main; then
    base_ref="origin/main"
  elif git -C "$repo_root" show-ref --verify --quiet refs/remotes/origin/master; then
    base_ref="origin/master"
  elif git -C "$repo_root" show-ref --verify --quiet refs/heads/main; then
    base_ref="main"
  elif git -C "$repo_root" show-ref --verify --quiet refs/heads/master; then
    base_ref="master"
  else
    base_ref="HEAD"
  fi
fi

branch="codex/${type}/${repo_short}/${ticket}-${slug}"
worktree_path="${worktrees_root%/}/${repo_short}/${ticket}-${slug}"

local_exists=0
remote_exists=0
if git -C "$repo_root" show-ref --verify --quiet "refs/heads/$branch"; then
  local_exists=1
fi
if git -C "$repo_root" show-ref --verify --quiet "refs/remotes/origin/$branch"; then
  remote_exists=1
fi

if [[ -e "$worktree_path" ]]; then
  echo "error: target worktree path already exists: $worktree_path" >&2
  exit 1
fi

mkdir -p "$(dirname "$worktree_path")"

if [[ $local_exists -eq 1 ]]; then
  if [[ $use_existing_branch -eq 1 ]]; then
    git -C "$repo_root" worktree add "$worktree_path" "$branch"
  else
    echo "error: local branch already exists: $branch" >&2
    echo "hint: rerun with --use-existing-branch or choose a different ticket/slug" >&2
    exit 1
  fi
else
  if [[ $remote_exists -eq 1 && $use_existing_branch -eq 0 ]]; then
    echo "error: remote branch already exists: origin/$branch" >&2
    echo "hint: choose a different ticket/slug, or fetch and create a local branch manually" >&2
    exit 1
  fi
  git -C "$repo_root" worktree add -b "$branch" "$worktree_path" "$base_ref"
fi

echo "Created persistent worktree"
echo "- repo:     $repo_root"
echo "- branch:   $branch"
echo "- base:     $base_ref"
echo "- worktree: $worktree_path"
echo ""
echo "Next steps:"
echo "1) cd '$worktree_path'"
echo "2) run repo-local checks and update docs/agent-handoff.md during handoff"
