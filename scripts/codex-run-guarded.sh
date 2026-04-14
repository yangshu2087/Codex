#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  codex-run-guarded.sh [--allow-heavy] [--print-decision] [--] [codex args...]

Behavior:
  - Reads pressure decision ONLY from /Users/yangshu/Codex/scripts/codex-runtime-health.sh
  - If status is high-pressure, forces:
      --profile quick
      -c agents.max_threads=1
  - If status is normal, forwards args to codex unchanged.

Options:
  --allow-heavy     Keep caller-provided profile even under high pressure (still caps threads=1)
  --print-decision  Print decision summary before launching codex
  -h, --help        Show help
USAGE
}

runtime_script="/Users/yangshu/Codex/scripts/codex-runtime-health.sh"
if [[ ! -x "$runtime_script" ]]; then
  echo "error: runtime health script missing: $runtime_script" >&2
  exit 1
fi

allow_heavy=0
print_decision=0

forward=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --allow-heavy) allow_heavy=1; shift ;;
    --print-decision) print_decision=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; while [[ $# -gt 0 ]]; do forward+=("$1"); shift; done ;;
    *) forward+=("$1"); shift ;;
  esac
done

status="normal"
rec_profile="default"
rec_threads="4"
load1m="0"
swap_mib="0"
while IFS='=' read -r k v; do
  case "$k" in
    STATUS) status="$v" ;;
    RECOMMENDED_PROFILE) rec_profile="$v" ;;
    RECOMMENDED_THREADS) rec_threads="$v" ;;
    LOAD_1M) load1m="$v" ;;
    SWAP_USED_MIB) swap_mib="$v" ;;
  esac
done < <("$runtime_script" --decision-only)

if [[ $print_decision -eq 1 ]]; then
  echo "Guard decision: status=$status load1m=$load1m swapMiB=$swap_mib profile=$rec_profile threads=$rec_threads"
fi

contains_profile_arg=0
for ((i=0; i<${#forward[@]}; i++)); do
  arg="${forward[$i]}"
  if [[ "$arg" == "--profile" || "$arg" == "-p" || "$arg" == --profile=* ]]; then
    contains_profile_arg=1
    break
  fi
done

if [[ "$status" == "high-pressure" ]]; then
  if [[ $allow_heavy -eq 1 ]]; then
    exec codex -c agents.max_threads=1 "${forward[@]}"
  fi

  if [[ $contains_profile_arg -eq 1 ]]; then
    echo "[guard] high-pressure detected; overriding caller profile to quick." >&2
    filtered=()
    skip_next=0
    for ((i=0; i<${#forward[@]}; i++)); do
      if [[ $skip_next -eq 1 ]]; then
        skip_next=0
        continue
      fi
      arg="${forward[$i]}"
      if [[ "$arg" == "--profile" || "$arg" == "-p" ]]; then
        skip_next=1
        continue
      fi
      if [[ "$arg" == --profile=* ]]; then
        continue
      fi
      filtered+=("$arg")
    done
    forward=("${filtered[@]}")
  fi

  exec codex --profile quick -c agents.max_threads=1 "${forward[@]}"
fi

exec codex "${forward[@]}"
