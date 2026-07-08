# Module 02 Runbook: SSH at Scale (config, agent, jump host)

Topology built: bedrock-vm (client) -> bedrock-prod (bastion) -> bedrock-private (target).
bedrock-private is reachable ONLY by hopping through bedrock-prod.

## Key principle
One SSH key per environment, never one key for everything. If a key leaks, revoke that one environment only.

## Steps
1. Generate a per-target key on the client:
   ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_to_prod -C "bedrock-vm-to-prod"
2. Install the public key on the target via Multipass (PowerShell):
   multipass transfer bedrock-vm:/home/ubuntu/.ssh/KEY.pub C:\path\to.pub
   multipass transfer C:\path\to.pub target:/home/ubuntu/to.pub
   multipass exec target -- bash -c "mkdir -p ~/.ssh && cat ~/to.pub >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys && rm ~/to.pub"
3. Build ~/.ssh/config (chmod 600 after):
   Host *
     ServerAliveInterval 60
     IdentitiesOnly yes
     AddKeysToAgent yes
   Host bedrock-prod
     HostName <prod-ip>
     User ubuntu
     IdentityFile ~/.ssh/id_ed25519_to_prod
   Host bedrock-private
     HostName <private-ip>
     User ubuntu
     IdentityFile ~/.ssh/id_ed25519_to_private
     ProxyJump bedrock-prod
4. SSH agent: eval "$(ssh-agent -s)" ; ssh-add ~/.ssh/id_ed25519_to_prod
5. Connect by name: ssh bedrock-prod / ssh bedrock-private (hops automatically)
6. Harden target sshd: drop-in at /etc/ssh/sshd_config.d/99-bedrock.conf with
   PermitRootLogin no, PasswordAuthentication no, MaxAuthTries 3, LoginGraceTime 30s.
   Always: sudo sshd -t  (validate) then sudo systemctl reload ssh.

## Gotchas
- VM IPs drift after restart. Never hardcode IPs except the HostName line. Re-check with multipass list.
- The client is whatever machine you type ssh on; it uses THAT machine's keys.
- WSL cannot route to Multipass VMs by default. Run the lab from inside the VMs.
- A successful jump shows "<no hostip for proxy command>" - that means it tunneled through the bastion.
- sshd -t before every reload, or you risk locking yourself out.

## Date
2026-07-08
