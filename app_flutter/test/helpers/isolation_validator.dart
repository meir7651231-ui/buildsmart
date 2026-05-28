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
    // Scaffold flagged whenever the constructor is called in any position
    final scaffoldHits = lines
        .where((l) => l.contains('Scaffold('))
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
  /// Strips both // single-line and /* */ block comments.
  static List<String> _codeLines(String filePath) {
    final file = File(filePath);
    expect(file.existsSync(), isTrue, reason: 'File not found: $filePath');
    final result = <String>[];
    var inBlock = false;
    for (final line in file.readAsLinesSync()) {
      var l = line;
      if (inBlock) {
        final end = l.indexOf('*/');
        if (end == -1) continue; // whole line inside block comment
        l = l.substring(end + 2);
        inBlock = false;
      }
      // strip inline /* ... */ spans (may be multiple per line)
      while (l.contains('/*')) {
        final start = l.indexOf('/*');
        final end = l.indexOf('*/', start);
        if (end == -1) {
          l = l.substring(0, start);
          inBlock = true;
          break;
        }
        l = l.substring(0, start) + l.substring(end + 2);
      }
      // strip // comment suffix
      final slashIdx = l.indexOf('//');
      if (slashIdx != -1) l = l.substring(0, slashIdx);
      if (l.trim().isNotEmpty) result.add(l);
    }
    return result;
  }
}
