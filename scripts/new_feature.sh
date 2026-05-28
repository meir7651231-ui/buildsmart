#!/bin/bash
# new_feature.sh — scaffold feature חדש לפי כלל 2 (בידוד)
# שימוש: bash scripts/new_feature.sh rank_engine
# יוצר: lib/features/[name]/{model,helper,widget}.dart + test/features/[name]_test.dart

set -e

FEATURE="${1:-}"
if [ -z "$FEATURE" ]; then
  echo "שימוש: bash scripts/new_feature.sh [feature_name]"
  echo "דוגמה: bash scripts/new_feature.sh rank_engine"
  exit 1
fi

BASE="app_flutter/lib/features/$FEATURE"
TEST="app_flutter/test/features/${FEATURE}_test.dart"

mkdir -p "$BASE"
mkdir -p "app_flutter/test/features"

# ── model.dart ───────────────────────────────────────────────────────────────
cat > "$BASE/model.dart" << DART
// $FEATURE/model.dart — data classes + enums only.
// מקור: proto [L????] — חובה למלא לפני קוד!
// אין UI · אין BuildContext · אין import מ-screens/

// TODO: הגדר כאן data classes + enums בלבד.
DART

# ── helper.dart ──────────────────────────────────────────────────────────────
cat > "$BASE/helper.dart" << DART
// $FEATURE/helper.dart — pure functions only.
// מקור: proto [L????] — חובה למלא לפני קוד!
// כלל: אין BuildContext · אין ref · אין side-effects

// TODO: הגדר כאן פונקציות טהורות בלבד.
// ReturnType helperName(params) { ... }
DART

# ── widget.dart ──────────────────────────────────────────────────────────────
cat > "$BASE/widget.dart" << DART
// $FEATURE/widget.dart — dial widget.
// מקור: proto [L????]
// כלל: DialRow + DialColumn בלבד — אסור Scaffold/Navigator/showDialog

import 'package:flutter/material.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/dial.dart';
// ✅ מותר:  data/ · state/ · theme/ · widgets/
// ❌ אסור:  screens/

// TODO: בנה את ה-dial widget כאן.
DART

# ── test file ────────────────────────────────────────────────────────────────
cat > "$TEST" << DART
// test/features/${FEATURE}_test.dart
// בדיקות מבודדות — חייב לעבור לפני כל חיבור לשל.
// flutter test test/features/${FEATURE}_test.dart

import 'package:flutter_test/flutter_test.dart';

import '../helpers/feature_isolation_test_base.dart';
// import 'package:buildsmart/features/$FEATURE/model.dart';
// import 'package:buildsmart/features/$FEATURE/helper.dart';

class _IsolationTest extends FeatureIsolationTestBase {
  @override
  String get featureName => '$FEATURE';

  @override
  List<String> get featureFiles => [
        'lib/features/$FEATURE/model.dart',
        'lib/features/$FEATURE/helper.dart',
        'lib/features/$FEATURE/widget.dart',
      ];
}

void main() {
  _IsolationTest().runIsolationChecks();

  group('$FEATURE — unit tests', () {
    // TODO: הוסף unit tests לכל helper לפי תנאי-גבול.
    test('placeholder — replace with real tests', () {
      expect(true, isTrue);
    });
  });
}
DART

chmod +x "$BASE/widget.dart" 2>/dev/null || true

echo ""
echo "✅  scaffold נוצר:"
echo "    $BASE/model.dart"
echo "    $BASE/helper.dart"
echo "    $BASE/widget.dart"
echo "    $TEST"
echo ""
echo "📋  ISOLATION CHECKLIST — לפני חיבור ל-shell:"
echo ""
echo "  [ ] 1.  מלא model.dart    — data classes, proto [L####]"
echo "  [ ] 2.  מלא helper.dart   — pure functions, proto [L####]"
echo "  [ ] 3.  כתוב unit tests   — כל תנאי-גבול"
echo "  [ ] 4.  flutter test test/features/${FEATURE}_test.dart → 0 failures"
echo "  [ ] 5.  מלא widget.dart   — DialRow/DialColumn בלבד"
echo "  [ ] 6.  flutter analyze test/features/${FEATURE}_test.dart → 0 issues"
echo "  [ ] 7.  flutter analyze lib/features/$FEATURE/ → 0 issues"
echo "  [ ] 8.  flutter test (הכל) → עדיין 0 failures"
echo "  [ ] 9.  חבר ל-shell/menu  — רק אחרי 1-8 ירוקים"
echo "  [ ] 10. commit"
echo ""
echo "🔑  אימות verbatim: grep -n 'מחרוזת' /home/user/buildsmart/index.html"
