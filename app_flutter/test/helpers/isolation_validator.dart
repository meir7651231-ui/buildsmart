// isolation_validator.dart — כלל 2: אוכף בידוד feature לפני חיבור.
//
// Usage:
//   IsolationValidator.assertNoScreenImports('lib/features/rank_engine/widget.dart');
//   IsolationValidator.assertNoR2Patterns('lib/features/rank_engine/widget.dart');

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

abstract final class IsolationValidator {
  /// Reads [filePath] and fails if any line imports from `screens/`.
  /// Strips single-line comments before scanning.
  static void assertNoScreenImports(String filePath) {
    final lines = _codeLines(filePath);
    final violations = lines
        .where((l) => l.contains('import') && l.contains('screens/'))
        .toList();
    expect(
      violations,
      isEmpty,
      reason:
          'כלל 2 — $filePath imports from screens/ (forbidden):\n'
          '${violations.join('\n')}',
    );
  }

  /// Reads [filePath] and fails if it contains R2-violating patterns:
  /// showDialog · showModalBottomSheet · Navigator.push · new Scaffold.
  static void assertNoR2Patterns(String filePath) {
    final lines = _codeLines(filePath);
    const banned = [
      'showDialog',
      'showModalBottomSheet',
      'Navigator.push',
      'Navigator.pushNamed',
    ];
    for (final pattern in banned) {
      final hits = lines.where((l) => l.contains(pattern)).toList();
      expect(
        hits,
        isEmpty,
        reason:
            'R2 violation — $filePath contains "$pattern":\n'
            '${hits.join('\n')}',
      );
    }
    // Scaffold only flagged when used as a constructor (new feature screen)
    final scaffoldHits = lines
        .where((l) => l.trimLeft().startsWith('Scaffold(') || l.contains('= Scaffold('))
        .toList();
    expect(
      scaffoldHits,
      isEmpty,
      reason:
          'R2 violation — $filePath constructs a Scaffold (forbidden in features/):\n'
          '${scaffoldHits.join('\n')}',
    );
  }

  /// Fails if no test file exists at [testPath].
  static void assertHasUnitTest(String testPath) {
    expect(
      File(testPath).existsSync(),
      isTrue,
      reason: 'כלל 2 — test file missing: $testPath',
    );
  }

  /// Reads [filePath] and fails if [substring] is not found.
  /// Use to assert a verbatim string from the prototype is present [L#].
  static void assertVerbatimPresent(String filePath, String substring) {
    final source = File(filePath).readAsStringSync();
    expect(
      source.contains(substring),
      isTrue,
      reason: 'VRB — "$substring" not found in $filePath',
    );
  }

  // ── internals ──────────────────────────────────────────────────────────────

  /// Returns non-empty, non-comment lines from [filePath].
  static List<String> _codeLines(String filePath) {
    final file = File(filePath);
    expect(file.existsSync(), isTrue, reason: 'File not found: $filePath');
    return file
        .readAsLinesSync()
        .where((l) => l.trim().isNotEmpty && !l.trimLeft().startsWith('//'))
        .toList();
  }
}
