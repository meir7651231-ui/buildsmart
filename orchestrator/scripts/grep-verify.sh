#!/usr/bin/env bash
# Verify the BYTES, not the agent's prose. Use after a fix fleet returns (especially on
# "already done" / "no change needed" claims) to confirm each fix is actually in the file.
# Each arg is a check: "file:::present_regex"  (must appear >=1)
#                  or  "file:::!absent_regex"  (must appear 0 times)
# Exits non-zero if any check fails.
# example: grep-verify.sh "lib/x.dart:::_loaded" "lib/x.dart:::!oldBuggyString"
set -uo pipefail
fail=0
for chk in "$@"; do
  f="${chk%%:::*}"; pat="${chk#*:::}"
  if [[ "$pat" == "!"* ]]; then
    p="${pat:1}"; n=$(grep -c "$p" "$f" 2>/dev/null || true); n=${n:-0}
    if [ "$n" -eq 0 ]; then echo "OK   absent   : $p   ($f)";
    else echo "FAIL should-be-absent (x$n): $p   ($f)"; fail=1; fi
  else
    n=$(grep -c "$pat" "$f" 2>/dev/null || true); n=${n:-0}
    if [ "$n" -gt 0 ]; then echo "OK   present x$n: $pat   ($f)";
    else echo "FAIL should-be-present: $pat   ($f)"; fail=1; fi
  fi
done
[ "$fail" -eq 0 ] && echo "BYTES VERIFIED" || echo "BYTE-CHECK FAILED — a claimed fix is missing"
exit $fail
