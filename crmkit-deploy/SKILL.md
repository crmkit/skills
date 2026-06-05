---
name: crmkit-deploy
description: Install and run the crmkitd server (the crmkit backend). Use when an operator wants to stand up a crmkit instance from pre-built binaries.
---

Use this skill to install crmkit from pre-built binaries and run the API server.
Once running, agents connect with the **crmkit** skill.

## Step 1 - Download binaries

The release archive auto-detects OS/arch:

```bash
set -e
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64) ARCH="amd64" ;;
  aarch64|arm64) ARCH="arm64" ;;
esac

VERSION="$(curl -fsSL https://api.github.com/repos/crmkit/crmkit/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')"
ARCHIVE="crmkit-${VERSION}-${OS}-${ARCH}.tar.gz"
curl -fsSL "https://github.com/crmkit/crmkit/releases/download/${VERSION}/${ARCHIVE}" -o "/tmp/${ARCHIVE}"
tar -xzf "/tmp/${ARCHIVE}" -C /tmp

INSTALL_DIR="${HOME}/.local/bin"
mkdir -p "${INSTALL_DIR}"
cp "/tmp/crmkit-${VERSION}-${OS}-${ARCH}/crmkitd" "${INSTALL_DIR}/crmkitd"
chmod +x "${INSTALL_DIR}/crmkitd"
echo "Installed crmkit ${VERSION} to ${INSTALL_DIR}"
```

## Step 2 - Verify

```bash
export PATH="${HOME}/.local/bin:${PATH}"
crmkitd --version
```

## Step 3 - Create the schema

The server never creates or alters schema; it refuses to start until the schema
is current. Run the migration once (a fresh database needs this). `crmkitd
migrate` alone is a dry run that prints the pending SQL and writes nothing;
`--execute` applies it:

```bash
crmkitd migrate            # preview: shows pending migrations, writes nothing
crmkitd migrate --execute  # apply (back up an existing database first)
```

Re-run `crmkitd migrate --execute` after upgrading to a build that adds
migrations; it is a no-op when the schema is already current.

## Step 4 - Run the server

crmkitd runs with zero configuration (SQLite, built-in defaults). For a
single-user instance on your own machine, `--local` echoes login codes so an
agent on the same box can authenticate without email:

```bash
crmkitd --local --listen :8080 &
```

For a served (multi-tenant) deployment, create `~/.config/crmkit/config.yaml`
(set `base_url` and SMTP so login codes are emailed) and run without `--local`:

```yaml
server:
  listen_addr: ':8080'
  base_url: 'https://api.crmkit.ai'
email:
  from: 'crmkit <no-reply@crmkit.ai>'
  smtp_host: 'smtp.example.com'
  smtp_port: 587
  smtp_user: '$CRMKIT_SMTP_USER'
  smtp_pass: '$CRMKIT_SMTP_PASS'
```

```bash
crmkitd > /tmp/crmkitd.log 2>&1 &
```

## Step 5 - Confirm and share the manual

```bash
curl -s http://localhost:8080/help                       # the agent operating manual
curl -s http://localhost:8080/.well-known/agent.md        # same manual, as a file (URLs resolved to base_url)
curl -s http://localhost:8080/.well-known/agent.json      # machine-readable agent card
```

The live `/.well-known/agent.md` is the canonical "LLM file" - its URLs resolve
against this deployment's `base_url`, so just point agents at it (or have them
load the **crmkit** skill).

## When to Use

- Standing up a new crmkit instance.
- Upgrading crmkit binaries.
- Producing the `agent.md` manual (served live at /.well-known/agent.md).
