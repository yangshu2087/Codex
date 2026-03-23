#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
vendor_root="${repo_root}/vendor/skills"
user_root="${HOME}/.agents/skills"

usage() {
  cat <<'EOF'
Usage:
  manage-vendored-skill.sh list
  manage-vendored-skill.sh status <skill>
  manage-vendored-skill.sh activate <skill>
  manage-vendored-skill.sh deactivate <skill>

Vendored skills live in the repository under vendor/skills and are activated
on demand by symlinking them into ~/.agents/skills.
EOF
}

require_skill_name() {
  if [[ $# -lt 2 || -z "${2:-}" ]]; then
    echo "missing skill name" >&2
    usage >&2
    exit 1
  fi
}

list_skills() {
  if [[ ! -d "${vendor_root}" ]]; then
    exit 0
  fi
  find "${vendor_root}" -mindepth 1 -maxdepth 1 -type d -print | sort | sed 's#^.*/##'
}

skill_path() {
  printf '%s/%s' "${vendor_root}" "$1"
}

user_link_path() {
  printf '%s/%s' "${user_root}" "$1"
}

status_skill() {
  local name="$1"
  local vendor_path
  local user_path
  vendor_path="$(skill_path "${name}")"
  user_path="$(user_link_path "${name}")"

  if [[ ! -d "${vendor_path}" ]]; then
    echo "vendored skill not found: ${name}" >&2
    exit 1
  fi

  echo "vendored: ${vendor_path}"
  if [[ -L "${user_path}" ]]; then
    echo "active: yes"
    echo "link: $(readlink "${user_path}")"
  elif [[ -e "${user_path}" ]]; then
    echo "active: blocked-by-existing-path"
    echo "path: ${user_path}"
    exit 2
  else
    echo "active: no"
  fi
}

activate_skill() {
  local name="$1"
  local vendor_path
  local user_path
  vendor_path="$(skill_path "${name}")"
  user_path="$(user_link_path "${name}")"

  if [[ ! -d "${vendor_path}" ]]; then
    echo "vendored skill not found: ${name}" >&2
    exit 1
  fi

  mkdir -p "${user_root}"

  if [[ -L "${user_path}" ]]; then
    if [[ "$(readlink "${user_path}")" == "${vendor_path}" ]]; then
      echo "already active: ${name}"
      return 0
    fi
    echo "refusing to overwrite existing symlink: ${user_path}" >&2
    exit 2
  fi

  if [[ -e "${user_path}" ]]; then
    echo "refusing to overwrite existing path: ${user_path}" >&2
    exit 2
  fi

  ln -s "${vendor_path}" "${user_path}"
  echo "activated: ${name}"
  echo "link: ${user_path} -> ${vendor_path}"
}

deactivate_skill() {
  local name="$1"
  local vendor_path
  local user_path
  vendor_path="$(skill_path "${name}")"
  user_path="$(user_link_path "${name}")"

  if [[ ! -L "${user_path}" ]]; then
    echo "not active: ${name}"
    return 0
  fi

  if [[ "$(readlink "${user_path}")" != "${vendor_path}" ]]; then
    echo "refusing to remove unrelated symlink: ${user_path}" >&2
    exit 2
  fi

  rm "${user_path}"
  echo "deactivated: ${name}"
}

case "${1:-}" in
  list)
    list_skills
    ;;
  status)
    require_skill_name "$@"
    status_skill "$2"
    ;;
  activate)
    require_skill_name "$@"
    activate_skill "$2"
    ;;
  deactivate)
    require_skill_name "$@"
    deactivate_skill "$2"
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
