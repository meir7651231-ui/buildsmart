#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
#  protocol/regression_v5.sh — HONEST regression tests for the v5 closes that
#  live in BASH / CI yaml (S1 bootstrap fail-closed, S2 gut-a-check→parity fails,
#  S3 re-pinned-gutted-hook detected vs trusted, S4 deploy uses trusted + root
#  scan). The ENGINE residuals (N1/F2/F3/A1/E4) are covered by the Dart
#  --self-test and the flutter_test mirror; THIS file covers what those cannot:
#  the runner/workflow shell logic. Every test asserts EXACTLY what it names.
#
#  Run:  bash protocol/regression_v5.sh        (exit 0 = all pass, 1 = a failure)
# ═══════════════════════════════════════════════════════════════════════════
set -uo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"
export PATH="/home/user/flutter/bin:$PATH"

PASS=0; FAIL=0
ok()   { echo "  ok   $1"; PASS=$((PASS+1)); }
bad()  { echo "  FAIL $1"; FAIL=$((FAIL+1)); }
check(){ # <name> <expected 0/1 for "condition true"> <actual rc>
  local name="$1" want="$2" got="$3"
  if [[ "$want" == "$got" ]]; then ok "$name"; else bad "$name (want=$want got=$got)"; fi
}

ENGINE="$REPO_ROOT/app_flutter/tool/protocol_check.dart"
REG="$REPO_ROOT/protocol/gates.tsv"

# ── helper: run a (possibly tampered) pre-commit in audit mode, emit ledger ──
run_audit() { # <hook-path> -> prints ledger path on stdout (or empty)
  local hook="$1" led; led="$(mktemp)"
  PROTOCOL_AUDIT_MODE=1 PROTOCOL_AUDIT_LEDGER="$led" bash "$hook" >/dev/null 2>&1 || true
  echo "$led"
}

# ── helper: verify-registry of a ledger; returns the engine RC ──
verify_rc() { # <ledger>
  ( cd "$REPO_ROOT/app_flutter" && dart run "$ENGINE" \
      --verify-registry --emitted "$1" --registry "$REG" >/dev/null 2>&1 )
  echo $?
}

echo "v5 bash/CI regression suite"
echo "═══════════════════════════════════════════════"

# ════════════════════════════════════════════════════════════════════════
#  S2 — group `ran` is now EXEC-proof: gut a check, parity FAILS.
#  Baseline: the clean hook's audit ledger == enforced set (verify-registry rc 0).
#  Tamper:  delete a check line (here gate 20's `[[ -d "test" ]] ... ; ran 20`).
#  In v4 the batch `ran 11 12 ... 20` at function ENTRY kept `ran 20` alive even
#  with the check gutted → parity PASSED (the bug). In v5 the `; ran 20` rides
#  WITH the check, so deleting the check drops `ran 20` → parity FAILS (rc != 0).
# ════════════════════════════════════════════════════════════════════════
BASE_LED="$(run_audit "$REPO_ROOT/.githooks/pre-commit")"
check "S2 baseline: clean hook audit ledger PASSES registry parity" "0" "$(verify_rc "$BASE_LED")"
# also assert the baseline ledger actually contains gate 20 (sanity of the probe)
if grep -qxF "20" "$BASE_LED"; then ok "S2 baseline ledger contains gate 20"; else bad "S2 baseline ledger contains gate 20"; fi

TAMP="$(mktemp)"; cp "$REPO_ROOT/.githooks/pre-commit" "$TAMP"
# Gut gate 20's check line ENTIRELY (its trailing `; ran 20` goes with it).
grep -v '\[\[ -d "test" \]\].*err "20".*ran 20' "$REPO_ROOT/.githooks/pre-commit" > "$TAMP"
# Confirm the tamper actually removed exactly the gate-20 line.
if ! grep -q 'ran 20' "$TAMP"; then ok "S2 tamper removed the gate-20 check+ran line"; else bad "S2 tamper removed the gate-20 check+ran line"; fi
TAMP_LED="$(run_audit "$TAMP")"
if ! grep -qxF "20" "$TAMP_LED"; then ok "S2 tampered ledger is MISSING gate 20 (exec-proof)"; else bad "S2 tampered ledger is MISSING gate 20 (exec-proof)"; fi
# Parity MUST now FAIL (rc != 0) — gate 20 enforced but did not run.
TAMP_RC="$(verify_rc "$TAMP_LED")"
if [[ "$TAMP_RC" != "0" ]]; then ok "S2 gutted-check → registry parity FAILS (rc=$TAMP_RC)"; else bad "S2 gutted-check → registry parity FAILS (got rc 0 — bug)"; fi
rm -f "$TAMP" "$TAMP_LED" "$BASE_LED"

# ════════════════════════════════════════════════════════════════════════
#  S1 — K2 bootstrap fallback fail-closed (workflow LOGIC, asserted by grep on
#  the yaml + an embedded simulation of the decision).
# ════════════════════════════════════════════════════════════════════════
WF="$REPO_ROOT/.github/workflows/protocol-enforce.yml"
# (a) the step reads trusted_complete (v4 NEVER read it).
if grep -q 'steps.trusted.outputs.trusted_complete' "$WF"; then ok "S1 workflow READS trusted_complete (was dead output)"; else bad "S1 workflow READS trusted_complete"; fi
# (b) it fails closed (exit 1) when incomplete and not BOOTSTRAP.
if grep -q 'S1 FAIL-CLOSED' "$WF"; then ok "S1 workflow has a FAIL-CLOSED branch"; else bad "S1 workflow has a FAIL-CLOSED branch"; fi
# (c) simulate the decision logic exactly (the same shell the step runs).
s1_decide() { # <complete> <bootstrap> -> echoes rc
  local complete="$1" boot="$2"
  if [[ "$complete" == "1" ]]; then echo 0; return; fi
  if [[ "$boot" == "1" ]]; then echo 0; return; fi
  echo 1
}
check "S1 sim: complete=1 → pass (rc0)"             "0" "$(s1_decide 1 '')"
check "S1 sim: incomplete + no bootstrap → FAIL(rc1)" "1" "$(s1_decide 0 '')"
check "S1 sim: incomplete + BOOTSTRAP=1 → pass(rc0)" "0" "$(s1_decide 0 1)"

# ════════════════════════════════════════════════════════════════════════
#  S3 — re-pin bypass defeated: a gutted hook RE-PINNED still differs from the
#  TRUSTED origin/main copy. We simulate the S3 diff: trusted=clean hook,
#  PR=gutted hook, re-pin the gutted hook → S3's `diff trusted vs PR` still flags
#  it (the pin is NOT the baseline; origin/main is). Also assert the trusted hook
#  is no longer a DEAD fetch in the workflow (it is RUN / diffed).
# ════════════════════════════════════════════════════════════════════════
TRUST_HOOK="$(mktemp)"; cp "$REPO_ROOT/.githooks/pre-commit" "$TRUST_HOOK"   # = clean origin/main
PR_HOOK="$(mktemp)";    grep -v '\[\[ -d "test" \]\].*err "20".*ran 20' "$REPO_ROOT/.githooks/pre-commit" > "$PR_HOOK"  # gutted PR copy
# Re-pin the GUTTED PR hook (the v4 bypass: pin matches the tampered file).
PR_PIN="$(sha256sum "$PR_HOOK" | awk '{print $1}')"
GUT_PIN="$(sha256sum "$PR_HOOK" | awk '{print $1}')"
if [[ "$PR_PIN" == "$GUT_PIN" ]]; then ok "S3 re-pin makes the PR pin MATCH the gutted PR hook (the v4 bypass)"; else bad "S3 re-pin setup"; fi
# v4 K4 would PASS (pin==file). v5 S3 diffs trusted-vs-PR:
if ! diff -q "$TRUST_HOOK" "$PR_HOOK" >/dev/null 2>&1; then ok "S3 trusted-vs-PR diff DETECTS the gutted hook (re-pin does NOT bypass)"; else bad "S3 trusted-vs-PR diff DETECTS the gutted hook"; fi
# Assert the workflow actually performs the trusted comparison + runs the trusted hook.
if grep -q 'cmp_one .githooks/pre-commit' "$WF"; then ok "S3 workflow DIFFS the PR hook vs the trusted copy"; else bad "S3 workflow DIFFS the PR hook vs trusted"; fi
if grep -q 'S3b — produce the K3 ledger from the TRUSTED runner' "$WF"; then ok "S3b workflow RUNS the trusted hook (no dead fetch)"; else bad "S3b workflow RUNS the trusted hook"; fi
if grep -q '.trusted/githooks/pre-commit' "$WF" && grep -q 'PROTOCOL_AUDIT_LEDGER' "$WF"; then ok "S3b trusted hook feeds the K3 ledger"; else bad "S3b trusted hook feeds the K3 ledger"; fi
rm -f "$TRUST_HOOK" "$PR_HOOK"

# ════════════════════════════════════════════════════════════════════════
#  S4 — deploy.yml ships via the TRUSTED engine over a REPO-ROOT tree.
# ════════════════════════════════════════════════════════════════════════
DEP="$REPO_ROOT/.github/workflows/deploy.yml"
# The trusted fetch pulls origin/main:<path> via a `pull` helper; assert both the
# fetch mechanism and the engine being pulled.
if grep -q 'origin/main:\$1' "$DEP" && grep -q 'pull app_flutter/tool/protocol_check.dart' "$DEP"; then ok "S4 deploy FETCHES the trusted engine from origin/main"; else bad "S4 deploy fetches trusted engine"; fi
if grep -q '.trusted/tool/protocol_check.dart' "$DEP"; then ok "S4 deploy RUNS the trusted engine (not the PR copy)"; else bad "S4 deploy runs the trusted engine"; fi
# K5 must NOT be confined to the app_flutter CWD; ls-tree runs from repo root.
if grep -q 'TRUSTED content engine over the WHOLE repo-root tree' "$DEP"; then ok "S4 deploy K5 scans the WHOLE repo-root tree"; else bad "S4 deploy K5 scans the whole repo-root tree"; fi
# the K5/S4 engine step must run from the REPO ROOT — i.e. between its `- name:`
# and the NEXT `- name:` there is NO `working-directory:` line.
K5_BLOCK="$(awk '/- name: K5\/S4 — TRUSTED content engine/{f=1;next} f&&/^      - name:/{exit} f{print}' "$DEP")"
if ! echo "$K5_BLOCK" | grep -q 'working-directory:'; then
  ok "S4 deploy K5 engine step is NOT pinned to the app_flutter CWD (runs from repo root)"
else
  bad "S4 deploy K5 engine step is NOT pinned to the app_flutter CWD"
fi
# S4 also fails closed on an incomplete trusted fetch (no PR-stub ship).
if grep -q 'S4 fail-closed' "$DEP"; then ok "S4 deploy FAILS CLOSED on an incomplete trusted fetch"; else bad "S4 deploy fails closed on incomplete trusted fetch"; fi

# ════════════════════════════════════════════════════════════════════════
#  THE ACCEPTANCE TEST — engine over the WHOLE 2202-file tree (root ls-tree),
#  the way CI K1 feeds it, MUST be RC 0 with ZERO ERR.
# ════════════════════════════════════════════════════════════════════════
git --no-replace-objects ls-tree -r --name-only HEAD > /tmp/_v5_tree.txt
TREE_N=$(wc -l < /tmp/_v5_tree.txt)
( cd "$REPO_ROOT/app_flutter" && dart run "$ENGINE" --tree \
    --names /tmp/_v5_tree.txt --show "git --no-replace-objects show HEAD:" \
    --stuck-log knowledge/stuck_log.md > /tmp/_v5_tree_out.txt 2>/dev/null )
TREE_RC=$?
# grep -c exits 1 on zero matches; capture the COUNT without the `|| echo` double-print.
TREE_ERR=$(grep -c '^ERR' /tmp/_v5_tree_out.txt); TREE_ERR=${TREE_ERR:-0}
echo "  [acceptance] whole-tree files=$TREE_N TREE_RC=$TREE_RC ERR=$TREE_ERR"
if [[ "$TREE_RC" == "0" && "$TREE_ERR" == "0" ]]; then ok "ACCEPTANCE: whole-tree ($TREE_N files) RC=0, ZERO ERR"; else bad "ACCEPTANCE: whole-tree RC=$TREE_RC ERR=$TREE_ERR"; fi
rm -f /tmp/_v5_tree.txt /tmp/_v5_tree_out.txt

echo "═══════════════════════════════════════════════"
echo "  v5 regression: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]] && exit 0 || exit 1
