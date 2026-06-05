#!/usr/bin/env bash
# Enforce that CRITICAL test flows EXIST. Paired with a green `flutter test` in central-verify, presence
# is sufficient: the suite fails the whole run if any test fails, so "present + suite-green" ⇒ the flow ran
# AND passed. This closes the gap where the gate runs "whatever tests happen to exist" without guaranteeing
# the real flows (state machine, cross-role) stay covered even when a change doesn't touch them.
# Manifest lines (#comments / blank lines ignored):
#   <relpath-to-test-file>                  the test file must exist
#   <relpath-to-test-file>:::<name-substr>  must exist AND contain that test-name substring (fixed-string)
# Paths relative to <base-dir>. Empty manifest FAILS. usage: required-tests.sh <base-dir> <manifest>
set -uo pipefail
BASE="${1:?base dir}"; MAN="${2:?manifest file}"
[ -d "$BASE" ] || { echo "REQ-TESTS FAIL: base dir not found: $BASE"; exit 2; }
[ -f "$MAN" ]  || { echo "REQ-TESTS FAIL: manifest not found: $MAN"; exit 2; }
mapfile -t lines < <(grep -vE '^[[:space:]]*(#|$)' "$MAN")
if [ "${#lines[@]}" -eq 0 ]; then echo "REQ-TESTS FAIL: manifest '$MAN' is empty (no required tests is not a pass)"; exit 1; fi
fail=0
for ln in "${lines[@]}"; do
  if [[ "$ln" == *":::"* ]]; then f="${ln%%:::*}"; name="${ln#*:::}"; else f="$ln"; name=""; fi
  p="$BASE/$f"
  if [ ! -f "$p" ]; then echo "FAIL missing-test-file : $f"; fail=1; continue; fi
  if [ -n "$name" ]; then
    if grep -qF "$name" "$p"; then echo "OK   $f  (has: $name)"; else echo "FAIL name-absent : '$name' not in $f"; fail=1; fi
  else
    echo "OK   $f  (exists)"
  fi
done
[ "$fail" -eq 0 ] && echo "REQUIRED TESTS PRESENT" || echo "REQUIRED-TESTS CHECK FAILED"
exit $fail
