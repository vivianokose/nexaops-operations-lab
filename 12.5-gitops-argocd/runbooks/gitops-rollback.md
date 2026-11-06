# Runbook: Rolling back a release with GitOps

**Applies to:** ClearOps, deployed by ArgoCD from [clearops-gitops](https://github.com/vivianokose/clearops-gitops)
**Owner:** Vivian Okose
**Last tested:** 6 November 2026, on a real bad release (see the incident record below)

---

## The rule

Git is the source of truth. **Roll back by changing git, never by changing the cluster.**

With auto-sync and self-heal on, any change made only in the cluster (`kubectl rollout undo`,
`kubectl set image`, or the ArgoCD UI's Rollback button) is either refused or undone within
seconds. Even when it sticks, git still holds the bad version, and the next sync redeploys it.

## When to use this

- A release is live and causing problems (errors, wrong data, failed health checks).
- The previous release was known to be good.

## Steps

### 1. Confirm what is running

```bash
argocd app get clearops-dev --refresh | grep -E "Sync Status|Health Status"
kubectl exec -n dev deploy/clearops-api -- python3 -c \
  "import urllib.request;print(urllib.request.urlopen('http://localhost:8080/health').read().decode())"
```

Note the version reported by `/health` and the commit ArgoCD is synced to.

### 2. Find the release commit in the config repo

```bash
cd ~/clearops-gitops
git pull --quiet
git --no-pager log --oneline -5 -- apps/clearops/overlays/dev
git --no-pager show --stat <commit>
```

The bad release is the `chore(dev): bump clearops to X.Y.Z` commit written by Jenkins.
**Check `show --stat` before reverting.** It should touch only `kustomization.yaml`.

### 3. Revert it

```bash
git revert --no-edit <commit>
git push
```

This adds a new commit that puts the previous image tag back. Nothing is erased.

Do **not** use `git reset` and a force-push. That deletes the record of what happened,
breaks other copies of the repo, and is blocked on protected branches anyway.

### 4. Let ArgoCD deploy it, then verify

```bash
argocd app get clearops-dev --refresh | grep -E "Sync Status|Health Status"
sleep 60
kubectl exec -n dev deploy/clearops-api -- python3 -c \
  "import urllib.request;print(urllib.request.urlopen('http://localhost:8080/health').read().decode());print(urllib.request.urlopen('http://localhost:8080/data').read().decode())"
```

**Done when:** Synced to the revert commit, Healthy, `/health` shows the previous version,
and the symptom is gone.

### 5. Ship the real fix forward

Fix the code in [clearops-app](https://github.com/vivianokose/clearops-app) with a `fix:` commit.
Jenkins builds it under a **new** version number. The pipeline refuses to reuse a tag that is
already on Docker Hub, so the fix can never be confused with the bad release.

---

## Break-glass: when git is not an option

Use only if production is down **and** git cannot be changed quickly (GitHub outage, a required
review that cannot be reached in time).

1. Turn off auto-sync for that one app: `argocd app set clearops-dev --sync-policy none`
2. Roll back in the UI: **History and Rollback**, choose the last good revision.
3. **Immediately** make the matching `git revert`, as in steps 2 and 3 above.
4. Once git and the cluster agree, turn auto-sync back on by re-applying the Application file
   from git: `kubectl apply -f argocd/apps/clearops-dev.yaml`

Skipping step 3 means the incident comes back the moment auto-sync is re-enabled.

## Limits: rollback rewinds config, not data

A revert changes which image runs. It cannot undo changes the bad release made to data.
If a release changes a database schema, the migration must be backwards-compatible
(add new columns first, remove old ones only in a later release), or the old code may not
work against the new schema. ClearOps' Redis has no schema, so this did not apply here.

---

## Incident record: 6 November 2026

| Time | Commit (clearops-gitops) | What happened |
|---|---|---|
| 08:53 | `8e52b8d` | 1.1.0 released by Jenkins. `/data` returns 42 records. |
| 09:44 | `d3478e1` | 1.1.1 released. A `fix:` made the record count configurable but the config was never set, so `/data` returned **0 records**. Health checks passed, everything showed green. |
| 09:53 | `b2f5e65` | Rolled back with `git revert`. ArgoCD redeployed 1.1.0 within a minute. 42 records again. |
| 10:04 | `505a6ac` | Real fix released as **1.1.2**. Jenkins found 1.1.1 already published and skipped it. |

**What we learned**

- Green health checks do not mean correct behaviour. The smoke test checks that services
  respond, not that the data is right. A data check on `/data` would have caught this.
- After a rollback, the deployed version goes backwards, so naive version bumping would have
  produced 1.1.1 again: overwriting the bad image on Docker Hub, and letting the cluster reuse
  its cached copy of the bug. The pipeline now never reuses a published tag.
