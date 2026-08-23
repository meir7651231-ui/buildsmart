#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
#  protocol/regression_v7.sh — HONEST end-to-end regression for the v7 DX
#  friction fixes. Pure bash (no Flutter) so it runs anywhere a shell exists.
#  Each test asserts EXACTLY the behaviour the DX item names, plus the
#  security-preserving counter-cases (a fix must NOT weaken detection/scoping).
#  The deeper Dart-level proofs (incl. DX7 secret-vs-image) live in the
#  flutter_test suite (test/dx_friction_test.dart + protocol_check_engine_test)
#  and the engine --self-test; this file is the bash-hook half (S-gate style).
#
#  Run: bash protocol/regression_v7.sh
# ═══════════════════════════════════════════════════════════════════════════
set -uo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
HOOK="$REPO_ROOT/.githooks/pre-commit"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
PASS=0; FAIL=0
ok()  { echo "  ok   $1"; PASS=$((PASS+1)); }
bad() { echo "  FAIL $1"; FAIL=$((FAIL+1)); }
chk() { if [[ "$2" == "$3" ]]; then ok "$1"; else bad "$1 (want='$3' got='$2')"; fi; }

# Extract a function body verbatim from the hook into a sourceable file.
extract_to() { awk "/^$1\\(\\) \\{/,/^\\}/" "$HOOK" >> "$2"; }

echo "protocol_v7 regression — DX friction fixes (bash, Flutter-free)"

# ── DX1: no non-comment `grep <emoji>` in the hook; gate 93 uses case/glob ──
DX1_OFFENDERS=$(grep -nP 'grep [^|#]*(🟦|✅|⬜|🎯|🎨|🎮|🎪|🎲)' "$HOOK" 2>/dev/null \
                  | grep -vcE ':[[:space:]]*#' || true)
chk "DX1 no non-comment grep<emoji> line (antipattern #40 source)" "$DX1_OFFENDERS" "0"
if grep -qF '*"✅"*|*"✔"*|*"✓"*|*"[x]"*' "$HOOK"; then
  ok "DX1 gate 93 uses a bash case/glob done-marker scan"
else
  bad "DX1 gate 93 case/glob scan missing"
fi
echo "  note DX1 clean-tree GREEN is asserted by stuck_regression #40 in flutter test"

# ── DX2: gate 32 JSON parsers — COUNT == NAMES from one source ──
DX2_LIB="$WORK/dx2.sh"; : > "$DX2_LIB"
extract_to parse_json_failures  "$DX2_LIB"
extract_to parse_json_passcount "$DX2_LIB"
cat > "$WORK/dx2.json" <<'JSONEOF'
{"suite":{"id":0,"platform":"vm","path":"/x/test/a_test.dart"},"type":"suite","time":0}
{"suite":{"id":9,"platform":"vm","path":"/x/test/b_test.dart"},"type":"suite","time":0}
{"test":{"id":1,"name":"loading","suiteID":0,"groupIDs":[]},"type":"testStart","time":1}
{"testID":1,"result":"success","skipped":false,"hidden":true,"type":"testDone","time":2}
{"test":{"id":3,"name":"alpha pass","suiteID":0,"groupIDs":[2]},"type":"testStart","time":3}
{"testID":3,"result":"success","skipped":false,"hidden":false,"type":"testDone","time":4}
{"test":{"id":4,"name":"beta FAIL one","suiteID":0,"groupIDs":[2]},"type":"testStart","time":5}
{"testID":4,"result":"failure","skipped":false,"hidden":false,"type":"testDone","time":6}
{"test":{"id":8,"name":"delta FAIL two","suiteID":9,"groupIDs":[]},"type":"testStart","time":9}
{"testID":8,"result":"error","skipped":false,"hidden":false,"type":"testDone","time":10}
JSONEOF
# shellcheck disable=SC1090
source "$DX2_LIB"
DX2_FAILS=$(parse_json_failures < "$WORK/dx2.json")
DX2_CNT=$(printf '%s' "$DX2_FAILS" | grep -c .)
DX2_NAMES=$(printf '%s\n' "$DX2_FAILS" | grep -c '_test\.dart	')
DX2_PASS=$(parse_json_passcount < "$WORK/dx2.json")
chk "DX2 failure COUNT == failure NAMES (self-contradiction gone)" "$DX2_CNT" "$DX2_NAMES"
chk "DX2 failure count is 2" "$DX2_CNT" "2"
chk "DX2 pass count is 1 (one success, non-hidden)" "$DX2_PASS" "1"

# ── DX3: select_test_targets — scoped for sibling-tested, WHOLE for shared ──
DX3_LIB="$WORK/dx3.sh"
# _DX3_CRITICAL is multi-line (ends on a line closing the double-quote).
awk '/^_DX3_CRITICAL=/{f=1} f{print} f&&/"[[:space:]]*$/{exit}' "$HOOK" > "$DX3_LIB"
echo "" >> "$DX3_LIB"
extract_to _code_lines "$DX3_LIB"   # B3 (v8): select_test_targets now uses it
extract_to select_test_targets "$DX3_LIB"
cat >> "$DX3_LIB" <<'MOCKEOF'
git() { case "$*" in *"diff --cached --name-only"*) printf '%s\n' "$MOCK";; *) :;; esac; }
MOCKEOF
runt() { ( cd "$REPO_ROOT/app_flutter" && MOCK="$1" bash -c "source '$DX3_LIB'; out=\$(select_test_targets); [ -z \"\$out\" ] && echo WHOLE || echo \"SCOPED \$out\"" ); }
D=$(runt "app_flutter/lib/logic/install_kit.dart")
case "$D" in SCOPED*install_kit_test.dart*knowledge_protocol_test.dart*) ok "DX3 sibling-tested helper → scoped + critical";; *) bad "DX3 sibling-tested helper (got: $D)";; esac
D=$(runt "app_flutter/lib/state/smart_cart.dart")
chk "DX3 shared lib/state → WHOLE suite (safe)" "$D" "WHOLE"
D=$(runt "app_flutter/lib/logic/price_estimate.dart")
chk "DX3 helper with no test → WHOLE suite (never under-test)" "$D" "WHOLE"
if grep -qE '^\s*run:\s*flutter test --no-pub --concurrency=4\s*$' "$REPO_ROOT/.github/workflows/protocol-enforce.yml"; then
  ok "DX3 CI still runs the FULL suite (authoritative layer unchanged)"
else
  bad "DX3 CI full-suite step missing/changed"
fi

# ── DX4: gate 42 — edit-existing=NO demand; new untested symbol=DEMAND ──
# (No `git commit` needed: the function compares the STAGED diff to on-disk tests.)
DX4_LIB="$WORK/dx4.sh"; : > "$DX4_LIB"; extract_to _code_lines "$DX4_LIB"; extract_to staged_new_untested_symbol "$DX4_LIB"
T4="$WORK/r4"; AF="$T4/app_flutter"; mkdir -p "$AF/lib/logic" "$AF/test"
( cd "$T4" && git init -q )
printf 'int existingFn(int a)=>a+1;\n' > "$AF/lib/logic/foo.dart"
printf 'void main(){ existingFn(1); }\n' > "$AF/test/foo_test.dart"
( cd "$T4" && git add -A )   # stage the existing (no NEW symbol vs an empty index baseline? -> see note)
# To model an EDIT (not a brand-new file), establish a baseline blob for foo via
# `git add` then re-stage an edited copy; the diff of an unchanged public symbol
# yields no NEW symbol line.
printf 'int existingFn(int a)=>a+1; // tweak only\n' > "$AF/lib/logic/foo.dart"
( cd "$T4" && git add app_flutter/lib/logic/foo.dart )
D=$( cd "$AF" && bash -c "source '$DX4_LIB'; staged_new_untested_symbol" )
# foo's public symbol existingFn is covered by foo_test.dart (staged on disk) → no demand
chk "DX4 edit existing tested helper → NO demand" "${D:-<none>}" "<none>"
printf 'class BarThing{ const BarThing(); }\nint barCompute(int x)=>x*2;\n' > "$AF/lib/logic/bar.dart"
( cd "$T4" && git add app_flutter/lib/logic/bar.dart )
D=$( cd "$AF" && bash -c "source '$DX4_LIB'; staged_new_untested_symbol" )
case "$D" in *bar.dart*) ok "DX4 NEW untested public symbol → DEMAND";; *) bad "DX4 new symbol (got: '$D')";; esac

# ── DX5: gate 116 — widget-test coverage satisfies; uncovered demands ──
DX5_LIB="$WORK/dx5.sh"; : > "$DX5_LIB"; extract_to _code_lines "$DX5_LIB"; extract_to staged_ui_covered_by_widget_test "$DX5_LIB"
T5="$WORK/r5"; mkdir -p "$T5/lib/widgets" "$T5/test"
printf 'class MyWidget extends StatelessWidget{ const MyWidget(); }\n' > "$T5/lib/widgets/my_widget.dart"
printf 'void main(){ testWidgets("w",(t) async { await t.pumpWidget(const MyWidget()); }); }\n' > "$T5/test/my_widget_test.dart"
D=$( cd "$T5" && bash -c "source '$DX5_LIB'; staged_ui_covered_by_widget_test app_flutter/lib/widgets/my_widget.dart" )
chk "DX5 widget covered by a widget test → NO demand" "${D:-<none>}" "<none>"
printf 'class Lonely extends StatelessWidget{ const Lonely(); }\n' > "$T5/lib/widgets/lonely.dart"
D=$( cd "$T5" && bash -c "source '$DX5_LIB'; staged_ui_covered_by_widget_test app_flutter/lib/widgets/lonely.dart" )
case "$D" in *lonely.dart*) ok "DX5 uncovered widget → DEMAND visual-verify";; *) bad "DX5 uncovered (got: '$D')";; esac

# ── DX6: all workflows pin the ONE real Flutter version; no 3.44.0 pin ──
DX6_BAD=$(grep -rhoE "flutter-version:?[[:space:]]*['\"]?[0-9]+\.[0-9]+\.[0-9]+" \
            "$REPO_ROOT"/.github/workflows/*.yml 2>/dev/null \
            | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | sort -u | grep -vc '^3\.29\.3$' || true)
chk "DX6 every workflow flutter-version pin == 3.29.3 (real)" "$DX6_BAD" "0"

echo ""
echo "── v7 regression: $PASS passed, $FAIL failed ──"
[[ "$FAIL" -eq 0 ]] || exit 1
