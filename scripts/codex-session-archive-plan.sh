#!/usr/bin/env bash
set -euo pipefail

CODEX_HOME="${CODEX_HOME:-/Users/yangshu/.codex}"
SESSIONS_DIR="${CODEX_SESSIONS_DIR:-$CODEX_HOME/sessions}"
ARCHIVE_ROOT="${CODEX_SESSION_ARCHIVE_ROOT:-$CODEX_HOME/session-archives}"
MIN_SIZE_MIB="${CODEX_SESSION_ARCHIVE_MIN_SIZE_MIB:-50}"
LIMIT="${CODEX_SESSION_ARCHIVE_LIMIT:-20}"
APPLY=0
MODE="dry-run"

usage() {
  cat <<'USAGE'
Usage: codex-session-archive-plan.sh [--min-size-mib N] [--limit N] [--archive-root DIR] [--apply --copy]

Default behavior is safe and read-only:
  - scans ~/.codex/sessions for large .jsonl files
  - writes a manifest and summary under /tmp
  - does not move, delete, compress, or rewrite session files

Optional copy archive:
  --apply --copy    Copy selected candidates into the archive root, preserving relative paths and metadata.
                   This does not delete or move originals and therefore does not reclaim disk by itself.

Environment variables:
  CODEX_HOME
  CODEX_SESSIONS_DIR
  CODEX_SESSION_ARCHIVE_ROOT
  CODEX_SESSION_ARCHIVE_MIN_SIZE_MIB
  CODEX_SESSION_ARCHIVE_LIMIT
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --min-size-mib)
      MIN_SIZE_MIB="${2:?missing value for --min-size-mib}"; shift 2 ;;
    --limit)
      LIMIT="${2:?missing value for --limit}"; shift 2 ;;
    --archive-root)
      ARCHIVE_ROOT="${2:?missing value for --archive-root}"; shift 2 ;;
    --apply)
      APPLY=1; shift ;;
    --copy)
      MODE="copy"; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2 ;;
  esac
done

if [[ "$APPLY" -eq 1 && "$MODE" != "copy" ]]; then
  echo "--apply currently requires --copy; move/delete modes are intentionally not implemented." >&2
  exit 2
fi

TS="$(date +%Y%m%d-%H%M%S)"
if [[ "$APPLY" -eq 1 ]]; then
  RUN_DIR="${ARCHIVE_ROOT%/}/archive-${TS}"
else
  RUN_DIR="/tmp/codex-session-archive-plan-${TS}"
fi
mkdir -p "$RUN_DIR"
MANIFEST="$RUN_DIR/manifest.jsonl"
SUMMARY="$RUN_DIR/summary.txt"

python3 - "$SESSIONS_DIR" "$ARCHIVE_ROOT" "$RUN_DIR" "$MANIFEST" "$SUMMARY" "$MIN_SIZE_MIB" "$LIMIT" "$APPLY" "$MODE" <<'PY'
from __future__ import annotations
import hashlib
import json
import os
import shutil
import sys
from datetime import datetime, timezone
from pathlib import Path

sessions_dir = Path(sys.argv[1]).expanduser()
archive_root = Path(sys.argv[2]).expanduser()
run_dir = Path(sys.argv[3]).expanduser()
manifest = Path(sys.argv[4])
summary = Path(sys.argv[5])
min_size_mib = float(sys.argv[6])
limit = int(sys.argv[7])
apply = sys.argv[8] == '1'
mode = sys.argv[9]
min_size = int(min_size_mib * 1024 * 1024)

if not sessions_dir.exists():
    raise SystemExit(f'sessions directory not found: {sessions_dir}')

def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b''):
            h.update(chunk)
    return h.hexdigest()

files = []
for p in sessions_dir.rglob('*.jsonl'):
    if not p.is_file():
        continue
    size = p.stat().st_size
    if size >= min_size:
        files.append((size, p))
files.sort(reverse=True, key=lambda item: item[0])
selected = files[:limit]

records = []
for size, src in selected:
    rel = src.relative_to(sessions_dir)
    dest = run_dir / 'sessions' / rel
    record = {
        'timestamp_utc': datetime.now(timezone.utc).isoformat(),
        'action': 'copy' if apply and mode == 'copy' else 'dry-run',
        'source': str(src),
        'relative_path': str(rel),
        'size_bytes': size,
        'size_mib': round(size / 1024 / 1024, 2),
        'sha256': sha256_file(src),
        'archive_path': str(dest) if apply and mode == 'copy' else None,
        'original_preserved': True,
    }
    if apply and mode == 'copy':
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dest)
        copied_hash = sha256_file(dest)
        if copied_hash != record['sha256']:
            raise SystemExit(f'sha256 mismatch after copy: {src} -> {dest}')
        record['archive_sha256'] = copied_hash
    records.append(record)

with manifest.open('w', encoding='utf-8') as f:
    for record in records:
        f.write(json.dumps(record, ensure_ascii=False) + '\n')

total_mib = sum(r['size_mib'] for r in records)
all_total_mib = sum(size for size, _ in files) / 1024 / 1024
with summary.open('w', encoding='utf-8') as f:
    f.write('Codex session archive plan\n')
    f.write('==========================\n')
    f.write(f'Mode: {"copy" if apply and mode == "copy" else "dry-run"}\n')
    f.write(f'Sessions dir: {sessions_dir}\n')
    f.write(f'Archive root: {archive_root}\n')
    f.write(f'Run dir: {run_dir}\n')
    f.write(f'Min size MiB: {min_size_mib}\n')
    f.write(f'Limit: {limit}\n')
    f.write(f'Candidate files above threshold: {len(files)} ({all_total_mib:.1f} MiB)\n')
    f.write(f'Selected files: {len(records)} ({total_mib:.1f} MiB)\n')
    f.write(f'Manifest: {manifest}\n')
    f.write('\n')
    if not records:
        f.write('No candidates selected.\n')
    else:
        f.write('Selected candidates:\n')
        for r in records:
            f.write(f"- {r['size_mib']:8.1f} MiB  {r['source']}\n")
            if r.get('archive_path'):
                f.write(f"  -> {r['archive_path']}\n")
    f.write('\nSafety notes:\n')
    f.write('- This script never deletes originals.\n')
    f.write('- Default dry-run writes only this plan/manifest.\n')
    f.write('- --apply --copy preserves originals and validates sha256 after copy.\n')
    f.write('- Moving/removing sessions should remain a separate, explicit, low-traffic-window decision.\n')

print(summary.read_text(encoding='utf-8'))
PY

echo "Summary: $SUMMARY"
echo "Manifest: $MANIFEST"
