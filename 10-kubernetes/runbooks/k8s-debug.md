# Runbook: debugging a broken pod

The sequence to follow when a pod is not healthy. The order matters: each step narrows
down where the problem is before the next. Most problems are identified by step 2.

## The one-line principle

The pod STATUS tells you the category of failure. The `describe` Events tell you the
specific cause. Logs only help once a container has actually started. Match the tool to
the failure rather than running all of them blindly.

## The sequence

### 1. Look at the pods

```bash
kubectl get pods -n <namespace>
```

Read three columns: STATUS, READY, and RESTARTS. A climbing RESTARTS count means
something is failing repeatedly even when the status momentarily looks calm. READY of
`0/1` on a `Running` pod means the container started but is not passing its readiness
probe.

### 2. Describe the pod and read the Events

```bash
kubectl describe pod <pod-name> -n <namespace>
```

The Events section is at the very bottom. This is the highest-value step and the one
beginners skip. Do not use `tail`, the Volumes and Tolerations boilerplate sits below the
Events; grep for them instead:

```bash
kubectl describe pod <pod-name> -n <namespace> | grep -A 15 "Events:"
```

Events state the actual cause: image not found, probe failing, scheduler could not place
the pod, credentials rejected.

### 3. Read the logs

```bash
kubectl logs <pod-name> -n <namespace>
kubectl logs <pod-name> --previous -n <namespace>
```

The app's own output. `--previous` is essential for a crash loop: the current container
just started with empty logs, so the useful output belongs to the container that died.
Note: if the container never started (ImagePullBackOff), there are no logs at all, this
step does not apply.

### 4. Get a shell inside the container

```bash
kubectl exec -it <pod-name> -n <namespace> -- /bin/sh
```

For when the pod is running but behaving wrong. Check what files exist, whether it can
reach another service, what environment variables are actually set.

### 5. Check the deployment

```bash
kubectl get deploy <name> -n <namespace> -o yaml
```

Confirms the spec Kubernetes is actually running matches what you think you applied.

### 6. Check the service and its endpoints

```bash
kubectl get svc <name> -n <namespace>
kubectl get endpoints <name> -n <namespace>
```

If a service is unreachable but the pods are healthy, check its endpoints. An empty
endpoint list almost always means the service's selector does not match the pods' labels.
That label mismatch is the single most common "service exists but nothing can reach it"
cause.

### 7. Check the node

```bash
kubectl describe node <node-name>
```

For `Pending` pods that never schedule: the node may be out of allocatable CPU or memory
to satisfy the pod's resource requests.

## Common statuses and what they mean

- **Pending** , not yet placed on a node. Usually no node has enough free CPU/memory for
  the pod's requests. Check node capacity (step 7).
- **ImagePullBackOff / ErrImageNeverPull** , the image could not be pulled. Wrong name,
  wrong tag, missing registry credentials, or (with pullPolicy Never) the image is not
  present locally. Events name it (step 2). No logs to read.
- **CrashLoopBackOff** , the container starts, dies, restarts, repeatedly, with Kubernetes
  waiting longer between attempts. The application is failing. Read the logs, including
  `--previous` (step 3).
- **OOMKilled** , the container exceeded its memory limit and was killed. Raise the limit
  or fix the leak. (CPU over-limit throttles; memory over-limit kills.)
- **Running but 0/1 READY** , the container is up but failing its readiness probe. Either
  the app is not ready yet, or the probe is misconfigured (wrong path or port). Events
  show the probe failures (step 2).

## Worked example from this module

Set the deployment to a non-existent image:

```
Warning  ErrImageNeverPull  Container image "clearops-api:does-not-exist" is not present
                            with pull policy of Never
Warning  Failed             Error: ErrImageNeverPull
```

STATUS was `ErrImageNeverPull`, and step 2's Events gave the exact cause in one line.
Fixed with `kubectl rollout undo`.
