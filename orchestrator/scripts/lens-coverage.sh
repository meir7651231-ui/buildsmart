#!/usr/bin/env bash
# Lens coverage gate — every REQUIRED audit lens must have been returned by the fleet.
# Kills the "we ran 9 of 10 lenses and nobody noticed the 10th was missing" gap: a missing viewpoint is
# a silent hole, not a visible failure. usage: lens-coverage.sh <required-lenses-file> <returned-dir-OR-listfile>
#   returned dir  -> uses basenames of *.md / *.json (lens id = filename without extension)
#   returned file -> one returned lens id per line (#-comments / blank lines ignored)
set -uo pipefail
REQ="${1:?required lenses file}"; RET="${2:?returned dir or list-file}"
[ -f "$REQ" ] || { echo "FAIL: required-lenses file not found: $REQ"; exit 2; }
strip(){ grep -vE '^[[:space:]]*(#|$)' "$1" | sed 's/[[:space:]]//g' | sort -u; }
req=$(strip "$REQ")
if [ -d "$RET" ]; then
  ret=$(find "$RET" -maxdepth 1 -type f \( -name '*.md' -o -name '*.json' \) -printf '%f\n' 2>/dev/null \
        | sed -E 's/\.(md|json)$//' | sort -u)
elif [ -f "$RET" ]; then
  ret=$(strip "$RET")
else
  echo "FAIL: returned path not found: $RET"; exit 2
fi
missing=$(comm -23 <(printf '%s\n' "$req") <(printf '%s\n' "$ret"))
if [ -n "$missing" ]; then
  echo "BLOCK: required lens(es) not returned by the fleet:"
  printf '%s\n' "$missing" | sed 's/^/  - /'
  exit 1
fi
echo "OK: all $(printf '%s\n' "$req" | grep -c .) required lens(es) covered"
