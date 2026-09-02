# Runbook: Module 9 AWS teardown

## Purpose
Remove every billable resource created in this module. Order matters: AWS refuses to delete
resources that other resources still depend on, so this runs in reverse dependency order.

## Cost context
The items that actually cost money here:
- NAT gateway, roughly $32/month, charged whether traffic flows or not
- Application Load Balancer, roughly $16/month
- RDS db.t3.micro, free tier eligible, otherwise roughly $12/month
- Unassociated Elastic IPs, charged specifically because they are idle

EC2 t2.micro/t3.micro instances are free tier eligible but still count toward the monthly
hour allowance.

## Steps

### 1. Load balancer
EC2 > Load Balancers > select > Actions > Delete load balancer.

### 2. Target group
EC2 > Target groups > select > Actions > Delete.

### 3. EC2 instances
EC2 > Instances > select all > Instance state > Terminate.
Terminate, not stop. Stopped instances still hold attached resources.

### 4. RDS database
RDS > Databases > select > Actions > Delete.
Untick final snapshot and retain automated backups for a lab database.
Takes several minutes.

### 5. RDS subnet group
RDS > Subnet groups > select > Delete.
Only works once the database is fully deleted.

### 6. S3 bucket
S3 > select bucket > Empty (required first, versioning keeps old copies) > then Delete.

### 7. NAT gateway  ← do this before attempting the VPC
VPC > NAT gateways > select > Actions > Delete NAT gateway.
Billing stops immediately on deletion. Wait 2-3 minutes for the state to reach Deleted, and
for its network interface to release, before attempting the VPC.

This step is the one that failed on the first attempt. The VPC deletion refused because the
NAT gateway and its elastic network interface were still present.

### 8. Elastic IPs
VPC > Elastic IPs > select any unassociated address > Release.
The NAT gateway's address is not released automatically when the gateway is deleted.

### 9. VPC
VPC > Your VPCs > select > Actions > Delete VPC.
The confirmation dialog lists everything going with it: subnets, route tables, internet
gateway, security groups, VPC endpoints. Read that list; it is a useful final inventory.

If it refuses, something is still attached. The dialog names it. Usually an instance not
fully terminated or a NAT gateway not fully deleted.

### 10. IAM
IAM > Roles > delete the EC2 role.
IAM > Policies > delete the custom S3 policy.

### 11. Leave in place
The budget alarm. It costs nothing and is worth keeping on any account.

## Verification
- EC2 > Instances shows no running or stopped instances
- RDS > Databases is empty
- VPC > Your VPCs shows only the default VPC
- VPC > Elastic IPs is empty
- Billing > Cost Explorer shows charges flattening over the following day
