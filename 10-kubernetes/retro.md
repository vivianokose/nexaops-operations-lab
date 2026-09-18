# Module 10 retro: Kubernetes

## What I set out to do
Take three services running as bare containers on one VM and rebuild them on Kubernetes:
self-healing, autoscaling, correct exposure per tier, config and secrets, persistent
storage, network isolation, and packaging. Then learn to debug it when it breaks.

## The approach that worked
This was the first module run fully on the two-stage method: a primer on Kubernetes as a
subject before I touched any videos or labs, then all nineteen concepts taught as concrete
problems before a single kubectl command. By the time I was applying manifests I was
confirming things I already understood rather than following steps I did not. For a subject
as dense as Kubernetes that ordering was the difference between it landing and washing over
me.

I also asked for and got a change of register partway through an earlier module that carried
into this one: real scenarios with real stakes, explained plainly, rather than either
whimsical stories or dense syntax up front. A couple of concepts (the cluster DNS one
especially) I had to ask to have re-explained from a different angle, and saying so rather
than nodding along is what got them to stick.

## What fought me, and what I learned
- **A stale cluster from months ago.** Minikube found an old cluster with 40+ pods from a
  tutorial I had forgotten, all fighting over 2 CPUs. `minikube delete` and start fresh.
  Lesson: local clusters persist, and a crowded one will starve new work.
- **buildkit failing inside Minikube's Docker.** My local Docker has a buildx builder that
  Minikube's plainer daemon does not. `DOCKER_BUILDKIT=0` or `minikube image build` both
  sidestep it. Worth knowing that "point docker at Minikube" changes which daemon you are
  really talking to.
- **rollout undo is a toggle, not a reset.** I ran it twice and bounced back to the broken
  version. `undo` means "go back one step from here," and rollback history is finite, so a
  good revision can age out. The real fix was to reapply the manifest from git. That is the
  actual lesson: the file in git is the source of truth, not the cluster's revision memory.
- **A NetworkPolicy that actually enforced.** I expected kindnet to ignore it (some plugins
  do), which would have looked identical to a working policy. It enforced, and I verified
  both directions, blocked for an unrelated pod, allowed for the API. A policy you have not
  tested from both sides is a guess.
- **A laptop reboot mid-lab.** The Minikube container stopped and kubectl threw connection
  refused. `minikube start` brought the whole cluster back, same pods, same volume, same
  policy. A reboot with everything in manifests is a non-event, which is the entire promise
  of declarative infrastructure, felt rather than read.
- **describe | tail hides the Events.** The Events section is at the bottom of describe, but
  so is a screen of Volumes and Tolerations boilerplate. `grep -A 15 "Events:"` is the move.
  Reading Events first is the single highest-value debugging habit and the one I had to
  train myself not to scroll past.

## The thing I want to remember
The whole system is one idea repeated: declare the desired state, and a control loop keeps
reality matching it. Self-healing, autoscaling, rolling updates, rollback, even recovery
after a reboot are all the same loop noticing a gap and closing it. Once that clicked, the
individual features stopped being separate things to memorise.

## How this connects to the rest
Module 9 built redundancy, load balancing, and health checks by hand on AWS, two servers, a
load balancer, security groups. This module does all of that as a few lines of YAML each,
and I understood why because I had done the manual version first. The three-tier isolation
here is the same instinct as the chained security groups there, enforced by labels instead
of IPs. Next is managed Kubernetes, where a cloud provider runs the control plane and
everything I wrote here applies unchanged.

## What I would do differently
- Delete stale local clusters before starting, not after hitting resource pressure.
- Reach for `describe` Events first when debugging, before logs, every time. It is faster
  and it is usually enough.
