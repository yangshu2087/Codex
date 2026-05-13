#!/usr/bin/env bash
set -euo pipefail

SUPPORTED_SERVERS=(cloudflare-api notion)
CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
BACKUP_DIR="${CODEX_MCP_OAUTH_BACKUP_DIR:-$CODEX_HOME_DIR/backups}"
TS="$(date +%Y%m%d-%H%M%S)"
OUT_ROOT="${CODEX_MCP_OAUTH_OUT:-/tmp/codex-mcp-oauth-refresh-${TS}}"
MODE="refresh"
DRY_RUN=0
SERVERS=()

usage() {
  cat <<'USAGE'
Usage:
  scripts/codex-mcp-oauth-refresh.sh [--check]
  scripts/codex-mcp-oauth-refresh.sh [--dry-run] <server> [server...]
  scripts/codex-mcp-oauth-refresh.sh [--dry-run] --all

Supported servers:
  cloudflare-api
  notion

What refresh does:
  1. Backup ~/.codex/auth.json and ~/.codex/config.toml metadata files locally.
  2. Run `codex mcp logout <server>` to remove stale OAuth credentials.
  3. Run `codex mcp login <server>` and wait for the browser OAuth callback.
  4. Verify `codex mcp list` and a read-only `codex exec` smoke do not show invalid_grant.

Notes:
  - The browser login/allow step is intentionally manual.
  - This script never prints token contents and never writes credentials into Git.
  - Use --check after manual authorization to validate current state without logging out.
USAGE
}

log() { printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
fail() { printf '[FAIL] %s\n' "$*" >&2; exit 1; }

contains_supported() {
  local target="$1"
  local item
  for item in "${SUPPORTED_SERVERS[@]}"; do
    [[ "$item" == "$target" ]] && return 0
  done
  return 1
}

add_all_servers() {
  local item
  for item in "${SUPPORTED_SERVERS[@]}"; do
    SERVERS+=("$item")
  done
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    --check)
      MODE="check"
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --all)
      add_all_servers
      shift
      ;;
    --*)
      fail "unknown option: $1"
      ;;
    *)
      contains_supported "$1" || fail "unsupported MCP server '$1'. Supported: ${SUPPORTED_SERVERS[*]}"
      SERVERS+=("$1")
      shift
      ;;
  esac
done

mkdir -p "$OUT_ROOT"

if ! command -v codex >/dev/null 2>&1; then
  fail "codex CLI not found on PATH"
fi

if [[ "$MODE" == "refresh" && ${#SERVERS[@]} -eq 0 ]]; then
  usage >&2
  fail "no MCP server specified; use --all or a supported server name"
fi

backup_files() {
  mkdir -p "$BACKUP_DIR"
  chmod 700 "$BACKUP_DIR" 2>/dev/null || true
  local src dst
  for src in "$CODEX_HOME_DIR/auth.json" "$CODEX_HOME_DIR/config.toml"; do
    if [[ -f "$src" ]]; then
      dst="$BACKUP_DIR/$(basename "$src").before-mcp-oauth-refresh-${TS}"
      if [[ "$DRY_RUN" == "1" ]]; then
        log "dry-run: would backup $src -> $dst"
      else
        cp "$src" "$dst"
        chmod 600 "$dst" 2>/dev/null || true
        log "backed up $(basename "$src") -> $dst"
      fi
    else
      log "skip backup; missing $src"
    fi
  done
}

run_check() {
  log "writing verification output to $OUT_ROOT"
  {
    echo '== codex --version =='
    codex --version
    echo
    echo '== codex mcp list =='
    codex mcp list
    echo
    echo '== selected MCP auth state =='
    codex mcp list | awk '/^cloudflare-api|^notion|^context7|^sentry/ {print}'
  } | tee "$OUT_ROOT/mcp-list.txt"

  log "running read-only codex exec smoke"
  if codex exec --profile quick --sandbox read-only --cd "$(pwd)" '只输出 OK，不要调用任何工具。' < /dev/null >"$OUT_ROOT/exec.stdout" 2>"$OUT_ROOT/exec.stderr"; then
    log "codex exec smoke exited 0"
  else
    log "codex exec smoke exited non-zero; inspect $OUT_ROOT/exec.stderr"
  fi

  if grep -RniE 'invalid_grant|OAuth token refresh failed|Grant not found|Invalid refresh token' "$OUT_ROOT" >/dev/null 2>&1; then
    grep -RniE 'invalid_grant|OAuth token refresh failed|Grant not found|Invalid refresh token' "$OUT_ROOT" >&2 || true
    fail "invalid_grant-like text found in verification output"
  fi

  if [[ "$(tr -d '\r\n ' < "$OUT_ROOT/exec.stdout" 2>/dev/null || true)" == "OK" ]]; then
    log "exec smoke output OK"
  else
    log "exec smoke did not return plain OK; inspect $OUT_ROOT/exec.stdout"
  fi

  log "check complete: $OUT_ROOT"
}

if [[ "$MODE" == "check" ]]; then
  run_check
  exit 0
fi

backup_files

for server in "${SERVERS[@]}"; do
  log "refreshing OAuth for $server"
  if [[ "$DRY_RUN" == "1" ]]; then
    log "dry-run: codex mcp logout $server"
    log "dry-run: codex mcp login $server"
    continue
  fi
  codex mcp logout "$server" || true
  log "starting OAuth login for $server; complete the browser authorization manually"
  codex mcp login "$server"
  log "OAuth login finished for $server"
done

if [[ "$DRY_RUN" == "1" ]]; then
  log "dry-run complete; no OAuth credentials changed"
  exit 0
fi

run_check
