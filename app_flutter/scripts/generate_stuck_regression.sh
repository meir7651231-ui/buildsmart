#!/bin/bash
# מייצר test/stuck_regression_test.dart מתוך knowledge/stuck_log.md
# כל ANTIPATTERN: regex הופך לבדיקה אוטומטית שרצה לנצח

REPO_ROOT="$(git rev-parse --show-toplevel)"
STUCK_LOG="$REPO_ROOT/app_flutter/knowledge/stuck_log.md"
OUT="$REPO_ROOT/app_flutter/test/stuck_regression_test.dart"

if [[ ! -f "$STUCK_LOG" ]]; then
    exit 0
fi

# חלץ ANTIPATTERN-ים (tr -d '\r' מונע CRLF-corruption על Windows/MSYS)
PATTERNS=$(grep "^ANTIPATTERN:" "$STUCK_LOG" 2>/dev/null | sed 's/^ANTIPATTERN: //' | tr -d '\r')

if [[ -z "$PATTERNS" ]]; then
    # אין רשומות אמיתיות — צור test ריק
    cat > "$OUT" << 'EOF'
// generated from knowledge/stuck_log.md
// אין אנטי-פטרנים מתועדים עדיין.
import 'package:flutter_test/flutter_test.dart';
void main() {
  test('stuck_log empty — no antipatterns to check', () {
    expect(true, isTrue);
  });
}
EOF
    exit 0
fi

# בנה test שסורק את כל lib/ לכל אנטי-פטרן
cat > "$OUT" << 'HEADER'
// ⚠️ AUTO-GENERATED from knowledge/stuck_log.md — אל תערוך ידנית
// כל ANTIPATTERN: שמתועד ב-stuck_log.md הופך לבדיקה רגרסיה לנצח.
// אם בדיקה כאן נכשלת = הבאג חזר. ראה stuck_log.md לפתרון.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('stuck_log regression — אנטי-פטרנים שלא חוזרים', () {
HEADER

# הוסף test לכל pattern
LINE_NUM=0
while IFS= read -r pattern; do
    pattern=$(echo "$pattern" | tr -d '\r')  # strip CRLF (Windows/MSYS)
    [[ -z "$pattern" ]] && continue
    LINE_NUM=$((LINE_NUM + 1))
    # ב-raw string של dart (r'''...''') backslash בודד הוא literal — לא לכפול
    pattern_for_dart="$pattern"
    # ל-title של הtest: escape אפוסטרופים בלבד
    pattern_for_title=$(echo "$pattern" | sed "s/'/\\\\'/g")
    cat >> "$OUT" << TESTEOF

    test("antipattern #${LINE_NUM} לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp(r'''${pattern_for_dart}''');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('\${entity.path}: \${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });
TESTEOF
done <<< "$PATTERNS"

cat >> "$OUT" << 'FOOTER'
  });
}
FOOTER

echo "✅ נוצר $OUT עם $LINE_NUM אנטי-פטרנים"
