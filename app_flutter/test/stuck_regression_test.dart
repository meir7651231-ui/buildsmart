// ⚠️ AUTO-GENERATED from knowledge/stuck_log.md — אל תערוך ידנית
// כל ANTIPATTERN: שמתועד ב-stuck_log.md הופך לבדיקה רגרסיה לנצח.
// ANTIPATTERN:       → סורק lib/ (Dart).  ANTIPATTERN[hook]: → סורק ../.githooks/pre-commit (bash).
// אם בדיקה כאן נכשלת = הבאג חזר. ראה stuck_log.md לפתרון.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('stuck_log regression — אנטי-פטרנים שלא חוזרים', () {

    test("antipattern #1 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('_p\\(\'218553\'\\), _p\\(\'217861\'\\)\\), isNotNull');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #2 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('isScrollControlled:\\s*false');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #3 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('cheaperAlternativesAcrossCatalog\\(\\).*kSmartProducts');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #4 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('sku: \'610706\'');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #5 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('\'מידות\':\\s*\'[0-9.×]+ ס"מ\'');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #6 (hook) לא קיים ב-.githooks/pre-commit", () {
      final hook = File('../.githooks/pre-commit');
      if (!hook.existsSync()) {
        // הריצה אולי לא מ-app_flutter/ — דלג בלי לשבור.
        return;
      }
      final matches = <String>[];
      final re = RegExp('grep -[qc] "(🟦|✅|⬜)');
      final lines = hook.readAsStringSync().split('\n');
      for (final line in lines) {
        // התעלם משורות הערה (מתחילות ב-# אחרי whitespace) — תיעוד התיקון מותר.
        if (RegExp(r'^\s*#').hasMatch(line)) continue;
        if (re.hasMatch(line)) matches.add(line.trim());
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #7 (hook) לא קיים ב-.githooks/pre-commit", () {
      final hook = File('../.githooks/pre-commit');
      if (!hook.existsSync()) {
        // הריצה אולי לא מ-app_flutter/ — דלג בלי לשבור.
        return;
      }
      final matches = <String>[];
      final re = RegExp('grep -cvE.*\\|\\| echo 0');
      final lines = hook.readAsStringSync().split('\n');
      for (final line in lines) {
        // התעלם משורות הערה (מתחילות ב-# אחרי whitespace) — תיעוד התיקון מותר.
        if (RegExp(r'^\s*#').hasMatch(line)) continue;
        if (re.hasMatch(line)) matches.add(line.trim());
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #8 (hook) לא קיים ב-.githooks/pre-commit", () {
      final hook = File('../.githooks/pre-commit');
      if (!hook.existsSync()) {
        // הריצה אולי לא מ-app_flutter/ — דלג בלי לשבור.
        return;
      }
      final matches = <String>[];
      final re = RegExp('gates=\\\$FAIL"');
      final lines = hook.readAsStringSync().split('\n');
      for (final line in lines) {
        // התעלם משורות הערה (מתחילות ב-# אחרי whitespace) — תיעוד התיקון מותר.
        if (RegExp(r'^\s*#').hasMatch(line)) continue;
        if (re.hasMatch(line)) matches.add(line.trim());
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #9 (hook) לא קיים ב-.githooks/pre-commit", () {
      final hook = File('../.githooks/pre-commit');
      if (!hook.existsSync()) {
        // הריצה אולי לא מ-app_flutter/ — דלג בלי לשבור.
        return;
      }
      final matches = <String>[];
      final re = RegExp('git add.*emergency_token');
      final lines = hook.readAsStringSync().split('\n');
      for (final line in lines) {
        // התעלם משורות הערה (מתחילות ב-# אחרי whitespace) — תיעוד התיקון מותר.
        if (RegExp(r'^\s*#').hasMatch(line)) continue;
        if (re.hasMatch(line)) matches.add(line.trim());
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #10 (hook) לא קיים ב-.githooks/pre-commit", () {
      final hook = File('../.githooks/pre-commit');
      if (!hook.existsSync()) {
        // הריצה אולי לא מ-app_flutter/ — דלג בלי לשבור.
        return;
      }
      final matches = <String>[];
      final re = RegExp('echo "\\\$[a-z_]+" \\| grep -qE.*shell-meta');
      final lines = hook.readAsStringSync().split('\n');
      for (final line in lines) {
        // התעלם משורות הערה (מתחילות ב-# אחרי whitespace) — תיעוד התיקון מותר.
        if (RegExp(r'^\s*#').hasMatch(line)) continue;
        if (re.hasMatch(line)) matches.add(line.trim());
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #11 (hook) לא קיים ב-.githooks/pre-commit", () {
      final hook = File('../.githooks/pre-commit');
      if (!hook.existsSync()) {
        // הריצה אולי לא מ-app_flutter/ — דלג בלי לשבור.
        return;
      }
      final matches = <String>[];
      final re = RegExp('grep -c [^|]*2>/dev/null \\|\\| echo 0');
      final lines = hook.readAsStringSync().split('\n');
      for (final line in lines) {
        // התעלם משורות הערה (מתחילות ב-# אחרי whitespace) — תיעוד התיקון מותר.
        if (RegExp(r'^\s*#').hasMatch(line)) continue;
        if (re.hasMatch(line)) matches.add(line.trim());
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #12 (hook) לא קיים ב-.githooks/pre-commit", () {
      final hook = File('../.githooks/pre-commit');
      if (!hook.existsSync()) {
        // הריצה אולי לא מ-app_flutter/ — דלג בלי לשבור.
        return;
      }
      final matches = <String>[];
      final re = RegExp('^for critical in compat_coverage_test');
      final lines = hook.readAsStringSync().split('\n');
      for (final line in lines) {
        // התעלם משורות הערה (מתחילות ב-# אחרי whitespace) — תיעוד התיקון מותר.
        if (RegExp(r'^\s*#').hasMatch(line)) continue;
        if (re.hasMatch(line)) matches.add(line.trim());
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #13 (hook) לא קיים ב-.githooks/pre-commit", () {
      final hook = File('../.githooks/pre-commit');
      if (!hook.existsSync()) {
        // הריצה אולי לא מ-app_flutter/ — דלג בלי לשבור.
        return;
      }
      final matches = <String>[];
      final re = RegExp('git diff --cached [a-z].*\\.md >/dev/null');
      final lines = hook.readAsStringSync().split('\n');
      for (final line in lines) {
        // התעלם משורות הערה (מתחילות ב-# אחרי whitespace) — תיעוד התיקון מותר.
        if (RegExp(r'^\s*#').hasMatch(line)) continue;
        if (re.hasMatch(line)) matches.add(line.trim());
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #14 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('^\\s*print\\(');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #15 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('matcher.*[\\"\\\']Bash[\\"\\\']\\s*\$');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #16 (hook) לא קיים ב-.githooks/pre-commit", () {
      final hook = File('../.githooks/pre-commit');
      if (!hook.existsSync()) {
        // הריצה אולי לא מ-app_flutter/ — דלג בלי לשבור.
        return;
      }
      final matches = <String>[];
      final re = RegExp('warn "4[24]"');
      final lines = hook.readAsStringSync().split('\n');
      for (final line in lines) {
        // התעלם משורות הערה (מתחילות ב-# אחרי whitespace) — תיעוד התיקון מותר.
        if (RegExp(r'^\s*#').hasMatch(line)) continue;
        if (re.hasMatch(line)) matches.add(line.trim());
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #17 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('core\\.hooksPath\\s*=\\s*[^.]');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #18 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('TEST_OUT=\\\$\\([^)]+\\)\\s*\$');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #19 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('grep -oE "\\[0-9\\]\\+ tests"\\s');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #20 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('git diff --cached.*\\| sort \\| uniq -d');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #21 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('flutter (test|analyze|build).*--no-pub');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #22 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('^(wip|test|asdf|tmp)\$');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #23 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('grep -E "\\\$[a-z]+"');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #24 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('kSecret\\w*\\s*=\\s*compute');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #25 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('export PATH=.*[/]home[/]user');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #26 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('^Owner:\\s*\$');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #27 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('lib/screens/.*\\.dart.*\\+\\+\\+.*no visual');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #28 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('prettyInch\\([a-z]+\\).*finder');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #29 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('parseSizeTokens.*\\?\\?.*tokensFromDims');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #30 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('\\\\\\\\d\\\\+×\\\\\\\\d\\\\+');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #31 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('pubspec.yaml.*grep.*"\\^"');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #32 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('sha256sum.*\\.git/hooks.*compare');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #33 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('awk.*Audit.*,.*\\^##');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #34 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('grep -c.*\\|\\| echo 0');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #35 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('sha256sum.*2>/dev/null.*\\|.*cut.*\\|\\| echo "missing"');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #36 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('grep.*ANTIPATTERN.*\\|.*sed.*pattern\\b[^|]');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #37 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('sha256sum.*git show.*HEAD.*githooks');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #38 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('while.*ANTIPATTERN.*done.*STAGED_DART=\\\$\\(git diff');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #39 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('git diff --cached app_flutter/lib/screens/home_shell.dart');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #40 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('\'v5\\.\\d+ · \\d+\\.\\d+\\.\\d+\' .*v5\\.41');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #41 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('flutter test --no-pub --reporter expanded');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #42 (hook) לא קיים ב-.githooks/pre-commit", () {
      final hook = File('../.githooks/pre-commit');
      if (!hook.existsSync()) {
        // הריצה אולי לא מ-app_flutter/ — דלג בלי לשבור.
        return;
      }
      final matches = <String>[];
      final re = RegExp('grep -oE "\\[0-9\\]\\+ ✗"');
      final lines = hook.readAsStringSync().split('\n');
      for (final line in lines) {
        // התעלם משורות הערה (מתחילות ב-# אחרי whitespace) — תיעוד התיקון מותר.
        if (RegExp(r'^\s*#').hasMatch(line)) continue;
        if (re.hasMatch(line)) matches.add(line.trim());
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #43 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('err.*32.*exit=\\\$TEST_EXIT.*תקן את הבדיקות');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #44 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('case kPpr[A-Z][a-z]+:\\s*\\n\\s*case kPpr[A-Z][a-z]+:\\s*\\n\\s*return \\[.spec_faser_20');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #45 (hook) לא קיים ב-.githooks/pre-commit", () {
      final hook = File('../.githooks/pre-commit');
      if (!hook.existsSync()) {
        // הריצה אולי לא מ-app_flutter/ — דלג בלי לשבור.
        return;
      }
      final matches = <String>[];
      final re = RegExp('grep [^|#]*(🟦|✅|⬜|🎯|🎨|🎮|🎪|🎲)');
      final lines = hook.readAsStringSync().split('\n');
      for (final line in lines) {
        // התעלם משורות הערה (מתחילות ב-# אחרי whitespace) — תיעוד התיקון מותר.
        if (RegExp(r'^\s*#').hasMatch(line)) continue;
        if (re.hasMatch(line)) matches.add(line.trim());
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #46 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('new provider or map in lib screens shipped without a matching WIRING row');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #47 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('version label bumped in home_shell without the same bump in STATUS');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #48 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('letter size regex without a negative lookahead on equals sign');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #49 (hook) לא קיים ב-.githooks/pre-commit", () {
      final hook = File('../.githooks/pre-commit');
      if (!hook.existsSync()) {
        // הריצה אולי לא מ-app_flutter/ — דלג בלי לשבור.
        return;
      }
      final matches = <String>[];
      final re = RegExp('RegExp\\(r\'\'\'');
      final lines = hook.readAsStringSync().split('\n');
      for (final line in lines) {
        // התעלם משורות הערה (מתחילות ב-# אחרי whitespace) — תיעוד התיקון מותר.
        if (RegExp(r'^\s*#').hasMatch(line)) continue;
        if (re.hasMatch(line)) matches.add(line.trim());
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #50 (hook) לא קיים ב-.githooks/pre-commit", () {
      final hook = File('../.githooks/pre-commit');
      if (!hook.existsSync()) {
        // הריצה אולי לא מ-app_flutter/ — דלג בלי לשבור.
        return;
      }
      final matches = <String>[];
      final re = RegExp('cached -- \'\\*\\.dart\' 2>/dev/null \\| grep');
      final lines = hook.readAsStringSync().split('\n');
      for (final line in lines) {
        // התעלם משורות הערה (מתחילות ב-# אחרי whitespace) — תיעוד התיקון מותר.
        if (RegExp(r'^\s*#').hasMatch(line)) continue;
        if (re.hasMatch(line)) matches.add(line.trim());
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #51 (hook) לא קיים ב-.githooks/pre-commit", () {
      final hook = File('../.githooks/pre-commit');
      if (!hook.existsSync()) {
        // הריצה אולי לא מ-app_flutter/ — דלג בלי לשבור.
        return;
      }
      final matches = <String>[];
      final re = RegExp('echo "\\\$TEST_OUT" \\| grep -q "\\\$critical"');
      final lines = hook.readAsStringSync().split('\n');
      for (final line in lines) {
        // התעלם משורות הערה (מתחילות ב-# אחרי whitespace) — תיעוד התיקון מותר.
        if (RegExp(r'^\s*#').hasMatch(line)) continue;
        if (re.hasMatch(line)) matches.add(line.trim());
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #52 (hook) לא קיים ב-.githooks/pre-commit", () {
      final hook = File('../.githooks/pre-commit');
      if (!hook.existsSync()) {
        // הריצה אולי לא מ-app_flutter/ — דלג בלי לשבור.
        return;
      }
      final matches = <String>[];
      final re = RegExp('IS_RETRY" == "true" && -f "\\\$STUCK_LOG"');
      final lines = hook.readAsStringSync().split('\n');
      for (final line in lines) {
        // התעלם משורות הערה (מתחילות ב-# אחרי whitespace) — תיעוד התיקון מותר.
        if (RegExp(r'^\s*#').hasMatch(line)) continue;
        if (re.hasMatch(line)) matches.add(line.trim());
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #53 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('return null;\\s*//.*photo-only.*fall.*through');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #54 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('45\',\\s*\'90');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #55 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('path=\\[מים, למיקום');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #56 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('git commit.*&\\s*\$');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #57 (hook) לא קיים ב-.githooks/pre-commit", () {
      final hook = File('../.githooks/pre-commit');
      if (!hook.existsSync()) {
        // הריצה אולי לא מ-app_flutter/ — דלג בלי לשבור.
        return;
      }
      final matches = <String>[];
      final re = RegExp('grep .*🟦.*ROADMAP');
      final lines = hook.readAsStringSync().split('\n');
      for (final line in lines) {
        // התעלם משורות הערה (מתחילות ב-# אחרי whitespace) — תיעוד התיקון מותר.
        if (RegExp(r'^\s*#').hasMatch(line)) continue;
        if (re.hasMatch(line)) matches.add(line.trim());
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן hook חזר ב-.githooks/pre-commit. ראה knowledge/stuck_log.md');
    });

    test("antipattern #58 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp(',,\\s*\$');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #59 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('openSmartProductSheet.*group.*header\$');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #60 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('brand == \'פולירול\' \\? \'');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #61 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('kCatalogProducts.*\\.\\.\\.\\s*\$');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #62 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('catalogSkus.*final p in products');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #63 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('known-failing.*product_images');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #64 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('kFinderGroups\\s*=\\s*\\[[^]]*\'צנרת PPR\'[^]]*\'אחר\'');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #65 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('hooking a brand to per-family crops without an R2 upload-check');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #66 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('"tests pass + sampled-once → asset is good"');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #67 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('`PHOTO_H = N` אחיד עבור catalog עם photos בגדלים שונים בעמוד.');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #68 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('v5\\.[0-9].*(הזמן עכשיו|אישור הזמנה)');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #69 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('שדרוג dynamic→named-type בלי לוודא שהטיפוס מיובא');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #70 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('titles: \\[\\]');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #71 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('שינוי ניווט פרסונה ממסך דיאל ל role app בלי עדכון בדיקות widget להתנהגות החדשה');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });

    test("antipattern #71 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp('שינוי lib data או lib state בלי הרצת mutation verify ועדכון mutation log באותו commit');
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (entity.path.contains('stuck_regression')) continue;
          try {
            final content = entity.readAsStringSync();
            for (final line in content.split('\n')) {
              if (re.hasMatch(line)) {
                matches.add('${entity.path}: ${line.trim()}');
              }
            }
          } catch (_) {}
        }
      }
      expect(matches, isEmpty,
        reason: 'אנטי-פטרן חזר. ראה knowledge/stuck_log.md');
    });
  });
}
