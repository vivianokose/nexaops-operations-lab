# Cost Report: Module 5 Cloud Infrastructure

## What I ran
A single-instance web server setup on AWS, in us-east-1 (N. Virginia):
a t3.micro EC2 instance, an 8 GB boot disk, a 1 GB data disk, one Elastic IP,
one snapshot, plus a custom VPC, security group, and a billing alarm.

## What it cost

| Service | What I used | Cost |
|---------|-------------|------|
| EC2 (t3.micro) | A handful of hours across several sessions | $0.00 (free tier: 750 hrs/month) |
| EBS storage | 8 GB boot + 1 GB data | $0.00 (free tier: 30 GB/month) |
| EBS snapshot | one small boot-disk snapshot | ~$0.00 (covered) |
| Elastic IP | attached to the running instance | $0.00 (free while attached) |
| Data transfer | minimal | $0.00 (free tier: 100 GB/month) |
| VPC, security group, billing alarm | networking and monitoring | $0.00 (always free) |
| **Total** | | **$0.00** |

Confirmed against the AWS Bills page: estimated grand total USD 0.00 for the period.

## Why it stayed at zero
Two habits did the work:
1. I stopped the instance between sessions, so it was not billing compute while idle.
2. I stayed on free-tier-eligible resources (t3.micro, small gp3 volumes) and well
   under every free-tier limit.

## How to avoid surprise bills

**Stop the instance when not working.** A running instance bills per hour whether or
not anyone uses it. Stopping it pauses the compute charge. This is the single biggest
lever.

**A stopped instance still costs a little.** Its EBS disks keep billing for storage even
while the instance is off. It is small (cents), but it is not zero. Full teardown is the
only way to reach truly zero.

**The Elastic IP is the backwards one.** It is free while attached to a running instance,
but it starts charging the moment it is unattached (for example, right after you
terminate the instance but before you release the IP). Always release the Elastic IP as
part of teardown.

**Snapshots bill while they exist.** Delete them when the backup is no longer needed.

**Set a billing alarm.** I set one to email me if estimated charges cross $5. It is a
tripwire, so a forgotten resource cannot quietly run up a bill unnoticed.

**Know your teardown.** I wrote a teardown runbook listing every resource and how to
remove it, in order, so nothing lingers billing after I am done.

## The rule
The scary AWS bills do not come from a busy week of careful work. They come from
forgetting a resource for three months. Stop what you are not using, release what you
no longer need, and keep a tripwire set.
