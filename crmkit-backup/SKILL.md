---
name: crmkit-backup
description: Export an entire crmkit workspace to JSON with a paging script - contacts, companies, deals, and activities. Use for backups, data portability, offsite archives, or before a risky bulk change. Cron-able.
---

A runnable recipe: snapshot the whole CRM to JSON files. Needs `CRMKIT_BASE_URL`
and a `CRMKIT_TOKEN` (a crmkit bearer token - get one via the email login:
`POST /auth/request` → `POST /auth/verify`).

## What it does

Pages through each collection with crmkit's keyset cursor (so it captures
everything, not just the first page) and writes one JSON array per entity:

```
crmkit-backup-20260605-1400/
  contacts.json   companies.json   deals.json   activities.json
```

Requires `curl` and `jq`. The script lives beside this file as `backup.sh`.

## Run it

```bash
export CRMKIT_BASE_URL=https://api.crmkit.ai
export CRMKIT_TOKEN=ck_...        # a crmkit bearer token (POST /auth/verify)
./backup.sh                       # -> ./crmkit-backup-<timestamp>/
./backup.sh /backups/crmkit       # or pick the output dir
```

## Automate / adapt it

- **Cron** a nightly backup, then sync the folder to S3/Backblaze/etc.:
  ```cron
  30 2 * * *  CRMKIT_BASE_URL=… CRMKIT_TOKEN=… /path/backup.sh /backups/crmkit-$(date +\%F)
  ```
- Pipe a JSON file through `jq -r` to make a CSV for a spreadsheet.
- Scope the workspace by using a token minted for it (see the manual's workspace
  tokens). Activities are pulled up to the server's max page; widen if needed.
