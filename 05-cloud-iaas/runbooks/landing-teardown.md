# Teardown Runbook: Module 5 Cloud Infrastructure

> Run this when you are done with the module, or pausing for a long time.
> Removing everything stops all charges. Work top to bottom; order matters.

## What exists (the inventory)

| Resource | Name / ID | Why it costs |
|----------|-----------|--------------|
| EC2 instance | viviancloud-web | Compute, while running |
| Boot disk (EBS) | 8 GB, attached to instance | Storage, even when stopped |
| Data disk (EBS) | 1 GB, mounted at /mnt/data | Storage, even when stopped |
| Elastic IP | 100.60.235.84 | Free while attached to running instance; charges when unattached |
| Snapshot | boot disk, "before key recovery drill" | Storage, while it exists |
| Security group | viviancloud-sg | Free |
| VPC + subnet + gateway | viviancloud-vpc | Free |
| Key pair | viviancloud-key | Free (but keep the .pem safe) |
| Billing alarm | billing-over-5-usd | Free |
| DNS record | app.viviancloud.site (at Namecheap) | Part of the domain you already own |

## PAUSING (keep it, stop the charges)

If you are only pausing and will return:

1. EC2 -> Instances -> viviancloud-web -> Instance state -> Stop.
   Compute charge stops. Disks and snapshot keep a small charge. Elastic IP stays free
   because it is still associated with the (stopped) instance.

That is all. Everything survives. To resume: start the instance, and if SSH times out,
check your home IP (curl -s https://checkip.amazonaws.com) and update the SSH rule in
viviancloud-sg.

## FULL TEARDOWN (remove everything, order matters)

### 1. Terminate the instance
EC2 -> Instances -> viviancloud-web -> Instance state -> Terminate.
This deletes the instance. By default it also deletes the attached boot disk.
Confirm the data disk's "delete on termination" setting: if it is NOT set to delete,
you must remove it manually in step 2.

### 2. Delete any leftover EBS volumes
EC2 -> Volumes. Delete any volume still showing "Available" (the 1 GB data disk may
remain if it was not set to delete on termination).
Actions -> Delete volume.

### 3. Delete the snapshot
EC2 -> Snapshots. Select the "before key recovery drill" snapshot -> Actions -> Delete.

### 4. Release the Elastic IP  (IMPORTANT - this one bills when unattached)
EC2 -> Elastic IPs -> select 100.60.235.84 -> Actions -> Release Elastic IP address.
Once the instance is gone, this IP is unattached and WILL start charging. Release it.

### 5. Remove the DNS record (at Namecheap)
Namecheap -> Domain List -> viviancloud.site -> Advanced DNS.
Delete the A record: app -> 100.60.235.84.
Leave the GitHub records (@ and www) alone; those run your portfolio site.

### 6. (Optional) Delete the custom VPC
Only if you want a full clean-up. VPC console -> Your VPCs -> viviancloud-vpc ->
Actions -> Delete VPC (this also removes its subnet, gateway, route table).
The security group goes with it. Skip this if you plan to launch here again soon.

### 7. Keep these
- Key pair viviancloud-key: harmless to keep; keep the .pem file backed up regardless.
- Billing alarm: free; leave it as a permanent safety net.
- IAM user, MFA, root lockdown: permanent account hygiene, never undo.

## Verify nothing is left billing
EC2 -> Instances (none running), Volumes (none), Snapshots (none),
Elastic IPs (none). Then check Billing -> Bills after a day to confirm $0 ongoing.

## The rule
Build carefully, tear down completely. A resource you forget is a resource you pay for.
