#!/usr/bin/env bash
#
# crmkit-import - bulk-upsert contacts (and their companies) from a CSV.
# Idempotent: contacts upsert on email, companies on domain - safe to re-run.
# Requires: curl, jq.
#
# CSV: a header row, then rows with these columns (extra columns ignored):
#   name,email,phone,company,domain,stage
#
#   CRMKIT_BASE_URL=… CRMKIT_TOKEN=… ./import.sh contacts.csv
#
set -euo pipefail

: "${CRMKIT_BASE_URL:?set CRMKIT_BASE_URL (e.g. https://api.crmkit.ai)}"
: "${CRMKIT_TOKEN:?set CRMKIT_TOKEN (a crmkit bearer token - get one via POST /auth/verify)}"
csv="${1:?usage: import.sh contacts.csv}"

post() { curl -fsS -H "Authorization: Bearer ${CRMKIT_TOKEN}" -X POST "${CRMKIT_BASE_URL}$1" -d "$2"; }

created=0 updated=0 companies=0 skipped=0

# Skip the header; read simple comma-separated fields. (For CSVs with embedded
# commas/quotes, pre-clean with a real CSV tool.)
while IFS=, read -r name email phone company domain stage _; do
  name="${name%$'\r'}"; stage="${stage%$'\r'}"   # tolerate CRLF line endings
  [ -z "${name// /}" ] && { skipped=$((skipped + 1)); continue; }

  company_id=""
  if [ -n "${domain// /}" ]; then
    cresp=$(post /companies "$(jq -nc --arg n "$company" --arg d "$domain" '{name:$n, domain:$d}')")
    company_id=$(printf '%s' "$cresp" | grep -oE 'co_[a-z0-9]+' | head -1)
    companies=$((companies + 1))
  fi

  body=$(jq -nc --arg name "$name" --arg email "$email" --arg phone "$phone" \
                --arg stage "$stage" --arg cid "$company_id" '
    {name: $name}
    + (if $email != "" then {email: $email} else {} end)
    + (if $phone != "" then {phone: $phone} else {} end)
    + (if $stage != "" then {stage: $stage} else {} end)
    + (if $cid   != "" then {company_id: $cid} else {} end)')

  resp=$(post /contacts "$body")
  if printf '%s' "$resp" | grep -q '# updated'; then
    updated=$((updated + 1))
  else
    created=$((created + 1))
  fi
done < <(tail -n +2 "$csv")

echo "done: ${created} created, ${updated} updated, ${companies} company upserts, ${skipped} skipped"
