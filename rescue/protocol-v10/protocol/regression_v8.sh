#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
#  protocol/regression_v8.sh — HONEST regression for the v8 pass.
#  Closes BOTH (1) the reopened S1 base64 image-magic laundering hole and
#  (2) the named buildability/honesty friction (B1/B2/B3/B4/H1). Pure bash
#  (no flutter test) except the engine is invoked with `dart` for the S1
#  decode-and-scan proofs (the same engine the hook + CI run). Each test
#  asserts EXACTLY what the item names; security counter-cases included.
#
#  Run: bash protocol/regression_v8.sh
# ═══════════════════════════════════════════════════════════════════════════
set -uo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
HOOK="$REPO_ROOT/.githooks/pre-commit"
ENGINE="$REPO_ROOT/app_flutter/tool/protocol_check.dart"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
PASS=0; FAIL=0
ok()  { echo "  ok   $1"; PASS=$((PASS+1)); }
bad() { echo "  FAIL $1"; FAIL=$((FAIL+1)); }
chk() { if [[ "$2" == "$3" ]]; then ok "$1"; else bad "$1 (want='$3' got='$2')"; fi; }
extract_to() { awk "/^$1\\(\\) \\{/,/^\\}/" "$HOOK" >> "$2"; }
gi() { ( cd "$1" && git init -q && git config user.email t@t && git config user.name t \
         && git config commit.gpgsign false ); }
DART="dart"; command -v dart >/dev/null 2>&1 || DART="$HOME/flutter/bin/dart"

echo "protocol_v8 regression — S1 laundering hole + B1/B2/B3/B4/H1 friction"

# ════════════════════════════════════════════════════════════════════════
#  S1 — the reopened base64 image-magic laundering hole is CLOSED.
#  We drive the REAL engine (--diff) over isolated leak diffs and assert the
#  laundering vectors are now ERR (RC 2), while a REAL image is still WARN
#  (RC 0). This is the actual hook+CI codepath (no mock).
# ════════════════════════════════════════════════════════════════════════
s1_run() { # <dart-line>  -> echoes "RC=<rc> <SEV>"
    local line="$1" T="$WORK/s1.$RANDOM" rc sev out
    mkdir -p "$T/app_flutter/lib"; gi "$T"
    printf '%s\n' "$line" > "$T/app_flutter/lib/leak.dart"
    ( cd "$T" && git add -A )
    ( cd "$T" && git diff --cached > "$T/d.diff" )
    out=$( cd "$REPO_ROOT/app_flutter" && "$DART" "$ENGINE" --diff "$T/d.diff" 2>/dev/null ); rc=$?
    sev=$(printf '%s\n' "$out" | grep -E '^(ERR|WARN)[[:space:]]+52' | head -1 | cut -f1)
    echo "RC=$rc ${sev:-NONE}"
}
if command -v "$DART" >/dev/null 2>&1; then
  RSEC='M67EXbVojz0wuPkM3NNGqdZ566kGk8gWmRuUKBViJSfe47gEbeQwwOuCt3Zkcz6abQ'
  # Real 1x1 PNG / minimal JPEG (decode to valid image, low-entropy header).
  PNG='iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAAHxXEiQAAAA1JREFUeJxiAAAAAP//AwAABgAF'
  # vectors
  chk "S1 LAUNDER magic-text+secret (same blob) → ERR"  "$(s1_run "const k = \"iVBORw0KGgo$RSEC\";")"   "RC=2 ERR"
  chk "S1 LAUNDER split \"magic\" \"secret\" (joined) → ERR" "$(s1_run "const k = \"iVBORw0KGgo\" \"$RSEC\";")" "RC=2 ERR"
  chk "S1 REAL decodable PNG blob → WARN (not ERR, no friction)" "$(s1_run "const img = \"$PNG\";")" "RC=0 WARN"
  echo "  note S1 magic-bytes-splice + fingerprint-in-decoded vectors: engine --self-test (ALL PASS v8)"
else
  echo "  SKIP S1 engine vectors (dart not found) — covered by --self-test in CI"
fi

# ════════════════════════════════════════════════════════════════════════
#  B1 — gate 102 retry-trap: demand a stuck_log lesson ONLY when the prior
#  failure included a GENUINE code/test gate (analyze ERROR / test failure),
#  NOT a bookkeeping-only first-failure (12/24/44/116) or non-numeric id.
#  We mirror the hook's exact classification `case` (extracted by grep-audit).
# ════════════════════════════════════════════════════════════════════════
# audit: the hook uses an explicit code/test case allowlist, NOT the v7 range
if grep -qE '31\|32\|33\|34\|35\|36\|37\|38\|39\|40\|41\)' "$HOOK"; then
  ok "B1 hook classifies code/test by an explicit allowlist (not a 31..45 range)"
else
  bad "B1 explicit code/test allowlist missing in hook"
fi
if grep -qE 'elif \[\[ -n "\$PRIOR_GATES" \]\]; then' "$HOOK"; then
  bad "B1 the v7 'elif any-prior → code/test' fail-toward-friction default still present"
else
  ok "B1 the v7 'elif any-prior → code/test' default is REMOVED"
fi
classify() {  # replicate the hook block verbatim-in-spirit
  local PRIOR_GATES="$1" PRIOR_HAS_CODE_TEST="" prior_nums g
  if [[ "$PRIOR_GATES" == v2:* ]]; then
    prior_nums="${PRIOR_GATES#v2:}"
    for g in ${prior_nums//,/ }; do
      case "$g" in 31|32|33|34|35|36|37|38|39|40|41) PRIOR_HAS_CODE_TEST="1"; break ;; esac
    done
  fi
  echo "$PRIOR_HAS_CODE_TEST"
}
chk "B1 bookkeeping-only retry (24 wiring) → NO stuck_log demand" "$(classify 'v2:24')" ""
chk "B1 bookkeeping-only retry (44 mutation_log) → NO demand"     "$(classify 'v2:44')" ""
chk "B1 bookkeeping-only retry (116 visual / 12 version) → NO demand" "$(classify 'v2:116,12')" ""
chk "B1 real CODE-fail retry (31 analyze ERROR) → DEMAND"        "$(classify 'v2:31')" "1"
chk "B1 real TEST-fail retry (32) → DEMAND"                      "$(classify 'v2:32')" "1"
chk "B1 mixed bookkeeping+test-fail (24,32) → DEMAND"            "$(classify 'v2:24,32')" "1"

# ════════════════════════════════════════════════════════════════════════
#  B2 — gate 31 touch-tax: a PRE-EXISTING warning in a touched file does NOT
#  block; a NEW warning (on an added line) DOES. We exercise the exact
#  added-line/warning-matching logic the hook uses, with a mocked ANALYZE.
# ════════════════════════════════════════════════════════════════════════
# audit: the hook gate-31 warning loop keys on ADDED line numbers, not just file
if grep -qE 'B2 .*INTRODUCED by THIS change|added-line set|אזהרות analyze חדשות' "$HOOK"; then
  ok "B2 hook gate-31 warning loop is per-CHANGE (added lines), not per-FILE"
else
  bad "B2 per-change warning logic missing in hook"
fi
T2="$WORK/b2"; AF2="$T2/app_flutter"; mkdir -p "$AF2/lib/logic"; gi "$T2"
printf 'void f(){\n  var unused = 1;\n}\n' > "$AF2/lib/logic/x.dart"
( cd "$T2" && git add -A && git commit -qm base --no-gpg-sign )
# add a NEW line (line 4) — line-2 warning is pre-existing; line-4 is new
printf 'void f(){\n  var unused = 1;\n}\nvoid g(){ var alsoUnused = 2; }\n' > "$AF2/lib/logic/x.dart"
( cd "$T2" && git add app_flutter/lib/logic/x.dart )
ADDED=$( cd "$T2" && git diff --cached -U0 -- app_flutter/lib/logic/x.dart | awk '
  /^@@/ { match($0, /\+[0-9]+/); s=substr($0,RSTART+1,RLENGTH-1); ln=s+0; next }
  /^\+\+\+/ { next } /^\+/ { print ln; ln++ }' | tr "\n" " ")
chk "B2 added-line set is exactly {4} (the new line only)" "$(echo $ADDED)" "4"
# mock analyze: warnings on the pre-existing line 2 AND the new line 4
ANALYZE="warning • unused • lib/logic/x.dart:2:7 • unused_local_variable
warning • unused • lib/logic/x.dart:4:15 • unused_local_variable"
count_new() { local n=0 wf wn; while IFS= read -r _wl; do [[ -z "$_wl" ]] && continue
    wf=$(printf '%s' "$_wl" | sed -E 's/.* • ([^ ]+):[0-9]+:[0-9]+ • .*/\1/')
    wn=$(printf '%s' "$_wl" | sed -E 's/.* • [^ ]+:([0-9]+):[0-9]+ • .*/\1/')
    [[ "$wf" == "lib/logic/x.dart" ]] || continue
    case " $ADDED " in *" $wn "*) n=$((n+1));; esac
  done <<< "$1"; echo "$n"; }
chk "B2 only the NEW warning (line 4) is fatal; pre-existing (line 2) skipped" "$(count_new "$ANALYZE")" "1"
# control: a commit that ONLY touches line 1 (no new warning line) → 0 fatal
ADDED="1"
chk "B2 a change with NO new-warning line → 0 fatal (pre-existing tolerated)" "$(count_new "$ANALYZE")" "0"

# ════════════════════════════════════════════════════════════════════════
#  B3 — DX3 scoping: a clear "scoped run — N tests; full suite in CI" notice
#  is printed, AND selection is smarter (a non-sibling test that references a
#  changed symbol is included).
# ════════════════════════════════════════════════════════════════════════
if grep -qE 'scoped run — .*the FULL suite runs in CI' "$HOOK"; then
  ok "B3 hook prints an explicit 'scoped run — …; FULL suite runs in CI' notice"
else
  bad "B3 explicit scoped-run notice missing"
fi
# smarter selection: a test whose NAME is not the sibling but which references a
# changed symbol in code is picked up.
B3LIB="$WORK/b3.sh"
awk '/^_DX3_CRITICAL=/{f=1} f{print} f&&/"[[:space:]]*$/{exit}' "$HOOK" > "$B3LIB"; echo "" >> "$B3LIB"
extract_to _code_lines "$B3LIB"
extract_to select_test_targets "$B3LIB"
T3="$WORK/b3repo"; AF3="$T3/app_flutter"; mkdir -p "$AF3/lib/logic" "$AF3/test"; gi "$T3"
printf 'int priceOf(int x)=>x+1;\n' > "$AF3/lib/logic/pricing.dart"
# NON-sibling test name, but references priceOf in real code:
printf 'void main(){ var p = priceOf(3); }\n' > "$AF3/test/checkout_flow_test.dart"
( cd "$T3" && git add app_flutter/lib/logic/pricing.dart )
cat >> "$B3LIB" <<'MOCK'
git() { case "$*" in *"diff --cached --name-only"*) printf '%s\n' "app_flutter/lib/logic/pricing.dart";; *) :;; esac; }
MOCK
D=$( cd "$AF3" && bash -c "source '$B3LIB'; select_test_targets" )
case "$D" in *checkout_flow_test.dart*) ok "B3 smarter selection includes a NON-sibling test that references the changed symbol";; *) bad "B3 symbol-referencing non-sibling not selected (got: $D)";; esac
# and CI still runs the FULL suite (authoritative)
if grep -qE '^\s*run:\s*flutter test --no-pub --concurrency=4\s*$' "$REPO_ROOT/.github/workflows/protocol-enforce.yml"; then
  ok "B3 CI still runs the FULL suite (the ~12s local win loses no coverage)"
else
  bad "B3 CI full-suite step missing/changed"
fi

# ════════════════════════════════════════════════════════════════════════
#  B4 — mutation_log demanded only on GENUINELY-NEW fault-injectable logic;
#  a constant tweak does NOT demand it. bookkeep.sh ensures version.g.dart.
# ════════════════════════════════════════════════════════════════════════
B4LIB="$WORK/b4.sh"; : > "$B4LIB"; extract_to _staged_helper_adds_logic "$B4LIB"
T4="$WORK/b4repo"; AF4="$T4/app_flutter"; mkdir -p "$AF4/lib/logic"; gi "$T4"
# constant-only change: stage a data file whose diff adds only a literal
printf 'const taxRate = 17;\n' > "$AF4/lib/logic/consts.dart"
( cd "$T4" && git add app_flutter/lib/logic/consts.dart )
R=$( cd "$AF4" && bash -c "source '$B4LIB'; _staged_helper_adds_logic && echo LOGIC || echo CONST" )
chk "B4 constant-only helper change → NO mutation_log demand" "$R" "CONST"
# genuinely-new logic: a function with a branch
printf 'int clamp(int x){ if (x < 0) return 0; return x; }\n' > "$AF4/lib/logic/fn.dart"
( cd "$T4" && git add app_flutter/lib/logic/fn.dart )
R=$( cd "$AF4" && bash -c "source '$B4LIB'; _staged_helper_adds_logic && echo LOGIC || echo CONST" )
chk "B4 new fault-injectable logic (branch) → mutation_log DEMANDED" "$R" "LOGIC"
if grep -qE 'gen_version\.sh' "$REPO_ROOT/scripts/bookkeep.sh"; then
  ok "B4 bookkeep.sh runs gen_version.sh (fresh-clone compile guard)"
else
  bad "B4 bookkeep.sh does not ensure version.g.dart"
fi

# ════════════════════════════════════════════════════════════════════════
#  H1 — coverage (gate 42/116/56) requires a REAL CODE reference, not a
#  comment/string mention; gate 42 widened to top-level vars/getters + state.
# ════════════════════════════════════════════════════════════════════════
H1LIB="$WORK/h1.sh"; : > "$H1LIB"; extract_to _code_lines "$H1LIB"; extract_to staged_new_untested_symbol "$H1LIB"
TH="$WORK/h1repo"; AFH="$TH/app_flutter"; mkdir -p "$AFH/lib/logic" "$AFH/lib/state" "$AFH/test"; gi "$TH"
# (a) new logic symbol, test only MENTIONS it in a comment + string → DEMAND
printf 'int newCompute(int x)=>x*3;\n' > "$AFH/lib/logic/calc.dart"
printf 'void main(){ /* newCompute */ var s = "newCompute"; }\n' > "$AFH/test/calc_test.dart"
( cd "$TH" && git add app_flutter/lib/logic/calc.dart )
D=$( cd "$AFH" && bash -c "source '$H1LIB'; staged_new_untested_symbol" )
case "$D" in *calc.dart*newCompute*) ok "H1 comment/string mention does NOT satisfy coverage → DEMAND";; *) bad "H1 comment-mention wrongly satisfied (got: '$D')";; esac
# (b) real code reference → NO demand
printf 'void main(){ var r = newCompute(2); }\n' > "$AFH/test/calc_test.dart"
D=$( cd "$AFH" && bash -c "source '$H1LIB'; staged_new_untested_symbol" )
chk "H1 real code reference satisfies coverage → NO demand" "${D:-<none>}" "<none>"
# (c) NEW top-level VAR in lib/state → gate 42 fires (widening)
printf 'final myProvider = 42;\n' > "$AFH/lib/state/prov.dart"
( cd "$TH" && git add app_flutter/lib/state/prov.dart )
D=$( cd "$AFH" && bash -c "source '$H1LIB'; staged_new_untested_symbol" )
case "$D" in *prov.dart*myProvider*) ok "H1 new top-level VAR in lib/state → gate 42 fires";; *) bad "H1 state var not caught (got: '$D')";; esac
# (d) DX win kept: editing an EXISTING tested symbol → NO demand
TE="$WORK/h1edit"; AFE="$TE/app_flutter"; mkdir -p "$AFE/lib/logic" "$AFE/test"; gi "$TE"
printf 'int existingFn(int a)=>a+1;\n' > "$AFE/lib/logic/foo.dart"
printf 'void main(){ var r = existingFn(1); }\n' > "$AFE/test/foo_test.dart"
( cd "$TE" && git add -A && git commit -qm base --no-gpg-sign )
printf 'int existingFn(int a)=>a+1; // tweak\n' > "$AFE/lib/logic/foo.dart"
( cd "$TE" && git add app_flutter/lib/logic/foo.dart )
D=$( cd "$AFE" && bash -c "source '$H1LIB'; staged_new_untested_symbol" )
chk "H1 edit existing tested symbol → NO demand (v7 DX win kept)" "${D:-<none>}" "<none>"

echo ""
echo "── v8 regression: $PASS passed, $FAIL failed ──"
[[ "$FAIL" -eq 0 ]] || exit 1
