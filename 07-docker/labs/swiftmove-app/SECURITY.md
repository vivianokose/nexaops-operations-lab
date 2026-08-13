# Security posture: SwiftMove app image

This document records the security decisions and known vulnerabilities for the
`swiftmove-app` container image. It is deliberately honest: the goal is not a
mythical "zero CVEs", it is knowing what is in the image, fixing what we can,
and documenting the rest with a reason.

## Image hardening applied

- **Multi-stage build**: build tooling never ships in the final image.
- **Minimal base**: `node:20-alpine` (Alpine Linux), small attack surface.
- **Non-root user**: the app runs as UID 10001, not root.
- **Healthcheck**: the container reports its own liveness.
- **.dockerignore**: build context excludes `.git`, `node_modules`, `.env`, and secrets.
- **No secrets in the image**: credentials are injected at run time via environment
  variables, never baked into a layer.

## Vulnerability scanning

Scanned with Trivy (`trivy image swiftmove-app:1.0.0`).

### Remediation performed
- Bumped the base image from `node:18-alpine` (Alpine 3.21) to `node:20-alpine`
  (Alpine 3.23). This reduced OS-level findings from 50 to 2, clearing both
  criticals in the OS layer, by pulling in patched OpenSSL and system libraries.

### Application dependencies: clean
- The application's own dependencies (`express`, `mysql2` and their trees under
  `app/node_modules/`) report **zero** vulnerabilities.

### Accepted / waiting upstream

**OS layer (2 HIGH): OpenSSL (`libcrypto3` / `libssl3`)**
- CVE-2026-45447. Installed 3.5.6-r0, fix expected in 3.5.7-r0.
- Status: **waiting upstream.** Alpine has not yet published the patched package.
  Will clear automatically on a future base-image rebuild. Not fixable by us today.

**Node layer: bundled `npm` tooling (not application code)**
- All remaining Node findings (`tar` CRITICAL, plus `brace-expansion`, `glob`,
  `minimatch`, `sigstore`, `cross-spawn`, `ip-address` HIGH) live inside the
  `npm` package manager that ships with the official Node image
  (`usr/local/lib/node_modules/npm/...`), not in the application.
- Status: **accepted.** Rationale:
  1. These packages are part of npm, not runtime dependencies of the app.
  2. The running container executes `node src/server.js` and does not invoke npm,
     so this code is not in the running app's path.
  3. They are not ours to patch; they clear when the Node image maintainers
     refresh the bundled npm. Rebuilding on a newer Node patch release picks up
     fixes as they land.

## Review cadence
Re-scan on every base-image bump and before each release. Move any item from
"waiting upstream" to "fixed" once the patched package is available.
