---
title: "From Blank VM to Bastion: Everything I Learned Hardening Linux"
published: false
description: "A full walkthrough of a hands-on Linux module: hardening a server, building a multi-user permission system, writing a diagnostic toolkit, and setting up a real jump host. Plus the seven times the docs lied and the delete command that scared me."
tags: linux, devops, bash, ssh
series: "DevOps in Practice, Module by Module"
canonical_url: https://vivianokose.hashnode.dev/from-blank-vm-to-bastion
---

Every server I will ever touch in DevOps runs Linux. Every container is a Linux process. Every CI runner shells out to bash. So I spent a module getting genuinely fluent at the command line, not copy-pasting my way through, but understanding every step. Here is everything I built, and more importantly, everything that went wrong on the way, because that is where the real learning was.

## What I built

**A hardened Ubuntu 24.04 server.** Starting from a blank VM, I brought it to a production baseline: a deny-by-default firewall (UFW) with only SSH allowed, fail2ban guarding against brute-force login attempts, automatic security updates, a correct timezone, and SSH locked down to key-only auth with no root login.

The order matters more than it looks. Enable the firewall before allowing SSH, and you lock yourself out of your own server. Allow SSH first, then enable. That sequence has saved more careers than any clever command.

![Firewall active, SSH allowed](./screenshots/m02-bedrock-003-ufw-active.png)

**A multi-tenant permission system.** Four users, each with a different level of access: two full developers with sudo constrained to specific commands, a read-only user who can look but not touch, and a contractor sealed into her own sandbox with an account set to auto-expire in 30 days. Then I tested every boundary by becoming each user and confirming the walls held.

This is where Linux permissions stopped being abstract. Watching a read-only user get "Permission denied" when they tried to write, and watching a "restricted" admin get blocked from reading the password file, made access control real in a way no diagram could.

![Contractor account set to auto-expire](./screenshots/m02-bedrock-009-dee-expiry.png)

**A four-tool diagnostic toolkit.** I got tired of typing the same six commands every time something felt slow, so I wrote tools that do it for me:

- `sysnap`: a one-screen snapshot of a server's health (load, memory, top processes, disk, open ports, failed logins)
- `logscan`: search the system logs for a pattern, with context, scoped to a time or service
- `diskmap`: find what's actually eating the disk, biggest-first
- `netcheck`: confirm I'm really online and reaching the things I depend on

Each is 30 to 45 lines of bash, all shellcheck-clean, all covered by a smoke test.

![sysnap running on a live server](./screenshots/m02-bedrock-010-sysnap-output.png)

![All four scripts pass shellcheck](./screenshots/m02-bedrock-012-shellcheck-clean.png)

**A real jump host (bastion).** Production servers don't sit on the open internet. They hide behind a gateway you have to hop through. I built that with three VMs: a client, a bastion, and a private server with no direct route from outside. With one line of SSH config (`ProxyJump`) and one command, `ssh bedrock-private`, SSH tunneled through the bastion to reach the hidden box.

The proof it worked: SSH printed `<no hostip for proxy command>` during the handshake, its way of saying "I reached this through a proxy, not directly." That phrase is the fingerprint of a working jump host.

![The jump host hop succeeding](./screenshots/m02-bedrock-014-jump-host-success.png)

## The seven times the docs lied

Here is what the tutorials never prepare you for: the documentation and my actual system disagreed seven separate times. Every time, the system was right. Learning to read what the machine tells me, instead of trusting what the guide claims, was the single most valuable skill of the module.

1. **The OS version was wrong.** I launched "22.04" and got 24.04. `lsb_release -a` is the source of truth, not the launch command.
2. **A find-and-replace silently did nothing.** My `sed` pattern didn't match, so it changed nothing, with no error. I only caught it by verifying with `grep` afterward. Silent no-ops are the most dangerous kind.
3. **A command flag didn't exist.** The guide used `adduser --expiredate`; my version had no such flag. The fix was a different tool (`chage -E`).
4. **A missing package.** `setfacl` didn't exist until I installed `acl`. "Command not found" is not always a typo.
5. **My restricted user wasn't restricted.** A user I'd limited to three commands still had full admin power, because `sudo` group membership silently overrode my rule. Checking effective permissions, not intended ones, revealed it.
6. **Mutually exclusive flags.** `df -T` and `df --output` couldn't be combined on my build.
7. **`grep` broke my test.** My smoke test failed because `grep` returns a failure exit code when it finds zero matches, which my `set -euo pipefail` correctly caught. Zero failed logins is good news, but `grep` calls it a failure. Guard it with `|| true`.

## The mistake that taught me the most

Near the end, I ran a recursive delete with a folder path accidentally on the list, and wiped my entire screenshots folder. No recycle bin. No undo.

Except the work survived, because it lived in two other places: committed in git, and backed up separately. One `git checkout` and a re-copy, and everything was back in under a minute.

That scare taught me more than any smooth step. Three habits I now hold without exception:

- **Commit often.** Recovery took a minute instead of hours because the work was already saved somewhere safe.
- **`ls` before you `rm`.** Look at exactly what you are about to delete.
- **Verify, don't assume.** A command running without error does not mean it did what you intended.

## The real takeaway

The gap between "works in the tutorial" and "works on my actual machine" is where the real skill lives. Run the command, read the error, understand what the system is telling you, adapt, repeat. Tutorials cannot teach that loop, because tutorials never fail. Your real system will, and that is a gift.

Next up: version control done properly. On to Git.
