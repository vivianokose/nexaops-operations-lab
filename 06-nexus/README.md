# Module 6: Artifact Repository with Nexus

Standing up a private artifact registry on AWS, then publishing four different kinds of
build artifact through it: Java, Node, Python, and Docker. Everything here was built by
hand and understood, not copied.

## What this module is about

Every build produces an artifact. A Java build makes a JAR, a Node build makes a package,
a Python build makes a wheel, a Docker build makes an image. The question this module
answers is: where do those artifacts go, and how does a team share them safely?

The answer is a registry. Think of it as a pantry for software. It stores your own
finished artifacts, caches copies of the public libraries your builds depend on, and
gives you one controlled place to version and audit everything. Nexus is the registry I
ran here.

![Architecture of the Nexus registry](architecture.png)

*Your laptop pushes and pulls artifacts through Nexus. Hosted repos hold your own work;
proxy repos cache the public registries so builds keep working even when the internet
does not.*

## The three kinds of repository

A registry stores things on three kinds of shelf:

- Hosted: your own artifacts. The jam you made yourself.
- Proxy: cached copies of public libraries. Shop-bought flour kept on your shelf, so you
  do not run to the shop every time, and you still have some when the shop is closed.
- Group: one address that serves from both, so a build only needs a single URL.

## 1. The server

Nexus is a hungry Java application, so it got its own dedicated EC2 instance rather than
sharing the Module 5 web server.

![EC2 instance running Nexus](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/06-nexus/screenshots/m06-nexus-001-ec2-nexus-instance.png)
*The dedicated Nexus instance, running in my own VPC from Module 5.*

The most important security decision: Nexus runs as a limited `nexus` operating-system
user, never as root. If the application is ever compromised, the damage is boxed into
that user's small world instead of the whole machine.

![Nexus running as the nexus user](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/06-nexus/screenshots/m06-nexus-002-nexus-running-user.png)
*Proof it runs as `nexus`, not root. The first column of the process list is the whole
security lesson.*

## 2. Securing the registry

![Nexus login page](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/06-nexus/screenshots/m06-nexus-003-nexus-login.png)
*The registry, live and reachable in the browser.*

![Admin password changed](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/06-nexus/screenshots/m06-nexus-004-admin-password-changed.png)
*Rotated the one-time admin password on first login.*

![Anonymous access disabled](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/06-nexus/screenshots/m06-nexus-005-anonymous-disabled.png)
*Anonymous access turned off, so every pull and push is identified and auditable.*

## 3. The repositories

![All repositories](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/06-nexus/screenshots/m06-nexus-006-all-repositories.png)
*The shelves. Nexus ships with the Maven set pre-built; I added npm, PyPI, and Docker
hosted repos.*

## 4. Publishing four artifact types

The satisfying part: taking artifacts I built in earlier modules and giving them a home.

### Maven (Java)

![Maven deploy success](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/06-nexus/screenshots/m06-nexus-007-maven-deploy-success.png)
*`mvn deploy` pushing my user-service JAR to the maven-releases shelf.*

![JAR in Nexus](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/06-nexus/screenshots/m06-nexus-008-jar-in-nexus.png)
*The JAR on the shelf, with the exact dependency snippet a teammate would use to pull it.*

### npm (Node)

![npm publish success](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/06-nexus/screenshots/m06-nexus-009-npm-publish-success.png)
*Publishing the notification-service package.*

![npm package in Nexus](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/06-nexus/screenshots/m06-nexus-010-npm-in-nexus.png)
*The package stored, with an audit record of who uploaded it and when.*

### PyPI (Python)

I had not built a Python package before, so this one I made from scratch: a small
report-service, sealed into a wheel with `build` and `pyproject.toml`, then uploaded with
`twine`.

![Python wheel built](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/06-nexus/screenshots/m06-nexus-011-python-wheel-built.png)
*Building the wheel, my first Python package.*

![Wheel in Nexus](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/06-nexus/screenshots/m06-nexus-012-pypi-in-nexus.png)
*The wheel on the PyPI shelf.*

### Docker

![Docker push](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/06-nexus/screenshots/m06-nexus-013-docker-push.png)
*Pushing a Docker image (the report-service, containerised) to the Docker shelf on port
8082.*

![Image in Nexus](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/06-nexus/screenshots/m06-nexus-014-docker-in-nexus.png)
*The image stored in docker-hosted.*

## 5. Least-privilege access

Everything above was published as admin, which is fine for setup but wrong for a real
build pipeline. So I created a `nexaops-deploy` user with a role that can only push to the
four repos, no admin, no delete, no user management.

![Deploy user can push](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/06-nexus/screenshots/m06-nexus-015-deploy-user-privileges.png)
*Both versions of the JAR on the shelf, one pushed by admin and one by the deploy user,
proving the deploy user can do its job.*

![Deploy user cannot admin](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/06-nexus/screenshots/m06-nexus-016-deploy-user-no-admin.png)
*Logged in as the deploy user: the admin settings are simply gone. Least privilege,
proven both ways.*

## 6. Housekeeping

![Cleanup policy](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/06-nexus/screenshots/m06-nexus-017-cleanup-policy.png)
*A cleanup policy set to prune stale snapshot builds automatically, so the registry does
not bloat over time.*

![API inventory](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/06-nexus/screenshots/m06-nexus-018-api-inventory.png)
*A bash script I wrote that queries the Nexus REST API and prints an inventory of every
artifact. One command, and the registry reports itself.*

![Backup archive](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/06-nexus/screenshots/m06-nexus-019-backup-archive.png)
*A verified backup of the registry's data folder, so a dead server is recoverable, not a
catastrophe.*

## What I published

| Type | Tool | Artifact |
|------|------|----------|
| Java | Maven | user-service JAR (from Module 4) |
| Node | npm | notification-service package (from Module 4) |
| Python | build + twine | report-service wheel (new, built here) |
| Docker | docker | report-service image (new, built here) |

## Files in this module

- `labs/report-service/` — the Python package and Dockerfile I built
- `scripts/nexus-inventory.sh` — REST API inventory script
- `SECURITY.md` — the security decisions and how credentials are handled
- `retro.md` — what I learned
- `architecture.png` — the diagram above
- `screenshots/` — 19 screenshots documenting each step

## Key takeaways

- A registry is a pantry for software: it stores your own artifacts, caches public ones,
  and gives you one controlled, auditable place for everything.
- Run services as a limited user, not root, so a break-in stays contained.
- Give automated systems least privilege: a deploy user should push, and nothing else.
- The same pattern (a project file, a credentials file, a publish command) repeats across
  Maven, npm, Python, and Docker. Learn it once, apply it everywhere.
