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
# Output path is overridable (STUCK_REGEN_OUT) so the pre-commit gate 111 can
# regenerate to a TEMP file and byte-diff it against the committed one (R5
# tamper-evidence) without clobbering the real file. Default = the real file.
OUT="${STUCK_REGEN_OUT:-$REPO_ROOT/app_flutter/test/stuck_regression_test.dart}"

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
//
// ⚠️ V10-A — ReDoS guard. Each ANTIPATTERN regex is matched under a HARD
// wall-clock budget in a throwaway isolate (_boundedHasMatch). A catastrophic
// pattern (e.g. `(a+)+$`) that would hang Dart's backtracking RegExp FOREVER —
// bricking `flutter test` for everyone — is instead KILLED at the budget and
// reported, so this suite can never hang. Inputs are also capped at 2KB.

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter_test/flutter_test.dart';

// V10-A: max input length fed to a backtracking match (caps blowup).
const int _kMaxLineLen = 2048;
// V10-A: hard wall-clock budget per pattern's WHOLE scan. One isolate spawn per
// pattern (NOT per line) — per-line spawning made this suite O(patterns×lines)
// and time out. A non-catastrophic regex scans thousands of lines well under
// this; only a ReDoS pattern blows it (then it is KILLED, not hung).
const Duration _kMatchBudget = Duration(milliseconds: 500);

// V10-A: top-level isolate entry — compile ONCE, scan ALL lines, send true on
// the first match. A runaway scan is KILLED by the parent on timeout.
void _scanWorker((SendPort, String, List<String>) m) {
  final (sp, pattern, lines) = m;
  var r = false;
  try {
    final re = RegExp(pattern);
    for (final raw in lines) {
      final l = raw.length > _kMaxLineLen ? raw.substring(0, _kMaxLineLen) : raw;
      if (re.hasMatch(l)) {
        r = true;
        break;
      }
    }
  } catch (_) {
    r = false;
  }
  sp.send(r);
}

// V10-A: scan ALL lines for one pattern under a hard wall-clock budget in ONE
// throwaway isolate. Returns (matched, timedOut). On timeout the isolate is
// KILLED — never hangs.
Future<({bool matched, bool timedOut})> _boundedAnyMatch(
    String pattern, List<String> lines) async {
  final rp = ReceivePort();
  final ep = ReceivePort();
  Isolate? iso;
  try {
    iso = await Isolate.spawn(_scanWorker, (rp.sendPort, pattern, lines),
        onError: ep.sendPort, errorsAreFatal: true);
  } catch (_) {
    rp.close();
    ep.close();
    return (matched: false, timedOut: false);
  }
  final c = Completer<({bool matched, bool timedOut})>();
  final t = Timer(_kMatchBudget, () {
    if (!c.isCompleted) c.complete((matched: false, timedOut: true));
  });
  rp.listen((v) {
    if (!c.isCompleted) c.complete((matched: v == true, timedOut: false));
  });
  ep.listen((_) {
    if (!c.isCompleted) c.complete((matched: false, timedOut: false));
  });
  final res = await c.future;
  t.cancel();
  iso.kill(priority: Isolate.immediate);
  rp.close();
  ep.close();
  return res;
}

// V10-A guard 2: reject a catastrophic regex shape (nested/large quantifier)
// BEFORE compiling — mirrors antipatternCatastrophicReason in the engine.
bool _isCatastrophic(String p) {
  if (RegExp(r'[+*?}]\)[+*?]|[+*?]\)\{').hasMatch(p)) return true;
  if (RegExp(r'\([^)]*[+*][^)]*\)[+*?{]').hasMatch(p)) return true;
  for (final m in RegExp(r'\{(\d+)(?:,(\d+)?)?\}').allMatches(p)) {
    final n = int.tryParse(m.group(1) ?? '');
    final u = int.tryParse(m.group(2) ?? '');
    if ((n != null && n >= 100) || (u != null && u >= 100)) return true;
  }
  return false;
}

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

    test("antipattern #${LINE_NUM} (hook) לא קיים ב-.githooks/pre-commit", () async {
      const pattern = '${pattern_for_dart}';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #${LINE_NUM} (hook) regex rejected as ReDoS-unsafe; skipped');
        return;
      }
      final hook = File('../.githooks/pre-commit');
      if (!hook.existsSync()) {
        // הריצה אולי לא מ-app_flutter/ — דלג בלי לשבור.
        return;
      }
      // התעלם משורות הערה (מתחילות ב-# אחרי whitespace) — תיעוד התיקון מותר.
      final lines = hook
          .readAsStringSync()
          .split('\n')
          .where((l) => !RegExp(r'^\s*#').hasMatch(l))
          .toList();
      // V10-A guard 3: ONE bounded scan over all lines — a runaway pattern is
      // KILLED at the budget, never hangs `flutter test`.
      final r = await _boundedAnyMatch(pattern, lines);
      expect(r.timedOut, isFalse,
        reason: 'antipattern #${LINE_NUM} (hook) regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });
TESTEOF
    else
        cat >> "$OUT" << TESTEOF

    test("antipattern #${LINE_NUM} לא קיים", () async {
      const pattern = '${pattern_for_dart}';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #${LINE_NUM} regex rejected as ReDoS-unsafe; skipped');
        return;
      }
      final libDir = Directory('lib');
      final lines = <String>[];
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            lines.addAll(entity.readAsStringSync().split('\n'));
          } catch (_) {}
        }
      }
      // V10-A guard 3: ONE bounded scan over all lib lines for this pattern.
      final r = await _boundedAnyMatch(pattern, lines);
      expect(r.timedOut, isFalse,
        reason: 'antipattern #${LINE_NUM} regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
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
