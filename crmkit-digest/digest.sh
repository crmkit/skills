#!/usr/bin/env bash
#
# crmkit digest - a one-screen briefing: follow-ups due/overdue, open pipeline,
# and recently logged activity. crmkit responses are plain-text and grepable, so
# no jq is needed. Cron it, or pipe it to mail / a chat webhook.
#
#   CRMKIT_BASE_URL=https://api.crmkit.ai CRMKIT_TOKEN=ck_... ./digest.sh
#
# Get the token via the email login (POST /auth/request → POST /auth/verify).
#
set -euo pipefail

: "${CRMKIT_BASE_URL:?set CRMKIT_BASE_URL (e.g. https://api.crmkit.ai)}"
: "${CRMKIT_TOKEN:?set CRMKIT_TOKEN (a crmkit bearer token - get one via POST /auth/verify)}"

get() {
  curl -fsS -H "Authorization: Bearer ${CRMKIT_TOKEN}" "${CRMKIT_BASE_URL}$1"
}

printf 'crmkit digest - %s\n' "$(date +%Y-%m-%d)"

printf '\n== Follow-ups due / overdue ==\n'
get '/reminders?limit=50'

printf '\n== Open pipeline (largest first) ==\n'
get '/deals?status=open&sort=-amount_cents&limit=50'

printf '\n== Recently logged ==\n'
get '/activities?limit=10'
