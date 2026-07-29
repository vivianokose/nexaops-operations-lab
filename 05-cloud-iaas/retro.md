# Module 4 Retro: Build Tools and Packaging

## What I built
- A Java service built with Maven into a versioned JAR, with four passing tests.
- A Node service built with npm, packaged as a versioned .tgz, with five passing tests.
- CycloneDX SBOMs for both, generated with Syft.
- Grype vulnerability scans against both. Clean.
- A SHA-256 checksum for the JAR, with tamper detection proven by breaking it.
- A signed git tag, v1.0.0, verified against the SSH key I set up in Module 1.
- A one-command build-and-verify script that runs the whole chain in order.

## The ideas that made it click
- Building is cooking. Source code is the recipe; the artifact is the meal. Nobody
  serves the recipe card to a customer, and nobody deploys source to production.
- Every build tool answers the same five questions: config file, lock file,
  registry, cache, artifact. Maven, npm and pip are one pattern in three dialects.
  Learning the third one took minutes because of this.
- Java compiles the whole book upfront. Node and Python translate live as they run.
  That is why the Maven build took 64 seconds and npm install took 4.
- Four questions turn a build output into an artifact: what is it, what is in it,
  is it safe, is it the one I built.

## What I will not forget
Log4j. Thousands of companies could not answer "are we using this?" because nobody
keeps a list of what is inside their software. The ones who answered in ten minutes
had an SBOM. That is the reason the ingredients label exists, and now both of my
artifacts have one.

## The moment that taught me most
I appended one single character to my JAR and the checksum verification failed
immediately. There is no such thing as a small tampering. Any change at all breaks
the seal, which is exactly what makes the seal worth publishing.

## What surprised me
- Scanning the Node .tgz found zero packages, because npm deliberately excludes
  node_modules from the package. The box holds the recipe, not the ingredients.
- One old version of lodash produced six findings, three of them High. All six had
  fixes already available. Most vulnerabilities are not mysteries, they are
  someone forgetting to update a library.
- `npm test` passed while testing nothing at all. Green ticks are not proof. I only
  caught it because the count said 1 and I had written 5.
- My own commitlint rule from Module 3 rejected my commit message for having
  capitals in it. Guardrails I built two modules ago are still doing their job.

## If someone hands me a JAR with no SBOM
I should assume nobody knows what is inside it, including the person who built it.
It might be fine. But there is no way to answer the Log4j question about it, and no
way to know whether it carries a known vulnerability. It is not ready to ship.

## What I would revisit
- Try this on an application with real dependencies, so the SBOM has hundreds of
  entries rather than one.
- Add `--fail-on high` to the script and watch a build get blocked by a scan.
- Look at cosign for signing the artifact itself, not just the release tag.

## Date
2026-07-23
