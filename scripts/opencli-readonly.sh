#!/usr/bin/env bash
set -euo pipefail

OPENCLI_READONLY_VERSION="${OPENCLI_READONLY_VERSION:-1.7.3}"
OPENCLI_PACKAGE="${OPENCLI_PACKAGE:-@jackwener/opencli}"
OPENCLI_READONLY_ROOT="${OPENCLI_READONLY_ROOT:-${TMPDIR:-/tmp}/codex-opencli-readonly-${USER:-user}}"
OPENCLI_READONLY_HOME="$OPENCLI_READONLY_ROOT/home"
OPENCLI_READONLY_PREFIX="$OPENCLI_READONLY_ROOT/npm"
OPENCLI_READONLY_CACHE="$OPENCLI_READONLY_ROOT/npm-cache"
OPENCLI_READONLY_CDP_ENDPOINT="${OPENCLI_CDP_ENDPOINT:-http://127.0.0.1:9222}"
OPENCLI_READONLY_DAEMON_PORT="${OPENCLI_DAEMON_PORT:-19825}"
OPENCLI_READONLY_OPENCLI="$OPENCLI_READONLY_PREFIX/node_modules/.bin/opencli"
OPENCLI_READONLY_REAL_HOME="${HOME:-}"

usage() {
  cat <<USAGE
Usage:
  opencli-readonly.sh hackernews <top|new|best|ask|show|jobs|search|user> [args...]
  opencli-readonly.sh gh <--version|version|auth status>   # local gh direct, read-only
  opencli-readonly.sh codex <status|probe|model|read>

Read-only allowlist only. Denies write-capable commands such as reddit, codex send/new/ask/export, gh repo/pr/issue writes, browser control, plugins, and installs.

Isolation:
  OPENCLI_READONLY_ROOT defaults to: ${TMPDIR:-/tmp}/codex-opencli-readonly-${USER:-user}
  HOME is forced to:                \$OPENCLI_READONLY_ROOT/home
  npm prefix is forced to:          \$OPENCLI_READONLY_ROOT/npm
  daemon is stopped automatically on exit.
  gh checks use local gh directly to avoid OpenCLI external auto-install.
USAGE
}

die() {
  printf 'opencli-readonly: %s\n' "$*" >&2
  exit 64
}

cleanup() {
  local status=$?
  if [ -x "$OPENCLI_READONLY_OPENCLI" ]; then
    HOME="$OPENCLI_READONLY_HOME" \
    OPENCLI_DAEMON_PORT="$OPENCLI_READONLY_DAEMON_PORT" \
      "$OPENCLI_READONLY_OPENCLI" daemon stop >/dev/null 2>&1 || true
  fi
  exit "$status"
}
trap cleanup EXIT INT TERM

ensure_opencli() {
  mkdir -p "$OPENCLI_READONLY_HOME" "$OPENCLI_READONLY_PREFIX" "$OPENCLI_READONLY_CACHE"
  if [ ! -x "$OPENCLI_READONLY_OPENCLI" ]; then
    HOME="$OPENCLI_READONLY_HOME" \
    npm_config_cache="$OPENCLI_READONLY_CACHE" \
    npm_config_update_notifier=false \
      npm install \
        --prefix "$OPENCLI_READONLY_PREFIX" \
        --ignore-scripts \
        --no-audit \
        --no-fund \
        "${OPENCLI_PACKAGE}@${OPENCLI_READONLY_VERSION}" >&2
  fi
  if [ ! -d "$OPENCLI_READONLY_HOME/.opencli/clis" ]; then
    HOME="$OPENCLI_READONLY_HOME" \
    OPENCLI_DAEMON_PORT="$OPENCLI_READONLY_DAEMON_PORT" \
      "$OPENCLI_READONLY_OPENCLI" list >/dev/null 2>&1 || true
  fi
}

run_opencli() {
  ensure_opencli
  HOME="$OPENCLI_READONLY_HOME" \
  OPENCLI_DAEMON_PORT="$OPENCLI_READONLY_DAEMON_PORT" \
    "$OPENCLI_READONLY_OPENCLI" "$@"
}

run_local_gh() {
  # Use the local GitHub CLI directly for read-only status checks. This avoids
  # OpenCLI external-CLI auto-install behavior and preserves the user's real gh auth.
  HOME="$OPENCLI_READONLY_REAL_HOME" gh "$@"
}

require_no_extra_args() {
  local subject="$1"; shift
  if [ "$#" -ne 0 ]; then
    die "$subject is read-only here and does not accept extra args"
  fi
}

codex_status_like_probe() {
  require_no_extra_args "codex status/probe" "$@"
  if curl -fsS --max-time 2 "$OPENCLI_READONLY_CDP_ENDPOINT/json/version" >/dev/null 2>&1; then
    printf '{"ok":true,"kind":"codex-cdp-probe","endpoint":"%s","reason":"cdp_reachable"}\n' "$OPENCLI_READONLY_CDP_ENDPOINT"
    return 0
  fi
  printf '{"ok":false,"kind":"codex-cdp-probe","endpoint":"%s","reason":"cdp_not_reachable","hint":"Launch Codex with --remote-debugging-port=9222 only if you explicitly want Desktop CDP automation."}\n' "$OPENCLI_READONLY_CDP_ENDPOINT"
  return 69
}

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  usage
  exit 0
fi

if [ "$#" -lt 1 ]; then
  usage >&2
  exit 64
fi

target="$1"
shift

case "$target" in
  hackernews)
    sub="${1:-}"
    [ -n "$sub" ] || die "missing hackernews subcommand"
    shift
    case "$sub" in
      top|new|best|ask|show|jobs|search|user)
        run_opencli hackernews "$sub" "$@"
        ;;
      *)
        die "hackernews subcommand '$sub' is not in the read-only allowlist"
        ;;
    esac
    ;;
  gh)
    command -v gh >/dev/null 2>&1 || die "local gh is not installed; refusing to let OpenCLI auto-install external CLI"
    case "${1:-}" in
      --version|version)
        require_no_extra_args "gh ${1}" "${@:2}"
        run_local_gh "$1"
        ;;
      auth)
        if [ "${2:-}" = "status" ] && [ "$#" -eq 2 ]; then
          run_local_gh auth status
        else
          die "only 'gh auth status' is allowed"
        fi
        ;;
      *)
        die "only 'gh --version', 'gh version', and 'gh auth status' are allowed"
        ;;
    esac
    ;;
  codex)
    sub="${1:-status}"
    shift || true
    case "$sub" in
      status|probe)
        codex_status_like_probe "$@"
        ;;
      model|read)
        require_no_extra_args "codex $sub" "$@"
        run_opencli codex "$sub"
        ;;
      *)
        die "only codex status/probe/model/read are allowed"
        ;;
    esac
    ;;
  *)
    die "target '$target' is denied; allowed targets: hackernews, gh, codex"
    ;;
esac
