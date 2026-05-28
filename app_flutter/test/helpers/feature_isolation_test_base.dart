/// feature_isolation_test_base.dart
///
/// Abstract base for feature-level isolation tests.
///
/// Subclass this to enforce the full isolation checklist
/// (PROTOCOL.md §15) for a feature under lib/features/[name]/.
///
/// Usage:
///   class OrderTrackIsolationTest extends FeatureIsolationTestBase {
///     @override
///     String get featureName => 'order_track';
///
///     @override
///     List<String> get featureFiles => [
///       'lib/features/order_track/model.dart',
///       'lib/features/order_track/helper.dart',
///       'lib/features/order_track/widget.dart',
///     ];
///   }
///
///   void main() {
///     final iso = OrderTrackIsolationTest();
///     iso.runIsolationChecks(); // registers all isolation tests
///     // ... your feature-specific tests
///   }

// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';

import 'isolation_validator.dart';

/// Abstract base that every new feature test must extend.
///
/// Registers a group of structural isolation checks as Flutter tests.
/// Subclasses declare which files belong to the feature; the base
/// class validates all of them automatically.
abstract class FeatureIsolationTestBase {
  // ---------------------------------------------------------------------------
  // Subclass contract — these must be overridden.
  // ---------------------------------------------------------------------------

  /// The feature name, matching the directory under lib/features/.
  ///
  /// Example: 'order_track' → lib/features/order_track/
  String get featureName;

  /// All source files that make up this feature.
  ///
  /// Typically:
  ///   - 'lib/features/[name]/model.dart'
  ///   - 'lib/features/[name]/helper.dart'
  ///   - 'lib/features/[name]/widget.dart'
  List<String> get featureFiles;

  // ---------------------------------------------------------------------------
  // Optional overrides
  // ---------------------------------------------------------------------------

  /// Whether to check for full-screen R2 pattern violations in widget.dart.
  ///
  /// Defaults to true. Override to false only for exceptional cases with ADR.
  bool get checkFullScreenPatterns => true;

  /// The path to the primary unit test file.
  ///
  /// Defaults to 'test/features/[featureName]_test.dart'.
  String get testFilePath => 'test/features/${featureName}_test.dart';

  /// Verbatim strings declared by the feature, for documentation.
  ///
  /// Each entry: (hebrewString, indexHtmlLineNumber).
  /// The base class calls IsolationValidator.assertVerbatimSource for each.
  List<(String, int)> get verbatimStrings => const [];

  // ---------------------------------------------------------------------------
  // Test registration
  // ---------------------------------------------------------------------------

  /// Registers all isolation checks as a named `group('isolation: [featureName]')`.
  ///
  /// Call this inside `main()` before your feature-specific tests:
  /// ```dart
  /// void main() {
  ///   final iso = MyFeatureTest();
  ///   iso.runIsolationChecks();
  ///   group('helper', () { ... });
  ///   group('widget', () { ... });
  /// }
  /// ```
  void runIsolationChecks() {
    group('isolation: $featureName', () {
      test('no import from lib/screens/', () {
        for (final file in featureFiles) {
          IsolationValidator.assertNoScreenImports(file);
        }
      });

      test('unit test file exists', () {
        // Check the primary test file for the helper.
        final helperPath = 'lib/features/$featureName/helper.dart';
        if (featureFiles.contains(helperPath)) {
          IsolationValidator.assertHasUnitTest(helperPath);
        } else {
          // At minimum, the declared test file must exist.
          IsolationValidator.assertHasUnitTest(featureFiles.first);
        }
      });

      if (checkFullScreenPatterns) {
        test('no full-screen R2 violations', () {
          final widgetPath = 'lib/features/$featureName/widget.dart';
          if (featureFiles.contains(widgetPath)) {
            IsolationValidator.assertNoFullScreenPatterns(widgetPath);
          }
        });
      }

      test('verbatim source declarations', () {
        for (final (string, line) in verbatimStrings) {
          IsolationValidator.assertVerbatimSource(string, line);
        }
        if (verbatimStrings.isEmpty) {
          print('ℹ️  No verbatim strings declared for feature "$featureName". '
              'Add to verbatimStrings if this feature has Hebrew labels.');
        }
      });
    });
  }

  // ---------------------------------------------------------------------------
  // Convenience: print the isolation checklist for this feature.
  // ---------------------------------------------------------------------------

  /// Prints the pre-connection integration checklist to stdout.
  ///
  /// Call from a test or directly in development to see what remains.
  void printIntegrationChecklist() {
    print('''
╔══════════════════════════════════════════════════════════════╗
║  Integration checklist: $featureName
╚══════════════════════════════════════════════════════════════╝
  □ flutter analyze — 0 issues in lib/features/$featureName/
  □ flutter test test/features/${featureName}_test.dart — 0 failures
  □ No import.*screens/ in any file under lib/features/$featureName/
  □ No showDialog / showModalBottomSheet / Navigator.push / new Scaffold
  □ All Hebrew strings have // [L####] verbatim source comment
  □ WIRING.md row added with status 🚧
  □ After connection: flutter test — full suite 0 failures
  □ After connection: update WIRING.md row to ✅ or ⛔
''');
  }
}
