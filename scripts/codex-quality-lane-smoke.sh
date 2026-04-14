#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CODEX_HOME="${CODEX_HOME:-/Users/yangshu/.codex}"
HOOKS_DIR="$CODEX_HOME/hooks"
COMMON="$HOOKS_DIR/common.py"
STOP_HOOK="$HOOKS_DIR/stop_quality_gate.py"
PROMPT_GUARD="$HOOKS_DIR/user_prompt_submit_guard.py"

printf 'Codex quality lane smoke started at %s\n' "$(date)"
printf 'Repo root: %s\n' "$REPO_ROOT"
printf 'Codex home: %s\n\n' "$CODEX_HOME"

for f in "$COMMON" "$STOP_HOOK" "$PROMPT_GUARD"; do
  [[ -f "$f" ]] || { echo "missing hook file: $f" >&2; exit 1; }
done
python3 -m py_compile "$COMMON" "$STOP_HOOK" "$PROMPT_GUARD"
echo "[1/6] hook python syntax passed"

for f in \
  "$CODEX_HOME/prompts/architecture-template.md" \
  "$CODEX_HOME/prompts/frontend-template.md" \
  "$CODEX_HOME/prompts/requirements-clarification-template.md" \
  "$CODEX_HOME/prompts/backend-template.md" \
  "$CODEX_HOME/prompts/ux-flow-template.md" \
  "$CODEX_HOME/prompts/code-quality-template.md"; do
  [[ -f "$f" ]] || { echo "missing prompt template: $f" >&2; exit 1; }
done
echo "[2/6] prompt templates present"

for d in \
  "$REPO_ROOT/.agents/skills/architecture-decision-review" \
  "$REPO_ROOT/.agents/skills/backend-api-contract-review" \
  "$REPO_ROOT/.agents/skills/product-ux-flow-review" \
  "$REPO_ROOT/.agents/skills/frontend-design-review"; do
  [[ -f "$d/SKILL.md" ]] || { echo "missing quality skill: $d/SKILL.md" >&2; exit 1; }
  if [[ "$d" != *frontend-design-review ]]; then
    [[ -f "$d/agents/openai.yaml" ]] || { echo "missing explicit-invocation policy: $d/agents/openai.yaml" >&2; exit 1; }
    grep -q 'allow_implicit_invocation: false' "$d/agents/openai.yaml" || {
      echo "skill is missing allow_implicit_invocation: false: $d" >&2
      exit 1
    }
  fi
done
echo "[3/6] quality skills present and explicit-only policies checked"

prompt_guard_out="$(mktemp)"
trap 'rm -f "$prompt_guard_out" "${stop_out:-}"' EXIT
printf '%s' '{"prompt":"请设计后端 API 架构和用户体验优化方案"}' | python3 "$PROMPT_GUARD" > "$prompt_guard_out"
grep -q 'architecture task' "$prompt_guard_out"
grep -q 'backend or API task' "$prompt_guard_out"
grep -q 'UX or product-flow task' "$prompt_guard_out"
echo "[4/6] prompt-submit quality context injection passed"

stop_out="$(mktemp)"
python3 - "$STOP_HOOK" "$stop_out" <<'PY'
from __future__ import annotations
import json
import subprocess
import sys
from pathlib import Path

hook = Path(sys.argv[1])
out = Path(sys.argv[2])

def run(payload: dict) -> str:
    proc = subprocess.run(
        [sys.executable, str(hook)],
        input=json.dumps(payload, ensure_ascii=False),
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if proc.returncode != 0:
        raise SystemExit(f"hook failed rc={proc.returncode}\nSTDOUT={proc.stdout}\nSTDERR={proc.stderr}")
    return proc.stdout.strip()

def transcript(user: str, assistant: str) -> dict:
    return {"transcript": {"messages": [{"role": "user", "content": user}, {"role": "assistant", "content": assistant}]}}

minimal = "已完成\n- 已处理。\n\n完成证据\n- 已检查。\n\n还缺什么\n- 无。\n\n后续建议\n- 无。"
checks = [
    ("architecture", transcript("请做架构方案", minimal), "architecture lane evidence"),
    ("backend", transcript("请做 backend API 评审", minimal), "backend/API lane evidence"),
    ("frontend", transcript("请做前端 UI 任务", minimal), "frontend lane evidence"),
    ("ux", transcript("请做 UX 用户路径优化", minimal), "UX lane evidence"),
]
lines = []
for name, payload, expected in checks:
    stdout = run(payload)
    if expected not in stdout:
        raise SystemExit(f"expected block marker {expected!r} for {name}, got: {stdout!r}")
    lines.append(f"block:{name}:ok")

full = """已完成
- 完成质量 lane 验证。

完成证据
- 架构：包含方案比较、tradeoff、风险、rollout、回滚。
- 后端/API：覆盖 API contract、接口契约、错误语义、权限、数据一致性、回归测试。
- 前端：覆盖 visual thesis、content plan、interaction thesis、hover/loading/empty/error/disabled，已做 browser verification 和 screenshot 检查。
- UX：覆盖 product contract、UX flow、用户路径、摩擦点、可访问性、状态覆盖。


Done criteria
- 质量 lane 证据齐全。

Verification
- hook synthetic pass。

还缺什么
- 无。

后续建议
- 无。"""
stdout = run(transcript("请做架构、backend API、前端 UI、UX 用户路径综合评审", full))
if stdout:
    raise SystemExit(f"expected pass with empty stdout, got: {stdout!r}")
lines.append("pass:all-lanes:ok")
out.write_text("\n".join(lines) + "\n", encoding="utf-8")
PY
cat "$stop_out"
echo "[5/6] stop-hook quality lane block/pass checks passed"

python3 - "$REPO_ROOT/skills-lock.json" <<'PY'
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text(encoding='utf-8'))
for name in ['architecture-decision-review', 'backend-api-contract-review', 'product-ux-flow-review']:
    meta = data.get('skills', {}).get(name)
    if not meta:
        raise SystemExit(f'missing skill lock entry: {name}')
    if meta.get('implicitInvocation') is not False:
        raise SystemExit(f'skill lock implicitInvocation should be false: {name}')
print('[6/6] skills-lock quality lane entries passed')
PY

echo ""
echo "All Codex quality lane smoke checks passed."
