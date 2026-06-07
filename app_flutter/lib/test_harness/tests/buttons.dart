import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/test_harness/types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Button-action tests — toggle each FAB dial, switch personas, drill paths.
/// Pattern: save state → mutate → assert → restore.
List<TestResult> testButtons(WidgetRef ref) {
  return [
    _runOne(
      id: 'button:activePersona',
      label: 'activePersona — מעבר בין דמויות',
      area: 'BS',
      run: () {
        final checks = <TestCheck>[];
        final before = ref.read(activePersonaProvider);
        for (final p in ['manager', 'contractor', 'store', 'courier', 'worker']) {
          ref.read(activePersonaProvider.notifier).state = p;
          final got = ref.read(activePersonaProvider);
          checks.add(TestCheck(
            name: 'מעבר ל-$p',
            pass: got == p,
            expected: p,
            got: got ?? 'null',
          ));
        }
        ref.read(activePersonaProvider.notifier).state = null;
        checks.add(TestCheck(
          name: 'איפוס ל-null (חזרה לרשת 5 דמויות)',
          pass: ref.read(activePersonaProvider) == null,
          got: '${ref.read(activePersonaProvider)}',
        ));
        ref.read(activePersonaProvider.notifier).state = before;
        return checks;
      },
    ),
    _runOne(
      id: 'button:resetAllDials',
      label: 'resetAllDials — מאפס את כל ה-state של ה-dial',
      area: 'דיאל',
      run: () {
        final checks = <TestCheck>[];
        // Snapshot
        final ap = ref.read(activePersonaProvider);
        // Make some state
        ref.read(activePersonaProvider.notifier).state = 'manager';
        // Reset
        resetAllDials(ref);
        checks.add(TestCheck(
          name: 'activePersona → null',
          pass: ref.read(activePersonaProvider) == null,
          got: '${ref.read(activePersonaProvider)}',
        ));
        // Restore
        ref.read(activePersonaProvider.notifier).state = ap;
        return checks;
      },
    ),
  ];
}

TestResult _runOne({
  required String id,
  required String label,
  required String area,
  required List<TestCheck> Function() run,
}) {
  var checks = <TestCheck>[];
  var crashed = false;
  try {
    checks = run();
  } on Object catch (e) {
    crashed = true;
    checks.add(TestCheck(
      name: 'הבדיקה רצה בלי לקרוס',
      pass: false,
      detail: '$e',
    ));
  }
  if (!crashed) {
    checks.add(const TestCheck(name: 'הבדיקה רצה בלי לקרוס', pass: true));
  }
  return TestResult(
    id: id,
    category: TestCategory.buttons,
    label: label,
    area: area,
    checks: checks,
  );
}
