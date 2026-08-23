#!/usr/bin/env bash
# Lint a run-report JSON against the report contract (pure jq — there is no `jsonschema` in this runtime).
# Catches the failure mode where a report SAYS "CLEAN" while it still carries deferred work or unresolved
# discrepancies — the "looks done, isn't" trap. schemas/report.schema.json documents the same shape.
# usage: report-lint.sh <report.json>
set -uo pipefail
F="${1:?report.json}"
[ -f "$F" ] || { echo "FAIL: no such report file: $F"; exit 2; }
if ! jq -e . "$F" >/dev/null 2>&1; then echo "FAIL: $F is not valid JSON"; exit 2; fi

errs=$(jq -r '
  [
    (.status as $s | if ($s|type)!="string" or (["CLEAN","PARTIAL","FAILED"]|index($s))==null
       then "status must be one of CLEAN|PARTIAL|FAILED (got \($s|tojson))" else empty end),
    (if (.fixed|type)!="array"          then "fixed must be an array (got \(.fixed|type))" else empty end),
    (if (.deferred|type)!="array"       then "deferred must be an array (got \(.deferred|type))" else empty end),
    (if (.discrepancies|type)!="array"  then "discrepancies must be an array (got \(.discrepancies|type))" else empty end),
    (if .status=="FAILED" and ((.reason|type)!="string" or ((.reason // "")|length)==0)
       then "status FAILED requires a non-empty reason" else empty end),
    (if .status=="CLEAN" and (((.deferred // [])|length)>0)
       then "status CLEAN but \((.deferred // [])|length) deferred item(s) — CLEAN forbids deferred work" else empty end),
    (if .status=="CLEAN" and (((.discrepancies // [])|map(select(.resolved!=true))|length)>0)
       then "status CLEAN but \((.discrepancies // [])|map(select(.resolved!=true))|length) unresolved discrepancy(ies)" else empty end)
  ]
  + ( (.deferred // []) | (if type=="array" then to_entries else [] end) | map(
        select((.value.reason|type)!="string" or ((.value.reason // "")|length)==0)
        | "deferred[\(.key)] needs a non-empty reason" ) )
  | .[]
' "$F" 2>/dev/null) || { echo "FAIL: report missing required keys (status/fixed/deferred/discrepancies)"; exit 1; }

if [ -n "$errs" ]; then
  echo "REPORT INVALID:"
  printf '%s\n' "$errs" | sed 's/^/  - /'
  exit 1
fi
echo "REPORT OK ($(jq -r .status "$F") · fixed=$(jq '.fixed|length' "$F") deferred=$(jq '.deferred|length' "$F") discrepancies=$(jq '.discrepancies|length' "$F"))"
