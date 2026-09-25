#!/usr/bin/env bash
# Read-only inventory of an n8n instance: workflows, their triggers and
# credential references, and recent execution results.
#
# Usage:
#   N8N_BASE_URL=... N8N_API_KEY=... scripts/n8n-audit.sh [executionsPerWorkflow]
#
# Prints credential names and types only; the n8n public API never returns
# credential values.
set -euo pipefail

: "${N8N_BASE_URL:?set N8N_BASE_URL}"
: "${N8N_API_KEY:?set N8N_API_KEY}"
limit="${1:-50}"

api() {
  curl -fsS -H "X-N8N-API-KEY: ${N8N_API_KEY}" -H "Accept: application/json" \
    "${N8N_BASE_URL%/}/api/v1$1"
}

echo "== Workflows"
api "/workflows?limit=250" | jq -r '.data[] | "\(.id)\tactive=\(.active)\t\(.name)"'

for id in $(api "/workflows?limit=250" | jq -r '.data[].id'); do
  wf=$(api "/workflows/$id")
  echo
  echo "== $(jq -r .name <<<"$wf") ($id)"

  echo "-- triggers"
  jq -r '.nodes[] | select(.type | test("[Tt]rigger|webhook|cron|schedule"; "i"))
         | "  \(.name)  [\(.type)]\(if .disabled then "  DISABLED" else "" end)"' <<<"$wf"

  echo "-- credential references"
  jq -r '[.nodes[] | select(.credentials) | .credentials | to_entries[]
          | "  \(.key): \(.value.name) (\(.value.id))"] | unique[]' <<<"$wf"

  echo "-- approval / wait nodes"
  jq -r '.nodes[] | select((.type | test("wait"; "i")) or ((.parameters.operation // "") == "sendAndWait"))
         | "  \(.name)  [\(.type)]"' <<<"$wf"

  echo "-- last $limit executions"
  api "/executions?workflowId=$id&limit=$limit&includeData=false" \
    | jq -r '.data | group_by(.status) | .[] | "  \(.[0].status): \(length)"'
  api "/executions?workflowId=$id&limit=$limit&includeData=false" \
    | jq -r '.data[] | select(.status != "success") | "  #\(.id) \(.status) \(.startedAt)"' | head -20
done
