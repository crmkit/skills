#!/usr/bin/env bash
#
# crmkit-backup - export the CRM to JSON. Pages through keyset-paginated
# collections (contacts, companies, deals) and pulls activities. Requires curl, jq.
#
#   CRMKIT_BASE_URL=… CRMKIT_TOKEN=… ./backup.sh [outdir]
#
set -euo pipefail

: "${CRMKIT_BASE_URL:?set CRMKIT_BASE_URL (e.g. https://api.crmkit.ai)}"
: "${CRMKIT_TOKEN:?set CRMKIT_TOKEN (a crmkit bearer token - get one via POST /auth/verify)}"
outdir="${1:-crmkit-backup-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$outdir"

get() { curl -fsS -H "Authorization: Bearer ${CRMKIT_TOKEN}" -H 'Accept: application/json' "${CRMKIT_BASE_URL}$1"; }

# dump a keyset-paginated collection to a JSON array file
dump() {
  local path="$1" file="$2" cursor="" all='[]' resp url
  while :; do
    url="${path}?limit=200"
    [ -n "$cursor" ] && url="${url}&cursor=${cursor}"
    resp=$(get "$url")
    all=$(jq -s '.[0] + (.[1].items // [])' <(printf '%s' "$all") <(printf '%s' "$resp"))
    cursor=$(printf '%s' "$resp" | jq -r '.next_cursor // ""')
    [ -z "$cursor" ] && break
  done
  printf '%s\n' "$all" > "$file"
  printf '  %-16s %s records\n' "$(basename "$file")" "$(jq length "$file")"
}

echo "backing up ${CRMKIT_BASE_URL} -> ${outdir}/"
dump /contacts  "$outdir/contacts.json"
dump /companies "$outdir/companies.json"
dump /deals     "$outdir/deals.json"
# activities aren't keyset-paginated; pull the server's max page. Every list is
# enveloped as {items, next_cursor}, so just take .items.
get '/activities?limit=500' | jq '.items' > "$outdir/activities.json"
printf '  %-16s %s records\n' "activities.json" "$(jq length "$outdir/activities.json")"
echo "done."
