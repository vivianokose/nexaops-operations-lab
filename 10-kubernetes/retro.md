# Module 9 retro: Cloud Fundamentals on AWS

## What I set out to do
Take a single server running an app, a database, and file storage, and rebuild it as a
production architecture: isolated networking, redundancy across availability zones, a
managed database, least-privilege permissions, and cost controls.

## The honest starting point
I watched the videos and zoned out repeatedly. That had happened before and I had blamed
myself for it, but the pattern was clearer this time: I do not learn from watching. I learn
from a concrete scenario, then building the thing, then explaining it back.

So we changed the method. Every concept started with a specific company with a specific
problem, named the idea plainly, and only then went near the console. Ten concepts before a
single resource existed. That order made the labs feel like confirmation rather than
instruction, which is the opposite of how the previous modules had gone.

Worth recording: I asked for the analogies to be less like storytelling and more grounded in
real scenarios and facts. Then the correction overshot into dense technical detail and I got
more confused, not less. The version that worked was in between, a real situation with real
stakes, explained in plain language. Knowing what I need is a skill in itself and it took
two attempts to describe it accurately.

## What fought me, and what I learned
- **A direct request to an app server timed out**, which was the correct result. The security
  group only admitted the load balancer. Timed out rather than refused is a genuinely useful
  distinction: dropped by a firewall versus reached the machine but nothing listening.
- **The MariaDB client rejected `--ssl-mode=VERIFY_IDENTITY`.** Amazon Linux ships MariaDB,
  not Oracle's MySQL client, and it spells the same option `--ssl-verify-server-cert`.
- **Deleting the VPC failed.** The NAT gateway and its network interface had to be deleted
  individually first. My teardown order was wrong, and finding that out by testing it is
  precisely why runbooks get tested rather than just written.
- **`aws s3 ls` returning AccessDenied was the win, not a bug.** After narrowing the role's
  policy to one named bucket, listing all buckets stopped working. The failure was the proof.

## The thing I want to remember
Least privilege is not a slogan. I had a working setup with a broad S3 policy, then replaced
it with a policy naming one bucket, and watched the blast radius shrink in real time. Two
statements were needed, one for the bucket and one for the objects inside it, which is the
detail most first attempts get wrong.

## Scope decision: the CI/CD stage
The optional lab wires Jenkins to deploy to these instances using SSM Send-Command instead of
SSH. I chose not to build it, and the reasoning is worth recording rather than hiding.

Automated deployment was demonstrated end to end in Module 8, including a full pipeline with
branch conditions, a shared library, and semantic versioning. Rebuilding a Jenkins server
here would have taken hours and added running cost to demonstrate a variation on a capability
already proven. The genuinely new idea is the pattern, and the pattern is this:

Instead of the pipeline connecting to a server over SSH, it calls `aws ssm send-command` with
the instance ID and the commands to run. AWS passes them to the agent already on the
instance. No key stored in the CI system, no inbound port on the server, every deploy logged
in CloudTrail against the identity that triggered it, and it reaches instances in private
subnets. The remaining question is how the pipeline authenticates to AWS, and the correct
answer is OIDC federation for short-lived credentials rather than stored access keys, which
belongs with the infrastructure-as-code module.

## What I would do differently
- Test the teardown order before needing it, not while running it.
- Set up the tight IAM policy from the start rather than starting broad and narrowing. The
  narrowing was a useful exercise once, but it is not the habit I want.

## Where this fits
Everything before this module ran on servers I configured by hand. This is the first module
about the environment those servers live in: what can reach what, what survives a failure,
and who is allowed to do what. Next is Kubernetes, and after that infrastructure as code,
where this whole architecture gets rebuilt from a file rather than from console clicks.
