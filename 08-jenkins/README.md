# Module 8: CI/CD with Jenkins

Last Friday a developer at VoyageAI SSHed into a server, ran a deploy script by hand, and
overwrote a config file. The booking service was down for 40 minutes. That is the problem
this module solves: replacing fragile manual deploys with an automated pipeline that runs
on every push, and refuses to ship broken code.

By the end I had a Jenkins pipeline that, from a single `git push`, works out the version,
lints, tests, builds a Docker image, pushes it to a registry, deploys it, verifies it is
healthy, and tags the release. Every step is understood, not copied.

![Pipeline architecture](architecture.png)
*The full pipeline: a push triggers Jenkins through a webhook, eight stages run, the image
lands on Docker Hub, and the app server pulls and runs it.*

## The story: from one button to no buttons

I built this in layers, each one removing a bit more manual effort.

First, a pipeline I triggered by hand. Then a webhook so a push triggered it for me. Then
multibranch so every branch and pull request got tested automatically. Then a shared
library so the build logic lived in one reusable place. Then dynamic versioning so my
commit messages decided the version number. Each layer is a real technique teams use.

## The two servers

CI/CD needs a separation: one machine automates, another runs the app. So I ran two
servers.

- **Jenkins server** (Linode 4GB) , the automation server. It watches GitHub, runs the
  pipeline, builds the image.
- **App server** (Linode 2GB) , where the deployed app actually runs and serves users.

Jenkins never runs the app. It builds it and ships it to the app server. Factory and shop,
kept apart.

![Jenkins dashboard](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/08-jenkins/screenshots/m08-jenkins-001-jenkins-dashboard.png)
*Jenkins running on its own server, reached in the browser.*

## The Jenkinsfile: a pipeline as code

The whole routine lives in a `Jenkinsfile` inside the repo. That means the deployment
process is version-controlled alongside the app, reviewed like any other change, and never
trapped in one person's head. This is called Pipeline as Code.

It looks like intimidating Groovy at first, but it is really a fill-in-the-blanks form:
a fixed `pipeline { stages { stage { steps { } } } }` structure, where each stage holds
shell commands I already knew from earlier modules.

The stages, in order: Checkout, Compute Version, Lint, Test, Build and Push, Deploy,
Verify, Tag Release.

## Secrets stay in a vault

The pipeline needs an SSH key, the app server's address, a Docker Hub token, and a GitHub
token. None of those belong in a file in a public repo. Jenkins has a built-in credential
store, so each secret lives there with a label, and the Jenkinsfile references only the
label. The real secret never appears in the code.

![Credentials added](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/08-jenkins/screenshots/m08-jenkins-003-credentials-added.png)
*Secrets stored in Jenkins' vault, referenced by label, never written into the pipeline.*

## Stage by stage

**Checkout** pulls the latest code from GitHub.

**Compute Version** reads the last git tag and my latest commit message, then bumps the
version: a `feat:` commit bumps the minor number, a `fix:` commit bumps the patch. My
commit message decides the release version, automatically.

**Lint and Test** run `npm run lint` and `npm test`. If a test fails, the pipeline stops
here. Broken code never reaches the app server.

**Build and Push** builds the Docker image and pushes it to Docker Hub. This logic lives in
a shared library (more below), so the Jenkinsfile calls it in one line.

**Deploy** (main branch only) has the app server pull the image from Docker Hub and run it.

**Verify** hits the `/health` endpoint to prove the new version is actually alive.

**Tag Release** (main only) creates a git tag for the version and pushes it to GitHub.

![All stages green](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/08-jenkins/screenshots/m08-jenkins-005-pipeline-stages-green.png)
*A full pipeline run, every stage green, ending with the app deployed and verified.*

![App deployed](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/08-jenkins/screenshots/m08-jenkins-006-app-deployed-browser.png)
*The deployed app answering on the app server, built and shipped entirely by the pipeline.*

## The webhook: making it automatic

A pipeline I have to start by hand is only half the win. A webhook is a doorbell: I told
GitHub to ping Jenkins on every push, so the instant I `git push`, the pipeline runs on
its own. To do this safely I opened Jenkins' port only to GitHub's published webhook IP
ranges, not to the whole internet.

![Webhook configured](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/08-jenkins/screenshots/m08-jenkins-007-webhook-configured.png)
*The GitHub webhook, delivering successfully to Jenkins.*

![Webhook triggered a build](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/08-jenkins/screenshots/m08-jenkins-008-webhook-triggered-build.png)
*A build that started on its own, seconds after a push. No button pressed.*

## Multibranch: testing every branch and pull request

A single-branch pipeline only watches main. A multibranch pipeline watches every branch
and every pull request, and builds each one automatically. So a feature branch gets
linted, tested, and built before it is ever merged, and the pull request shows a pass or
fail check right on GitHub.

![Multibranch view](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/08-jenkins/screenshots/m08-jenkins-009-multibranch-view.png)
*The multibranch job discovering and building branches automatically.*

![Pull request build](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/08-jenkins/screenshots/m08-jenkins-010-pr-build.png)
*A pull request built automatically by Jenkins.*

![GitHub status check](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/08-jenkins/screenshots/m08-jenkins-011-github-check.png)
*The pass check stamped straight onto the pull request, so a reviewer sees it is safe to merge.*

I also made Deploy run only on main, so feature branches are tested but never shipped to
production. Everyone's work is inspected; only the approved branch is deployed.

## Shared library: write the logic once

Copy-pasting the same build-and-push logic into every project's Jenkinsfile is a
maintenance trap. Instead I put it in a shared library, a separate repo with reusable
functions. My Jenkinsfile loads it and calls `buildAndPushImage(...)` in one line. Fix the
logic once in the library, and every project using it gets the fix.

![Shared library in use](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/08-jenkins/screenshots/m08-jenkins-012-shared-library.png)
*The pipeline calling the shared library function to build and push the image.*

## Dynamic versioning: the commit message decides

The version number should mean something. Using semantic versioning (MAJOR.MINOR.PATCH), a
`feat:` commit bumps the minor number and a `fix:` commit bumps the patch. The pipeline
reads the commit, works out the next version, tags the image with it, and pushes a git tag.
No human picks a version.

![Auto version tag](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/08-jenkins/screenshots/m08-jenkins-013-auto-version-tag.png)
*Tags created automatically by the pipeline: a feat commit produced v0.1.0, a fix commit v0.1.1.*

## A security fix I made along the way

Jenkins warned that passing the app server's IP into shell commands via Groovy string
interpolation was insecure, the secret got baked into the assembled command, where it
could leak into logs. I fixed it by pulling the secret from the vault as a runtime shell
environment variable, using single-quoted shell blocks so Groovy never touches it. The
warning went away and the secret is genuinely protected.

## The five things a production pipeline is judged on

- **Idempotency** , same input, same result. Each run is clean.
- **Speed** , a push to a deployed, verified app in well under a minute.
- **Visibility** , green and red stage boxes, and pass/fail checks on every pull request.
- **Safety** , secrets never leak; broken code never deploys; only main ships.
- **Recoverability** , the pipeline is code in git. If Jenkins dies, redeploy and it works
  (see the disaster-recovery runbook in this folder).

## Files and repos

- The application and its Jenkinsfile: [voyageai-booking-api](https://github.com/vivianokose/voyageai-booking-api)
- The shared library: [jenkins-shared-lib](https://github.com/vivianokose/jenkins-shared-lib)
- `architecture.png` , the diagram above
- `retro.md` , what fought me and what I learned
- `runbooks/jenkins-disaster-recovery.md` , what to do if Jenkins dies
- `screenshots/` , the full step-by-step record

## Key takeaways

- CI/CD is a tireless robot doing the build-test-deploy routine a human would do by hand.
- A Jenkinsfile is a form you fill in, not a language you master.
- A webhook is what makes it hands-off: push, and everything happens.
- Multibranch plus PR checks is how teams keep main safe.
- Shared libraries keep pipelines short and logic in one place.
- Conventional Commit prefixes can drive versioning automatically.
- Secrets belong in a vault, referenced by label, never interpolated into commands.
