#!/bin/bash
# BuildSmart — שער אימות מלא ל-app_flutter בפקודה אחת.
#   bash scripts/verify-flutter.sh          # analyze + test + build web
#   bash scripts/verify-flutter.sh --fast   # analyze + test בלבד (בלי build)
# נכשל על: שגיאת analyze, אזהרת analyze חדשה, טסט אדום, build שבור.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="${FLUTTER_HOME:-/home/user/flutter}/bin:$PATH"
cd "$REPO/app_flutter"

command -v flutter >/dev/null || { echo "❌ flutter לא ב-PATH — הרץ scripts/bootstrap-env.sh"; exit 1; }

echo "═══ 1/3 flutter analyze ═══"
ANALYZE_OUT="$(flutter analyze --no-pub 2>&1)"
ERRORS=$(echo "$ANALYZE_OUT" | grep -cE "^\s*error •" || true)
WARNINGS=$(echo "$ANALYZE_OUT" | grep -cE "^\s*warning •" || true)
INFOS=$(echo "$ANALYZE_OUT" | grep -cE "^\s*info •" || true)
echo "errors=$ERRORS warnings=$WARNINGS infos=$INFOS"
if [ "$ERRORS" -gt 0 ]; then
  echo "$ANALYZE_OUT" | grep -E "^\s*error •" | head -20
  echo "❌ analyze: $ERRORS שגיאות"; exit 1
fi
if [ "$WARNINGS" -gt 0 ]; then
  echo "$ANALYZE_OUT" | grep -E "^\s*warning •" | head -40
  echo "❌ analyze: $WARNINGS אזהרות — הסטנדרט הוא 0"; exit 1
fi

echo "═══ 2/3 flutter test ═══"
flutter test 2>&1 | tail -2 | head -1
TEST_EXIT=${PIPESTATUS[0]}
[ "$TEST_EXIT" -eq 0 ] || { echo "❌ flutter test נכשל"; exit 1; }

if [ "${1:-}" != "--fast" ]; then
  echo "═══ 3/3 flutter build web --release ═══"
  flutter build web --release 2>&1 | tail -2
  BUILD_EXIT=${PIPESTATUS[0]}
  [ "$BUILD_EXIT" -eq 0 ] || { echo "❌ build נכשל"; exit 1; }
fi

echo "✅ verify-flutter עבר במלואו"
