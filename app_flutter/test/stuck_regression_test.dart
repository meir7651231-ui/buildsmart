// ⚠️ AUTO-GENERATED from knowledge/stuck_log.md — אל תערוך ידנית
// כל ANTIPATTERN: שמתועד ב-stuck_log.md הופך לבדיקה רגרסיה לנצח.
// אם בדיקה כאן נכשלת = הבאג חזר. ראה stuck_log.md לפתרון.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('stuck_log regression — אנטי-פטרנים שלא חוזרים', () {

    test("antipattern #1 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp(r'''^\s*print\(''');
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
      final re = RegExp(r'''matcher.*[\"\']Bash[\"\']\s*$''');
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
      final re = RegExp(r'''core\.hooksPath\s*=\s*[^.]''');
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
      final re = RegExp(r'''TEST_OUT=\$\([^)]+\)\s*$''');
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
      final re = RegExp(r'''grep -oE "\[0-9\]\+ tests"\s''');
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

    test("antipattern #6 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp(r'''git diff --cached.*\| sort \| uniq -d''');
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

    test("antipattern #7 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp(r'''flutter (test|analyze|build).*--no-pub''');
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

    test("antipattern #8 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp(r'''^(wip|test|asdf|tmp)$''');
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

    test("antipattern #9 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp(r'''grep -E "\$[a-z]+"''');
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

    test("antipattern #10 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp(r'''kSecret\w*\s*=\s*compute''');
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

    test("antipattern #11 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp(r'''export PATH=.*[/]home[/]user''');
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

    test("antipattern #12 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp(r'''^Owner:\s*$''');
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

    test("antipattern #13 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp(r'''lib/screens/.*\.dart.*\+\+\+.*no visual''');
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

    test("antipattern #14 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp(r'''prettyInch\([a-z]+\).*finder''');
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
      final re = RegExp(r'''parseSizeTokens.*\?\?.*tokensFromDims''');
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

    test("antipattern #16 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp(r'''\\\\d\\+×\\\\d\\+''');
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

    test("antipattern #17 לא קיים", () {
      final libDir = Directory('lib');
      final matches = <String>[];
      final re = RegExp(r'''pubspec.yaml.*grep.*"\^"''');
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
      final re = RegExp(r'''sha256sum.*\.git/hooks.*compare''');
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
      final re = RegExp(r'''awk.*Audit.*,.*\^##''');
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
      final re = RegExp(r'''grep -c.*\|\| echo 0''');
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
