#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  worktree-close.sh --repo <repo-path> (--worktree <path> | --branch <name>) [options]

Required:
  --repo <path>         Repository root or any path inside the repo
  --worktree <path>     Worktree path to close
  --branch <name>       Branch name to locate and close its worktree

Optional:
  --base <ref>          Base ref used for merged check (default: origin/HEAD -> main/master fallback)
  --delete-remote       Also delete remote branch (origin)
  --force               Allow closing even when branch is not merged (uses branch -D)
  -h, --help            Show help
USAGE
}

repo=""
worktree=""
branch=""
base_ref=""
delete_remote=0
force=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) repo="$2"; shift 2 ;;
    --worktree) worktree="$2"; shift 2 ;;
    --branch) branch="$2"; shift 2 ;;
    --base) base_ref="$2"; shift 2 ;;
    --delete-remote) delete_remote=1; shift ;;
    --force) force=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown arg: $1" >&2; usage >&2; exit 1 ;;
  esac
done

if [[ -z "$repo" ]]; then
  echo "error: --repo is required" >&2
  usage >&2
  exit 1
fi

if [[ -z "$worktree" && -z "$branch" ]]; then
  echo "error: provide --worktree or --branch" >&2
  usage >&2
  exit 1
fi

repo_root="$(git -C "$repo" rev-parse --show-toplevel)"
repo_root_real="$(cd "$repo_root" && pwd -P)"

if [[ -z "$base_ref" ]]; then
  if base_head="$(git -C "$repo_root" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)"; then
    base_ref="$base_head"
  elif git -C "$repo_root" show-ref --verify --quiet refs/remotes/origin/main; then
    base_ref="origin/main"
  elif git -C "$repo_root" show-ref --verify --quiet refs/remotes/origin/master; then
    base_ref="origin/master"
  elif git -C "$repo_root" show-ref --verify --quiet refs/heads/main; then
    base_ref="main"
  else
    base_ref="master"
  fi
fi

if [[ -n "$branch" && -z "$worktree" ]]; then
  while IFS= read -r line; do
    if [[ "$line" == worktree\ * ]]; then
      current_path="${line#worktree }"
    elif [[ "$line" == branch\ refs/heads/* ]]; then
      current_branch="${line#branch refs/heads/}"
      if [[ "$current_branch" == "$branch" ]]; then
        worktree="$current_path"
        break
      fi
    elif [[ -z "$line" ]]; then
      current_path=""
      current_branch=""
    fi
  done < <(git -C "$repo_root" worktree list --porcelain; echo)

  if [[ -z "$worktree" ]]; then
    echo "error: branch not found in any linked worktree: $branch" >&2
    exit 1
  fi
fi

worktree_real="$(cd "$worktree" && pwd -P)"
if [[ "$worktree_real" == "$repo_root_real" ]]; then
  echo "error: refusing to remove primary repository worktree: $worktree_real" >&2
  exit 1
fi

if [[ -z "$branch" ]]; then
  branch="$(git -C "$worktree_real" branch --show-current || true)"
fi

if [[ -z "$branch" ]]; then
  echo "error: unable to detect branch for worktree: $worktree_real" >&2
  echo "hint: pass --branch explicitly or detach cleanup manually" >&2
  exit 1
fi

if git -C "$repo_root" show-ref --verify --quiet "refs/heads/$branch"; then
  if [[ $force -eq 0 ]]; then
    if ! git -C "$repo_root" merge-base --is-ancestor "$branch" "$base_ref"; then
      echo "error: branch '$branch' is not merged into '$base_ref'" >&2
      echo "hint: merge first or rerun with --force" >&2
      exit 1
    fi
  fi
fi

remove_args=(worktree remove)
if [[ $force -eq 1 ]]; then
  remove_args+=(--force)
fi
remove_args+=("$worktree_real")

git -C "$repo_root" "${remove_args[@]}"

if git -C "$repo_root" show-ref --verify --quiet "refs/heads/$branch"; then
  if [[ $force -eq 1 ]]; then
    git -C "$repo_root" branch -D "$branch"
  else
    git -C "$repo_root" branch -d "$branch"
  fi
fi

if [[ $delete_remote -eq 1 ]]; then
  if git -C "$repo_root" ls-remote --exit-code --heads origin "$branch" >/dev/null 2>&1; then
    git -C "$repo_root" push origin --delete "$branch"
  else
    echo "remote branch not found (skip): origin/$branch"
  fi
fi

git -C "$repo_root" worktree prune

echo "Closed worktree"
echo "- repo:     $repo_root"
echo "- branch:   $branch"
echo "- worktree: $worktree_real"
echo "- base:     $base_ref"
