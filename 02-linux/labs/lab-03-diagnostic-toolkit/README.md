# Lab 03: Diagnostic Toolkit

Four small, shellcheck-clean bash tools for daily server diagnostics. Built on Ubuntu 24.04, tested on a hardened Multipass VM.

## The tools

| Tool | What it does |
|------|--------------|
| `sysnap` | One-screen snapshot: host, uptime, load, memory, top CPU/memory processes, disk usage, listening ports, recent logins, failed login count. |
| `logscan` | Search the systemd journal for a pattern with context. Scope by time (`--since`) or service (`--service`). |
| `diskmap` | Find the largest files and folders at a path. Control depth with `--top N`. |
| `netcheck` | Connectivity sanity check: ping key targets, resolve DNS, confirm outbound HTTPS. |

## Layout

    lab-03-diagnostic-toolkit/
    ├── bin/
    │   ├── sysnap
    │   ├── logscan
    │   ├── diskmap
    │   └── netcheck
    └── tests/
        └── smoke.sh

## Usage

    ./bin/sysnap                          # full snapshot
    ./bin/sysnap --no-color               # plain text (for piping to a file)
    ./bin/logscan "Accepted" --since "1 day ago"
    ./bin/logscan "error" --service ssh
    ./bin/diskmap /var --top 10
    ./bin/netcheck

## Testing

    ./tests/smoke.sh

Runs shellcheck on all scripts, then executes each tool to confirm it exits cleanly. Prints `Smoke OK` on success.

## Design notes and gotchas learned
- Every script starts with `set -euo pipefail` for fail-loud, fail-early behavior.
- `grep` returns a non-zero exit when it finds no matches. Under `set -e` this reads as a script failure, so the "failed logins" count in `sysnap` is guarded with `|| true` (zero failed logins is good news, not an error).
- `df -T` and `df --output` are mutually exclusive on this Ubuntu build; `--output` carries the fstype column on its own.
- `netcheck` intentionally checks three layers (ping, DNS, HTTPS) because some hosts (e.g. github.com) block ping while serving HTTPS fine. One check would lie; three corroborate.

## Install (optional)
Symlink into PATH so the tools are callable from anywhere:

    chmod +x bin/*
    ln -sf "$(pwd)/bin/"* /usr/local/bin/
