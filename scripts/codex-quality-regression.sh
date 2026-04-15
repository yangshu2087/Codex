#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TS="$(date +%Y%m%d-%H%M%S)"
OUT_ROOT="${CODEX_REGRESSION_OUT:-/tmp/codex-quality-regression-${TS}}"
BROWSER_URL="${CODEX_REGRESSION_BROWSER_URL:-https://example.com}"
PROFILE_TIMEOUT_SECONDS="${CODEX_REGRESSION_PROFILE_TIMEOUT_SECONDS:-240}"
PROFILE_PROMPT="${CODEX_REGRESSION_PROFILE_PROMPT:-这是一次 Codex 质量回归 profile smoke，不是前端或 UI 实现任务；真实浏览器视觉验证由 agent-browser-smoke 阶段单独负责。本 profile smoke 不要访问外部网站，不要编辑文件，不要运行 shell 命令，不要声称缺少视觉验证。请只用中文输出这些小节：已完成；完成证据；Done criteria；Verification；还缺什么；后续建议。}"

mkdir -p "$OUT_ROOT"

log() { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }
section() { printf '\n== %s ==\n' "$*" | tee -a "$OUT_ROOT/regression.log"; }
run_logged() {
  local name="$1"; shift
  local log_file="$OUT_ROOT/${name}.log"
  section "$name"
  log "running: $*" | tee -a "$OUT_ROOT/regression.log"
  "$@" > >(tee "$log_file") 2> >(tee "$OUT_ROOT/${name}.err" >&2)
}

log "Codex quality regression started"
log "repo root: $REPO_ROOT"
log "output: $OUT_ROOT"
log "browser URL: $BROWSER_URL"
log "profile timeout seconds: $PROFILE_TIMEOUT_SECONDS"

section "version"
{
  echo "which codex: $(command -v codex || true)"
  codex --version
} | tee "$OUT_ROOT/version.log"

run_logged "features" codex features list
run_logged "mcp-list" codex mcp list
run_logged "upgrade-check" "$REPO_ROOT/scripts/check-codex-upgrade.sh"
run_logged "skill-audit" "$REPO_ROOT/scripts/skill-audit.sh"
run_logged "quality-lane-smoke" "$REPO_ROOT/scripts/codex-quality-lane-smoke.sh"
run_logged "challenge-smoke" "$REPO_ROOT/scripts/codex-challenge-smoke.sh"
run_logged "memory-audit" "$REPO_ROOT/scripts/codex-memory-audit.sh"
run_logged "feedback-capture-smoke" env CODEX_FEEDBACK_LOG="$OUT_ROOT/feedback-smoke.jsonl" "$REPO_ROOT/scripts/codex-feedback-capture.sh" --feedback "quality regression feedback smoke" --task-type "quality-regression" --root-cause "synthetic smoke" --memory-candidate "none" --action-required "none"

section "outcome-smoke"
python3 - "$OUT_ROOT" <<'PY_OUTCOME'
from pathlib import Path
import sys

out_root = Path(sys.argv[1])
samples = {
    "good": "已完成\n- x\n完成证据\n- command passed\n还缺什么\n- 无\n后续建议\n- 无，等待你的下一步指令",
    "bad": "完成了，应该可以。",
}
required = ["已完成", "完成证据", "还缺什么", "后续建议"]
log = []
for name, text in samples.items():
    missing = [item for item in required if item not in text]
    log.append(f"{name}: missing={missing}")
    if name == "good" and missing:
        raise SystemExit(f"good sample missing {missing}")
    if name == "bad" and not missing:
        raise SystemExit("bad sample unexpectedly passed")
(out_root / "outcome-smoke.log").write_text("\n".join(log) + "\n", encoding="utf-8")
print("outcome-smoke:ok")
PY_OUTCOME

section "agent-browser-smoke"
log "running: $REPO_ROOT/scripts/agent-browser-smoke.sh $BROWSER_URL $OUT_ROOT" | tee -a "$OUT_ROOT/regression.log"
"$REPO_ROOT/scripts/agent-browser-smoke.sh" "$BROWSER_URL" "$OUT_ROOT" > >(tee "$OUT_ROOT/agent-browser-smoke.log") 2> >(tee "$OUT_ROOT/agent-browser-smoke.err" >&2)

section "profile-smoke"
python3 - "$REPO_ROOT" "$OUT_ROOT" "$PROFILE_TIMEOUT_SECONDS" "$PROFILE_PROMPT" <<'PY'
from __future__ import annotations
import subprocess
import sys
from pathlib import Path

repo_root = Path(sys.argv[1])
out_root = Path(sys.argv[2])
timeout = int(sys.argv[3])
prompt_base = sys.argv[4]

profiles = [
    ("quick", ["--profile", "quick"]),
    ("default", []),
    ("deep", ["--profile", "deep"]),
    ("research", ["--profile", "research"]),
]

for name, extra in profiles:
    print(f"--- profile:{name} ---", flush=True)
    last = out_root / f"profile-{name}.txt"
    log = out_root / f"profile-{name}.log"
    cmd = [
        "codex", "exec",
        "--ephemeral",
        "--sandbox", "read-only",
        "-C", str(repo_root),
        *extra,
        "--output-last-message", str(last),
        f"{prompt_base}\n\nprofile={name}。完成证据里必须写明 profile smoke passed。Done criteria 写明只读 profile smoke 返回了指定小节。Verification 写明未编辑文件、未运行 shell、未访问外部网站。",
    ]
    try:
        proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=timeout)
    except subprocess.TimeoutExpired as exc:
        partial = (exc.stdout or "") + (exc.stderr or "")
        log.write_text(partial, encoding="utf-8")
        raise SystemExit(f"profile {name} timed out after {timeout}s; see {log}")

    log.write_text(proc.stdout, encoding="utf-8")
    if proc.returncode != 0:
        raise SystemExit(f"profile {name} failed rc={proc.returncode}; see {log}")
    text = last.read_text(encoding="utf-8") if last.exists() else proc.stdout
    lower = text.lower()
    required = ["已完成", "完成证据", "done criteria", "verification", "还缺什么", "后续建议", "profile smoke passed"]
    missing = [item for item in required if item.lower() not in lower]
    if missing:
        raise SystemExit(f"profile {name} output missing {missing}; see {last if last.exists() else log}")
    print(text.strip())
    print(f"profile:{name}:ok", flush=True)
PY

section "summary"
{
  echo "Codex quality regression passed"
  echo "Output dir: $OUT_ROOT"
  echo "Version: $(codex --version)"
  echo "Browser URL: $BROWSER_URL"
  echo "Profile timeout seconds: $PROFILE_TIMEOUT_SECONDS"
  echo "Profile outputs:"
  ls -1 "$OUT_ROOT"/profile-*.txt 2>/dev/null || true
  echo "Browser screenshots:"
  ls -1 "$OUT_ROOT"/agent-browser-smoke-*.png 2>/dev/null || true
} | tee "$OUT_ROOT/summary.txt"

log "Codex quality regression passed; summary: $OUT_ROOT/summary.txt"
