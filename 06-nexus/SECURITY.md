# Security Decisions: Nexus Registry

## OS-level security
- Nexus runs as a dedicated `nexus` operating-system user, never as root.
- Verified with: `ps aux | grep nexus` (the process owner is `nexus`).
- Why: if the application is compromised, the blast radius is limited to what the `nexus`
  user can touch, not the whole machine.

## Application-level security
- The one-time admin password was rotated on first login.
- Anonymous access is disabled, so every pull and push is authenticated and auditable.
- A dedicated `nexaops-deploy` user handles artifact pushes, with a role scoped to only
  the four hosted repositories. It cannot administer the registry, manage users, or
  delete repositories.
- Verified both ways: the deploy user successfully pushed an artifact, and, when logged
  in, has no access to admin settings.

## Credential management
Credentials never live in source control. Each tool keeps them in its own local file:
- Maven: `~/.m2/settings.xml`
- npm: `.npmrc` (gitignored)
- Python/twine: `~/.pypirc`
- Docker: `~/.docker/config.json`

All credential files are chmod 600 where applicable, and `.npmrc`/`.pypirc` are excluded
via `.gitignore`. The pre-commit gitleaks hook is a second line of defence.

## Lab compromises (would harden for production)
- The Docker repo is served over plain HTTP via Docker's insecure-registries setting. In
  production this would be TLS on 443.
- Configs reference the server by raw IP. Production would use a domain name.
- The deploy role currently includes broader view privileges than strictly needed; the
  textbook-clean version would be add-only.

## In production, credentials would move to
- AWS Secrets Manager, HashiCorp Vault, or CI/CD pipeline secrets (never files on disk).
