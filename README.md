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
Skills come in two flavours:

- **`crmkit-connect`** - the scene-setter. It connects, authenticates, and loads
  the server's **operating manual** (`/.well-known/agent.md`), which is the single
  source of truth for every endpoint. Use it first.
- **Recipe skills** - runnable automations (curl + a small script) that turn the
  API into an outcome: a digest, an import, a backup. They build on
  `crmkit-connect` (which exports `CRMKIT_BASE_URL` / `CRMKIT_TOKEN`) and defer to
  the manual for syntax, so they don't restate the API or go stale.

## Install

Skills are folders an agent loads. Start with **`crmkit-connect`**; the recipe
skills build on it.

**With [`npx skills`](https://github.com/vercel-labs/skills)** (recommended — one
command, works across Claude Code, Cursor, and 40+ agents):

```bash
npx skills add crmkit/skills
```

It detects your agent and installs all six. Preview them with
`npx skills add crmkit/skills --list`, grab just one with
`--skill crmkit-connect`, or add `-g` to install globally (`~/.claude/skills`)
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

Then run **`crmkit-connect`** first — it authenticates and loads the operating
manual; every recipe skill builds on it.

## Skills

| Skill                                           | Kind     | Description                                                                    |
| ----------------------------------------------- | -------- | ------------------------------------------------------------------------------ |
| [crmkit-connect](crmkit-connect/SKILL.md)       | connect  | Authenticate and load the operating manual. Use first.                         |
| [crmkit-digest](crmkit-digest/SKILL.md)         | recipe   | One-screen briefing - follow-ups, pipeline, recent activity (`digest.sh`).     |
| [crmkit-import](crmkit-import/SKILL.md)         | recipe   | Bulk-upsert contacts & companies from a CSV (`import.sh`).                     |
| [crmkit-backup](crmkit-backup/SKILL.md)         | recipe   | Export the whole CRM to JSON, paging every collection (`backup.sh`).           |
| [crmkit-inbox-sync](crmkit-inbox-sync/SKILL.md) | recipe   | Turn recent emails into logged activities (`log-interaction.sh` + email tool). |
| [crmkit-deploy](crmkit-deploy/SKILL.md)         | operator | Install and run the crmkitd server from pre-built binaries.                    |

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
