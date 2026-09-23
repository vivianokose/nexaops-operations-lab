# Retro: Module 11, ClearOps on EKS

## The short version

I took ClearOps from Minikube to a real EKS cluster. Same three services, frontend, API, and Redis, but now behind a real load balancer, with pods that carry their own AWS identity, secrets that never touch git, and a batch job that ran without a single EC2 node backing it. Then I tore all of it down and checked the receipts.

## What actually clicked this time

IRSA stopped being a concept I could recite and became something I could point at. Running `sts get-caller-identity` from inside a pod and getting back an assumed role ARN, not a node role, not a stored key, was the moment it landed. The pod is not borrowing permissions from anything. It has its own identity, granted by AWS, verified through a token Kubernetes mounted for it. No secret sitting in an environment variable waiting to leak.

That is not a small thing coming from a lab background. Every reagent, every sample, has a chain of custody. You know exactly what touched what and when. IRSA gives you the same thing for permissions: this pod, this role, this narrow set of actions, nothing implied or inherited.

## Two things broke, and both taught me more than the parts that worked

**The ALB sat with no address for eight minutes, and the fix was a version mismatch, not a broken trust policy.**

I pulled the IAM policy for the AWS Load Balancer Controller from a `v2.7.2` tag, because that is what the reference instructions pointed to. The Helm chart installed the current controller, `v3.5.0`. The newer controller calls an API action the older policy never granted. The result was not a crash. The controller ran fine, the pods were healthy, and it just quietly failed every attempt to build the load balancer with an `AccessDenied` on `DescribeListenerAttributes`.

Nothing about the identity was wrong. The role assumed correctly, the trust policy was fine, IRSA was doing its job. The permissions attached to that identity were just stale. It is a good reminder that a working identity and a correct identity are not the same thing, and that pinned versions age quietly until something downstream needs a permission that was not there yet when the file was written.

**ESO rejected a manifest with an error that looked like a missing CRD, when the CRD was already installed.**

`no matches for kind "ClusterSecretStore" in version "external-secrets.io/v1beta1"` reads like the CRDs never installed. They had. `kubectl get crds` showed all of them, right there. The actual issue was narrower: that CRD still lists `v1beta1` as a known version, but it is not served anymore. `v1` is what the API server actually accepts now.

The lesson is to check `served: true/false` on the specific version before assuming a resource is missing entirely. An error message pointing at "CRDs" can really mean "this specific version of this CRD," which is a much smaller and faster fix once you know to look there.

## On the app itself

The API returned `{"error": "not found"}` for `/api/health` even though the app was healthy. Turned out the Ingress forwards the full path unchanged, so the app received `/api/health` literally, a path it never defined. It only knows `/health` and `/data` at the root. Nothing was broken. It was just two systems agreeing on a name but not agreeing on where the prefix gets stripped. Worth remembering for the next Ingress: decide up front whether the app or the routing layer owns the prefix, and be explicit about it either way.

## Teardown

Order mattered more than I expected going in. Deleting the Ingress first, before touching the cluster, let the ALB controller actually clean up the load balancer it created. Deleting the cluster first would have removed the only thing capable of tearing that ALB down, and it would have kept billing with nothing left to manage it. I confirmed the ALB list was empty before moving on, and did the same check again after the cluster delete finished: EKS cluster list empty, NAT gateway list empty, load balancer list empty. Also had to remember that a policy with more than one version cannot be deleted directly; each extra version has to go first. Small thing, but the kind of thing that leaves an orphaned resource behind if you skip it.

## What I'd do differently next time

Pull IAM policies for third party controllers from `main`, not a pinned tag, unless I have a specific reason to match an older controller version. And when a "kind not found" or "resource mapping not found" error shows up for something I can see is installed, check served versions on the CRD before assuming anything is missing.
