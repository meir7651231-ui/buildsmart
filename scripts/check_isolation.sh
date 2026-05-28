#!/bin/bash
# check_isolation.sh — כלל 2: בדיקת בידוד feature
# שימוש: bash scripts/check_isolation.sh lib/features/[name]/
# עובר אם אין imports מ-screens/ — נכשל אם יש

set -e
FEATURE_DIR="${1:-lib/features/}"
ERRORS=0

echo "🔍 בדיקת isolation: $FEATURE_DIR"
echo "─────────────────────────────────"

# בדיקה: אין import מ-screens/
SCREEN_IMPORTS=$(grep -rn "import.*screens/" "$FEATURE_DIR" 2>/dev/null || true)
if [ -n "$SCREEN_IMPORTS" ]; then
  echo "❌ FAIL — imports מ-screens/ (אסור לפי כלל 2):"
  echo "$SCREEN_IMPORTS"
  ERRORS=$((ERRORS + 1))
else
  echo "✅ אין imports מ-screens/"
fi

# בדיקה: אין showDialog / Navigator.push / Scaffold חדש (R2)
R2_VIOLATIONS=$(grep -rn "showDialog\|Navigator\.push\|Navigator\.pushNamed\|showModalBottomSheet\|new Scaffold\|Scaffold(" "$FEATURE_DIR" 2>/dev/null | grep -v "//.*Scaffold" || true)
if [ -n "$R2_VIOLATIONS" ]; then
  echo "❌ FAIL — הפרות R2 (showDialog/Navigator.push/Scaffold):"
  echo "$R2_VIOLATIONS"
  ERRORS=$((ERRORS + 1))
else
  echo "✅ אין הפרות R2"
fi

# בדיקה: כל קובץ helper.dart — אין BuildContext בפרמטרים
CONTEXT_IN_HELPERS=$(grep -rn "BuildContext" "$FEATURE_DIR"/**/helper.dart 2>/dev/null || grep -rn "BuildContext" "$FEATURE_DIR/helper.dart" 2>/dev/null || true)
if [ -n "$CONTEXT_IN_HELPERS" ]; then
  echo "⚠️  WARNING — BuildContext ב-helper (helper חייב להיות pure):"
  echo "$CONTEXT_IN_HELPERS"
fi

# בדיקה: קיים test file
FEATURE_NAME=$(basename "$FEATURE_DIR")
TEST_FILE="test/features/${FEATURE_NAME}_test.dart"
if [ ! -f "$TEST_FILE" ]; then
  echo "❌ FAIL — חסר test file: $TEST_FILE"
  ERRORS=$((ERRORS + 1))
else
  echo "✅ test file קיים: $TEST_FILE"
fi

# בדיקה: מחרוזות עבריות ללא [L#]
HEB_NO_SOURCE=$(grep -rn "[֐-׿]" "$FEATURE_DIR" 2>/dev/null | grep -v "//.*\[L" | grep -v "test" | grep "'" || true)

echo "─────────────────────────────────"
if [ "$ERRORS" -eq 0 ]; then
  echo "✅ ISOLATION CHECK PASSED — מוכן לחיבור"
  exit 0
else
  echo "❌ ISOLATION CHECK FAILED — $ERRORS שגיאות. תקן לפני חיבור."
  exit 1
fi
