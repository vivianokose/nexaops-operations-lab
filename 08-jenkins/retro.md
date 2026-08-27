# Module 8 retro: CI/CD with Jenkins

## What I set out to do
Replace manual, error-prone deploys with an automated Jenkins pipeline: build, test,
package, deploy, and verify on every push. Then layer on the advanced techniques real
teams use, multibranch, a shared library, dynamic versioning.

## The honest starting point
I was lost. I watched the whole video series and understood almost none of it. The moment
Groovy appeared on screen I zoned out, convinced I needed to learn a programming language
to do this job. That fear was the real blocker, not the tools.

What fixed it: learning that a Jenkinsfile is a fill-in-the-blanks form, not a language to
master. The structure is fixed; I only fill in stage names and shell commands I already
knew from Docker. Once that clicked, the whole module opened up. DevOps engineers read and
adapt scripts. They are not software developers, and I do not need to become one.

## What fought me, and what I learned
- **AWS suspended my account mid-module**, with two days of free tier left. I had already
  built the whole Jenkins setup on EC2. Frustrating, but it turned into the best lesson of
  the module: I rebuilt everything on Linode in a fraction of the time, because I
  understood every step instead of following blindly. Understanding is portable;
  server setups are not.
- **I deleted my SSH directory** with a careless \`rm -rf\`, including my git signing key.
  I learned, the hard way, to read the whole command before running it, especially the end.
  And I learned to restore SSH commit signing properly rather than just turning it off.
- **The Jenkins signing key repo kept failing to verify** (NO_PUBKEY). Fetching the key
  directly from the keyserver by its ID is the reliable fix. A genuinely useful move to know.
- **Jenkins would not start on Java 17.** The log said it plainly: it needed Java 21. Read
  the log, install the right version, move on. Textbook troubleshooting.
- **The Lint stage hung forever.** My lint command loaded the app, which started a web
  server, which never exits. A lint check should check the code, not run it. Switching to
  \`node --check\` fixed it. Servers run forever by design; a stage waiting on one waits
  forever.
- **The first pipeline failed on a missing npm.** The Jenkins server is a separate machine;
  whatever the pipeline runs must be installed there. Obvious in hindsight, easy to forget.

## What I would do differently
- Install every tool the pipeline needs (node, docker) on the Jenkins server before the
  first run, instead of discovering each gap by failure.
- Set up commit signing and SSH keys more carefully so one bad command cannot wipe them.
- Pick a cloud provider with a clear, stable free tier from the start.

## Where this fits
This is the module that ties everything together. My git workflow, my build tools, my
Docker images, my registry, they all now flow through one automated pipeline. This is the
point where the separate tools stop being separate and start being a system. Next: I would
add ephemeral build agents and proper SSO, the production-hardening steps.
