#!/bin/bash
# new_feature.sh — scaffold פיצ׳ר חדש לפי כלל 2 (בידוד)
# שימוש: bash scripts/new_feature.sh rank_engine
# יוצר lib/features/[name]/ + test/features/[name]_test.dart

set -e
FEATURE="$1"

if [ -z "$FEATURE" ]; then
  echo "שימוש: bash scripts/new_feature.sh [feature_name]"
  echo "דוגמה: bash scripts/new_feature.sh rank_engine"
  exit 1
fi

BASE="app_flutter/lib/features/$FEATURE"
TEST="app_flutter/test/features/${FEATURE}_test.dart"

mkdir -p "$BASE"
mkdir -p "app_flutter/test/features"

# model.dart
cat > "$BASE/model.dart" << EOF
// $FEATURE/model.dart — data classes + enums
// מקור: proto [L????] — למלא לפני קוד!

// TODO: הגדר כאן את ה-data classes וה-enums בלבד
// אין UI, אין BuildContext, אין ייבוא מ-screens/
EOF

# helper.dart
cat > "$BASE/helper.dart" << EOF
// $FEATURE/helper.dart — pure functions
// מקור: proto [L????] — למלא לפני קוד!
// כלל: אין BuildContext, אין ref, אין side-effects

// TODO: הגדר כאן פונקציות טהורות בלבד
// דוגמה:
// ReturnType helperName(params) {
//   // logic בלבד
// }
EOF

# widget.dart
cat > "$BASE/widget.dart" << EOF
// $FEATURE/widget.dart — dial widget
// מקור: proto [L????]
// כלל: DialRow + DialColumn בלבד — אסור Scaffold/Navigator/showDialog

import 'package:flutter/material.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/dial.dart';
// ✅ מותר: data/ state/ theme/ widgets/
// ❌ אסור: screens/

// TODO: בנה את ה-dial widget כאן
// class ${FEATURE^}Widget extends StatelessWidget { ... }
EOF

# test file
cat > "$TEST" << EOF
// test/features/${FEATURE}_test.dart
// בדיקות מבודדות — רצות לפני כל חיבור לשל
// flutter test test/features/${FEATURE}_test.dart

import 'package:flutter_test/flutter_test.dart';
// import 'package:buildsmart/features/$FEATURE/model.dart';
// import 'package:buildsmart/features/$FEATURE/helper.dart';

void main() {
  group('$FEATURE — isolation tests', () {
    // TODO: בדוק כל helper לפי תנאי-גבול
    // test('TODO', () {
    //   expect(helperName(input), expected);
    // });

    test('placeholder — remove when real tests added', () {
      expect(true, isTrue);
    });
  });
}
EOF

echo ""
echo "✅ Feature scaffold נוצר: $BASE"
echo ""
echo "📋 ISOLATION CHECKLIST — לפני חיבור ל-shell:"
echo "  [ ] 1. מלא model.dart — data classes בלבד"
echo "  [ ] 2. מלא helper.dart — pure functions"
echo "  [ ] 3. כתוב בדיקות ב-$TEST"
echo "  [ ] 4. flutter test test/features/${FEATURE}_test.dart → 0 failures"
echo "  [ ] 5. מלא widget.dart — dial בלבד (לא Scaffold)"
echo "  [ ] 6. bash scripts/check_isolation.sh $BASE → PASSED"
echo "  [ ] 7. flutter analyze → 0 errors"
echo "  [ ] 8. רק אז → חבר ל-shell/menu"
echo ""
echo "🔑 מקור: grep -n 'מחרוזת' /home/user/buildsmart/index.html"
