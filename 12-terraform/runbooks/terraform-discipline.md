# Runbook: Terraform discipline

The habits that separate "I can write Terraform" from "I can be trusted with Terraform."
Written for StackForge, applies anywhere.

## 1. Never change infrastructure by hand
Once a resource is managed by Terraform, the AWS console is read-only for it. Every change
goes through the .tf files and a plan/apply. If you must make an emergency manual change, run
`terraform plan` immediately after to see the drift, then reconcile the code and apply, or
`terraform import` if it is a new resource. Drift is a process failure, not a tool problem.

## 2. The plan gets reviewed before the apply
A pull request that changes infrastructure includes its `terraform plan` output so a colleague
can see exactly what will happen. No surprise applies. In CI, the five checks (fmt, validate,
tflint, tfsec, checkov) run on every PR touching .tf files.

## 3. State is sacred
- Never commit terraform.tfstate or terraform.tfvars to git (.gitignore handles both; gitleaks
  is the backstop).
- State lives in the S3 backend: versioned (roll back a bad state), encrypted (state holds
  secrets in plain text), public access blocked, DynamoDB-locked (no concurrent applies).
- Never hand-edit the state JSON. Use terraform import / state mv / state rm.

## 4. One state per environment
Dev and prod do not share a state file. Separate them by the backend `key` path. Workspaces
are for ephemeral environments, not prod separation.

## 5. Pin versions
Pin the provider (`~> 5.0`) and commit .terraform.lock.hcl. A surprise provider release can
break a clean apply. Pin community module versions too (`version = "20.24.0"`).

## 6. Secrets never in variables if avoidable
tfvars + sensitive = true is the teaching approach. The production upgrade: have Terraform
pull or generate secrets into AWS Secrets Manager so the human-typed secret never exists, and
the value never lands in state in a readable form.

## 7. Prove it with destroy-and-reapply
Periodically destroy and reapply a non-prod environment. If it does not come back identical,
you have drift, unmanaged resources, or a dependency your code does not capture. A setup that
cannot survive the cycle is not really code.

## Teardown order (EKS included)
`terraform destroy` handles dependency order automatically, which is the whole point. For the
state backend itself (which Terraform cannot manage, since it stores Terraform's own state),
delete the S3 bucket and DynamoDB table by hand, and only after everything else is destroyed
and the docs are committed.
