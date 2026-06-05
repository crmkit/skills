---
name: crmkit-connect
description: Connect to a crmkit CRM, authenticate, and load its operating manual - the single source of truth for every endpoint. crmkit is an agent-first CRM driven over plain HTTP, with no UI. Use first, before any other crmkit skill, whenever the user wants to work with contacts, companies, deals, or activities on a crmkit instance.
---

crmkit is an **agent-first CRM** - you (the agent) operate it directly over plain
HTTP; there is no UI. This skill sets the scene: get connected, then **load the
server's operating manual and follow it.** The manual is authoritative - don't
rely on memorized endpoints.

## 1. Base URL

Ask the user for their crmkit **base URL** (e.g. `https://api.crmkit.ai`).

## 2. Load the manual (do this first, every session)

```
GET <base_url>/.well-known/agent.md      # or: GET <base_url>/help
```

It documents every endpoint, the auth flow, query syntax, and conventions.
Re-fetch any time you're unsure.

## 3. Authenticate (once per token)

Per the manual: `POST /auth/request` (emailed code) → `POST /auth/verify` →
bearer token. Send `Authorization: Bearer <token>` on every request and save it.
Export it so the recipe skills' scripts can use it:

```bash
export CRMKIT_BASE_URL=https://api.crmkit.ai
export CRMKIT_TOKEN=ck_...
```

## 4. Then operate

Drive the CRM per the manual - plain-text responses by default (grepable),
`Accept: application/json` for JSON. For automated workflows, reach for the
**recipe skills** (e.g. `crmkit-digest`): each is a runnable curl/script recipe
built on top of this connection.

## Good habits

- 4xx errors carry an instructive `hint` - read it and self-correct.
- Records are addressed by stable `kind/id` handles (`contact/c_…`, `deal/d_…`).
- `DELETE` is two-step (confirm token); creating past a plan cap returns
  `plan_limit_reached` (don't retry - tell the user).
