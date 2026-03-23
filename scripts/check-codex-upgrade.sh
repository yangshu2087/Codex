#!/usr/bin/env bash

set -euo pipefail

if ! command -v codex >/dev/null 2>&1; then
  echo "codex is not installed or not on PATH" >&2
  exit 1
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

codex_path="$(command -v codex)"
codex_raw="$(codex --version)"
app_plist="/Applications/Codex.app/Contents/Info.plist"
app_dmg_url="https://persistent.oaistatic.com/codex-app-prod/Codex.dmg"
cwd="${PWD}"
user_config="${HOME}/.codex/config.toml"
project_config="${cwd}/.codex/config.toml"
user_agents="${HOME}/.codex/AGENTS.md"
project_agents="${cwd}/AGENTS.md"
user_skills_dir="${HOME}/.agents/skills"
project_skills_dir="${cwd}/.agents/skills"

if [[ -f "$app_plist" ]]; then
  plutil -extract CFBundleShortVersionString raw -o - "$app_plist" >"$tmpdir/app_version.txt"
else
  printf 'not-installed\n' >"$tmpdir/app_version.txt"
fi

npm view @openai/codex version dist-tags --json >"$tmpdir/npm.json"

python3 - <<'PY' >"$tmpdir/github.json"
import json
import urllib.request

url = "https://api.github.com/repos/openai/codex/releases/latest"
with urllib.request.urlopen(url, timeout=20) as resp:
    data = json.load(resp)

payload = {
    "tag_name": data.get("tag_name"),
    "name": data.get("name"),
    "published_at": data.get("published_at"),
    "html_url": data.get("html_url"),
}
print(json.dumps(payload))
PY

if command -v curl >/dev/null 2>&1; then
  curl -fsSI "$app_dmg_url" >"$tmpdir/app_headers.txt" || true
else
  : >"$tmpdir/app_headers.txt"
fi

if [[ "$(uname -s)" == "Darwin" ]] && command -v hdiutil >/dev/null 2>&1; then
  mountpoint="$tmpdir/codex-app"
  mkdir -p "$mountpoint"
  if hdiutil attach -nobrowse -readonly -mountpoint "$mountpoint" "$app_dmg_url" >/dev/null 2>&1; then
    mounted_plist="$mountpoint/Codex.app/Contents/Info.plist"
    if [[ -f "$mounted_plist" ]]; then
      plutil -extract CFBundleShortVersionString raw -o - "$mounted_plist" >"$tmpdir/app_installer_version.txt"
    else
      printf 'missing-in-dmg\n' >"$tmpdir/app_installer_version.txt"
    fi
    hdiutil detach "$mountpoint" -force >/dev/null 2>&1 || true
  else
    printf 'unavailable\n' >"$tmpdir/app_installer_version.txt"
  fi
else
  printf 'unsupported-platform\n' >"$tmpdir/app_installer_version.txt"
fi

if [[ -d "$user_skills_dir" ]]; then
  find "$user_skills_dir" -name SKILL.md -type f | wc -l | tr -d ' ' >"$tmpdir/user_skill_count.txt"
else
  printf '0\n' >"$tmpdir/user_skill_count.txt"
fi

if [[ -d "$project_skills_dir" ]]; then
  find "$project_skills_dir" -name SKILL.md -type f | wc -l | tr -d ' ' >"$tmpdir/project_skill_count.txt"
else
  printf '0\n' >"$tmpdir/project_skill_count.txt"
fi

python3 - \
  "$codex_path" \
  "$codex_raw" \
  "$tmpdir/app_version.txt" \
  "$tmpdir/app_installer_version.txt" \
  "$tmpdir/npm.json" \
  "$tmpdir/github.json" \
  "$tmpdir/app_headers.txt" \
  "$cwd" \
  "$user_config" \
  "$project_config" \
  "$user_agents" \
  "$project_agents" \
  "$user_skills_dir" \
  "$project_skills_dir" \
  "$tmpdir/user_skill_count.txt" \
  "$tmpdir/project_skill_count.txt" <<'PY'
import json
import pathlib
import re
import sys


def parse_cli_version(raw: str) -> str:
    match = re.search(r"codex-cli\s+([^\s]+)", raw)
    return match.group(1) if match else raw.strip()


def normalize_version(version: str):
    version = version.strip()
    if version in {"not-installed", "unavailable", "unsupported-platform", "missing-in-dmg", ""}:
        return tuple(), ("missing", version)
    version = re.sub(r"^(rust-v|v)", "", version)
    version = re.sub(r"-(darwin|linux|win32).*$", "", version)
    if "-" in version:
        base, prerelease = version.split("-", 1)
    else:
        base, prerelease = version, ""
    numbers = tuple(int(part) for part in base.split(".") if part.isdigit())
    prerelease_parts = ()
    if prerelease:
        prerelease_parts = tuple(
            int(part) if part.isdigit() else part
            for part in re.split(r"[.\-]", prerelease)
            if part
        )
    return numbers, prerelease_parts


def compare_versions(left: str, right: str) -> int:
    l_main, l_pre = normalize_version(left)
    r_main, r_pre = normalize_version(right)
    if not l_main or not r_main:
        if left == right:
            return 0
        return -1
    if l_main != r_main:
        return -1 if l_main < r_main else 1
    if not l_pre and r_pre:
        return 1
    if l_pre and not r_pre:
        return -1
    if l_pre == r_pre:
        return 0
    return -1 if l_pre < r_pre else 1


codex_path = sys.argv[1]
installed_cli = parse_cli_version(sys.argv[2])
app_version = pathlib.Path(sys.argv[3]).read_text().strip()
app_installer_version = pathlib.Path(sys.argv[4]).read_text().strip()
npm_data = json.loads(pathlib.Path(sys.argv[5]).read_text())
github_data = json.loads(pathlib.Path(sys.argv[6]).read_text())
app_headers = pathlib.Path(sys.argv[7]).read_text()
cwd = pathlib.Path(sys.argv[8])
user_config = pathlib.Path(sys.argv[9])
project_config = pathlib.Path(sys.argv[10])
user_agents = pathlib.Path(sys.argv[11])
project_agents = pathlib.Path(sys.argv[12])
user_skills_dir = pathlib.Path(sys.argv[13])
project_skills_dir = pathlib.Path(sys.argv[14])
user_skill_count = pathlib.Path(sys.argv[15]).read_text().strip()
project_skill_count = pathlib.Path(sys.argv[16]).read_text().strip()

npm_latest = npm_data["dist-tags"]["latest"]
npm_alpha = npm_data["dist-tags"]["alpha"]
github_latest = github_data["name"] or github_data["tag_name"]
last_modified = "unknown"
for line in app_headers.splitlines():
    if line.lower().startswith("last-modified:"):
        last_modified = line.split(":", 1)[1].strip()
        break

status = []
if compare_versions(installed_cli, npm_latest) < 0:
    status.append("installed CLI is behind the latest stable npm/GitHub release")
elif compare_versions(installed_cli, npm_latest) == 0:
    status.append("installed CLI matches the latest stable release")
else:
    status.append("installed CLI is ahead of the latest stable release")

if compare_versions(installed_cli, npm_alpha) < 0:
    status.append("a newer alpha build is also available")
else:
    status.append("installed CLI is on or ahead of the current alpha track")

if codex_path.startswith("/Applications/Codex.app/"):
    status.append("active CLI is the desktop app bundled binary")
else:
    status.append("active CLI is a standalone binary on PATH")

if app_version == "not-installed":
    status.append("desktop app is not installed")
elif compare_versions(app_version, app_installer_version) == 0:
    status.append("desktop app matches the current official installer")
elif compare_versions(app_version, app_installer_version) < 0:
    status.append("desktop app is behind the current official installer")
else:
    status.append("desktop app is newer than the current official installer")

if user_config.exists():
    status.append("user config is present")
else:
    status.append("user config is missing")

if project_config.exists():
    status.append("project config is present in the current directory")
else:
    status.append("project config is missing in the current directory")

recommended = []
if codex_path.startswith("/Applications/Codex.app/"):
    recommended.append("Current CLI is bundled inside the desktop app; prefer app auto-update or reinstalling the app over npm overriding PATH.")
else:
    recommended.append("Current CLI is not app-bundled; upgrading via npm or a GitHub binary is straightforward.")

if compare_versions(installed_cli, npm_latest) < 0:
    recommended.append("If you want the stable channel, upgrade to the latest stable release first.")

if compare_versions(installed_cli, npm_alpha) < 0:
    recommended.append("Only move to the alpha channel if you explicitly want preview features and can tolerate regressions.")

if int(user_skill_count) > 6:
    recommended.append("You have many user-level skills loaded globally; consider pruning low-value ones to reduce first-turn routing overhead.")
else:
    recommended.append("Keep global user skills narrow and few; prefer project-local instructions for repo-specific behavior.")

print("Codex upgrade report")
print("====================")
print(f"CLI path:            {codex_path}")
print(f"Installed CLI:       {installed_cli}")
print(f"Desktop app:         {app_version}")
print(f"Official app build:  {app_installer_version}")
print(f"App installer mtime: {last_modified}")
print(f"npm latest:          {npm_latest}")
print(f"npm alpha:           {npm_alpha}")
print(f"GitHub latest:       {github_latest}")
print(f"Release published:   {github_data['published_at']}")
print(f"Release URL:         {github_data['html_url']}")
print("")
print("Configuration:")
print(f"- Current directory: {cwd}")
print(f"- User config:       {'present' if user_config.exists() else 'missing'} ({user_config})")
print(f"- Project config:    {'present' if project_config.exists() else 'missing'} ({project_config})")
print(f"- User AGENTS:       {'present' if user_agents.exists() else 'missing'} ({user_agents})")
print(f"- Project AGENTS:    {'present' if project_agents.exists() else 'missing'} ({project_agents})")
print(f"- User skills:       {user_skill_count} ({user_skills_dir})")
print(f"- Project skills:    {project_skill_count} ({project_skills_dir})")
print("")
print("Status:")
for line in status:
    print(f"- {line}")
print("")
print("Recommended next step:")
for line in recommended:
    print(f"- {line}")
PY
