# Module 02 Runbook: Ubuntu VM Baseline Hardening

> How to provision and harden a fresh Ubuntu server from zero to production-baseline. Reproducible on any Ubuntu 22.04 or 24.04 machine (local VM or cloud).

## What this produces
A fresh Ubuntu box with: automatic security updates, a deny-by-default firewall with only SSH open, brute-force protection, correct timezone, and hardened SSH (no root login, key-only auth).

## Environment used
- Host: Windows 11 Pro
- Virtualization: Multipass (Hyper-V backend)
- Guest OS: Ubuntu 24.04.4 LTS (noble)
- Hostname: bedrock-vm-01

## Steps

### 1. Launch the VM (run on Windows, PowerShell)
    multipass launch 24.04 --name bedrock-vm --cpus 2 --memory 4G --disk 25G
    multipass list
    multipass shell bedrock-vm

Note: the multipass launch alias may resolve to a newer point release. Always confirm the actual OS with `lsb_release -a` once inside.

### 2. Patch the system (run on the VM)
    sudo apt update && sudo apt upgrade -y

### 3. Install the security and diagnostic toolkit
    sudo apt install -y unattended-upgrades fail2ban ufw htop iotop ncdu jq shellcheck

### 4. Set a meaningful hostname
    sudo hostnamectl set-hostname bedrock-vm-01
    hostnamectl

### 5. Configure the firewall (ORDER MATTERS)
Allow SSH BEFORE enabling, or you lock yourself out.

    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow OpenSSH
    sudo ufw enable
    sudo ufw status verbose

### 6. Confirm fail2ban is guarding SSH
    sudo systemctl status fail2ban
    sudo fail2ban-client status sshd

### 7. Set the timezone
    sudo timedatectl set-timezone Africa/Lagos
    timedatectl

### 8. Harden SSH
    sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
    sudo grep -E '^PermitRootLogin|^PasswordAuthentication' /etc/ssh/sshd_config
    sudo systemctl restart ssh

## Gotchas I hit (and you will too)
- **Version surprise.** `multipass launch 22.04` gave me a 24.04 box. Trust `lsb_release -a`, not the launch alias. Both are LTS, both fine.
- **Silent sed miss.** My first PermitRootLogin sed used a pattern that assumed exact spacing and matched nothing, changing nothing, with no error. The `#*` version is forgiving of comments and spacing. ALWAYS grep-verify after a sed edit before restarting the service.
- **Never disable password auth before confirming key login works.** On a real server this locks you out permanently. On Multipass, `multipass shell` is your recovery path.

## Verification
- `sudo ufw status verbose` shows deny-in / allow-out, only OpenSSH allowed
- `sudo fail2ban-client status sshd` shows the jail active
- `timedatectl` shows the correct zone and synced clock
- `sudo grep -E '^PermitRootLogin|^PasswordAuthentication' /etc/ssh/sshd_config` shows both as `no`

## Date
2026-07-04
