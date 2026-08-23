#!/usr/bin/env bash
# Run a manifest of BYTE assertions (conformance + regression) so source-conformance and "this bug must
# never come back" are ENFORCED by the gate automatically — not left to remembering to run grep-verify with
# the right patterns. This is the systematic form of the kit's core rule (verify bytes, not prose).
# Manifest lines (#comments / blank lines ignored):
#   <relpath>:::<present_regex>     file MUST contain it      (conformance: a required verbatim string)
#   <relpath>:::!<absent_regex>     file must NOT contain it  (regression: a banned/buggy string)
# Paths are relative to <base-dir>. The actual byte-check is delegated to grep-verify.sh (one source of truth).
# An EMPTY manifest FAILS — "no assertions" is never a silent pass. usage: assert-manifest.sh <base-dir> <manifest>
set -uo pipefail
BASE="${1:?base dir}"; MAN="${2:?manifest file}"
HERE=$(cd "$(dirname "$0")" && pwd)
[ -d "$BASE" ] || { echo "ASSERT FAIL: base dir not found: $BASE"; exit 2; }
[ -f "$MAN" ]  || { echo "ASSERT FAIL: manifest not found: $MAN"; exit 2; }
mapfile -t lines < <(grep -vE '^[[:space:]]*(#|$)' "$MAN")
if [ "${#lines[@]}" -eq 0 ]; then echo "ASSERT FAIL: manifest '$MAN' has no assertions (empty is not a pass)"; exit 1; fi
args=()
for ln in "${lines[@]}"; do
  if [[ "$ln" != *":::"* ]]; then echo "ASSERT FAIL: malformed line (no ':::'): $ln"; exit 1; fi
  f="${ln%%:::*}"; pat="${ln#*:::}"
  args+=("$BASE/$f:::$pat")
done
echo "asserting ${#args[@]} byte-rule(s) from $(basename "$MAN") against $BASE"
"$HERE/grep-verify.sh" "${args[@]}"
