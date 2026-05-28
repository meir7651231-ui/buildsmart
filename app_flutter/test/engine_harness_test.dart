// Gate the in-app "מנוע" regression module (lib/test_harness/tests/engine.dart)
// under `flutter test`, so the button the user presses on a device runs the same
// green guarantees CI enforces. If testEngine() ever returns a failing check,
// this turns the suite red.
import 'package:buildsmart/test_harness/tests/engine.dart';
import 'package:buildsmart/test_harness/types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('in-app engine regression module is all-green', () {
    final results = testEngine();
    expect(results, isNotEmpty);

    final failures = <String>[];
    for (final r in results) {
      for (final c in r.checks) {
        if (!c.pass) {
          failures.add('${r.label} › ${c.name} '
              '(expected ${c.expected ?? "—"}, got ${c.got ?? "—"})');
        }
      }
    }
    for (final r in results) {
      print('${r.allPass ? "✓" : "✗"} ${r.label} '
          '(${r.checks.where((c) => c.pass).length}/${r.checks.length})');
    }
    if (failures.isNotEmpty) {
      print('\nFailures:');
      for (final f in failures) print('  ✗ $f');
    }
    expect(failures, isEmpty);

    // Every result must be filed under the dedicated engine bucket so the
    // "מנוע" filter pill in the regression panel shows them all.
    expect(results.every((r) => r.category == TestCategory.engine), isTrue);
  });
}
