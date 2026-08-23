#!/usr/bin/env bash
# Self-test for the tooling layer — exercises every script on synthetic data with EXPECTED exit codes.
# Hermetic: uses a throwaway `git init` repo + a tmpdir, cleaned on exit. Touches nothing in the real
# worktree. Run before committing tooling changes; it must print "SELFTEST PASS".
# usage: selftest.sh
set -uo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
LENSES="$HERE/../lenses/registry.txt"
CKPT="$HERE/ckpt.sh"; REG="$HERE/registry.sh"; RLINT="$HERE/report-lint.sh"
LCOV_S="$HERE/lens-coverage.sh"; DCOV="$HERE/diff-coverage.sh"; GVER="$HERE/grep-verify.sh"
AM="$HERE/assert-manifest.sh"; RT="$HERE/required-tests.sh"

failed=0
check(){ # check "<label>" <expected-exit> <cmd...>
  local label="$1" exp="$2"; shift 2
  local out rc
  out=$("$@" 2>&1); rc=$?
  if [ "$rc" -eq "$exp" ]; then echo "PASS [$label] (exit $rc)";
  else echo "FAIL [$label] expected exit $exp got $rc"; printf '%s\n' "$out" | sed 's/^/    | /'; failed=$((failed+1)); fi
}

T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
R="$T/repo"; git init -q "$R"

echo "== ckpt.sh =="
check "ckpt not-a-worktree"     2 "$CKPT" "$T/nope" show
check "ckpt init"               0 "$CKPT" "$R" init "selftest goal"
check "ckpt guard-too-early"    1 "$CKPT" "$R" guard audit
check "ckpt phase audit"        0 "$CKPT" "$R" phase audit
check "ckpt guard-now-ok"       0 "$CKPT" "$R" guard audit
check "ckpt guard-future"       1 "$CKPT" "$R" guard deploy
check "ckpt unknown-phase"      2 "$CKPT" "$R" phase bogus
check "ckpt set"                0 "$CKPT" "$R" set version v6.17
v=$("$CKPT" "$R" get version 2>/dev/null)
if [ "$v" = "v6.17" ]; then echo "PASS [ckpt get value] (=$v)"; else echo "FAIL [ckpt get value] got '$v'"; failed=$((failed+1)); fi

echo "== registry.sh =="
check "reg reset"               0 "$REG" "$R" reset
check "reg open a1"             0 "$REG" "$R" open a1 auditor cross-role
check "reg assert (a1 open)"    1 "$REG" "$R" assert-none-open
check "reg open dup a1"         2 "$REG" "$R" open a1 auditor money
check "reg close a1"            0 "$REG" "$R" close a1 CLEAN
check "reg close again"         2 "$REG" "$R" close a1 CLEAN
check "reg assert (none open)"  0 "$REG" "$R" assert-none-open

echo "== report-lint.sh =="
mk(){ printf '%s' "$2" > "$T/$1"; }
mk r_clean.json        '{"run":"t","status":"CLEAN","fixed":[],"deferred":[],"discrepancies":[]}'
mk r_clean_defer.json  '{"run":"t","status":"CLEAN","fixed":[],"deferred":[{"item":"x","reason":"later"}],"discrepancies":[]}'
mk r_failed_nore.json  '{"run":"t","status":"FAILED","fixed":[],"deferred":[],"discrepancies":[]}'
mk r_failed_ok.json    '{"run":"t","status":"FAILED","reason":"build broke","fixed":[],"deferred":[],"discrepancies":[]}'
mk r_badstatus.json    '{"run":"t","status":"DONE","fixed":[],"deferred":[],"discrepancies":[]}'
mk r_defer_nore.json   '{"run":"t","status":"PARTIAL","fixed":[],"deferred":[{"item":"x"}],"discrepancies":[]}'
mk r_unresolved.json   '{"run":"t","status":"CLEAN","fixed":[],"deferred":[],"discrepancies":[{"claim":"c","resolved":false}]}'
mk r_notjson.txt       'this is not json'
check "lint clean"              0 "$RLINT" "$T/r_clean.json"
check "lint clean+deferred"     1 "$RLINT" "$T/r_clean_defer.json"
check "lint failed-no-reason"   1 "$RLINT" "$T/r_failed_nore.json"
check "lint failed-with-reason" 0 "$RLINT" "$T/r_failed_ok.json"
check "lint bad-status"         1 "$RLINT" "$T/r_badstatus.json"
check "lint deferred-no-reason" 1 "$RLINT" "$T/r_defer_nore.json"
check "lint clean-unresolved"   1 "$RLINT" "$T/r_unresolved.json"
check "lint not-json"           2 "$RLINT" "$T/r_notjson.txt"

echo "== lens-coverage.sh =="
grep -vE '^[[:space:]]*(#|$)' "$LENSES" > "$T/ret_all.txt"
head -n -1 "$T/ret_all.txt" > "$T/ret_missing.txt"   # drop the last lens id
mkdir -p "$T/ret_dir"; while read -r l; do : > "$T/ret_dir/$l.md"; done < "$T/ret_all.txt"
check "lens all (list)"         0 "$LCOV_S" "$LENSES" "$T/ret_all.txt"
check "lens missing one (list)" 1 "$LCOV_S" "$LENSES" "$T/ret_missing.txt"
check "lens all (dir)"          0 "$LCOV_S" "$LENSES" "$T/ret_dir"

echo "== diff-coverage.sh =="
printf 'SF:app_flutter/lib/foo.dart\nend_of_record\n'              > "$T/lcov_ok.info"
printf 'SF:/abs/wt/app_flutter/lib/foo.dart\nend_of_record\n'      > "$T/lcov_abs.info"
printf 'TN:\n'                                                      > "$T/lcov_empty.info"
printf 'app_flutter/lib/foo.dart\n'                                > "$T/changed_ok.txt"
printf 'app_flutter/lib/foo.dart\napp_flutter/lib/bar.dart\n'      > "$T/changed_partial.txt"
printf 'app_flutter/test/foo_test.dart\n'                          > "$T/changed_testonly.txt"
check "dcov covered"            0 "$DCOV" "$T/lcov_ok.info"    "$T/changed_ok.txt"
check "dcov missing one"        1 "$DCOV" "$T/lcov_ok.info"    "$T/changed_partial.txt"
check "dcov prefix-mismatch"    1 "$DCOV" "$T/lcov_abs.info"   "$T/changed_ok.txt"
check "dcov prefix-fixed"       0 "$DCOV" "$T/lcov_abs.info"   "$T/changed_ok.txt" "/abs/wt"
check "dcov test-only changed"  0 "$DCOV" "$T/lcov_ok.info"    "$T/changed_testonly.txt"
check "dcov no coverage"        1 "$DCOV" "$T/lcov_empty.info" "$T/changed_ok.txt"

echo "== grep-verify.sh (sanity) =="
printf 'hello world\n_loaded=true\n' > "$T/src.txt"
check "grep present"            0 "$GVER" "$T/src.txt:::_loaded"
check "grep absent-ok"          0 "$GVER" "$T/src.txt:::!neverHere"
check "grep should-be-present"  1 "$GVER" "$T/src.txt:::notThere"
check "grep missing-file"       1 "$GVER" "$T/gone.txt:::anything"

echo "== assert-manifest.sh =="
mkdir -p "$T/app2/lib"
printf 'final a = "הסל שלי";\nfinal b = "₪120";\n' > "$T/app2/lib/x.dart"
printf '# conf+regression\nlib/x.dart:::הסל שלי\nlib/x.dart:::₪120\nlib/x.dart:::!₪80\n' > "$T/am_ok.txt"
printf 'lib/x.dart:::NOT_PRESENT_HERE\n'  > "$T/am_bad.txt"
printf 'lib/x.dart:::!₪120\n'             > "$T/am_regress.txt"
printf 'lib/missing.dart:::x\n'           > "$T/am_missing.txt"
printf '# only comments\n'                > "$T/am_empty.txt"
printf 'no-triple-colon\n'                > "$T/am_malformed.txt"
check "assert ok"             0 "$AM" "$T/app2"  "$T/am_ok.txt"
check "assert bad-present"    1 "$AM" "$T/app2"  "$T/am_bad.txt"
check "assert banned-present" 1 "$AM" "$T/app2"  "$T/am_regress.txt"
check "assert missing-file"   1 "$AM" "$T/app2"  "$T/am_missing.txt"
check "assert empty"          1 "$AM" "$T/app2"  "$T/am_empty.txt"
check "assert malformed"      1 "$AM" "$T/app2"  "$T/am_malformed.txt"
check "assert no-base"        2 "$AM" "$T/nodir" "$T/am_ok.txt"

echo "== required-tests.sh =="
mkdir -p "$T/app2/test"
printf 'void main(){ test("orders engine advances stage", (){}); }\n' > "$T/app2/test/flow_test.dart"
printf 'test/flow_test.dart\n'                  > "$T/rt_ok.txt"
printf 'test/flow_test.dart:::advances stage\n' > "$T/rt_name_ok.txt"
printf 'test/flow_test.dart:::no such name\n'   > "$T/rt_name_bad.txt"
printf 'test/missing_test.dart\n'               > "$T/rt_missing.txt"
printf '# empty\n'                              > "$T/rt_empty.txt"
check "reqtests file-ok"      0 "$RT" "$T/app2" "$T/rt_ok.txt"
check "reqtests name-ok"      0 "$RT" "$T/app2" "$T/rt_name_ok.txt"
check "reqtests name-bad"     1 "$RT" "$T/app2" "$T/rt_name_bad.txt"
check "reqtests missing"      1 "$RT" "$T/app2" "$T/rt_missing.txt"
check "reqtests empty"        1 "$RT" "$T/app2" "$T/rt_empty.txt"

echo
if [ "$failed" -eq 0 ]; then echo "SELFTEST PASS (all checks green)"; exit 0
else echo "SELFTEST FAIL ($failed check(s) failed)"; exit 1; fi
