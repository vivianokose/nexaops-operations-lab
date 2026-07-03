# Module 01 Runbook: Foundations Setup

> How to reproduce my Module 01 engineering setup on a fresh machine.

## What this covers
Setting up the engineering identity and portfolio base: GitHub CLI, the umbrella repo, ADRs, a personal site on GitHub Pages, SSH commit signing, and 2FA.

## Prerequisites
- A machine running WSL (Ubuntu) or Linux
- Git installed
- A GitHub account with a professional email

## Steps

### 1. Install GitHub CLI (gh)
Do NOT use snap. Use GitHub's official apt repository.

```bash
(type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
&& sudo mkdir -p -m 755 /etc/apt/keyrings \
&& out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
&& cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
&& sudo mkdir -p -m 755 /etc/apt/sources.list.d \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update && sudo apt install gh -y
```

Then authenticate:
```bash
gh auth login
```

### 2. Install wslview (so gh can open the browser)
```bash
sudo apt update && sudo apt install wslu -y
```

### 3. Create and scaffold the repo
```bash
cd ~
gh repo create nexaops-operations-lab --public --description "Production-grade DevOps portfolio, working through industry-standard tooling end to end." --clone
cd nexaops-operations-lab
mkdir -p ADRs 01-foundations/{labs,runbooks,screenshots,posts}
```

Then add README.md, ADR-0001, ADR-0002, and .gitignore. Commit and push:
```bash
git add .
git commit -m "chore(repo): scaffold nexaops-operations-lab with module-01 skeleton"
git push -u origin main
```

### 4. Personal site on GitHub Pages
Put a one-page index.html in a docs/ folder, commit and push, then in the repo Settings > Pages, set Source to "Deploy from a branch", branch main, folder /docs, and Save. Live URL appears in about 2 minutes.

Live site: https://vivianokose.github.io/nexaops-operations-lab/

### 5. SSH commit signing
```bash
ssh-keygen -t ed25519 -C "vivian-signing-2026" -f ~/.ssh/id_ed25519_signing
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519_signing.pub
git config --global commit.gpgsign true
echo "vivian-signing-2026 $(cat ~/.ssh/id_ed25519_signing.pub)" >> ~/.ssh/allowed_signers
git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
gh ssh-key add ~/.ssh/id_ed25519_signing.pub --title "vivian-signing-2026" --type signing
```

Gotcha I hit: uploading the signing key needs the admin:ssh_signing_key scope. If gh ssh-key add returns a 404, run:
```bash
gh auth refresh -h github.com -s admin:ssh_signing_key
```
Then re-run the gh ssh-key add command. The key must be on GitHub BEFORE the commit is pushed, or the commit shows Unverified.

### 6. Two-factor auth
GitHub > Settings > Password and authentication > enable 2FA with an authenticator app. Save the recovery codes.

## Verification
- `gh repo view --web` opens the repo
- README renders with the module table
- Live site loads in under 1 second
- `git log --show-signature -1` shows "Good signature"
- Latest commit shows a green "Verified" badge on GitHub
- 2FA is active

## Date
2026-07-03
