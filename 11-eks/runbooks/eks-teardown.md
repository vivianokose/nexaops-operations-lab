# Runbook: EKS Teardown (ClearOps, Module 11)

Use this whenever the `clearops-eks` cluster and its supporting resources need to come down cleanly. The order matters. Deleting the cluster before the ALB is gone leaves an orphaned load balancer with nothing left to clean it up, and it keeps billing.

Run every step in the same session the cluster was created in. Do not leave this for later.

## 1. Delete app resources first, especially the Ingress

```bash
kubectl delete ingress --all -n clearops 2>/dev/null || true
kubectl delete namespace clearops 2>/dev/null || true
kubectl delete namespace batch 2>/dev/null || true
```

Deleting the Ingress explicitly gives the ALB controller a clean signal to start deprovisioning the load balancer right away, rather than as a side effect of the namespace delete.

## 2. Confirm the ALB is actually gone before continuing

```bash
aws elbv2 describe-load-balancers --query 'LoadBalancers[].LoadBalancerName' --output text
```

Do not move to step 3 until this returns empty. ALB deprovisioning is not instant. Wait and re-run if it still shows something.

## 3. Remove External Secrets Operator and the Secrets Manager value

```bash
kubectl delete externalsecret --all -A 2>/dev/null || true
kubectl delete clustersecretstore --all 2>/dev/null || true
helm uninstall external-secrets -n external-secrets 2>/dev/null || true
aws secretsmanager delete-secret --secret-id clearops/db-password \
  --force-delete-without-recovery --region $REGION 2>/dev/null || true
```

`--force-delete-without-recovery` skips the normal recovery window. Fine for a lab secret. Be careful with that flag in anything real.

## 4. Delete the cluster

```bash
CLUSTER=clearops-eks
REGION=us-east-1

cd ~/clearops-eks-config
eksctl delete cluster -f eksctl.yaml --wait
```

This removes the control plane, both nodes, the VPC, the NAT gateway, the OIDC provider, the Fargate profile, and every IAM role created through `eksctl create iamserviceaccount` (the ALB controller role, the API's S3 role, ESO's role). Takes 10 to 15 minutes. Let it finish before running anything else against this cluster.

## 5. Clean up what the cluster delete does not touch

Standalone IAM policies, ECR repos, and the S3 bucket are separate objects. They survive the cluster delete.

```bash
REGION=us-east-1
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)

aws ecr delete-repository --repository-name clearops-api --force --region $REGION
aws ecr delete-repository --repository-name clearops-frontend --force --region $REGION

aws s3 rb s3://clearops-dev-$ACCOUNT --force

for P in AWSLoadBalancerControllerIAMPolicy ClearopsS3Read ClearopsESORead; do
  ARN=$(aws iam list-policies --scope Local --query "Policies[?PolicyName=='$P'].Arn" --output text)
  [ -n "$ARN" ] && aws iam delete-policy --policy-arn "$ARN" && echo "deleted $P" || echo "$P not found"
done
```

If a policy has more than one version (for example, after a `create-policy-version` fix), IAM refuses to delete it until every non-default version is removed:

```bash
ARN=arn:aws:iam::<account-id>:policy/<policy-name>

aws iam list-policy-versions --policy-arn $ARN \
  --query 'Versions[?IsDefaultVersion==`false`].VersionId' --output text \
  | tr '\t' '\n' | while read v; do
    aws iam delete-policy-version --policy-arn $ARN --version-id $v
    echo "deleted version $v"
done

aws iam delete-policy --policy-arn $ARN
```

## 6. Verify clean

```bash
aws eks list-clusters --region $REGION --query clusters
aws ec2 describe-nat-gateways --filter Name=tag:Project,Values=clearops --query 'NatGateways[?State!=`deleted`].State' --output text
aws elbv2 describe-load-balancers --query 'LoadBalancers[].LoadBalancerName' --output text
```

All three should come back empty. If any of them do not, track it down before closing the session. Something still returning a result is something still billing.

Leave the budget alarm in place. Check Billing > Cost Explorer the next day to confirm the spend spike ends.
