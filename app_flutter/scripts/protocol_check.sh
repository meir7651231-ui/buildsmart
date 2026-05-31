#!/bin/bash

# בדיקת פרוטוקול מלאה — מריצים לפני כל commit ולפני כל push
# לא ניתן לעקוף — כל שגיאה = עצירה מלאה

export PATH="/home/user/flutter/bin:$PATH"
cd /home/user/buildsmart/app_flutter

PASS=0
FAIL=0

ok()   { echo "✅ $1"; PASS=$((PASS+1)); }
fail() { echo "❌ $1"; FAIL=$((FAIL+1)); }
warn() { echo "⚠️  $1"; }

echo ""
echo "════════════════════════════════════════"
echo "  בדיקת פרוטוקול BuildSmart Flutter"
echo "════════════════════════════════════════"
echo ""

# ─── שער 1: ניתוח קוד ───
echo "[ שער 1 ] ניתוח קוד"
if flutter analyze --no-pub 2>&1 | grep -q "No issues found"; then
    ok "ניתוח קוד נקי"
else
    fail "יש שגיאות בניתוח הקוד — חובה לתקן לפני המשך"
fi

# ─── שער 2: בדיקות ───
echo ""
echo "[ שער 2 ] בדיקות"
TEST_OUTPUT=$(flutter test --no-pub 2>&1)
TEST_COUNT=$(echo "$TEST_OUTPUT" | grep -E "^\+[0-9]+" | tail -1 | grep -oE "^\+[0-9]+" | tr -d '+')
if echo "$TEST_OUTPUT" | tail -10 | grep -q "All tests passed\|tests passed"; then
    ok "כל הבדיקות ירוקות ($TEST_COUNT בדיקות)"
else
    fail "יש בדיקות שנכשלות"
    echo "$TEST_OUTPUT" | grep -E "FAILED|Error" | head -10
fi

# ─── שער 3: בנייה לאינטרנט ───
echo ""
echo "[ שער 3 ] בנייה לאינטרנט"
if flutter build web --release --no-pub 2>&1 | tail -3 | grep -q "Built"; then
    ok "בנייה הצליחה"
else
    fail "הבנייה נכשלה"
fi

# ─── שער 4: סנכרון גרסאות ───
echo ""
echo "[ שער 4 ] סנכרון גרסאות"
VERSION_SHELL=$(grep -oE "v[0-9]+\.[0-9]+" lib/screens/home_shell.dart | head -1)
VERSION_STATUS=$(grep -oE "v[0-9]+\.[0-9]+" knowledge/STATUS.md | head -1)
if [[ "$VERSION_SHELL" == "$VERSION_STATUS" ]]; then
    ok "גרסאות מסונכרנות ($VERSION_SHELL)"
else
    fail "גרסאות לא מסונכרנות: home_shell=$VERSION_SHELL, STATUS=$VERSION_STATUS"
fi

# ─── שער 5: WIRING.md קיים ומעודכן ───
echo ""
echo "[ שער 5 ] קובץ החיווט"
if [[ -f "../WIRING.md" ]]; then
    WIRING_LINES=$(grep -c "✅\|🚧\|⛔" ../WIRING.md 2>/dev/null || echo "0")
    ok "קובץ החיווט קיים ($WIRING_LINES שורות)"
else
    fail "קובץ החיווט לא נמצא"
fi

# ─── שער 6: אין surface כהה ───
echo ""
echo "[ שער 6 ] בדיקת צבע רקע"
DARK=$(grep -rn "0xFF111111\|BsTokens.bgDark" lib/screens/ 2>/dev/null | grep -v "_test\|//")
if [[ -z "$DARK" ]]; then
    ok "אין משטחים כהים"
else
    fail "נמצאו משטחים כהים:"
    echo "$DARK"
fi

# ─── שער 7: ענף עבודה נכון ───
echo ""
echo "[ שער 7 ] ענף עבודה"
BRANCH=$(git branch --show-current)
if [[ "$BRANCH" == "claude/whats-happening-LyY9G" ]]; then
    ok "על הענף הנכון ($BRANCH)"
else
    fail "על הענף הלא נכון: $BRANCH (צריך: claude/whats-happening-LyY9G)"
fi

# ─── שער 8: אין שינויים לא שמורים ───
echo ""
echo "[ שער 8 ] שינויים לא שמורים"
if git diff --quiet && git diff --cached --quiet; then
    ok "אין שינויים לא שמורים"
else
    warn "יש שינויים לא שמורים — שמור אותם לפני push"
fi

# ─── תוצאה סופית ───
echo ""
echo "════════════════════════════════════════"
echo "  תוצאה: $PASS עברו | $FAIL נכשלו"
echo "════════════════════════════════════════"
echo ""

if [[ "$FAIL" -gt 0 ]]; then
    echo "❌ הפרוטוקול לא עבר — תקן את השגיאות לפני המשך."
    exit 1
else
    echo "✅ הפרוטוקול עבר — מותר להמשיך."
    exit 0
fi
