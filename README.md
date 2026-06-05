<p align="center">
  <img src="https://crmkit.ai/icon-dark.svg" alt="crmkit" width="80" height="80" />
</p>

<h3 align="center">crmkit Skills</h3>

<p align="center">
  Skill definitions that teach an AI agent how to operate a crmkit instance.
</p>

---

## Overview

crmkit is an agent-first CRM with no UI - an AI agent drives it over plain HTTP.
These skills are **runnable recipes** (curl + a small script) that turn the API
into an outcome: a digest, a CSV import, a backup, an inbox sync. Each reads
`CRMKIT_BASE_URL` and a `CRMKIT_TOKEN` (a crmkit bearer token - get one via the
email login `POST /auth/request` → `POST /auth/verify`, or reuse a session from an
MCP connector) and defers to the server's **operating manual** (`GET /help`, aka
`/.well-known/agent.md`) for request syntax, so they don't restate the API or go
stale.

## Install

Skills are folders an agent loads. Each is a self-contained recipe - set
`CRMKIT_BASE_URL` and a `CRMKIT_TOKEN` to run it (see the Overview above).

> **On a chat app (ChatGPT, Claude.ai)?** Nothing to install here - add crmkit as
> an MCP connector instead (`https://api.crmkit.ai/mcp`); see
> [Connecting](https://github.com/crmkit/crmkit#mcp-connector). Skills are for
> coding agents with a filesystem (Claude Code, Codex, Cursor).

**With [`npx skills`](https://github.com/vercel-labs/skills)** (recommended - one
command, works across Claude Code, Cursor, and 40+ agents):

```bash
npx skills add crmkit/skills
```

It detects your agent and installs all four. Preview them with
`npx skills add crmkit/skills --list`, grab just one with
`--skill crmkit-digest`, or add `-g` to install globally (`~/.claude/skills`)
rather than into the project's `.claude/skills/`.

**Or download the release** and unzip into your skills directory (offline, or to
pin a version):

```bash
curl -fsSL https://github.com/crmkit/skills/releases/latest/download/crmkit-skills.zip -o /tmp/crmkit-skills.zip \
  && unzip -o /tmp/crmkit-skills.zip -d ~/.claude/skills/
```

A tagged `crmkit-skills-vX.Y.Z.zip` is on every [release](https://github.com/crmkit/skills/releases) for pinning.

**Or from source:**

```bash
git clone https://github.com/crmkit/skills
cp -r skills/crmkit-* ~/.claude/skills/
```

Each recipe defers to the server's manual (`GET /help`) for request syntax, so
they stay tiny and never go stale.

## Skills

| Skill                                           | Kind     | Description                                                                    |
| ----------------------------------------------- | -------- | ------------------------------------------------------------------------------ |
| [crmkit-digest](crmkit-digest/SKILL.md)         | recipe   | One-screen briefing - follow-ups, pipeline, recent activity (`digest.sh`).     |
| [crmkit-import](crmkit-import/SKILL.md)         | recipe   | Bulk-upsert contacts & companies from a CSV (`import.sh`).                     |
| [crmkit-backup](crmkit-backup/SKILL.md)         | recipe   | Export the whole CRM to JSON, paging every collection (`backup.sh`).           |
| [crmkit-inbox-sync](crmkit-inbox-sync/SKILL.md) | recipe   | Turn recent emails into logged activities (`log-interaction.sh` + email tool). |

## What makes a good recipe skill

Not a restatement of the API (that's the manual's job) - a **runnable recipe**
that automates something:

- a short `*.sh` (or other) script using `curl` and the plain-text, grepable
  responses (no heavy tooling needed)
- a clear outcome, plus how to **automate** it (cron, a chat webhook, the agent's
  shell tool)
- judgment on what "good" looks like, deferring to the manual for request syntax

---

<p align="center">
  <a href="https://crmkit.ai">crmkit.ai</a>
</p>
