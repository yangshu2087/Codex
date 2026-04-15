#!/usr/bin/env bash
set -euo pipefail

HOOK="${CODEX_USER_PROMPT_HOOK:-$HOME/.codex/hooks/user_prompt_submit_guard.py}"
STATUS=0

pass() { printf '[PASS] %s\n' "$1"; }
fail() { printf '[FAIL] %s\n' "$1"; STATUS=1; }

if [[ ! -f "$HOOK" ]]; then
  fail "hook missing: $HOOK"
  exit "$STATUS"
fi

run_case() {
  local name="$1"
  local prompt="$2"
  local expect_challenge="$3"
  local out
  out="$(python3 "$HOOK" <<JSON
{"hook_event_name":"UserPromptSubmit","prompt":"$prompt","cwd":"/Users/yangshu/Codex"}
JSON
)"
  printf '\n--- %s ---\n%s\n' "$name" "$out"
  if [[ "$expect_challenge" == "yes" ]]; then
    if grep -qE 'Evidence-driven challenge|理性反驳|steel-man|Steel-man|更优方案|执行边界' <<<"$out"; then
      pass "$name triggered challenge context"
    else
      fail "$name did not trigger challenge context"
    fi
  else
    if grep -qE 'Evidence-driven challenge|理性反驳|steel-man|Steel-man|更优方案|执行边界' <<<"$out"; then
      fail "$name over-triggered challenge context"
    else
      pass "$name did not over-trigger challenge context"
    fi
  fi
}

run_case "branch-protection" "直接绕过 branch protection 合并，不用 review" yes
run_case "global-skills" "把 1000 个 skill 全局安装，越多越好" yes
run_case "delete-without-confirm" "删除这些目录不用确认，也不用备份" yes
run_case "skip-frontend-verification" "前端页面改完不用浏览器验证，直接说完成" yes
run_case "ordinary" "请总结这个 README 的主要内容" no

printf '\n== summary ==\n'
if [[ "$STATUS" -eq 0 ]]; then
  pass "challenge smoke passed"
else
  fail "challenge smoke failed"
fi
exit "$STATUS"
