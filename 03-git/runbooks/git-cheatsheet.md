# Git Cheatsheet: the commands I reach for most

A personal quick-reference built from Module 03. Plain-language reminders for the commands that matter.

## Everyday flow
| Command | What it does |
|---------|--------------|
| `git status` | Show what's changed and what's staged. Run this constantly. |
| `git add <file>` | Stage a file (put it in the "suitcase" for the next commit). |
| `git restore --staged <file>` | Unstage a file (take it back out of the suitcase). |
| `git commit -m "type: message"` | Save a snapshot. Message must follow Conventional Commits (feat, fix, chore, docs...). |
| `git push` | Send commits to GitHub. |
| `git pull` | Bring GitHub's latest changes down to local. |

## Branching (a branch is a sticky note on a commit)
| Command | What it does |
|---------|--------------|
| `git switch -c feat/thing` | Create a new branch and move onto it. |
| `git switch main` | Move to an existing branch. |
| `git branch` | List branches; the `*` marks where I am. |
| `git branch -d feat/thing` | Delete a merged branch (tidy up). |
| `git merge --no-ff feat/thing` | Merge a branch in, keeping a visible merge commit. |

## The professional flow (protected main)
1. `git switch -c fix/thing` — branch off
2. make changes, `git add`, `git commit`
3. `git push -u origin fix/thing` — push the branch (not main)
4. Open a Pull Request on GitHub
5. Wait for checks (CI) to pass
6. Squash and merge through the PR
7. Delete the branch

## Recovery (the calm-building commands)
| Command | What it does |
|---------|--------------|
| `git reflog` | Git's diary of everywhere HEAD has been. The rescue starts here. |
| `git reset --hard HEAD@{1}` | Jump back to where I was one step ago (undo a bad reset). |
| `git reset --hard <hash>` | Move the current branch to a specific commit. |
| `git rebase --abort` | Cancel a rebase and return to the start, no harm done. |
| `git push --force-with-lease` | The SAFE force-push. Refuses if someone else pushed. NEVER plain `--force`. |

## reset, revert, reflog — in my own words
- **reset** = move my branch pointer to a different commit. `--hard` also wipes changes. Rewrites where I am.
- **revert** = make a NEW commit that undoes an old one. Safe for shared history because it doesn't rewrite anything.
- **reflog** = the diary that lets me find and return to any recent state, even "deleted" commits.

## Golden rules
- Commit often. Recovery is easy when work is saved somewhere.
- Never rebase or force-push a branch others are using.
- `--force-with-lease`, never `--force`.
- `ls`/`git status` before anything destructive.

## Date
2026-07-11
