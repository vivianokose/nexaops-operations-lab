# Runbook: Postgres Backup and Restore

> How to back up a Postgres database and restore it after a disaster. Drilled and verified, not theoretical.

## The rule this exists for
A backup you have never restored is a wish, not a backup. This procedure has been tested end to end: database destroyed on purpose, restored from dump, row counts verified.

## Measured recovery time
- Dataset: 3 authors, 3 posts (small dev seed data)
- Backup size: 8.2K (custom format)
- **Restore completed in 47 seconds** (includes recreating the empty database)
- Real restores scale with data size. The process is proven; the timing is a floor, not a ceiling.

## Environment
- Postgres 16 (alpine) running in Docker via compose
- Database: lumberyard_dev, user: lumberyard
- Stack lives in 04-databases/labs/lab-01-stack

---

## PART 1: Taking a backup

### 1. Count the rows first (your proof-of-truth)
    docker compose exec postgres psql -U lumberyard -d lumberyard_dev \
      -c "SELECT (SELECT COUNT(*) FROM authors) AS authors, (SELECT COUNT(*) FROM posts) AS posts;"

Write these numbers down. After restore they MUST match exactly.

### 2. Dump the database
    docker compose -f ../lab-01-stack/compose.yaml exec -T postgres \
      pg_dump -U lumberyard -Fc lumberyard_dev > backups/lumberyard_$(date +%Y%m%d_%H%M%S).dump

- `-Fc` = custom format (compressed, flexible, restorable selectively)
- `-T` = no TTY, so the output pipes cleanly to a file
- The `$(date ...)` timestamps the filename automatically

### 3. VERIFY THE BACKUP IS REAL
    ls -lh backups/

A zero-byte file means the backup FAILED. Always check the size. This is the single most common silent failure.

---

## PART 2: Restoring after a disaster

### 1. Start the clock
    START=$(date +%s)

### 2. Recreate the empty database
    docker compose -f ../lab-01-stack/compose.yaml exec -T postgres \
      psql -U lumberyard -d postgres -c "CREATE DATABASE lumberyard_dev;"

pg_restore needs an existing empty database to restore INTO. It will not create one for you.

### 3. Restore from the dump
    cat backups/lumberyard_*.dump | docker compose -f ../lab-01-stack/compose.yaml exec -T postgres \
      pg_restore -U lumberyard -d lumberyard_dev

### 4. Stop the clock
    END=$(date +%s); echo "Restore took $((END-START)) seconds"

### 5. VERIFY the data came back
    docker compose -f ../lab-01-stack/compose.yaml exec -T postgres psql -U lumberyard -d lumberyard_dev \
      -c "SELECT (SELECT COUNT(*) FROM authors) AS authors, (SELECT COUNT(*) FROM posts) AS posts;"

Compare to the numbers from Part 1, Step 1. If they do not match, the restore is INCOMPLETE. Do not declare victory on "no errors" alone; verify counts.

---

## Gotchas I hit (and you will too)
- **DROP DATABASE fails if anyone is connected.** Use `WITH (FORCE)` to kick off active connections first.
- **You cannot drop or create a database you are connected to.** Connect to the default `postgres` database to issue those commands.
- **pg_restore needs the target database to already exist.** Create it empty first, or the restore errors immediately.
- **Never trust a backup you have not restored.** The whole point of this drill.
- **Check the dump file size.** An 0-byte dump is a silent, catastrophic failure that only surfaces during a real incident.

## Verification checklist
- [ ] Backup file exists and is non-zero
- [ ] Row counts recorded before backup
- [ ] Restore completes without errors
- [ ] Row counts after restore match exactly
- [ ] Restore time recorded

## Date drilled
2026-07-16
