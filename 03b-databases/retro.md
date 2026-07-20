# Module 03 Retro: Version Control with Git

## What I built
- Commit-message enforcement (commitlint) so bad messages get rejected before they exist.
- A pre-commit hook chain (gitleaks, shellcheck, file checks) that makes it physically impossible to commit a secret.
- A GitHub Actions workflow running my hooks on every push and pull request (my first CI).
- Branch protection on main: pull requests required, signed commits required, linear history, force-pushes blocked, status checks must pass.
- Hands-on practice with rebase, merge conflicts, and recovery.

## The big concept that unlocked everything
A branch is not a copy of my code. It is a sticky note (a pointer) stuck on one commit. "Moving a commit to another branch" is really just sliding sticky notes around while the commit stays put. Once this clicked, reset, branching, and recovery all made sense.

## reset, revert, reflog in my own words
- **reset** = move my branch's sticky note to a different commit. `--hard` also wipes the working changes. It changes where I am.
- **revert** = make a brand-new commit that undoes a previous one. Safe for shared history because it doesn't rewrite anything, it adds.
- **reflog** = Git's diary of everywhere HEAD has been. `git log` only shows my current path; `reflog` remembers the paths I left, including "deleted" commits. It's how I get lost work back.

## What surprised me
- Deleting commits with `reset --hard` looks permanent but isn't, reflog kept the way back.
- husky and pre-commit both fought over the same hook "door"; I had to let one tool manage it.
- A file I deleted from disk was still staged (the "suitcase" still had it), so a scanner kept catching it. Staged state and disk state are separate.
- One bad commit message slipped through before I finished wiring the hook. Lesson: test enforcement before trusting it.

## The moment I got lost (and what fixed it)
Moving a commit between branches made no sense to me until I stopped thinking of branches as copies and started seeing them as sticky notes on commits. Asking to slow down instead of pretending to understand was the right call.

## What clicked
- The professional flow: locked main, work on a branch, open a PR, pass CI, merge through the door.
- reflog as a safety net, the calm it gives is the whole point.
- Signed commits + protected main = a repo that resists my own mistakes.

## Date
2026-07-11
