# Module 6 Retro: Artifact Repository with Nexus

## Where I started
Honest truth: after watching the videos, I was lost. All of it. The words made sense one
at a time but the picture would not form. So we threw the videos out and rebuilt it from
one idea: a registry is a pantry for software. Once that landed, everything else clicked
into place, one concept at a time.

## What I built
A private Sonatype Nexus registry on its own AWS EC2 instance, running as a limited OS
user under systemd. Then I published four kinds of artifact through it:
- A Java JAR (Maven), my user-service from Module 4.
- A Node package (npm), my notification-service from Module 4.
- A Python wheel (PyPI), a report-service I built from scratch here.
- A Docker image, the report-service containerised.

Plus a least-privilege deploy user, a cleanup policy, a REST API inventory script I
wrote, and a verified backup.

## What problem did Nexus solve that I did not realise I had?
Before this, if you had asked me how a team shares its build artifacts, I would have said
they upload them to a repository like Nexus or JFrog for distribution and versioning, and
for control over what stays in the repository and what does not. And that turned out to be
right. But saying it and building it are different things. What I did not appreciate was
how much of a registry is about control and safety, not just storage. The limited OS user.
Anonymous access off. A deploy user that can push but cannot touch admin. An audit record
of who uploaded what. A registry is not a shared folder. It is a controlled, auditable
gate that everything passes through.

## What surprised me most
That all four artifact types work the same way underneath. Java, Node, Python, Docker,
completely different tools, and yet each one is: point the tool at Nexus, give it a
credential, run a publish command. Once I had done Maven, the other three were variations
on a pattern I already knew. The registry stored each one the same way too: the artifact
plus the metadata needed to use it. Seeing that same shape hold across four ecosystems was
the moment it stopped feeling like four things to memorise and started feeling like one
idea.

## The parts that fought me
- The version chase. The lab specified an old Nexus that wanted Java 8, but I had Java 17.
  Then the download links kept 404ing because Sonatype had rotated the versions and even
  changed the filename format. I learned to go to the official download page for the
  current link instead of trusting a hardcoded version number. The newer Nexus shipped its
  own Java, which solved the whole thing.
- The least-privilege 403s. Setting up the deploy user, I kept hitting "forbidden" errors,
  one for the jar, one for the metadata. Each one taught me that access control is
  iterative: you grant the minimum, test, find you are one privilege short, grant exactly
  that, and no more. The errors were the lesson.

## What I would do differently or explore next
- Use a domain name (nexus.viviancloud.site) instead of the raw IP in my configs, so
  nothing breaks if the address changes.
- Put TLS in front of the Docker repo instead of the plain-HTTP insecure-registry
  shortcut, which is a lab compromise, not production.
- Tighten the deploy role to add-only (no delete), the textbook-clean version.
- Automate the backup off the server to S3, which a later module covers.

## The one line I want to remember
A registry is a pantry for software. Once I saw that, a topic that had completely lost me
became something I could build with my own hands and explain to someone else.

## Date
2026-08-04
