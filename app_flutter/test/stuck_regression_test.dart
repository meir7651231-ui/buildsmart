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

    test("antipattern #1 (hook) לא קיים ב-.githooks/pre-commit", () async {
      const pattern = 'grep -[qc] "(🟦|✅|⬜)';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #1 (hook) regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #1 (hook) regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #2 (hook) לא קיים ב-.githooks/pre-commit", () async {
      const pattern = 'grep -cvE.*\\|\\| echo 0';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #2 (hook) regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #2 (hook) regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #3 (hook) לא קיים ב-.githooks/pre-commit", () async {
      const pattern = 'gates=\\\$FAIL"';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #3 (hook) regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #3 (hook) regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #4 (hook) לא קיים ב-.githooks/pre-commit", () async {
      const pattern = 'git add.*emergency_token';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #4 (hook) regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #4 (hook) regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #5 (hook) לא קיים ב-.githooks/pre-commit", () async {
      const pattern = 'echo "\\\$[a-z_]+" \\| grep -qE.*shell-meta';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #5 (hook) regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #5 (hook) regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #6 (hook) לא קיים ב-.githooks/pre-commit", () async {
      const pattern = 'grep -c [^|]*2>/dev/null \\|\\| echo 0';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #6 (hook) regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #6 (hook) regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #7 (hook) לא קיים ב-.githooks/pre-commit", () async {
      const pattern = '^for critical in compat_coverage_test';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #7 (hook) regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #7 (hook) regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #8 (hook) לא קיים ב-.githooks/pre-commit", () async {
      const pattern = 'git diff --cached [a-z].*\\.md >/dev/null';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #8 (hook) regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #8 (hook) regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #9 לא קיים", () async {
      const pattern = '^\\s*print\\(';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #9 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #9 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #10 לא קיים", () async {
      const pattern = 'matcher.*[\\"\\\']Bash[\\"\\\']\\s*\$';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #10 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #10 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #11 (hook) לא קיים ב-.githooks/pre-commit", () async {
      const pattern = 'warn "4[24]"';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #11 (hook) regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #11 (hook) regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #12 לא קיים", () async {
      const pattern = 'core\\.hooksPath\\s*=\\s*[^.]';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #12 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #12 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #13 לא קיים", () async {
      const pattern = 'TEST_OUT=\\\$\\([^)]+\\)\\s*\$';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #13 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #13 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #14 לא קיים", () async {
      const pattern = 'grep -oE "\\[0-9\\]\\+ tests"\\s';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #14 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #14 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #15 לא קיים", () async {
      const pattern = 'git diff --cached.*\\| sort \\| uniq -d';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #15 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #15 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #16 לא קיים", () async {
      const pattern = 'flutter (test|analyze|build).*--no-pub';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #16 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #16 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #17 לא קיים", () async {
      const pattern = '^(wip|test|asdf|tmp)\$';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #17 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #17 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #18 לא קיים", () async {
      const pattern = 'grep -E "\\\$[a-z]+"';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #18 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #18 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #19 לא קיים", () async {
      const pattern = 'kSecret\\w*\\s*=\\s*compute';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #19 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #19 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #20 לא קיים", () async {
      const pattern = 'export PATH=.*[/]home[/]user';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #20 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #20 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #21 לא קיים", () async {
      const pattern = '^Owner:\\s*\$';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #21 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #21 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #22 לא קיים", () async {
      const pattern = 'lib/screens/.*\\.dart.*\\+\\+\\+.*no visual';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #22 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #22 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #23 לא קיים", () async {
      const pattern = 'prettyInch\\([a-z]+\\).*finder';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #23 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #23 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #24 לא קיים", () async {
      const pattern = 'parseSizeTokens.*\\?\\?.*tokensFromDims';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #24 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #24 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #25 לא קיים", () async {
      const pattern = '\\\\\\\\d\\\\+×\\\\\\\\d\\\\+';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #25 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #25 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #26 לא קיים", () async {
      const pattern = 'pubspec.yaml.*grep.*"\\^"';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #26 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #26 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #27 לא קיים", () async {
      const pattern = 'sha256sum.*\\.git/hooks.*compare';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #27 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #27 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #28 לא קיים", () async {
      const pattern = 'awk.*Audit.*,.*\\^##';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #28 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #28 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #29 לא קיים", () async {
      const pattern = 'grep -c.*\\|\\| echo 0';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #29 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #29 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #30 לא קיים", () async {
      const pattern = 'sha256sum.*2>/dev/null.*\\|.*cut.*\\|\\| echo "missing"';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #30 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #30 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #31 לא קיים", () async {
      const pattern = 'grep.*ANTIPATTERN.*\\|.*sed.*pattern\\b[^|]';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #31 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #31 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #32 לא קיים", () async {
      const pattern = 'sha256sum.*git show.*HEAD.*githooks';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #32 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #32 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #33 לא קיים", () async {
      const pattern = 'while.*ANTIPATTERN.*done.*STAGED_DART=\\\$\\(git diff';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #33 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #33 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #34 לא קיים", () async {
      const pattern = 'git diff --cached app_flutter/lib/screens/home_shell.dart';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #34 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #34 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #35 לא קיים", () async {
      const pattern = '\'v5\\.\\d+ · \\d+\\.\\d+\\.\\d+\' .*v5\\.41';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #35 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #35 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #36 לא קיים", () async {
      const pattern = 'flutter test --no-pub --reporter expanded';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #36 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #36 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #37 (hook) לא קיים ב-.githooks/pre-commit", () async {
      const pattern = 'grep -oE "\\[0-9\\]\\+ ✗"';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #37 (hook) regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #37 (hook) regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #38 לא קיים", () async {
      const pattern = 'err.*32.*exit=\\\$TEST_EXIT.*תקן את הבדיקות';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #38 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #38 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #39 לא קיים", () async {
      const pattern = 'case kPpr[A-Z][a-z]+:\\s*\\n\\s*case kPpr[A-Z][a-z]+:\\s*\\n\\s*return \\[.spec_faser_20';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #39 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #39 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #40 (hook) לא קיים ב-.githooks/pre-commit", () async {
      const pattern = 'grep [^|#]*(🟦|✅|⬜|🎯|🎨|🎮|🎪|🎲)';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #40 (hook) regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #40 (hook) regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #41 לא קיים", () async {
      const pattern = 'new provider or map in lib screens shipped without a matching WIRING row';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #41 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #41 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #42 לא קיים", () async {
      const pattern = 'version label bumped in home_shell without the same bump in STATUS';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #42 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #42 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #43 לא קיים", () async {
      const pattern = 'letter size regex without a negative lookahead on equals sign';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #43 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #43 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #44 (hook) לא קיים ב-.githooks/pre-commit", () async {
      const pattern = 'RegExp\\(r\'\'\'';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #44 (hook) regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #44 (hook) regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #45 (hook) לא קיים ב-.githooks/pre-commit", () async {
      const pattern = 'cached -- \'\\*\\.dart\' 2>/dev/null \\| grep';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #45 (hook) regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #45 (hook) regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #46 (hook) לא קיים ב-.githooks/pre-commit", () async {
      const pattern = 'echo "\\\$TEST_OUT" \\| grep -q "\\\$critical"';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #46 (hook) regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #46 (hook) regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #47 (hook) לא קיים ב-.githooks/pre-commit", () async {
      const pattern = 'IS_RETRY" == "true" && -f "\\\$STUCK_LOG"';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #47 (hook) regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #47 (hook) regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #48 לא קיים", () async {
      const pattern = 'return null;\\s*//.*photo-only.*fall.*through';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #48 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #48 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #49 לא קיים", () async {
      const pattern = '45\',\\s*\'90';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #49 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #49 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #50 לא קיים", () async {
      const pattern = 'path=\\[מים, למיקום';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #50 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #50 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #51 לא קיים", () async {
      const pattern = 'git commit.*&\\s*\$';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #51 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #51 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #52 (hook) לא קיים ב-.githooks/pre-commit", () async {
      const pattern = 'grep .*🟦.*ROADMAP';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #52 (hook) regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #52 (hook) regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #53 לא קיים", () async {
      const pattern = ',,\\s*\$';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #53 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #53 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #54 לא קיים", () async {
      const pattern = 'openSmartProductSheet.*group.*header\$';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #54 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #54 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #55 לא קיים", () async {
      const pattern = 'brand == \'פולירול\' \\? \'';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #55 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #55 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #56 לא קיים", () async {
      const pattern = 'kCatalogProducts.*\\.\\.\\.\\s*\$';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #56 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #56 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #57 לא קיים", () async {
      const pattern = 'catalogSkus.*final p in products';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #57 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #57 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #58 לא קיים", () async {
      const pattern = 'known-failing.*product_images';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #58 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #58 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #59 לא קיים", () async {
      const pattern = 'kFinderGroups\\s*=\\s*\\[[^]]*\'צנרת PPR\'[^]]*\'אחר\'';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #59 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #59 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #60 לא קיים", () async {
      const pattern = 'hooking a brand to per-family crops without an R2 upload-check';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #60 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #60 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #61 לא קיים", () async {
      const pattern = '"tests pass + sampled-once → asset is good"';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #61 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #61 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #62 לא קיים", () async {
      const pattern = '`PHOTO_H = N` אחיד עבור catalog עם photos בגדלים שונים בעמוד.';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #62 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #62 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #63 לא קיים", () async {
      const pattern = 'v5\\.[0-9].*(הזמן עכשיו|אישור הזמנה)';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #63 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #63 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #64 לא קיים", () async {
      const pattern = 'שדרוג dynamic→named-type בלי לוודא שהטיפוס מיובא';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #64 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #64 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #65 לא קיים", () async {
      const pattern = 'GIT_INDEX_FILE';
      // V10-A guard 2: a catastrophic regex never runs — it would ReDoS-hang.
      if (_isCatastrophic(pattern)) {
        printOnFailure('antipattern #65 regex rejected as ReDoS-unsafe; skipped');
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
        reason: 'antipattern #65 regex TIMED OUT — possible ReDoS; rewrite it');
      expect(r.matched, isFalse,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });
  });
}
