#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  update-agent-handoff.sh [repo-path]
  update-agent-handoff.sh --repo /path/to/repo [--verify "command"]... [--note "text"]...

Behavior:
  - updates docs/agent-handoff.md in the target repo
  - preserves human-written sections such as Current goal, Done, Next step, and Blockers
  - refreshes Branch, Changed files, and Verification
  - ignores the handoff file itself when computing changed files, so the refresh does not report its own edit

Examples:
  /Users/yangshu/Codex/scripts/update-agent-handoff.sh /Users/yangshu/Codex/projects/codex-main
  /Users/yangshu/Codex/scripts/update-agent-handoff.sh --repo . --verify "git worktree list"
  /Users/yangshu/Codex/scripts/update-agent-handoff.sh --repo . --verify "npm test" --note "Smoke test not run for the UI package."
EOF
}

repo_arg=""
declare -a verify_cmds=()
declare -a note_lines=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --repo)
      [[ $# -ge 2 ]] || { echo "error: --repo requires a path" >&2; exit 1; }
      repo_arg="$2"
      shift 2
      ;;
    --verify)
      [[ $# -ge 2 ]] || { echo "error: --verify requires a command string" >&2; exit 1; }
      verify_cmds+=("$2")
      shift 2
      ;;
    --note)
      [[ $# -ge 2 ]] || { echo "error: --note requires text" >&2; exit 1; }
      note_lines+=("$2")
      shift 2
      ;;
    *)
      if [[ -z "$repo_arg" ]]; then
        repo_arg="$1"
        shift
      else
        echo "error: unexpected argument: $1" >&2
        usage >&2
        exit 1
      fi
      ;;
  esac
done

if [[ -z "$repo_arg" ]]; then
  repo_arg="$PWD"
fi

repo_root="$(git -C "$repo_arg" rev-parse --show-toplevel)"
handoff_rel="docs/agent-handoff.md"
handoff_path="$repo_root/$handoff_rel"
mkdir -p "$(dirname "$handoff_path")"

if [[ ! -f "$handoff_path" ]]; then
  cat > "$handoff_path" <<'EOF'
# Agent Handoff

Use this file to transfer execution state between Codex and Cursor.
Update it before pausing work, switching tools, or asking another agent to continue.

## Current goal

- _Replace with the current task in one sentence._

## Branch

- Current branch: `_replace-me_`

## Done

- _Completed item 1_
- _Completed item 2_

## Changed files

- `_replace-me_`

## Verification

- `_command_` — `_result_`

## Next step

- _Smallest safe next action for the next tool or agent._

## Blockers

- _None_ / _describe blocker_
EOF
fi

tmpdir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT

branch="$(git -C "$repo_root" branch --show-current || true)"
if [[ -z "$branch" ]]; then
  branch="DETACHED"
fi

head_line="$(git -C "$repo_root" log --oneline -n 1)"
refreshed_at="$(TZ=Asia/Shanghai date '+%Y-%m-%d %H:%M:%S %Z')"

status_output="$(git -C "$repo_root" status --short --untracked-files=all | grep -v 'docs/agent-handoff.md' || true)"
status_count="$(printf '%s\n' "$status_output" | sed '/^$/d' | wc -l | tr -d ' ')"

changed_file_list="$tmpdir/changed_files.md"
verification_list="$tmpdir/verification.md"
: > "$changed_file_list"
: > "$verification_list"

if [[ -n "$status_output" ]]; then
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    safe_line="${line//\`/\'}"
    printf -- '- `%s`\n' "$safe_line" >> "$changed_file_list"
  done <<< "$status_output"
  printf -- '- `git status --short` — dirty (%s path(s), excluding `docs/agent-handoff.md`)\n' "$status_count" >> "$verification_list"
else
  printf -- '- _Working tree clean (excluding `docs/agent-handoff.md`)_\n' >> "$changed_file_list"
  printf -- '- `git status --short` — clean (excluding `docs/agent-handoff.md`)\n' >> "$verification_list"
fi

if [[ ${#verify_cmds[@]} -gt 0 ]]; then
  for cmd in "${verify_cmds[@]}"; do
    output_file="$tmpdir/verify.out"
    set +e
    bash -lc "cd \"$repo_root\" && $cmd" >"$output_file" 2>&1
    exit_code=$?
    set -e

    if [[ $exit_code -eq 0 ]]; then
      status_label="passed"
    else
      status_label="failed"
    fi

    first_line="$(awk 'NF { print; exit }' "$output_file" | tr '\t' ' ' | tr -d '\r')"
    if [[ ${#first_line} -gt 140 ]]; then
      first_line="${first_line:0:137}..."
    fi
    safe_cmd="${cmd//\`/\'}"
    safe_line="${first_line//\`/\'}"

    if [[ -n "$safe_line" ]]; then
      printf -- '- `%s` — %s (exit %s); %s\n' "$safe_cmd" "$status_label" "$exit_code" "$safe_line" >> "$verification_list"
    else
      printf -- '- `%s` — %s (exit %s)\n' "$safe_cmd" "$status_label" "$exit_code" >> "$verification_list"
    fi
  done
else
  printf -- '- _No explicit verification command recorded in this refresh._\n' >> "$verification_list"
fi

if [[ ${#note_lines[@]} -gt 0 ]]; then
  for note in "${note_lines[@]}"; do
    safe_note="${note//\`/\'}"
    printf -- '- %s\n' "$safe_note" >> "$verification_list"
  done
fi

python3 - "$handoff_path" "$branch" "$head_line" "$refreshed_at" "$changed_file_list" "$verification_list" <<'PY'
import re
import sys
from pathlib import Path

handoff_path = Path(sys.argv[1])
branch = sys.argv[2]
head_line = sys.argv[3]
refreshed_at = sys.argv[4]
changed_path = Path(sys.argv[5])
verification_path = Path(sys.argv[6])

text = handoff_path.read_text(encoding="utf-8")
changed_body = changed_path.read_text(encoding="utf-8").rstrip() + "\n"
verification_body = verification_path.read_text(encoding="utf-8").rstrip() + "\n"

def section_regex(title: str) -> re.Pattern:
    return re.compile(rf'(^## {re.escape(title)}\n\n)(.*?)(?=^## |\Z)', re.M | re.S)

def replace_section(document: str, title: str, body: str) -> str:
    pattern = section_regex(title)
    if pattern.search(document):
      return pattern.sub(lambda m: m.group(1) + body + "\n", document, count=1)
    suffix = "" if document.endswith("\n") else "\n"
    return f"{document}{suffix}\n## {title}\n\n{body}\n"

branch_body = (
    f"- Current branch: `{branch}`\n"
    f"- HEAD: `{head_line}`\n"
    f"- Last refreshed: `{refreshed_at}`\n"
)

text = replace_section(text, "Branch", branch_body)
text = replace_section(text, "Changed files", changed_body)
text = replace_section(text, "Verification", verification_body)
handoff_path.write_text(text, encoding="utf-8")
PY

echo "Updated $handoff_path"
