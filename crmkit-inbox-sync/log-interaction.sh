#!/usr/bin/env bash
#
# log-interaction - log a one-line interaction summary against the contact with
# the given email. No-op (exit 0) if there is no matching contact. Requires curl, jq.
#
#   CRMKIT_BASE_URL=… CRMKIT_TOKEN=… ./log-interaction.sh someone@co.com email "Re: pricing - sent proposal"
#
set -euo pipefail

: "${CRMKIT_BASE_URL:?set CRMKIT_BASE_URL (e.g. https://api.crmkit.ai)}"
: "${CRMKIT_TOKEN:?set CRMKIT_TOKEN (a crmkit bearer token - get one via POST /auth/verify)}"
email="${1:?usage: log-interaction.sh <email> <kind> <summary>}"
kind="${2:-note}"
summary="${3:?provide a one-line summary}"

api() { curl -fsS -H "Authorization: Bearer ${CRMKIT_TOKEN}" -H 'Accept: application/json' "$@"; }

cid=$(api "${CRMKIT_BASE_URL}/contacts?email=${email}" | jq -r '.items[0].id // ""')
if [ -z "$cid" ]; then
  echo "no contact for ${email} - skipping"
  exit 0
fi

api -X POST "${CRMKIT_BASE_URL}/contacts/${cid}/activities" \
    -H 'Content-Type: application/json' \
    -d "$(jq -nc --arg k "$kind" --arg b "$summary" '{kind: $k, body: $b}')" >/dev/null
echo "logged ${kind} for ${email} (${cid})"
