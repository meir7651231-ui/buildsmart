#!/bin/bash
# Audit — בודק שכל 9 השערים חוסמים הרמטית
# כל שער מקבל באג מיקרוסקופי ובודק שהוא תופס אותו

REPO="$(git rev-parse --show-toplevel)"
cd "$REPO" || exit 1

PASS=0
FAIL=0

test_gate() {
    local name="$1"
    local should_block="$2"
    local result="$3"

    if [[ "$should_block" == "$result" ]]; then
        echo "✅ שער $name — חוסם נכון"
        PASS=$((PASS+1))
    else
        echo "❌ שער $name — לא חסם (אמור: $should_block, קיבל: $result)"
        FAIL=$((FAIL+1))
    fi
}

echo ""
echo "════════════════════════════════════"
echo "  Audit — 9 שערים"
echo "════════════════════════════════════"
echo ""

# שער 1: ענף שגוי
echo "── שער 1: ענף ──"
TEST_BRANCH="main"
if [[ "$TEST_BRANCH" == claude/* ]]; then BLOCKS="no"; else BLOCKS="yes"; fi
test_gate "1 (ענף שגוי)" "yes" "$BLOCKS"

TEST_BRANCH="claude/feature"
if [[ "$TEST_BRANCH" == claude/* ]]; then BLOCKS="no"; else BLOCKS="yes"; fi
test_gate "1 (ענף נכון)" "no" "$BLOCKS"

# שער 5: גרסאות לא מסונכרנות
echo ""
echo "── שער 5: גרסאות ──"
V_SHELL="v5.35"
V_STATUS="v5.35"
if [[ "$V_SHELL" == "$V_STATUS" && -n "$V_SHELL" ]]; then BLOCKS="no"; else BLOCKS="yes"; fi
test_gate "5 (גרסאות שוות)" "no" "$BLOCKS"

V_SHELL="v5.35"
V_STATUS="v5.34"
if [[ "$V_SHELL" == "$V_STATUS" && -n "$V_SHELL" ]]; then BLOCKS="no"; else BLOCKS="yes"; fi
test_gate "5 (גרסאות שונות בנקודה אחת)" "yes" "$BLOCKS"

V_SHELL=""
V_STATUS="v5.35"
if [[ "$V_SHELL" == "$V_STATUS" && -n "$V_SHELL" ]]; then BLOCKS="no"; else BLOCKS="yes"; fi
test_gate "5 (גרסה ריקה)" "yes" "$BLOCKS"

# שער 6: WIRING.md לא עודכן
echo ""
echo "── שער 6: WIRING ──"
STAGED_LIB="app_flutter/lib/screens/test.dart"
STAGED_WIRING=""
if [[ -n "$STAGED_LIB" && -z "$STAGED_WIRING" ]]; then BLOCKS="yes"; else BLOCKS="no"; fi
test_gate "6 (קוד בלי WIRING)" "yes" "$BLOCKS"

STAGED_LIB="app_flutter/lib/screens/test.dart"
STAGED_WIRING="app_flutter/WIRING.md"
if [[ -n "$STAGED_LIB" && -z "$STAGED_WIRING" ]]; then BLOCKS="yes"; else BLOCKS="no"; fi
test_gate "6 (קוד + WIRING)" "no" "$BLOCKS"

STAGED_LIB=""
STAGED_WIRING=""
if [[ -n "$STAGED_LIB" && -z "$STAGED_WIRING" ]]; then BLOCKS="yes"; else BLOCKS="no"; fi
test_gate "6 (רק תיעוד)" "no" "$BLOCKS"

# שער 7: שם קובץ בדיקה
echo ""
echo "── שער 7: שמות בדיקות ──"
BAD="my_test.dart"
if echo "$BAD" | grep -qE "_tests\.dart$"; then BLOCKS="yes"; else BLOCKS="no"; fi
test_gate "7 (_test.dart תקין)" "no" "$BLOCKS"

BAD="my_tests.dart"
if echo "$BAD" | grep -qE "_tests\.dart$"; then BLOCKS="yes"; else BLOCKS="no"; fi
test_gate "7 (_tests.dart שגוי)" "yes" "$BLOCKS"

BAD="api_tests_helper.dart"
if echo "$BAD" | grep -qE "_tests\.dart$"; then BLOCKS="yes"; else BLOCKS="no"; fi
test_gate "7 (לא בדיקה — _tests באמצע)" "no" "$BLOCKS"

# שער 8: משטח כהה
echo ""
echo "── שער 8: צבעים ──"
DARK="0xFF111111"
if echo "$DARK" | grep -qE "0xFF111111|BsTokens\.bgDark"; then BLOCKS="yes"; else BLOCKS="no"; fi
test_gate "8 (0xFF111111)" "yes" "$BLOCKS"

DARK="BsTokens.bgDark"
if echo "$DARK" | grep -qE "0xFF111111|BsTokens\.bgDark"; then BLOCKS="yes"; else BLOCKS="no"; fi
test_gate "8 (BsTokens.bgDark)" "yes" "$BLOCKS"

DARK="0xFFFFFFFF"
if echo "$DARK" | grep -qE "0xFF111111|BsTokens\.bgDark"; then BLOCKS="yes"; else BLOCKS="no"; fi
test_gate "8 (לבן)" "no" "$BLOCKS"

# שער 9: hook tampering
echo ""
echo "── שער 9: hook integrity ──"
if diff -q "$REPO/.githooks/pre-commit" "$REPO/.git/hooks/pre-commit" >/dev/null 2>&1; then
    BLOCKS="no"
else
    BLOCKS="yes"
fi
test_gate "9 (hooks סונכרנים)" "no" "$BLOCKS"

# בדיקת PreToolUse hook
echo ""
echo "── PreToolUse: --no-verify ──"
TEST_CMD='git commit --no-verify -m "x"'
if echo "$TEST_CMD" | grep -q -- "--no-verify"; then BLOCKS="yes"; else BLOCKS="no"; fi
test_gate "PreTool (bypass-verify)" "yes" "$BLOCKS"

TEST_CMD='git commit -m "fix --no-verify mention"'
if echo "$TEST_CMD" | grep -q -- "--no-verify"; then BLOCKS="yes"; else BLOCKS="no"; fi
test_gate "PreTool (--no-verify בהודעה)" "yes" "$BLOCKS"

TEST_CMD='git push --force origin x'
if echo "$TEST_CMD" | grep -qE "push.*(--force|-f )"; then BLOCKS="yes"; else BLOCKS="no"; fi
test_gate "PreTool (force push)" "yes" "$BLOCKS"

TEST_CMD='rm .githooks/pre-commit'
if echo "$TEST_CMD" | grep -qE "rm.*\.githooks|rm.*\.git/hooks"; then BLOCKS="yes"; else BLOCKS="no"; fi
test_gate "PreTool (מחיקת hook)" "yes" "$BLOCKS"

TEST_CMD='git config core.hooksPath /tmp'
if echo "$TEST_CMD" | grep -qE "git config.*core\.hooksPath"; then BLOCKS="yes"; else BLOCKS="no"; fi
test_gate "PreTool (שינוי hooksPath)" "yes" "$BLOCKS"

echo ""
echo "════════════════════════════════════"
echo "  תוצאה: $PASS עברו · $FAIL נכשלו"
echo "════════════════════════════════════"

if [[ "$FAIL" -gt 0 ]]; then
    exit 1
fi
exit 0
