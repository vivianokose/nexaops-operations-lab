# Runbook: Building and Verifying an Artifact

> How to take source code and produce something you can actually ship: built,
> listed, scanned, and sealed. Tested end to end on Java and Node.

## The rule this exists for
A build output is not an artifact yet. A real artifact answers four questions:
what is it, what is inside it, is it safe, and is it the one I built. If it
cannot answer all four, it is not ready to ship.

## The one command
    cd 04-build-tools
    ./scripts/build-and-verify.sh

That runs all four steps in order and stops dead if any of them fails. Prefer
this over running the steps by hand; on a tired Friday you will skip one.

---

## The four steps, if you need to run them manually

### 1. Build the artifact
Java (Maven):
    cd labs/user-service
    mvn -B clean package
    ls -lh target/*.jar

Node (npm):
    cd labs/notification-service
    npm ci
    npm test
    npm pack
    ls -lh *.tgz

`clean` deletes the previous build first, so you never ship a stale artifact.
Use `npm ci` rather than `npm install` in any automated context: it installs
exactly what the lock file says, nothing newer.

### 2. Generate the SBOM (what is inside it)
    syft target/user-service-1.0.0.jar -o cyclonedx-json > sbom/user-service-1.0.0-sbom.json

For Node, scan the directory rather than the .tgz. The .tgz deliberately excludes
node_modules, so scanning it finds nothing:
    syft dir:. -o cyclonedx-json > notification-service-1.0.0-sbom.json

### 3. Scan for known vulnerabilities (is it safe)
    grype sbom:sbom/user-service-1.0.0-sbom.json

Read the table as: what you have, what fixes it, how bad, how likely to be
exploited. Sort your work by the RISK column, not by severity alone.

To make a pipeline fail on anything serious:
    grype sbom:... --fail-on high

### 4. Produce and verify the checksum (is it unchanged)
    sha256sum target/user-service-1.0.0.jar > target/user-service-1.0.0.jar.sha256
    sha256sum -c target/user-service-1.0.0.jar.sha256

Expect `OK`. Any change at all to the file, even one byte, produces `FAILED`.

---

## Releasing (who made it)

    git tag -s v1.0.0 -m "description of the release"
    git tag -v v1.0.0        # expect: Good "git" signature
    git push --tags

Update CHANGELOG.md in the same commit. Move entries out of [Unreleased] into a
new version heading, and start a fresh [Unreleased].

---

## What goes in git and what does not

Commit: pom.xml, package.json, package-lock.json, source files, CHANGELOG.md, SBOMs.
Never commit: target/, node_modules/, *.jar, *.tgz, *.class.

The rule is: commit the recipe, not the meal. Build output is reproducible from
source, so storing it in git bloats the repo and adds nothing.

Keep SBOMs outside target/, or the ignore rule for build output will sweep them
away too.

## Gotchas hit while building this
- Node's .tgz contains the recipe, not the ingredients. Scan the directory instead.
- A jar holds many classes but only startable ones can be run. `java -cp jar Class`
  needs a class with a main method, or you get "Main method not found".
- A command finishing without error does not mean it did what you wanted. `npm test`
  ran green while testing nothing, because the path pattern was wrong. Check the
  count against what you expected.
- Stray files land in artifacts easily. Check the file list that `npm pack` prints.

## Date drilled
2026-07-23
