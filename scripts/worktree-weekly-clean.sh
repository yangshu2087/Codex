#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  worktree-weekly-clean.sh --repo <repo-path> [options]

Required:
  --repo <path>         Repository root or any path inside the repo

Optional:
  --days-stale <n>      Days of inactivity before "review" (default: 7)
  --days-drop <n>       Days of inactivity + merged for auto-close (default: 30)
  --base <ref>          Base ref for merged checks (default: origin/HEAD -> main/master fallback)
  --apply               Apply auto-close actions for stale+merged linked worktrees
  --yes                 Required with --apply (safety gate)
  --delete-remote       With --apply, also delete remote branches
  -h, --help            Show help

Default mode is audit-only (no deletion).
USAGE
}

repo=""
days_stale=7
days_drop=30
base_ref=""
apply=0
yes=0
delete_remote=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) repo="$2"; shift 2 ;;
    --days-stale) days_stale="$2"; shift 2 ;;
    --days-drop) days_drop="$2"; shift 2 ;;
    --base) base_ref="$2"; shift 2 ;;
    --apply) apply=1; shift ;;
    --yes) yes=1; shift ;;
    --delete-remote) delete_remote=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown arg: $1" >&2; usage >&2; exit 1 ;;
  esac
done

if [[ -z "$repo" ]]; then
  echo "error: --repo is required" >&2
  usage >&2
  exit 1
fi

if [[ $apply -eq 1 && $yes -ne 1 ]]; then
  echo "error: --apply requires --yes" >&2
  exit 1
fi

repo_root="$(git -C "$repo" rev-parse --show-toplevel)"
repo_root_real="$(cd "$repo_root" && pwd -P)"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
close_script="$script_dir/worktree-close.sh"

if [[ ! -x "$close_script" ]]; then
  echo "error: close helper not found: $close_script" >&2
  exit 1
fi

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

git -C "$repo_root" worktree prune

tmp_report="$(mktemp)"
cleanup() {
  rm -f "$tmp_report"
}
trap cleanup EXIT

current_path=""
current_branch=""
now_ts="$(date +%s)"

write_entry() {
  local path="$1"
  local branch="$2"
  if [[ -z "$path" ]]; then
    return
  fi

  local path_real
  path_real="$(cd "$path" && pwd -P)"

  local branch_display merged action
  branch_display="$branch"
  if [[ -z "$branch_display" ]]; then
    branch_display="<detached>"
  fi

  local last_ts=0
  last_ts="$(git -C "$path_real" log -1 --format=%ct 2>/dev/null || echo 0)"
  if [[ -z "$last_ts" ]]; then
    last_ts=0
  fi
  local days=0
  if [[ "$last_ts" =~ ^[0-9]+$ ]] && [[ "$last_ts" -gt 0 ]]; then
    days=$(( (now_ts - last_ts) / 86400 ))
  fi

  merged="n/a"
  if [[ -n "$branch" ]] && git -C "$repo_root" show-ref --verify --quiet "refs/heads/$branch"; then
    if git -C "$repo_root" merge-base --is-ancestor "$branch" "$base_ref"; then
      merged="yes"
    else
      merged="no"
    fi
  elif [[ -n "$branch" ]]; then
    merged="missing-local"
  fi

  if [[ "$path_real" == "$repo_root_real" ]]; then
    action="primary"
  elif [[ "$merged" == "yes" && "$days" -ge "$days_drop" ]]; then
    action="auto-close"
  elif [[ "$days" -ge "$days_stale" ]]; then
    action="review"
  else
    action="keep"
  fi

  printf '%s\t%s\t%s\t%s\t%s\n' "$path_real" "$branch_display" "$days" "$merged" "$action" >> "$tmp_report"
}

while IFS= read -r line; do
  if [[ "$line" == worktree\ * ]]; then
    write_entry "$current_path" "$current_branch"
    current_path="${line#worktree }"
    current_branch=""
  elif [[ "$line" == branch\ refs/heads/* ]]; then
    current_branch="${line#branch refs/heads/}"
  elif [[ -z "$line" ]]; then
    write_entry "$current_path" "$current_branch"
    current_path=""
    current_branch=""
  fi
done < <(git -C "$repo_root" worktree list --porcelain; echo)

echo "Worktree weekly cleanup report"
echo "============================="
echo "Repo:         $repo_root"
echo "Base ref:     $base_ref"
echo "Days stale:   $days_stale"
echo "Days drop:    $days_drop"
echo "Mode:         $([[ $apply -eq 1 ]] && echo apply || echo audit-only)"
echo ""
printf '%-9s %-6s %-12s %s\n' "Action" "Days" "Merged" "Worktree (branch)"
printf '%-9s %-6s %-12s %s\n' "------" "----" "------" "-----------------"

auto_close_count=0
review_count=0
keep_count=0
primary_count=0

while IFS=$'\t' read -r path branch days merged action; do
  case "$action" in
    auto-close) auto_close_count=$((auto_close_count+1)) ;;
    review) review_count=$((review_count+1)) ;;
    keep) keep_count=$((keep_count+1)) ;;
    primary) primary_count=$((primary_count+1)) ;;
  esac
  printf '%-9s %-6s %-12s %s (%s)\n' "$action" "$days" "$merged" "$path" "$branch"
done < "$tmp_report"

echo ""
echo "Summary: primary=$primary_count keep=$keep_count review=$review_count auto-close=$auto_close_count"

if [[ $apply -eq 1 ]]; then
  if [[ $auto_close_count -eq 0 ]]; then
    echo "Apply requested, but no auto-close candidates found."
    exit 0
  fi

  echo ""
  echo "Applying auto-close actions..."
  while IFS=$'\t' read -r path branch days merged action; do
    [[ "$action" == "auto-close" ]] || continue
    args=("$close_script" --repo "$repo_root" --worktree "$path")
    if [[ $delete_remote -eq 1 ]]; then
      args+=(--delete-remote)
    fi
    "${args[@]}"
  done < "$tmp_report"

  echo ""
  echo "Apply complete."
else
  echo ""
  echo "Audit-only mode: no worktrees were removed."
  echo "Use --apply --yes to close stale+merged linked worktrees."
fi
