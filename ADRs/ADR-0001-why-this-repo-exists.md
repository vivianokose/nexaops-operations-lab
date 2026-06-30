# ADR-0001: Why this repo exists

## Status
Accepted

## Context
I am working through a DevOps bootcamp curriculum spanning 17 modules. The default outcome of bootcamps is a folder of disconnected lab files that nobody can read or reproduce. The default outcome is not a portfolio.

## Decision
I will maintain a single monolithic repo called `nexaops-operations-lab` that contains every module's labs, runbooks, screenshots, and writeups. Each module gets a numbered folder. Each lab gets its own subfolder with a README. Every artifact is reproducible from the README.

## Consequences
- Pro: One link to share. One mental model. One git history.
- Pro: Recruiters and engineers can navigate by folder.
- Con: The repo will grow large. Will mitigate with `.gitignore` discipline and a future split if any module's artifacts exceed 100 MB.
- Con: If I ever need to make one module private, I cannot do it without splitting the repo.

## Date
2026-06-30
