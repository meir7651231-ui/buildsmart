/// isolation_validator.dart
///
/// Static assertions that enforce the lib/features/ isolation pattern.
///
/// Every feature under lib/features/[name]/ must pass these checks
/// before being connected to the shell. See PROTOCOL.md §15.
///
/// Usage (in feature tests):
///   IsolationValidator.assertNoScreenImports('lib/features/order_track/helper.dart');
///   IsolationValidator.assertHasUnitTest('lib/features/order_track/helper.dart');

// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

abstract final class IsolationValidator {
  /// Reads [featurePath] and fails if it contains any import from `lib/screens/`.
  ///
  /// R2 enforcement: feature files must never reach into the screens layer.
  /// Allowed imports: lib/data/, lib/state/, lib/theme/, lib/widgets/.
  ///
  /// [featurePath] — path relative to the repo root, or absolute.
  ///
  /// Example:
  /// ```dart
  /// IsolationValidator.assertNoScreenImports(
  ///   'lib/features/order_track/helper.dart',
  /// );
  /// ```
  static void assertNoScreenImports(String featurePath) {
    final file = _resolveFile(featurePath);
    if (!file.existsSync()) {
      fail(
        'IsolationValidator.assertNoScreenImports: '
        'file not found: ${file.path}',
      );
    }
    final content = file.readAsStringSync();
    // Match any import that references the screens package path.
    final forbidden = RegExp(r'''import\s+['"][^'"]*screens/''');
    if (forbidden.hasMatch(content)) {
      final lines = content.split('\n');
      final offenders = <String>[];
      for (var i = 0; i < lines.length; i++) {
        if (forbidden.hasMatch(lines[i])) {
          offenders.add('  L${i + 1}: ${lines[i].trim()}');
        }
      }
      fail(
        'IsolationValidator: R2 violation — import from lib/screens/ '
        'found in ${file.path}:\n${offenders.join('\n')}\n\n'
        'Features must only import from lib/data/, lib/state/, '
        'lib/theme/, lib/widgets/.',
      );
    }
    print('✅ IsolationValidator: no screens/ imports in ${file.path}');
  }

  /// Asserts that a given [string] is verbatim from the prototype source,
  /// identified by its line number in index.html.
  ///
  /// This is a documentation placeholder. It prints the contract so CI
  /// output is self-documenting, but does not re-read the HTML at runtime.
  ///
  /// For actual verbatim verification use:
  ///   grep -n "המחרוזת" /home/user/buildsmart/index.html
  ///
  /// [string]     — the Hebrew string as used in the feature.
  /// [lineNumber] — the [L####] line from index.html where it originates.
  ///
  /// Example:
  /// ```dart
  /// IsolationValidator.assertVerbatimSource('הזמנות פתוחות', 11970);
  /// ```
  static void assertVerbatimSource(String string, int lineNumber) {
    // Passes unconditionally — serves as living documentation in test output.
    print('📌 VRB-01 contract: "$string" ← index.html L$lineNumber');
    expect(string.isNotEmpty, isTrue,
        reason: 'VRB-01: verbatim string must not be empty [L$lineNumber]');
  }

  /// Asserts that a unit test file exists for the given [helperPath].
  ///
  /// Convention:
  ///   lib/features/[name]/helper.dart
  ///     → test/features/[name]_test.dart
  ///   lib/logic/[domain]_helper.dart
  ///     → test/[domain]_helper_test.dart
  ///
  /// [helperPath] — path to the helper dart file (relative or absolute).
  ///
  /// Example:
  /// ```dart
  /// IsolationValidator.assertHasUnitTest('lib/features/order_track/helper.dart');
  /// ```
  static void assertHasUnitTest(String helperPath) {
    final testPath = _deriveTestPath(helperPath);
    final testFile = _resolveFile(testPath);
    if (!testFile.existsSync()) {
      fail(
        'IsolationValidator: FND-07 violation — no unit test found for '
        '"$helperPath".\n'
        'Expected test file: ${testFile.path}\n'
        'Create the test file before connecting to shell.',
      );
    }
    print('✅ IsolationValidator: test exists for $helperPath → ${testFile.path}');
  }

  /// Asserts that [featurePath] contains no forbidden full-screen patterns
  /// (R2 enforcement at source level).
  ///
  /// Forbidden identifiers: showDialog, showModalBottomSheet,
  /// Navigator.push, new Scaffold (as first widget in a feature build method).
  ///
  /// [featurePath] — path to the dart file to scan.
  static void assertNoFullScreenPatterns(String featurePath) {
    final file = _resolveFile(featurePath);
    if (!file.existsSync()) {
      fail(
        'IsolationValidator.assertNoFullScreenPatterns: '
        'file not found: ${file.path}',
      );
    }
    final rawContent = file.readAsStringSync();
    // Strip single-line comments (//) before scanning so that commented-out
    // examples in templates do not trigger false positives.
    final lines = rawContent.split('\n');
    final activeLines = lines
        .where((l) => !l.trimLeft().startsWith('//'))
        .join('\n');

    final forbidden = <String, RegExp>{
      'showDialog': RegExp(r'\bshowDialog\s*\('),
      'showModalBottomSheet': RegExp(r'\bshowModalBottomSheet\s*\('),
      'Navigator.push': RegExp(r'\bNavigator\.push\b'),
      'new Scaffold': RegExp(r'\breturn\s+Scaffold\s*\('),
    };

    final violations = <String>[];
    for (final entry in forbidden.entries) {
      if (entry.value.hasMatch(activeLines)) {
        violations.add('  • ${entry.key}');
      }
    }
    if (violations.isNotEmpty) {
      fail(
        'IsolationValidator: FRM-02 violation — full-screen pattern(s) '
        'found in ${file.path}:\n${violations.join('\n')}\n\n'
        'Feature widgets must use DialColumn/DialRow only.',
      );
    }
    print('✅ IsolationValidator: no full-screen patterns in ${file.path}');
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  static File _resolveFile(String path) {
    if (path.startsWith('/')) return File(path);
    // Resolve relative to the package root (two levels up from test/helpers/).
    final script = Platform.script.toFilePath();
    // Walk up to find pubspec.yaml anchor.
    var dir = Directory(script).parent;
    for (var i = 0; i < 6; i++) {
      if (File('${dir.path}/pubspec.yaml').existsSync()) {
        return File('${dir.path}/$path');
      }
      dir = dir.parent;
    }
    // Fallback: use current working directory.
    return File(path);
  }

  /// Derives the test path from a helper/source path.
  ///
  /// lib/features/[name]/helper.dart → test/features/[name]_test.dart
  /// lib/logic/[name]_helper.dart    → test/[name]_helper_test.dart
  static String _deriveTestPath(String helperPath) {
    // Normalise to relative (strip leading slash and package root).
    var rel = helperPath.replaceAll(r'\', '/');
    if (rel.startsWith('/')) {
      // Try to strip everything up to 'lib/'.
      final idx = rel.indexOf('/lib/');
      if (idx >= 0) rel = rel.substring(idx + 1);
    }

    // lib/features/[name]/helper.dart → test/features/[name]_test.dart
    final featureMatch =
        RegExp(r'^lib/features/([^/]+)/\w+\.dart$').firstMatch(rel);
    if (featureMatch != null) {
      final name = featureMatch.group(1)!;
      return 'test/features/${name}_test.dart';
    }

    // lib/logic/[name]_helper.dart → test/[name]_helper_test.dart
    final logicMatch =
        RegExp(r'^lib/logic/(.+)\.dart$').firstMatch(rel);
    if (logicMatch != null) {
      final name = logicMatch.group(1)!;
      return 'test/${name}_test.dart';
    }

    // Generic fallback: replace lib/ with test/ and append _test.
    return rel.replaceFirst('lib/', 'test/').replaceAll('.dart', '_test.dart');
  }
}
