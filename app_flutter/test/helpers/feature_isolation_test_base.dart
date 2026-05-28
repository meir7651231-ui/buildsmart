// feature_isolation_test_base.dart — base class for feature isolation tests.
//
// Every lib/features/[name]/ directory gets one test file that extends this.
// Call runIsolationChecks() in main() to register the full Rule-2 check group.
//
// Usage:
//   class RankEngineIsolationTest extends FeatureIsolationTestBase {
//     @override String get featureName => 'rank_engine';
//     @override List<String> get featureFiles => [
//       'lib/features/rank_engine/model.dart',
//       'lib/features/rank_engine/helper.dart',
//       'lib/features/rank_engine/widget.dart',
//     ];
//   }
//   void main() => RankEngineIsolationTest().runIsolationChecks();

import 'package:flutter_test/flutter_test.dart';

import 'isolation_validator.dart';

abstract class FeatureIsolationTestBase {
  /// Feature directory name under lib/features/
  String get featureName;

  /// All source files that belong to this feature.
  List<String> get featureFiles;

  /// Expected test file path (defaults to test/features/[featureName]_test.dart).
  String get testFilePath => 'test/features/${featureName}_test.dart';

  /// Registers the full Rule-2 isolation check group.
  /// Call this from main() in the feature's test file.
  void runIsolationChecks() {
    group('Rule 2 — isolation: $featureName', () {
      test('test file exists', () {
        IsolationValidator.assertHasUnitTest(testFilePath);
      });

      for (final file in featureFiles) {
        test('$file — no screens/ imports', () {
          IsolationValidator.assertNoScreenImports(file);
        });

        test('$file — no R2 patterns', () {
          IsolationValidator.assertNoR2Patterns(file);
        });
      }
    });
  }
}
