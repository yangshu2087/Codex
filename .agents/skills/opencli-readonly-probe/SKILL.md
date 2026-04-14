---
name: opencli-readonly-probe
description: Use when evaluating OpenCLI from Codex with strict read-only constraints, especially for HackerNews, local GitHub CLI status, or Codex Desktop CDP reachability checks.
---

# OpenCLI Read-Only Probe

## Overview

Use OpenCLI only through the workspace wrapper. The wrapper keeps OpenCLI out of global PATH, forces an isolated HOME/runtime for OpenCLI-backed commands, restricts commands to a small allowlist, and stops the OpenCLI daemon on exit. The GitHub status checks deliberately use local `gh` directly to avoid OpenCLI external auto-install behavior.

Wrapper:

```bash
/Users/yangshu/Codex/scripts/opencli-readonly.sh
```

## Allowed Commands

| Need | Command |
|---|---|
| HackerNews public reads | `scripts/opencli-readonly.sh hackernews top --limit 5 -f json` |
| Other HackerNews public reads | `scripts/opencli-readonly.sh hackernews new|best|ask|show|jobs|search|user ...` |
| Local GitHub CLI version | `scripts/opencli-readonly.sh gh --version` |
| Local GitHub auth status | `scripts/opencli-readonly.sh gh auth status` |
| Codex Desktop CDP reachability | `scripts/opencli-readonly.sh codex status` |
| Codex Desktop current model | `scripts/opencli-readonly.sh codex model` |
| Codex Desktop current thread read | `scripts/opencli-readonly.sh codex read` |

## Hard Rules

- Do not run `opencli` directly for Codex work; use the wrapper.
- Do not install OpenCLI globally or add shell completion.
- Do not install the Browser Bridge extension unless the user explicitly approves it in a separate task.
- Do not run write-capable commands: `reddit`, `codex send/new/ask/export`, `gh repo/pr/issue`, `browser`, `plugin`, `install`, or `register`.
- The wrapper forces OpenCLI `HOME` into `/tmp`; `gh --version` and `gh auth status` use the local `gh` binary directly and never delegate to OpenCLI external CLI auto-install.
- Treat `codex read` as sensitive: summarize only what is necessary and avoid exposing unrelated private thread content.
- If Codex Desktop CDP is not reachable, report the gap; do not restart Codex with `--remote-debugging-port` unless explicitly asked.

## Verification

Before trusting results, run the narrow checks:

```bash
bash -n /Users/yangshu/Codex/scripts/opencli-readonly.sh
/Users/yangshu/Codex/scripts/opencli-readonly.sh --help
/Users/yangshu/Codex/scripts/opencli-readonly.sh hackernews top --limit 3 -f json
/Users/yangshu/Codex/scripts/opencli-readonly.sh gh --version
/Users/yangshu/Codex/scripts/opencli-readonly.sh codex status
```

After use, confirm daemon cleanup:

```bash
curl -fsS --max-time 2 -H 'X-OpenCLI: 1' http://127.0.0.1:19825/status || true
```
