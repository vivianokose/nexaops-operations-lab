# Infrastructure Log — nexaops-operations-lab

The per-module record of what was built, where, and what happened to it. This is the
detailed history that used to live in the Project instructions. It is kept here so the
live instructions stay short, and so any future session can read the full picture when a
specific module is in play.

Read this file when picking a module back up, resuming cloud work, or reproducing
something. The live instructions carry only the current cloud arrangement and a pointer
here.

Repo: nexaops-operations-lab (github.com/vivianokose/nexaops-operations-lab)
Active container registry: Docker Hub (vivianokose). The Module 6 Nexus registry is gone
(its AWS account was suspended).

---

## Current cloud arrangement (the one fact that matters most)

Borrowed-but-authorised AWS account. Not Vivian's own card, so cost discipline is
tighter than usual.
- IAM user: crixtal
- Account: 948102249482
- Region: us-east-1
- Free-tier-restricted: t3.small and t3.micro are allowed; t3.medium is BLOCKED.
- Standing budget alarms left in place: clearops-eks-monthly ($15),
  stackforge-monthly-budget ($5).
- Pattern: spin up at the start of a session, tear down at the end. Nothing is left
  running overnight.

History of earlier arrangements (for context only): the original AWS account was
suspended during Module 8; Module 8 was rebuilt on Linode (since destroyed); Module 9
onward uses the borrowed account above.

---

## Teardown gotchas (hard-won, don't relearn these)

- Delete in REVERSE dependency order. A VPC will not delete while anything still lives
  in it.
- The NAT gateway and its network interface (ENI) must be deleted individually BEFORE
  the VPC will delete. This is what broke the Module 9 teardown on first run.
- A NAT gateway (~$32/month) and a forgotten load balancer (~$16/month) bill around the
  clock whether or not anything uses them. Unattached Elastic IPs bill too.
- `aws s3 rb --force` does NOT empty a versioned bucket. It clears current objects but
  leaves every old version and delete marker, and the bucket refuses to delete while any
  version remains. List and delete the versions and delete markers first, then `rb`.
  (Hit this on the Module 12 Terraform state bucket.)
- For EKS: delete the Ingress FIRST so the controller removes the ALB, confirm the ALB is
  gone, THEN delete the cluster. Otherwise the ALB and its security groups orphan.
- Terraform cannot manage its own state backend, so the S3 state bucket and DynamoDB lock
  table are created and deleted by hand, outside the Terraform run.

---

## Module 5 (Cloud/IaaS, folder 05-cloud-iaas)

Built viviancloud-vpc. The web server (viviancloud-web) has since been TERMINATED and its
Elastic IP released. Nothing from this module is still running.

---

## Module 6 (Nexus, folder 06-nexus) — infra GONE

Dedicated m7i-flex.large EC2 (8GB) with Elastic IP 32.196.216.219, in viviancloud-vpc,
security group nexaops-nexus-sg (ports 22/8081/8082 to my IP). Nexus 3.94 ran as limited
OS user 'nexus' via systemd. Repos: the pre-built Maven set plus npm-hosted, pypi-hosted,
docker-hosted. Published: user-service JAR (Maven) and notification-service (npm) from
Module 4; report-service wheel (PyPI) and report-service Docker image, both built new in
this module. Least-privilege login user: nexaops-deploy. Inventory script at
06-nexus/scripts/nexus-inventory.sh.

Status: the AWS account was suspended, so the Nexus EC2 is gone and unreachable. All
registry work since then uses Docker Hub instead (see Module 8).

---

## Module 7 (Docker/Containers, folder 07-docker) — COMPLETE & PUBLISHED

SwiftMove Node + MySQL app. Multi-stage build 1.11GB -> 133MB; non-root UID 10001;
cosign-signed; pushed to Docker Hub and (at the time) Nexus. Full docs + 18 screenshots,
all published across the standing set.

---

## Module 8 (CI/CD with Jenkins, folder 08-jenkins) — COMPLETE & PUBLISHED, infra DESTROYED

Full Jenkins pipeline on TWO Linode servers (voyageai-jenkins 4GB + voyageai-app 2GB,
Newark). Pipeline: checkout, compute-version (semver from feat:/fix: commit prefix), lint,
test, build & push (via shared library) to Docker Hub, deploy (main only, docker pull+run
over ssh), verify (/health), tag release. Plus: GitHub webhook auto-trigger (firewall
opened only to GitHub's webhook IP ranges), multibranch pipeline with PR status checks, a
shared library (jenkins-shared-lib repo, registered in Jenkins as 'voyageai-lib', function
buildAndPushImage), and a security fix for insecure secret interpolation.

Two SEPARATE repos created this module (both public, correct exceptions to the
everything-in-portfolio rule):
- github.com/vivianokose/voyageai-booking-api (the Node app + its Jenkinsfile)
- github.com/vivianokose/jenkins-shared-lib (the reusable pipeline library)

Docker Hub is the active registry (vivianokose), tags are semver (0.1.0, 0.1.1...).
Jenkins credentials used (IDs): jenkins-deploy-key (SSH), app-server-ip (secret text),
dockerhub-credentials (user+token), github-token (user+PAT, repo + admin:repo_hook).

ALL LINODE INFRA DESTROYED at module end (both servers + voyageai-fw firewall gone). The
pipeline is reproducible from the Jenkinsfile + the disaster-recovery runbook at
08-jenkins/runbooks/jenkins-disaster-recovery.md.

Notes worth keeping: Jenkins needs Java 21 on its own server (Java 17 fails to start with
"minimum required version Java 21").

---

## Module 9 (Cloud Fundamentals on AWS, folder 09-cloud-fundamentals) — COMPLETE, DESTROYED

Built the StackForge architecture on the borrowed AWS account: stackforge-vpc
(10.0.0.0/16) with four subnets across us-east-1a and us-east-1b, internet gateway, one
NAT gateway, S3 gateway endpoint. Three chained security groups (ALB accepts public
HTTP/HTTPS; app servers accept 3000 only from the ALB's SG; database accepts 3306 only
from the app SG, referencing groups rather than IPs). Two EC2 app servers launched with NO
key pair and reached via SSM Session Manager. An ALB across both AZs with /health checks.
RDS MySQL in private subnets, public access off, connected from an app server using the
MariaDB client with --ssl-verify-server-cert (NOT MySQL's --ssl-mode=VERIFY_IDENTITY,
which that client rejects). S3 bucket with versioning on and all public access blocked.
IAM role narrowed from AmazonS3FullAccess to a two-statement policy naming one bucket,
verified by `aws s3 ls` returning AccessDenied. Budget alarm set first, at $5.

The optional Jenkins-deploys-via-SSM-SendCommand lab was DELIBERATELY SKIPPED and
documented as a scope decision (Module 8 already proved automated deployment; rebuilding
Jenkins would have cost hours and money for a variation). The pattern is written up in
09-cloud-fundamentals/retro.md.

ALL AWS RESOURCES DESTROYED at module end. Only the budget alarm was deliberately left.

---

## Module 10 (Container Orchestration with Kubernetes, folder 10-kubernetes) — COMPLETE & PUBLISHED

Ran fully on the two-stage method (subject primer before videos, then all concepts as
concrete problems before any kubectl) and it worked well on a dense subject. Built the
ClearOps three-tier app (frontend, API, Redis) on a LOCAL Minikube cluster in WSL, no
cloud cost. Deployments + Services (frontend NodePort 30080, API and Redis ClusterIP
internal-only), ConfigMap, HPA (2->6 on 60% CPU, proven under load), self-healing (proven
by deleting pods), rolling updates + rollback, Redis as a StatefulSet with a
PersistentVolumeClaim (proven to survive pod deletion where a plain Deployment lost data),
a NetworkPolicy (Redis accepts only app:clearops-api, enforced by kindnet and verified
both directions), packaged the app with BOTH Helm and Kustomize, and a deliberate-break
debug drill. Everything lives in the portfolio repo under 10-kubernetes/ (kept there, NOT
a separate clearops-kubernetes repo, since it's demo material not a reusable artifact).
Cluster deleted at module end.

Kubernetes learnings worth not relearning:
- Build images into Minikube's own docker daemon (eval $(minikube docker-env) then
  DOCKER_BUILDKIT=0 docker build, or minikube image build) with imagePullPolicy: Never.
- A stale months-old Minikube cluster with dozens of pods needed minikube delete first.
- check-yaml pre-commit hook chokes on Helm templates and multi-doc YAML, so it now has
  args:[--allow-multiple-documents] and excludes the chart templates folder.
- rollout undo is a toggle (go back one step, not to the original) and history is finite,
  so the manifest in git is the real source of truth.
- describe|tail hides the Events; use grep -A 15 "Events:".

---

## Module 11 (Managed Kubernetes / EKS, folder 11-eks) — COMPLETE & PUBLISHED, DESTROYED

ClearOps on Amazon EKS. Key lessons worth not relearning:
- Free-tier-restricted account: t3.medium is BLOCKED; t3.small works. The lab's default
  node type had to be changed.
- The lab's k8s version (1.30) was retired; used 1.32 instead. Check available versions
  before running.
- The community EKS module does not grant the creating IAM user cluster access by default
  under the newer EKS access-entry system. Add yourself with create-access-entry +
  AmazonEKSClusterAdminPolicy for the crixtal user.
- Teardown order: delete the Ingress first so the controller removes the ALB, confirm the
  ALB is gone, THEN delete the cluster.

All torn down the same session.

---

## Module 12 (Infrastructure as Code / Terraform, folder 12-terraform) — COMPLETE & PUBLISHED, DESTROYED

Rebuilt the StackForge architecture as Terraform, plus an EKS stack, all on the borrowed
AWS account.
- Remote state backend: S3 bucket stackforge-terraform-state-948102249482 (versioned,
  encrypted, public-blocked) + DynamoDB table stackforge-terraform-locks. Created and
  (at module end) deleted BY HAND, since Terraform cannot manage its own backend.
- StackForge stack (18 resources): VPC 10.0.0.0/16, 4 subnets, IGW, route table, 2 chained
  security groups, 2x t3.micro EC2, RDS MySQL db.t3.micro, S3 bucket. Four own modules
  (networking, compute, database, storage) wired output -> variable.
- EKS stack (52 resources): community VPC + EKS modules, k8s 1.32, 2x t3.small,
  enable_irsa=true, single NAT. Plus a custom app-iam module that builds an IRSA role for
  any pod (cluster + namespace + service account -> role ARN).
- Import and drift both demonstrated.
- CI: .github/workflows/terraform-ci.yml runs fmt, validate, tflint, tfsec (soft_fail),
  checkov (soft_fail) on any PR that touches a .tf file.
- Resilience test passed: destroy -> apply -> identical (73 resources total across both
  stacks), then destroy. Verified clean.

Terraform lessons worth not relearning:
- count breaks when you scale past the number of subnets (index error).
- for_each over not-yet-created resource ARNs fails at plan time; use count instead (only
  the length needs to be known up front).
- DynamoDB lock param is deprecated (use use_lockfile) — harmless warning.
- The EKS community module's inline_policy is deprecated — harmless warning from the
  module's own code.
- State holds secrets in plain text; sensitive=true only hides from output, not from
  state. Protect with an encrypted, access-controlled backend.
- The community EKS module doesn't auto-grant IAM user cluster access under the
  access-entry system (same as Module 11).
- `aws s3 rb --force` does not empty a versioned bucket (see teardown gotchas above).

ALL AWS RESOURCES DESTROYED, state backend deleted by hand, account verified clean.

---

## Separate repos (exceptions to the everything-in-portfolio rule)

- github.com/vivianokose/voyageai-booking-api (Module 8 Node app + its Jenkinsfile)
- github.com/vivianokose/jenkins-shared-lib (Module 8 reusable pipeline library)

Everything else lives inside nexaops-operations-lab under its module folder.
