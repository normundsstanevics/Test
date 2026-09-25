#!/usr/bin/env bash
# Export a timestamped backup of n8n workflows before editing them.
#
# Usage:
#   N8N_BASE_URL=https://your-n8n.example.com N8N_API_KEY=... \
#     scripts/n8n-backup.sh <workflowId> [<workflowId> ...]
#
# With no IDs, every workflow is exported.
#
# Output goes to backups/<workflowId>/<UTC timestamp>.json, which is git-ignored:
# workflow JSON can hold phone numbers, prompts and message samples, and this
# repository is public. Credential *values* are never part of an n8n workflow
# export (nodes only carry {id, name} references), but the script still refuses
# to write a file that looks like it contains a secret.
set -euo pipefail

: "${N8N_BASE_URL:?set N8N_BASE_URL (e.g. https://n8n-production-xxxx.up.railway.app)}"
: "${N8N_API_KEY:?set N8N_API_KEY (n8n Settings -> n8n API)}"

api() {
  curl -fsS -H "X-N8N-API-KEY: ${N8N_API_KEY}" -H "Accept: application/json" \
    "${N8N_BASE_URL%/}/api/v1$1"
}

ids=("$@")
if [ ${#ids[@]} -eq 0 ]; then
  mapfile -t ids < <(api "/workflows?limit=250" | jq -r '.data[].id')
fi

stamp=$(date -u +%Y%m%dT%H%M%SZ)
root="$(cd "$(dirname "$0")/.." && pwd)/backups"

for id in "${ids[@]}"; do
  out="$root/$id/$stamp.json"
  json=$(api "/workflows/$id")

  # Refuse anything that looks like a secret rather than a reference.
  if grep -Eiq '"(password|accessToken|refreshToken|privateKey|apiKey|clientSecret)"[[:space:]]*:[[:space:]]*"[^"={]' <<<"$json" \
    || grep -Eq -- '-----BEGIN [A-Z ]*PRIVATE KEY-----|sk-[A-Za-z0-9]{20,}|EAA[A-Za-z0-9]{50,}' <<<"$json"; then
    echo "!! $id: export looks like it contains a literal secret; not written. Move it into an n8n credential." >&2
    continue
  fi

  mkdir -p "$root/$id"
  printf '%s\n' "$json" | jq '.' >"$out"
  name=$(jq -r '.name' "$out")
  active=$(jq -r '.active' "$out")
  nodes=$(jq '.nodes | length' "$out")
  echo "saved $out  ($name, active=$active, $nodes nodes)"
done
