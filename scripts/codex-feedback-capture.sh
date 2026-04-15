#!/usr/bin/env bash
set -euo pipefail

LOG_PATH="${CODEX_FEEDBACK_LOG:-$HOME/.codex/memories/feedback-log.jsonl}"
REPO="${CODEX_FEEDBACK_REPO:-}"
TASK_TYPE="codex-feedback"
FEEDBACK=""
ROOT_CAUSE=""
MEMORY_CANDIDATE=""
ACTION_REQUIRED=""
ALLOW_SENSITIVE=0

usage() {
  cat <<'USAGE'
Usage: codex-feedback-capture.sh --feedback TEXT [options]

Options:
  --repo PATH                 Repository/workspace path. Defaults to git root or cwd.
  --task-type TEXT            Task type, e.g. codex-maintenance, frontend, backend-api.
  --root-cause TEXT           Root-cause summary.
  --memory-candidate TEXT     Short memory candidate, or "none".
  --action-required TEXT      Durable follow-up such as update AGENTS/skill/hook/script.
  --log PATH                  Override JSONL output path.
  --allow-sensitive           Do not reject secret-like text. Use only for redacted test fixtures.
  -h, --help                  Show this help.

The script appends one short JSONL event. It rejects obvious secrets by default.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) REPO="${2:?missing --repo value}"; shift 2 ;;
    --task-type) TASK_TYPE="${2:?missing --task-type value}"; shift 2 ;;
    --feedback) FEEDBACK="${2:?missing --feedback value}"; shift 2 ;;
    --root-cause) ROOT_CAUSE="${2:?missing --root-cause value}"; shift 2 ;;
    --memory-candidate) MEMORY_CANDIDATE="${2:?missing --memory-candidate value}"; shift 2 ;;
    --action-required) ACTION_REQUIRED="${2:?missing --action-required value}"; shift 2 ;;
    --log) LOG_PATH="${2:?missing --log value}"; shift 2 ;;
    --allow-sensitive) ALLOW_SENSITIVE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ -z "$FEEDBACK" ]]; then
  echo "Missing required --feedback" >&2
  usage >&2
  exit 2
fi

if [[ -z "$REPO" ]]; then
  REPO="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi

python3 - "$LOG_PATH" "$REPO" "$TASK_TYPE" "$FEEDBACK" "$ROOT_CAUSE" "$MEMORY_CANDIDATE" "$ACTION_REQUIRED" "$ALLOW_SENSITIVE" <<'PY'
from __future__ import annotations
import json
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

log_path = Path(sys.argv[1]).expanduser()
repo, task_type, feedback, root_cause, memory_candidate, action_required = sys.argv[2:8]
allow_sensitive = sys.argv[8] == "1"

secret_patterns = [
    r"AKIA[0-9A-Z]{16}",
    r"sk-[A-Za-z0-9_-]{20,}",
    r"xox[baprs]-[A-Za-z0-9-]{20,}",
    r"gh[pousr]_[A-Za-z0-9_]{20,}",
    r"(?i)(api[_-]?key|secret|token|password|cookie)\s*[:=]\s*['\"]?[^\s'\"]{8,}",
]
joined = "\n".join([feedback, root_cause, memory_candidate, action_required])
if not allow_sensitive:
    for pattern in secret_patterns:
        if re.search(pattern, joined):
            raise SystemExit("Refusing to store secret-like feedback text; redact it or pass --allow-sensitive for a controlled test.")

def compact(value: str, limit: int = 1000) -> str:
    value = " ".join((value or "").split())
    return value[:limit] + ("…" if len(value) > limit else "")

event = {
    "date": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
    "repo": repo,
    "task_type": compact(task_type, 160),
    "feedback": compact(feedback),
    "root_cause": compact(root_cause, 500),
    "memory_candidate": compact(memory_candidate, 500),
    "action_required": compact(action_required, 500),
}
log_path.parent.mkdir(parents=True, exist_ok=True)
with log_path.open("a", encoding="utf-8") as fh:
    fh.write(json.dumps(event, ensure_ascii=False, sort_keys=True) + "\n")
print(f"captured_feedback={log_path}")
print(json.dumps(event, ensure_ascii=False, sort_keys=True))
PY
