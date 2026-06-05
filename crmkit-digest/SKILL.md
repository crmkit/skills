---
name: crmkit-digest
description: Generate a one-screen crmkit briefing - follow-ups due/overdue, open pipeline, and recent activity - with a small curl script you can run on demand or cron. Use when the user wants a daily/weekly standup, a pipeline snapshot, or a "what needs attention" digest from their crmkit CRM.
---

A runnable recipe: one command turns crmkit into a daily briefing. It reads
`CRMKIT_BASE_URL` and a `CRMKIT_TOKEN` (a crmkit bearer token - get one via the
email login: `POST /auth/request` → `POST /auth/verify`).

## What it does

Pulls three things and prints them as a digest:

- **Follow-ups due/overdue** (`/reminders`) - what needs attention now
- **Open pipeline** (`/deals?status=open`) - biggest deals first
- **Recent activity** (`/activities`) - what's been logged lately

crmkit responses are plain-text and grepable by design, so the script is tiny and
needs no JSON tooling.

## Run it

```bash
export CRMKIT_BASE_URL=https://api.crmkit.ai
export CRMKIT_TOKEN=ck_...        # a crmkit bearer token (POST /auth/verify)
./digest.sh
```

## Automate it

- **Cron** a weekday-morning digest, emailed to you:
  ```cron
  0 8 * * 1-5  CRMKIT_BASE_URL=https://api.crmkit.ai CRMKIT_TOKEN=ck_… /path/to/digest.sh | mail -s "crmkit digest" you@co.com
  ```
- **Slack/Discord**: pipe the output into a webhook post.
- **Ad-hoc**: the agent can run it with its shell tool whenever the user asks
  "what's on today?".

## Adapt it

Change the limits/windows, add a "closing this week" section (filter deals by
`follow_up_at`), or group differently - see the manual (`GET /help`) for
query filters and `sort`. Keep it plain-text in, plain-text out. The script lives
beside this file as `digest.sh`.
