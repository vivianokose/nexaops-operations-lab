# Module 12 retro: Infrastructure as Code with Terraform

## What I set out to do
Rebuild the StackForge AWS architecture (the one I built by clicking in Module 9) entirely as
Terraform code: remote state, modules, variables, outputs, an EKS cluster, my own reusable
module, import and drift handling, CI policy checks, and the destroy-and-reapply resilience
test. The goal was to stop building infrastructure by hand and start building it as code.

## The approach
Ran on the two-stage method: a Terraform primer before any videos, then all sixteen concepts
as concrete problems before writing a line of HCL. Because I already understood "declare the
desired state, let the tool reconcile" deeply from Kubernetes, most of Terraform landed as the
same idea pointed at the cloud itself. The concepts that needed the most time were the ones
unique to Terraform: state, remote state, and modules.

## What fought me, and what I learned
- **count breaks when you scale past your subnets.** I changed the app server count from 2 to
  3 to see the plan, and got "Invalid index: count.index is 2, list has 2 elements." The
  third instance tried to use a third subnet that did not exist. A real limitation of count
  that the lab's own 2-to-3 exercise does not warn about. The fix in a real design is more
  subnets or a modulo wrap; for the lab, the point was seeing it.
- **The labs' tooling had aged, again.** The DynamoDB-table lock parameter is now deprecated
  in favour of use_lockfile, and the EKS module warned about a deprecated inline_policy inside
  its own code. Both harmless, both the same "labs age, read what the tool tells you" lesson
  from the EKS module's retired Kubernetes version.
- **The free-tier instance limit still applies.** The EKS lab specified t3.medium, which this
  account blocks. I set t3.small from the start this time, pre-empting the failure I hit in
  Module 11 rather than discovering it after a 27-minute build.
- **State holds secrets in plain text.** Seeing the RDS password sitting in the state file
  made concrete why state never goes in git and why the backend must be encrypted. sensitive =
  true only hides a value from screen output, not from state.

## The thing I want to remember
The whole module is one idea: infrastructure you can read, review, reproduce, and reliably
destroy. The clearest proof is destroy-and-reapply giving an identical environment. Every
hand-ordered teardown that failed in earlier modules (the Module 9 VPC delete order, the
Module 11 orphaned-ALB risk) becomes a single terraform destroy that knows the order itself.

## How this connects
Module 9 built this architecture by clicking. Module 11 built EKS with eksctl and a pile of
commands. This module makes both reproducible from files. The EKS cluster that took a whole
saga in Module 11 is one module block here. Next is GitOps with ArgoCD, where a git repo drives
a cluster automatically, the same declarative thread, applied to deployment.

## What I would do differently
- Set instance types to free-tier-eligible from the first draft, not after a failed build.
- Check the provider and module versions the lab specifies against what is current before
  trusting them, the deprecation warnings would have been no surprise.
- Run tfsec/checkov earlier, so the open security group on port 3000 was flagged as a
  conscious accepted risk from the start rather than at the end.
