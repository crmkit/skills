---
name: crmkit-inbox-sync
description: Keep crmkit current by turning recent emails into logged activities - read the inbox with your email tool, match senders to contacts, and log a short summary against each. Use when the user wants to sync email activity to the CRM or bring interaction history up to date. Requires an email/Gmail tool available to the agent.
---

A recipe that combines your **email tool** with crmkit: scan recent mail and log
each meaningful thread as an activity on the right contact. Needs
`CRMKIT_BASE_URL` and a `CRMKIT_TOKEN` (a crmkit bearer token - get one via the
email login: `POST /auth/request` → `POST /auth/verify`).

This one is agent-driven (the inbox read happens through your email/Gmail tool,
not curl), with a small helper script for the crmkit side.

## Workflow

1. **Read recent mail** with your email tool (sent + received, e.g. the last 7
   days). Group by thread/contact.
2. **Match** each correspondent's address to a crmkit contact (the helper does
   this - it looks up `/contacts?email=…`). Skip addresses with no contact, or
   capture them first with `POST /contacts`.
3. **Summarize** each thread in one line: topic + outcome + next step. Do **not**
   copy full bodies.
4. **Log** an activity (`kind: email`) against the contact - run the helper, or
   POST directly per the manual.
5. **Skip duplicates**: don't re-log a thread already captured; prefer the most
   recent meaningful exchange per contact.

## Helper

`log-interaction.sh <email> <kind> <summary>` finds the contact by email and logs
the activity (no-op if there's no match):

```bash
export CRMKIT_BASE_URL=https://api.crmkit.ai CRMKIT_TOKEN=ck_...
./log-interaction.sh jane@acme.com email "Re: pricing - sent proposal, awaiting reply by Fri"
```

Requires `curl` and `jq`.

## Privacy

| Do                                                 | Don't                                     |
| -------------------------------------------------- | ----------------------------------------- |
| Log a one-line summary (topic, outcome, next step) | Store full email bodies or attachments    |
| Set a follow-up if a next step exists              | Log every trivial auto-reply / newsletter |
| Skip addresses with no matching contact            | Create contacts silently - confirm first  |
