---
title: "The Week Git Stopped Being Scary: Secrets, Conflicts, and Recovery"
published: false
description: "A hands-on Git module: making it impossible to commit a secret, surviving my first merge conflict, recovering deleted commits, and locking down main with a real pull-request workflow."
tags: git, devops, devsecops, beginners
canonical_url: https://vivianokose.hashnode.dev/the-week-git-stopped-being-scary
---

Most people learn just enough Git to `add`, `commit`, and `push`. I used to be one of them. This module was about crossing the gap between "I use Git" and "I trust Git with my work", the gap that, on most teams, separates a junior from a mid-level engineer. Here is everything I built, including the part where I got completely lost and how I found my way back.

## Making it impossible to commit a secret

The single most valuable thing I set up: a pre-commit hook chain that scans every commit *before* it happens. I tested it by deliberately trying to commit a fake AWS key.

The commit never happened. The scanner (gitleaks) spotted the key, pointed to the exact file and line, and blocked it cold. Nothing leaked. Nothing to rotate.

![gitleaks blocking a secret](./screenshots/m03-lineage-004-gitleaks-blocks-secret.png)

This matters because leaked cloud keys get found by attackers within seconds of hitting a public repo, and the cleanup is genuinely painful. The whole philosophy here: turn discipline into automation. Not "remember to check for secrets," but "make it physically impossible to commit one." The same chain also enforces good commit messages, so a lazy "fixed stuff" gets rejected at the door.

![A bad commit message rejected](./screenshots/m03-lineage-001-commit-rejected.png)

## Surviving my first merge conflict

I used to think merge conflicts were a disaster. They're not. A conflict is just Git saying "two people changed the same spot, you decide which wins."

I created one on purpose in a throwaway sandbox: changed the same line on two branches, then tried to combine them. Git stopped and marked the clash with `<<<<<<<` and `>>>>>>>` markers.

![Conflict markers in a file](./screenshots/m03-lineage-005-conflict-marker.png)

Resolving it was simpler than the reputation suggests: edit the file to what I actually want, delete the marker lines, tell Git it's resolved. That's the entire skill. Once I'd done it once, conflicts stopped being frightening.

## The concept that unlocked everything

Halfway through, I got completely lost. Moving a commit between branches made no sense to me. I stopped and admitted I didn't understand, rather than pretending.

The fix was reframing what a branch actually *is*. A branch is not a copy of your code. It's a sticky note stuck on one commit. "Moving a commit to another branch" is really just sliding sticky notes around while the commit itself stays put. The moment that clicked, branching, resetting, and recovery all suddenly made sense.

Admitting I was lost was the best decision I made all module.

## Recovering deleted work

Then I broke things on purpose. I ran `git reset --hard` and wiped three commits, including a merge. They vanished. In a real panic, this is the stomach-drop moment.

Except they weren't gone. Git keeps a diary called the reflog, a record of everywhere I've been. My "deleted" commits were still in it. One command, and everything came back.

![Reflog rescue](./screenshots/m03-lineage-007-reflog-rescue.png)

This is the calm that experienced engineers have and beginners don't. `git log` only shows my current path; `git reflog` remembers the paths I left, including the lost work. Knowing that safety net exists changes how it feels to make a mistake.

## Locking down main like a real team

Finally, I protected my main branch: no direct pushes, changes must come through a pull request, commits must be signed, history must stay linear. I proved it worked by trying to push straight to main, and watching GitHub reject it.

Then I did the full professional flow: made a branch, pushed it, opened a pull request, watched my automated checks run on GitHub's servers, and merged through the proper door.

![CI passing on a pull request](./screenshots/m03-lineage-011-ci-green.png)

That flow, branch, push, PR, pass checks, merge, is exactly what I'll do every day in a DevOps job. Building it on my own repo, with no pressure, is the best practice I could ask for.

## What I actually learned

The commands matter, but the mindset matters more. Git isn't a thing to fear; it's a safety net that remembers almost everything. The real skills are: make good habits automatic so they don't depend on memory, and know your recovery moves before you need them.

And the most important lesson had nothing to do with Git: when I was lost, saying so out loud, instead of nodding along, was what let me actually learn. That's a habit worth keeping.

Next up: databases.
