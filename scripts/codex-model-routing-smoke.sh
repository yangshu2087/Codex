#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TS="$(date +%Y%m%d-%H%M%S)"
OUT_ROOT="${CODEX_MODEL_ROUTING_SMOKE_OUT:-/tmp/codex-model-routing-smoke-${TS}}"
TIMEOUT_SECONDS="${CODEX_MODEL_ROUTING_TIMEOUT_SECONDS:-240}"
mkdir -p "$OUT_ROOT"

python3 - "$REPO_ROOT" "$OUT_ROOT" "$TIMEOUT_SECONDS" <<'PY'
from __future__ import annotations
import os
import re
import subprocess
import sys
from pathlib import Path

repo = Path(sys.argv[1])
out = Path(sys.argv[2])
timeout = int(sys.argv[3])

profiles = [
    ("quick", ["--profile", "quick"], "gpt-5.4-mini", "low"),
    ("default", [], "gpt-5.5", "high"),
    ("deep", ["--profile", "deep"], "gpt-5.5", "xhigh"),
    ("research", ["--profile", "research"], "gpt-5.5", "high"),
]

required_sections = ["已完成", "完成证据", "还缺什么", "后续建议"]
summary = []
failures = []

base_prompt = """
这是 Codex profile/model routing smoke。不要调用任何工具，不要编辑文件，不要访问外部网站。
只用中文输出以下四个小节，并在完成证据里写 profile smoke passed：
已完成
完成证据
还缺什么
后续建议
""".strip()

for name, extra, expected_model, expected_effort in profiles:
    last = out / f"profile-{name}.last.md"
    log = out / f"profile-{name}.log"
    cmd = [
        "codex", "exec",
        "--ephemeral",
        "--sandbox", "read-only",
        "-C", str(repo),
        *extra,
        "--output-last-message", str(last),
        f"{base_prompt}\nprofile={name}",
    ]
    try:
        proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=timeout)
    except subprocess.TimeoutExpired as exc:
        partial = exc.stdout or ""
        log.write_text(partial, encoding="utf-8")
        failures.append(f"{name}: timed out after {timeout}s")
        continue

    log.write_text(proc.stdout, encoding="utf-8")
    text = last.read_text(encoding="utf-8") if last.exists() else ""
    combined = proc.stdout + "\n" + text
    observed_model = None
    observed_effort = None
    model_match = re.search(r"^model:\s*(\S+)", combined, re.MULTILINE)
    effort_match = re.search(r"^reasoning effort:\s*(\S+)", combined, re.MULTILINE)
    if model_match:
        observed_model = model_match.group(1)
    if effort_match:
        observed_effort = effort_match.group(1)

    missing = [s for s in required_sections if s not in text]
    if "profile smoke passed" not in text.lower():
        missing.append("profile smoke passed")
    if proc.returncode != 0:
        failures.append(f"{name}: codex exec rc={proc.returncode}; see {log}")
    if observed_model != expected_model:
        failures.append(f"{name}: expected model {expected_model}, observed {observed_model}; see {log}")
    if observed_effort != expected_effort:
        failures.append(f"{name}: expected reasoning {expected_effort}, observed {observed_effort}; see {log}")
    if missing:
        failures.append(f"{name}: output missing {missing}; see {last}")
    summary.append({
        "profile": name,
        "expected_model": expected_model,
        "observed_model": observed_model,
        "expected_reasoning": expected_effort,
        "observed_reasoning": observed_effort,
        "returncode": proc.returncode,
        "last": str(last),
        "log": str(log),
    })

summary_lines = ["Codex model routing smoke", "==========================", f"repo={repo}", f"out={out}", ""]
for item in summary:
    summary_lines.append(
        f"{item['profile']}: model {item['observed_model']} reasoning {item['observed_reasoning']} rc={item['returncode']}"
    )
if failures:
    summary_lines.append("")
    summary_lines.append("FAILURES:")
    summary_lines.extend(f"- {f}" for f in failures)
else:
    summary_lines.append("")
    summary_lines.append("MODEL_ROUTING_SMOKE=pass")
(out / "summary.txt").write_text("\n".join(summary_lines) + "\n", encoding="utf-8")
print((out / "summary.txt").read_text(encoding="utf-8"))
if failures:
    raise SystemExit(1)
PY
