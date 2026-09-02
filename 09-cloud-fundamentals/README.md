# Module 9: Cloud Fundamentals on AWS

StackForge is a SaaS company with 500 paying customers, and everything runs on one server.
The web app, the MySQL database, and the folder where customer uploads land, all on a single
box with a single public IP. When that server restarted after an update, 500 businesses
could not log in for eleven minutes.

The worse problem was quieter. The login logs showed thousands of automated attempts every
night. Those bots were not just knocking on the app. The database sat at the same address,
one weak password away from every customer record.

This module rebuilds that single server as a real production architecture: isolated
networking, redundancy across two data centres, a managed database that nothing on the
internet can route to, and permissions granted without a single stored credential.

![Architecture](architecture.png)
*The finished architecture. Customers reach only the load balancer; app servers sit behind
it; the database sits in private subnets no internet route reaches.*

## The network

The foundation is a VPC, a private network inside AWS with its own address range. Inside it,
four subnets across two availability zones: a public subnet in each zone for things that
must face customers, and a private subnet in each for things that must not.

The distinction between public and private is worth stating precisely, because it is a
common interview question and it is not a setting. A subnet is public because its route
table contains a route to the internet gateway. The private subnets have no such route, so
the database is not guarded, it is unreachable. Its outbound traffic goes through a NAT
gateway instead, which allows requests out and replies back but permits nothing to initiate
a connection inward.

![VPC created](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/09-cloud-fundamentals/screenshots/m09-aws-002-vpc-created.png)
*The VPC resource map: four subnets across two availability zones, one internet gateway, one
NAT gateway, and a free S3 gateway endpoint.*

![Subnets](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/09-cloud-fundamentals/screenshots/m09-aws-003-subnets-four.png)
*Two public and two private subnets, one pair per availability zone.*

![Route tables](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/09-cloud-fundamentals/screenshots/m09-aws-004-route-tables.png)
*The public route table points 0.0.0.0/0 at the internet gateway. The private one points it
at the NAT gateway instead. That single difference is what public and private mean.*

## Security groups, and why they reference each other

Network position controls what is reachable at all. Security groups control who may talk to
what within that. Three groups form a chain:

- The load balancer accepts HTTP and HTTPS from anywhere. It is the public face.
- The app servers accept port 3000 **only from the load balancer's security group**.
- The database accepts port 3306 **only from the app servers' security group**.

The detail that matters: those rules name security groups, not IP addresses. Add a third app
server tomorrow, or replace a dead one with a different IP, and the database rule still
works, because it grants access to anything wearing the app-server badge. Rules that
hardcode IPs break the first time infrastructure changes, and infrastructure always changes.

![Security groups](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/09-cloud-fundamentals/screenshots/m09-aws-005-security-groups.png)
*Three security groups, each trusting only the tier in front of it.*

I tested this before building the load balancer by trying to reach an app server directly on
port 3000 from my browser. It timed out. Not refused, timed out, meaning the packets were
silently dropped rather than rejected. That distinction is a useful troubleshooting signal:
a timeout usually means a firewall or missing route, a refusal means you reached the machine
but nothing was listening.

## Redundancy and the load balancer

Two app servers, one in each availability zone. Availability zones are physically separate
data centres with independent power and networking, so a failure in one does not touch the
other. Running both servers in the same zone would have been twice the cost for none of the
protection.

The load balancer gives customers a single address and distributes requests between the two
servers. More importantly, it health checks each one every thirty seconds by requesting
`/health`. Three consecutive failures and a server is pulled from rotation automatically.
That is the eleven-minute outage solved without anyone being woken up.

![EC2 instances](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/09-cloud-fundamentals/screenshots/m09-aws-006-ec2-instances-running.png)
*Both app servers running, one per availability zone, launched with no SSH key pair.*

![Healthy targets](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/09-cloud-fundamentals/screenshots/m09-aws-007-target-group-healthy.png)
*Both targets healthy. The load balancer will only send traffic to servers answering
/health.*

![Server A](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/09-cloud-fundamentals/screenshots/m09-aws-008-alb-response-server-a.png)
*A request through the load balancer, served by the first instance.*

![Server B](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/09-cloud-fundamentals/screenshots/m09-aws-009-alb-response-server-b.png)
*A refresh, served by the second. Same URL, different server, and no way to reach either
directly.*

## Permissions without credentials

The app servers need to write files to S3. The obvious approach is to generate AWS access
keys and put them in a config file, and it is the wrong one. That secret then lives on disk,
usually in the repository, on every laptop that cloned it, and in the backups. It does not
expire. Leaked AWS keys in public repositories are among the most common causes of
compromise, and there are bots that do nothing but scan for them.

Instead, an IAM role is attached to the instances. AWS supplies temporary credentials
automatically, rotated without anyone doing anything. There is no secret to leak, nothing to
commit by accident, and nothing to rotate. If the instance is destroyed, the permission dies
with it, unlike a stolen key that still works from anywhere.

I started with the broad AWS-managed S3 policy to get moving, then replaced it with a policy
naming exactly one bucket. Two statements are required, one for actions on the bucket itself
and one for actions on the objects inside it, a distinction that trips up most first
attempts at S3 policies.

![IAM role](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/09-cloud-fundamentals/screenshots/m09-aws-010-iam-role-policy.png)
*The role carrying only what the servers need: SSM management, and read/write on one bucket.*

The verification that mattered was the failure. After the swap, uploading to the named bucket
still worked, and `aws s3 ls` returned AccessDenied, because listing every bucket in the
account was no longer permitted. A compromised app server can now reach one bucket of assets
and nothing else.

## The managed database

The database runs on RDS rather than on an instance I maintain. AWS handles backups,
patching, storage and hardware replacement. There is no SSH into an RDS instance, and that is
the feature rather than a limitation: the shell existed to do maintenance work that is no
longer mine. What you get instead is a stable endpoint, which survives hardware replacement
and failover, so the application reconnects to the same address regardless of what happened
underneath.

It sits in the private subnets with public access disabled and a security group admitting
only the app servers.

![RDS private](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/09-cloud-fundamentals/screenshots/m09-aws-011-rds-private.png)
*The database with public accessibility disabled, placed in the private subnet group.*

## Shell access with zero inbound ports

The app servers were launched with no key pair at all, and their security group has no SSH
rule. Access is through SSM Session Manager instead, where an agent on the instance holds an
outbound connection to AWS, and sessions are delivered back through it.

The consequences are practical. There is no port 22 to scan and no key to store, copy, lose,
or rotate. Authentication is your own IAM identity, so removing someone's AWS access locks
them out of every server at once, and every session is logged in CloudTrail under a real
name rather than "whoever held the key." It also reaches instances in private subnets, which
removes the need for a bastion host entirely.

![Database connection](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/09-cloud-fundamentals/screenshots/m09-aws-012-rds-connect-from-ec2.png)
*A shell on an instance with no SSH key and no open ports, connecting to a private database
over a certificate-verified TLS connection.*

That connection is worth reading as proof of the whole design. My laptop cannot reach that
database at all, no route exists. The app server can, because its security group badge is on
the database's guest list.

One small practical note: Amazon Linux ships the MariaDB client, which uses
`--ssl-verify-server-cert` rather than MySQL's `--ssl-mode=VERIFY_IDENTITY`. Same
intent, different spelling, and an easy few minutes to lose.

## Object storage

Files moved off the app servers' local disks into S3. With two servers, local storage was
already broken: a file uploaded to one was simply absent from the other. Object storage is
shared, durable, and has no capacity to manage.

Versioning is enabled, so an overwrite or delete keeps the previous copy. All four public
access blocks are on. Publicly readable buckets are one of the most famous causes of data
exposure in the industry, and the correct pattern for genuinely public files is a CDN
reading from a sealed bucket rather than opening the bucket itself.

![Bucket settings](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/09-cloud-fundamentals/screenshots/m09-aws-013-s3-bucket-settings.png)
*Versioning on, all public access blocked.*

![Upload via role](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/09-cloud-fundamentals/screenshots/m09-aws-014-s3-upload-via-role.png)
*A file uploaded from an app server with no credentials configured anywhere. The role
supplied them.*

## Cost discipline

Cloud resources bill for existing, not for being used. An idle NAT gateway costs the same as
a busy one, roughly a dollar a day. So the budget alarm was the first thing created in this
module, before any resource existed, and every resource was tagged on creation.

![Billing alarm](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/09-cloud-fundamentals/screenshots/m09-aws-001-billing-alarm.png)
*The budget alarm, created before anything else.*

Teardown is documented in `runbooks/aws-teardown.md`, and the order in it is not
decorative. AWS refuses to delete resources other resources depend on, so the runbook goes in
reverse dependency order. Testing it found a real gap: deleting the VPC failed because the
NAT gateway and its network interface had to go first and individually. An untested teardown
runbook fails at exactly that point in real life too.

## Scope note

The optional CI/CD stage, deploying to these instances from Jenkins via SSM Send-Command,
was left as a documented design rather than built. Automated deployment was demonstrated end
to end in Module 8, and standing up a fresh Jenkins server here would have added hours and
running cost to show a variation on a proven capability. The pattern is recorded in
`retro.md`.

## What this module covers

- VPC design with public and private subnets across two availability zones
- Route tables, internet gateway, and NAT gateway, and what actually makes a subnet public
- Security groups chained by group reference rather than IP address
- An Application Load Balancer with health checks across two zones
- RDS MySQL in private subnets, unreachable from the internet
- IAM roles and least-privilege policies, with no stored credentials
- S3 with versioning and public access blocked
- SSM Session Manager for shell access with zero inbound ports
- Budgets, tagging, and a tested teardown runbook
