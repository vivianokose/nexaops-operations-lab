# Module 7 retro: Docker and containers

## What I set out to do
Take a real Node.js and MySQL app and containerise it to a standard I could actually
ship: small, non-root, health-checked, scanned, signed, and living in a registry. Not a
demo image. A production one.

## What landed
- The mental model clicked early: a container is a ready meal for software, an image is
  the frozen version, a container is it heated up. Once that stuck, the rest followed.
- Multi-stage builds are the whole game for size. Watching 1.11GB become 133MB, and then
  seeing dive confirm 99 percent efficiency, made the "ship the sandwich, not the kitchen"
  idea real.
- Compose finally made multi-service work feel simple. One file, one command, and the app
  and database come up together on a private network with the database not even exposed to
  my laptop.

## What fought me, and what I learned from it
- **The database timing bug.** On first boot the app hit "table doesn't exist" because
  MySQL was not quite ready. A restart fixed it, but the real fix was adding a retry loop
  so the app waits patiently for the database. That taught me more than any clean run
  would have: production apps must be resilient to a database that is still waking up.
- **The Trivy report looked scary at first.** 77 findings. Reading it calmly showed most
  shared one root cause (an outdated OpenSSL), and bumping the base image dropped the OS
  findings from 50 to 2. The lesson that stuck: security scanning is not pass or fail. It
  is know what is there, fix what you can, document the rest.
- **The Nexus push 403.** My least-privilege deploy user could not create a brand-new repo,
  so I pushed as admin and noted that in production I would grant the deploy user specific
  rights instead. That was the least-privilege principle from last module, felt from the
  other side.
- **The Docker Hub account tangle.** I unlinked things in the wrong order and briefly
  orphaned an account. Annoying, but I learned how OAuth account linking actually works,
  and that a registry username does not need to match my GitHub.

## What I would do differently
- Pin the base image to an exact patch version from the start, not just node:20-alpine, so
  scans are reproducible.
- Set up the retry logic in the app before the first compose run, not after hitting the bug.

## Where this fits
This is the module that makes everything before it deployable. I can build artifacts
(Module 4), store them (Module 6), and now I can package a whole application into a
portable, verified image and publish it to a registry, ready for a real deployment.
Next: CI/CD, where all of this gets automated.
