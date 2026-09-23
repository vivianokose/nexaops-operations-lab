# Module 11: ClearOps on EKS

Deploying the ClearOps 3 tier app (frontend, API, Redis) to a real AWS EKS cluster. Module 10 covered the same app on Minikube. This module moves it to production style infrastructure: managed nodes, a real load balancer, per pod IAM identity, encrypted secrets, and a serverless compute lane for batch work.

## What this module proves

- A working EKS cluster with OIDC enabled, the identity layer everything else depends on
- An AWS Load Balancer Controller that turns a Kubernetes Ingress into a real internet facing ALB
- IRSA (IAM Roles for Service Accounts): pods getting their own scoped AWS permissions with no access keys stored anywhere
- External Secrets Operator (ESO) pulling a secret from AWS Secrets Manager into the cluster, so the real value never touches git
- A Fargate profile running a pod with no EC2 node involved at all
- A full, verified teardown, so nothing keeps billing after the session ends

## Architecture

See `architecture.png`. In short:

- Two `t3.small` nodes run the frontend, API, and Redis
- The Ingress creates an ALB that routes `/` to the frontend and `/api` to the API
- `clearops-api` runs under its own IRSA identity (`clearops-api-sa`) with read only access to one S3 bucket
- ESO runs under its own IRSA identity (`eso-sa`) and syncs a database password from Secrets Manager into a normal Kubernetes Secret
- A Fargate profile (`fp-batch`) runs any pod in the `batch` namespace on AWS managed infrastructure, no node of ours involved

## Prerequisites

- AWS CLI v2, authenticated (`aws sts get-caller-identity`)
- `eksctl`, `kubectl`, `helm`
- Docker images for `clearops-api` and `clearops-frontend` already built and pushed to ECR
- A budget alarm in place before creating anything (this account is free tier restricted; only `t3.micro` and `t3.small` are allowed, not `t3.medium`)

## How to reproduce

1. **Cluster**: apply `eksctl.yaml` with `eksctl create cluster -f eksctl.yaml`, then confirm both nodes are `Ready` and the OIDC provider is registered in IAM (`aws iam list-open-id-connect-providers`).
2. **ALB Controller**: create the IAM policy from the AWS Load Balancer Controller repo, wire it to an IRSA service account with `eksctl create iamserviceaccount`, then install with Helm.
3. **Manifests**: copy the Minikube manifests into `k8s-eks/`, point the images at ECR, drop `imagePullPolicy: Never`, and swap the frontend Service from NodePort to ClusterIP plus an ALB Ingress.
4. **Deploy**: `kubectl apply -f k8s-eks/...` in order (namespace, redis, api, frontend), then wait for the Ingress `ADDRESS` to populate.
5. **IRSA for the app**: create a scoped S3 read policy, an IRSA service account for the API, and patch the deployment to use it.
6. **Secrets**: store a value in Secrets Manager, install ESO, give ESO its own IRSA identity, then create a `ClusterSecretStore` and an `ExternalSecret` that syncs the value in.
7. **Fargate**: create a Fargate profile targeting a namespace, run any pod there, and confirm it lands on a `fargate-` node rather than one of the EC2 nodes.
8. **Teardown**: see `runbooks/eks-teardown.md`. Do this in the same session you did the work in.

## Cost notes

Everything here bills while it exists: the EKS control plane, two `t3.small` nodes, the NAT gateway, and the ALB. None of it is expensive for a short session, but none of it is free either. A `$15` monthly budget alarm was set before cluster creation, and the full teardown in Step 8 was run and verified the same day.

## Two real gotchas hit during this build

- **IAM policy pinned to an old controller version.** The AWS Load Balancer Controller IAM policy JSON was pulled from a `v2.7.2` tag, but the Helm chart installed a newer controller (`v3.5.0`). The newer controller calls `elasticloadbalancing:DescribeListenerAttributes`, an action the older policy never granted. Result: the ALB got stuck with no `ADDRESS` and the Ingress events showed a clear `AccessDenied`. Fix: pull the policy from `main` instead of a pinned tag, add it as a new IAM policy version, and restart the controller pods.
- **ESO's `ClusterSecretStore` API version had moved on.** The install instructions used `external-secrets.io/v1beta1`, which the CRD still lists but no longer serves (`served: false`). Kubernetes rejected the apply with a "no matches for kind" error that looked like a missing CRD, when the CRD was actually installed and fine. Fix: check `served: true/false` per version on the CRD directly, then switch to `v1`.

Full detail and reflection on both in `retro.md`.

## Repo layout

```
11-eks/
├── README.md
├── architecture.png
├── retro.md
├── runbooks/
│   └── eks-teardown.md
├── k8s-eks/            # manifests adapted for EKS
├── eksctl.yaml          # cluster config
└── screenshots/         # the 11 screenshots for this module
```
