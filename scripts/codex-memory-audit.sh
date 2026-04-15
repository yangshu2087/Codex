#!/usr/bin/env bash
set -euo pipefail

MEMORY_DIR="${1:-${CODEX_MEMORY_DIR:-$HOME/.codex/memories}}"
MAX_MEMORY_BYTES="${CODEX_MEMORY_MAX_BYTES:-131072}"
MAX_LINE_BYTES="${CODEX_MEMORY_MAX_LINE_BYTES:-4096}"
STATUS=0

section() { printf '\n== %s ==\n' "$1"; }
pass() { printf '[PASS] %s\n' "$1"; }
warn() { printf '[WARN] %s\n' "$1"; }
fail() { printf '[FAIL] %s\n' "$1"; STATUS=1; }

section "memory path"
printf 'memory_dir=%s\n' "$MEMORY_DIR"
if [[ ! -d "$MEMORY_DIR" ]]; then
  fail "memory directory missing"
  exit "$STATUS"
fi

python3 - "$MEMORY_DIR" "$MAX_MEMORY_BYTES" "$MAX_LINE_BYTES" <<'PY'
from __future__ import annotations
import json
import re
import sys
from pathlib import Path

root = Path(sys.argv[1]).expanduser()
max_bytes = int(sys.argv[2])
max_line = int(sys.argv[3])
status = 0

secret_patterns = [
    ("aws_access_key", r"AKIA[0-9A-Z]{16}"),
    ("openai_key", r"sk-[A-Za-z0-9_-]{20,}"),
    ("github_token", r"gh[pousr]_[A-Za-z0-9_]{20,}"),
    ("slack_token", r"xox[baprs]-[A-Za-z0-9-]{20,}"),
    ("generic_secret_assignment", r"(?i)(api[_-]?key|secret|token|password|cookie)\s*[:=]\s*['\"]?[^\s'\"]{8,}"),
]

def report(kind: str, msg: str):
    print(f"[{kind}] {msg}")

def fail(msg: str):
    global status
    status = 1
    report("FAIL", msg)

files = sorted([p for p in root.rglob("*") if p.is_file()])
if not files:
    report("WARN", "no memory files found")
else:
    report("PASS", f"memory files found: {len(files)}")

for p in files:
    rel = p.relative_to(root)
    size = p.stat().st_size
    if size > max_bytes:
        fail(f"{rel} exceeds max bytes {max_bytes}: {size}")
    else:
        report("PASS", f"size ok: {rel} ({size} bytes)")
    text = p.read_text(encoding="utf-8", errors="replace")
    for idx, line in enumerate(text.splitlines(), start=1):
        if len(line.encode("utf-8")) > max_line:
            fail(f"{rel}:{idx} line exceeds {max_line} bytes")
        for name, pattern in secret_patterns:
            if re.search(pattern, line):
                fail(f"{rel}:{idx} contains secret-like pattern: {name}")
    if p.suffix == ".jsonl":
        for idx, line in enumerate(text.splitlines(), start=1):
            if not line.strip():
                continue
            try:
                obj = json.loads(line)
            except json.JSONDecodeError as exc:
                fail(f"{rel}:{idx} invalid JSONL: {exc}")
                continue
            required = ["date", "repo", "task_type", "feedback", "root_cause", "memory_candidate", "action_required"]
            missing = [key for key in required if key not in obj]
            if missing:
                fail(f"{rel}:{idx} missing keys: {missing}")
        if status == 0:
            report("PASS", f"jsonl ok: {rel}")

sys.exit(status)
PY
STATUS=$?

section "summary"
if [[ "$STATUS" -eq 0 ]]; then
  pass "memory audit passed"
else
  fail "memory audit failed"
fi
exit "$STATUS"
