#!/bin/bash
# מייצר test/stuck_regression_test.dart מתוך knowledge/stuck_log.md
# כל ANTIPATTERN: regex הופך לבדיקה אוטומטית שרצה לנצח.
#
# שני סוגים:
#   ANTIPATTERN:        regex  → סורק את כל lib/ (קוד Dart)
#   ANTIPATTERN[hook]:  regex  → סורק את ../.githooks/pre-commit (קוד bash)
# (תיקון אודיט 2026-06-01: 17/31 אנטי-פטרנים הם hook-bash. עד לתיקון הם סרקו
#  lib/ לחינם — שער 109 החזיר את אנטי-פטרן #27 בלי שאף בדיקה תפסה.)

REPO_ROOT="$(git rev-parse --show-toplevel)"
STUCK_LOG="$REPO_ROOT/app_flutter/knowledge/stuck_log.md"
OUT="$REPO_ROOT/app_flutter/test/stuck_regression_test.dart"

if [[ ! -f "$STUCK_LOG" ]]; then
    exit 0
fi

# חלץ שורות ANTIPATTERN (כולל הצורה המתויגת [hook]). tr -d '\r' מונע CRLF.
RAW=$(grep -E "^ANTIPATTERN(\[hook\])?:" "$STUCK_LOG" 2>/dev/null | tr -d '\r')

if [[ -z "$RAW" ]]; then
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

# בנה test
cat > "$OUT" << 'HEADER'
// ⚠️ AUTO-GENERATED from knowledge/stuck_log.md — אל תערוך ידנית
// כל ANTIPATTERN: שמתועד ב-stuck_log.md הופך לבדיקה רגרסיה לנצח.
// ANTIPATTERN:       → סורק lib/ (Dart).  ANTIPATTERN[hook]: → סורק ../.githooks/pre-commit (bash).
// אם בדיקה כאן נכשלת = הבאג חזר. ראה stuck_log.md לפתרון.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('stuck_log regression — אנטי-פטרנים שלא חוזרים', () {
HEADER

# הוסף test לכל pattern
LINE_NUM=0
while IFS= read -r raw; do
    raw=$(echo "$raw" | tr -d '\r')
    [[ -z "$raw" ]] && continue
    LINE_NUM=$((LINE_NUM + 1))

    # זהה סוג + חלץ את ה-regex עצמו
    if [[ "$raw" == ANTIPATTERN\[hook\]:* ]]; then
        target="hook"
        pattern="${raw#ANTIPATTERN\[hook\]: }"
    else
        target="lib"
        pattern="${raw#ANTIPATTERN: }"
    fi
    [[ -z "$pattern" ]] && continue
    # הקשחה (דיווח קטלגן 2026-06-01, commit 4ad3dbb): pattern שמתחיל/נגמר ב-'
    # שובר את עטיפת `r'''…'''` (4 גרשים רצופים בגבול ⇒ שגיאת קומפילציה ⇒ כל
    # הסוויטה נשברת לכל הסוכנים). פתרון כללי: escape ל-Dart string רגיל (לא-raw).
    # סדר קריטי — backslash ראשון: כל `\` ⇒ `\\`, ואז אין "unknown escape" ב-Dart.
    pattern_for_dart="$pattern"
    pattern_for_dart="${pattern_for_dart//\\/\\\\}"   # \  → \\
    pattern_for_dart="${pattern_for_dart//\$/\\\$}"   # $  → \$
    pattern_for_dart="${pattern_for_dart//\'/\\\'}"   # '  → \'

    if [[ "$target" == "hook" ]]; then
        cat >> "$OUT" << TESTEOF

    test("antipattern #${LINE_NUM} (hook) לא קיים ב-.githooks/pre-commit", () {
      final hook = File('../.githooks/pre-commit');
      if (!hook.existsSync()) {
        // הריצה אולי לא מ-app_flutter/ — דלג בלי לשבור.
        return;
      }
      final matches = <String>[];
      final re = RegExp('${pattern_for_dart}');
      final lines = hook.readAsStringSync().split('\n');
      for (final line in lines) {
        // התעלם משורות הערה (מתחילות ב-# אחרי whitespace) — תיעוד התיקון מותר.
        if (RegExp(r'^\s*#').hasMatch(line)) continue;
        if (re.hasMatch(line)) matches.add(line.trim());
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });
TESTEOF
    else
        cat >> "$OUT" << TESTEOF

    test("antipattern #${LINE_NUM} לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('${pattern_for_dart}');
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
    fi
done <<< "$RAW"

cat >> "$OUT" << 'FOOTER'
  });
}
FOOTER

echo "✅ נוצר $OUT עם $LINE_NUM אנטי-פטרנים"
