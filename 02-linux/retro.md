# Module 02 Retro: Linux, OS & Shell Fundamentals

## What I built
- Hardened Ubuntu 24.04 VM: UFW (deny-by-default, SSH only), fail2ban, unattended-upgrades, key-only SSH, no root login.
- Multi-tenant permissions: devs with constrained sudo, read-only user via ACL, contractor sandboxed and auto-expiring in 30 days. Every boundary tested by becoming each user.
- Four-tool diagnostic toolkit (sysnap, logscan, diskmap, netcheck), shellcheck-clean, smoke-tested.
- Three-VM SSH setup with a working jump host.

## What surprised me (doc vs reality, the system was always right)
- multipass launch 22.04 gave a 24.04 box.
- A sed pattern silently matched nothing, changed nothing, no error.
- adduser had no --expiredate flag; used chage -E.
- The acl package wasn't installed; setfacl didn't exist until I added it.
- Being in the sudo group overrode my constrained sudoers rule.
- df -T and --output are mutually exclusive on this build.
- grep returning non-zero on no-match broke my smoke test under set -e.

## The scary moment
Ran rm -r with a folder path accidentally on the delete list and wiped my local screenshots folder. Recovered fully because the work lived in two other places: committed in git, and the Windows originals. Never felt "commit often" more viscerally. New habits: ls before rm, never -rf on anything but a specific certain file.

## What clicked
- Permissions became real once tested as actual users.
- "Small tools piped together" as a philosophy.
- Jump hosts: reaching a server with no direct route, through a bastion, in one word.

## Date
2026-07-08
