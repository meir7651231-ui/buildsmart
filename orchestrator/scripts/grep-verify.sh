#!/usr/bin/env bash
# Verify the BYTES, not the agent's prose. Use after a fix fleet returns (especially on
# "already done" / "no change needed" claims) to confirm each fix is actually in the file.
# Each arg is a check: "file:::present_string"  (must appear >=1)
#                  or  "file:::!absent_string"  (must appear 0 times)
# Patterns are FIXED STRINGS (grep -F), never regexes: a rule is a verbatim snippet of source, so
# `[`, `$`, `.`, `\s` mean themselves. (Issue #67: as regexes, `x = [` was an invalid pattern whose
# grep error was swallowed into "count 0" — a false FAIL on present-rules and, worse, a false
# "OK absent" on ban-rules. Same contract as required-tests.sh.)
# Exits non-zero if any check fails; exits 2 when called with no checks at all.
# example: grep-verify.sh "lib/x.dart:::_loaded" "lib/x.dart:::!oldBuggyString"
set -uo pipefail
if [ "$#" -eq 0 ]; then echo "FAIL no checks given (zero checks is never a pass)"; exit 2; fi
fail=0
for chk in "$@"; do
  f="${chk%%:::*}"; pat="${chk#*:::}"
  # A claim cannot be verified against a file that doesn't exist — FAIL, never pass silently.
  # (Found by the bootstrap A/B: the absent-check used to print "OK" on a missing file.)
  if [ ! -f "$f" ]; then echo "FAIL file-missing : $f"; fail=1; continue; fi
  neg=0; p="$pat"
  if [[ "$pat" == "!"* ]]; then neg=1; p="${pat:1}"; fi
  # An empty pattern matches every line — a vacuous pass (or an impossible ban). FAIL it.
  if [ -z "$p" ]; then echo "FAIL empty-pattern : $chk"; fail=1; continue; fi
  # grep -F treats a newline as "OR" (and a trailing one as "match everything") — never what a rule means.
  if [[ "$p" == *$'\n'* ]]; then echo "FAIL multiline-pattern : $f"; fail=1; continue; fi
  # -F literal · -e so a pattern starting with '-' is not parsed as an option · -- ends options ·
  # </dev/null so a mis-parse can never hang on stdin. grep exits 0 (match) / 1 (no match) / >=2 (error):
  # an ERROR is a loud FAIL, never a silent count of 0.
  n=$(grep -cF -e "$p" -- "$f" 2>/dev/null </dev/null); rc=$?
  if [ "$rc" -ge 2 ]; then echo "FAIL grep-error (rc=$rc) : $p   ($f)"; fail=1; continue; fi
  n=${n:-0}
  if [ "$neg" -eq 1 ]; then
    if [ "$n" -eq 0 ]; then echo "OK   absent   : $p   ($f)";
    else echo "FAIL should-be-absent (x$n): $p   ($f)"; fail=1; fi
  else
    if [ "$n" -gt 0 ]; then echo "OK   present x$n: $p   ($f)";
    else echo "FAIL should-be-present: $p   ($f)"; fail=1; fi
  fi
done
[ "$fail" -eq 0 ] && echo "BYTES VERIFIED" || echo "BYTE-CHECK FAILED — a claimed fix is missing"
exit $fail
