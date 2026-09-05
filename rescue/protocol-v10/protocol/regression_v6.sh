#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
#  protocol/regression_v6.sh — HONEST regression tests for the v6 closes that
#  require a REAL git tree (the silent-skip CLASS) or the workflow shell, which
#  the pure-Dart --self-test cannot exercise:
#    H1  a Hebrew-named .dart with a secret is CAUGHT end-to-end through the
#        engine's --tree mode over an ACTUAL git tree (quoted names fed).
#    H2  a file with a high-bit (invalid-UTF-8) byte + a secret is CAUGHT (the
#        old FormatException-swallow shipped it).
#    H3  a deliberately-unscannable file makes the --tree run FAIL CLOSED (rc 3)
#        and NAMES the skipped file. Distinct from clean(0) and findings(2).
#    H5  the engine's --emit-ran is LOGIC-COUPLED: gut a Dart gate's predicate →
#        its id is no longer emitted → registry parity (verify-registry) FAILS.
#    +   the workflows pass core.quotePath=false to every ls-tree/diff, and the
#        CI tree step recognises rc 3 (H3) and asserts the reconciliation line.
#
#  Each test asserts EXACTLY what it names. No laundering: the H1/H2/H3 cases
#  build a throwaway git repo and run the REAL engine binary over it.
#
#  Run:  bash protocol/regression_v6.sh        (exit 0 = all pass, 1 = a failure)
# ═══════════════════════════════════════════════════════════════════════════
set -uo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
export PATH="/home/user/flutter/bin:$PATH"

PASS=0; FAIL=0
ok()   { echo "  ok   $1"; PASS=$((PASS+1)); }
bad()  { echo "  FAIL $1"; FAIL=$((FAIL+1)); }
check(){ local name="$1" want="$2" got="$3"
  if [[ "$want" == "$got" ]]; then ok "$name"; else bad "$name (want=$want got=$got)"; fi
}

ENGINE="$REPO_ROOT/app_flutter/tool/protocol_check.dart"
REG="$REPO_ROOT/protocol/gates.tsv"
SECRET='AKIAIOSFODNN7EXAMPLE1234567890ABCD'   # AKIA provider fingerprint

echo "v6 engine/CI regression suite"
echo "═══════════════════════════════════════════════"

# ── helper: build a throwaway git repo with given files, echo its path ──
mk_repo() { # creates $1 as a fresh repo; caller adds files then commits
  local d="$1"
  rm -rf "$d"; mkdir -p "$d"
  ( cd "$d" && git init -q && git config user.email t@t && git config user.name t \
       && git config commit.gpgsign false )
}
commit_all() { ( cd "$1" && git add -A && git -c commit.gpgsign=false commit -q --no-gpg-sign -m t ); }

# run engine --tree over a repo's HEAD; echo rc; stdout+stderr captured to $2
tree_run() { # <repo> <outfile> <namesfile>
  local d="$1" out="$2" names="$3"
  ( cd "$d" && dart run "$ENGINE" --tree --names "$names" \
      --show "git --no-replace-objects show HEAD:" ) > "$out" 2>&1
  echo $?
}

# ════════════════════════════════════════════════════════════════════════
#  H1 — Hebrew-named .dart with a secret, CAUGHT through the WHOLE-tree scan
#       even when QUOTED names (git default) are fed (engine unquotes them).
# ════════════════════════════════════════════════════════════════════════
H1=/tmp/reg_v6_h1
mk_repo "$H1"; mkdir -p "$H1/app_flutter/lib/screens"
printf 'const apiSecret = "%s";\n' "$SECRET" \
  > "$H1/app_flutter/lib/screens/$(printf '\327\236\327\241\327\232').dart"
commit_all "$H1"
# Feed the QUOTED names (what core.quotePath=true emits — the original bypass).
( cd "$H1" && git ls-tree -r --name-only HEAD ) > "$H1/names_quoted.txt"
# sanity: the fed name IS C-quoted (proves we are testing the real bypass input)
if grep -q '\\327' "$H1/names_quoted.txt"; then ok "H1 fed names are C-quoted (the original bypass input)"; else bad "H1 fed names are C-quoted"; fi
H1_RC="$(tree_run "$H1" "$H1/out.txt" "$H1/names_quoted.txt")"
check "H1 Hebrew-named .dart secret is CAUGHT via --tree (rc=2)" "2" "$H1_RC"
if grep -q $'^ERR\t52' "$H1/out.txt"; then ok "H1 the AKIA secret is reported as gate-52 ERR"; else bad "H1 gate-52 ERR reported"; fi
if grep -q 'fed==scanned==1' "$H1/out.txt"; then ok "H1 reconciliation reports fed==scanned==1"; else bad "H1 reconciliation fed==scanned"; fi

# ════════════════════════════════════════════════════════════════════════
#  H2 — a file with a HIGH-BIT (invalid-UTF-8) byte + a secret is CAUGHT.
# ════════════════════════════════════════════════════════════════════════
H2=/tmp/reg_v6_h2
mk_repo "$H2"; mkdir -p "$H2/app_flutter/web"
{ printf 'const k = "%s";\n' "$SECRET"; printf '\xe9 latin1 byte\n'; } > "$H2/app_flutter/web/x.html"
commit_all "$H2"
( cd "$H2" && git ls-tree -r --name-only HEAD ) > "$H2/names.txt"
# sanity: the blob really does carry a non-UTF-8 byte (0xE9 alone).
if ( cd "$H2" && git show HEAD:app_flutter/web/x.html | grep -qaP '\xe9' ); then ok "H2 the blob carries a raw high-bit byte (0xE9)"; else bad "H2 blob carries a high-bit byte"; fi
H2_RC="$(tree_run "$H2" "$H2/out.txt" "$H2/names.txt")"
check "H2 high-bit-byte file secret is CAUGHT (not skipped) (rc=2)" "2" "$H2_RC"
if grep -q $'^ERR\t52' "$H2/out.txt"; then ok "H2 the secret is reported as gate-52 ERR"; else bad "H2 gate-52 ERR reported"; fi

# ════════════════════════════════════════════════════════════════════════
#  H3 — a deliberately-unscannable file FAILS CLOSED (rc 3) and is NAMED;
#       and the three rc bands (0 clean / 2 findings / 3 skip) are DISTINCT.
# ════════════════════════════════════════════════════════════════════════
H3=/tmp/reg_v6_h3
mk_repo "$H3"; mkdir -p "$H3/app_flutter/lib"
printf 'final x = 1;\n' > "$H3/app_flutter/lib/clean.dart"
commit_all "$H3"
# (a) clean tree → rc 0
( cd "$H3" && git ls-tree -r --name-only HEAD ) > "$H3/names_clean.txt"
H3C_RC="$(tree_run "$H3" "$H3/clean.txt" "$H3/names_clean.txt")"
check "H3 clean tree → rc 0" "0" "$H3C_RC"
# (b) feed a SCANNABLE name that cannot be fetched → rc 3 fail-closed, named.
printf 'app_flutter/lib/ghost_missing.dart\n' > "$H3/names_ghost.txt"
H3G_RC="$(tree_run "$H3" "$H3/ghost.txt" "$H3/names_ghost.txt")"
check "H3 unscannable file → FAIL CLOSED (rc 3, not 0/2)" "3" "$H3G_RC"
if grep -q 'ghost_missing.dart' "$H3/ghost.txt"; then ok "H3 the skipped file is NAMED in the failure"; else bad "H3 skipped file named"; fi
if grep -q 'H3 reconciliation FAIL' "$H3/ghost.txt"; then ok "H3 emits an explicit reconciliation-FAIL message"; else bad "H3 reconciliation-FAIL message"; fi
# (c) a planted secret → rc 2 (distinct from the skip band)
printf 'const k = "%s";\n' "$SECRET" > "$H3/app_flutter/lib/leak.dart"
commit_all "$H3"
( cd "$H3" && git ls-tree -r --name-only HEAD ) > "$H3/names2.txt"
H3S_RC="$(tree_run "$H3" "$H3/leak.txt" "$H3/names2.txt")"
check "H3 planted secret → rc 2 (findings band, distinct from skip)" "2" "$H3S_RC"
# (d) a NON-scannable asset (.png) is NOT reconciled (legit not-scanned).
H3A=/tmp/reg_v6_h3a
mk_repo "$H3A"; mkdir -p "$H3A/app_flutter/assets" "$H3A/app_flutter/lib"
printf 'PNG\n' > "$H3A/app_flutter/assets/logo.png"
printf 'final y = 2;\n' > "$H3A/app_flutter/lib/ok.dart"
commit_all "$H3A"
( cd "$H3A" && git ls-tree -r --name-only HEAD ) > "$H3A/names.txt"
H3A_RC="$(tree_run "$H3A" "$H3A/out.txt" "$H3A/names.txt")"
check "H3 non-scannable asset (.png) is NOT reconciled → rc 0" "0" "$H3A_RC"
if grep -q 'fed==scanned==1' "$H3A/out.txt"; then ok "H3 only the 1 scannable file is reconciled (asset excluded)"; else bad "H3 asset excluded from reconciliation"; fi

# ════════════════════════════════════════════════════════════════════════
#  H5 — --emit-ran is LOGIC-COUPLED. Gut a Dart gate's predicate in a COPY of
#       the engine; that gate's canary no longer fires → its id is dropped from
#       --emit-ran → registry⇄runtime parity (verify-registry) FAILS.
# ════════════════════════════════════════════════════════════════════════
EMPTY="$(mktemp)"; : > "$EMPTY"
# Baseline: the real engine emits all 20 ids, and they ⊆ enforced → parity OK.
( cd "$REPO_ROOT/app_flutter" && dart run "$ENGINE" --diff "$EMPTY" --emit-ran 2>/dev/null ) \
  | grep '^RAN' | cut -f2 | sort -u > /tmp/reg_v6_emit_base.txt
BASE_N="$(wc -l < /tmp/reg_v6_emit_base.txt | tr -d ' ')"
check "H5 baseline --emit-ran emits all 20 gate ids (logic-coupled, all fire)" "20" "$BASE_N"
# Build a gutted COPY of the engine: gate 52 (secrets) predicate → always false.
GUT_DIR="$(mktemp -d)"; cp "$ENGINE" "$GUT_DIR/protocol_check.dart"
cp "$REPO_ROOT/app_flutter/tool/protocol_check_selftest.dart" "$GUT_DIR/protocol_check_selftest.dart"
# Neuter lineHasSecret's body so gate 52 NEVER fires (the "gutted gate").
python3 - "$GUT_DIR/protocol_check.dart" <<'PY'
import re, sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
# Replace the body of `bool lineHasSecret(String line) {` up to its first return
# with an immediate `return false;` — gut the gate while keeping it compilable.
s = re.sub(r'(bool lineHasSecret\(String line\) \{)',
           r'\1\n  return false; // GUTTED for H5 regression', s, count=1)
open(p, 'w', encoding='utf-8').write(s)
PY
GUT_EMIT="$(mktemp)"
( cd "$GUT_DIR" && dart run "$GUT_DIR/protocol_check.dart" --diff "$EMPTY" --emit-ran 2>/dev/null ) \
  | grep '^RAN' | cut -f2 | sort -u > "$GUT_EMIT"
if ! grep -qxF "52" "$GUT_EMIT"; then ok "H5 gutted gate-52 → its id is NOT emitted by --emit-ran (true proof)"; else bad "H5 gutted gate-52 id should be absent"; fi
GUT_N="$(wc -l < "$GUT_EMIT" | tr -d ' ')"
check "H5 gutted engine emits 19 ids (52 dropped)" "19" "$GUT_N"
# Parity vs the REAL registry must now FAIL (52 enforced but did not run).
( cd "$REPO_ROOT/app_flutter" && dart run "$ENGINE" \
    --verify-registry --emitted "$GUT_EMIT" --registry "$REG" >/dev/null 2>&1 )
GUT_PARITY=$?
if [[ "$GUT_PARITY" != "0" ]]; then ok "H5 gutted-gate ledger → registry parity FAILS (rc=$GUT_PARITY)"; else bad "H5 gutted-gate parity should FAIL (got 0)"; fi
rm -rf "$GUT_DIR" "$GUT_EMIT" "$EMPTY"

# ════════════════════════════════════════════════════════════════════════
#  WORKFLOW shell — quotePath=false on every ls-tree/diff, rc-3 handling, and
#  the reconciliation belt are PRESENT (asserted by grep on the yaml/hook).
# ════════════════════════════════════════════════════════════════════════
WF="$REPO_ROOT/.github/workflows/protocol-enforce.yml"
DP="$REPO_ROOT/.github/workflows/deploy.yml"
PC="$REPO_ROOT/.githooks/pre-commit"
grep -q 'core.quotePath=false .*ls-tree' "$WF"             && ok "WF protocol-enforce ls-tree uses core.quotePath=false" || bad "WF ls-tree quotePath=false"
grep -q 'core.quotePath=false .*diff --name-only' "$WF"    && ok "WF protocol-enforce diff --name-only uses quotePath=false" || bad "WF diff quotePath=false"
grep -q 'core.quotePath=false .*ls-tree' "$DP"             && ok "WF deploy ls-tree uses core.quotePath=false" || bad "WF deploy ls-tree quotePath=false"
grep -q 'core.quotePath=false diff --cached' "$PC"         && ok "pre-commit diff --cached uses quotePath=false" || bad "pre-commit quotePath=false"
grep -qE 'TREE_RC.*-eq 3|DIFF_RC.*-eq 3' "$WF"             && ok "WF protocol-enforce handles rc 3 (H3 fail-closed)" || bad "WF rc-3 handling"
grep -q 'TREE_RC.*-eq 3' "$DP"                             && ok "WF deploy handles rc 3 (H3 fail-closed)" || bad "WF deploy rc-3 handling"
grep -q 'H3 reconciliation: fed==scanned' "$WF"            && ok "WF protocol-enforce asserts the fed==scanned belt" || bad "WF reconciliation belt"
grep -q 'H3 reconciliation: fed==scanned' "$DP"            && ok "WF deploy asserts the fed==scanned belt" || bad "WF deploy reconciliation belt"

echo "═══════════════════════════════════════════════"
echo "v6: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]] || exit 1
exit 0
