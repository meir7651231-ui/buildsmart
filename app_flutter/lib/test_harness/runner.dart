import 'package:buildsmart/test_harness/regression_state.dart';
import 'package:buildsmart/test_harness/tests/behavior.dart';
import 'package:buildsmart/test_harness/tests/buttons.dart';
import 'package:buildsmart/test_harness/tests/cart.dart';
import 'package:buildsmart/test_harness/tests/catalog.dart';
import 'package:buildsmart/test_harness/tests/dsync.dart';
import 'package:buildsmart/test_harness/tests/dupes.dart';
import 'package:buildsmart/test_harness/tests/engine.dart';
import 'package:buildsmart/test_harness/tests/finder.dart';
import 'package:buildsmart/test_harness/tests/products.dart';
import 'package:buildsmart/test_harness/tests/sections.dart';
import 'package:buildsmart/test_harness/tests/settings.dart';
import 'package:buildsmart/test_harness/tests/tabs.dart';
import 'package:buildsmart/test_harness/types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> _yieldToUi() =>
    Future<void>.delayed(const Duration(milliseconds: 0));

Future<void> runRegression(WidgetRef ref) async {
  if (ref.read(regressionStatusProvider) == RegressionStatus.running) return;

  ref.read(regressionStatusProvider.notifier).state = RegressionStatus.running;
  ref.read(regressionResultsProvider.notifier).state = const [];

  // Let the UI paint the "running" state.
  await Future<void>.delayed(const Duration(milliseconds: 60));

  final results = <TestResult>[];

  try {
    results.addAll(testDsync());
    await _yieldToUi();

    results.addAll(testTabs(ref));
    await _yieldToUi();

    results.addAll(testButtons(ref));
    await _yieldToUi();

    results.addAll(testProducts());
    await _yieldToUi();

    results.addAll(testBehavior(ref));
    await _yieldToUi();

    results.addAll(testDupes());
    await _yieldToUi();

    results.addAll(testSections());
    await _yieldToUi();

    results.addAll(testSettings(ref));
    await _yieldToUi();

    results.addAll(testCatalog());
    await _yieldToUi();

    results.addAll(testFinder());
    await _yieldToUi();

    results.addAll(testEngine());
    await _yieldToUi();

    results.addAll(testCart());
  } on Object catch (e, st) {
    results.add(
      TestResult(
        id: 'runner:crash',
        category: TestCategory.dsync,
        label: 'הריצה קרסה',
        checks: [
          TestCheck(
            name: 'הריצה הסתיימה בלי לקרוס',
            pass: false,
            detail: '$e\n$st',
          ),
        ],
      ),
    );
  }

  ref.read(regressionResultsProvider.notifier).state = results;
  ref.read(regressionStatusProvider.notifier).state = RegressionStatus.done;
}
