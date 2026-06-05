---
name: crmkit-import
description: Bulk-import contacts (and their companies) into crmkit from a CSV file, with a small curl script. Idempotent - safe to re-run. Use when the user wants to load a list of leads/contacts, migrate from another CRM or spreadsheet, or onboard a batch of people.
---

A runnable recipe: turn a CSV into crmkit contacts and companies in one command.
Needs `CRMKIT_BASE_URL` and a `CRMKIT_TOKEN` (a crmkit bearer token - get one via
the email login: `POST /auth/request` → `POST /auth/verify`).

## What it does

Reads a CSV and, per row, upserts the company (by domain) then the contact (by
email), linking them. Because crmkit upserts on email/domain, **re-running is
safe** - it updates instead of duplicating. Reports created vs updated counts.

CSV columns (header row required; extra columns ignored):

```
name,email,phone,company,domain,stage
Jane Doe,jane@acme.com,+1 555 0100,ACME Inc,acme.com,lead
```

## Run it

```bash
export CRMKIT_BASE_URL=https://api.crmkit.ai
export CRMKIT_TOKEN=ck_...        # a crmkit bearer token (POST /auth/verify)
./import.sh contacts.csv
# -> done: 42 created, 8 updated, 30 company upserts, 1 skipped
```

Requires `curl` and `jq`. The script lives beside this file as `import.sh`.

## Automate / adapt it

- Re-run the same file after edits - upserts make it a sync, not a one-shot.
- Export from another CRM to this column layout, or tweak the `jq` body builder to
  map your columns / push extras into the `custom` object.
- For messy CSVs (embedded commas/quotes), pre-clean with a real CSV tool and
  feed the simple form in.
- Mind plan limits: a huge import can hit `plan_limit_reached` - raise the plan or
  import in batches.
