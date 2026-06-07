import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/test_harness/types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Button-action tests — toggle each FAB dial, switch personas, drill paths.
/// Pattern: save state → mutate → assert → restore.
List<TestResult> testButtons(WidgetRef ref) {
  return [
    _runOne(
      id: 'button:openDial-each',
      label: 'openDial — פתיחת כל אחד מ-5 ה-FABs',
      area: 'דיאל',
      run: () {
        final checks = <TestCheck>[];
        final before = ref.read(openDialProvider);
        for (final d in OpenDial.values) {
          ref.read(openDialProvider.notifier).state = d;
          final got = ref.read(openDialProvider);
          checks.add(TestCheck(
            name: 'דיאל "${d.name}" נפתח',
            pass: got == d,
            expected: d.name,
            got: got.name,
          ));
        }
        ref.read(openDialProvider.notifier).state = before;
        return checks;
      },
    ),
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
      id: 'button:searchTool',
      label: 'searchTool — בחירת כלי חיפוש',
      area: 'חיפוש',
      run: () {
        final checks = <TestCheck>[];
        final before = ref.read(searchToolProvider);
        for (final t in SearchTool.values) {
          ref.read(searchToolProvider.notifier).state = t;
          checks.add(TestCheck(
            name: 'בחירת ${t.name}',
            pass: ref.read(searchToolProvider) == t,
            got: ref.read(searchToolProvider)?.name ?? 'null',
          ));
        }
        ref.read(searchToolProvider.notifier).state = null;
        checks.add(TestCheck(
          name: 'איפוס ל-null',
          pass: ref.read(searchToolProvider) == null,
        ));
        ref.read(searchToolProvider.notifier).state = before;
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
        final bd = ref.read(openDialProvider);
        final ap = ref.read(activePersonaProvider);
        final st = ref.read(searchToolProvider);
        // Make some state
        ref.read(openDialProvider.notifier).state = OpenDial.search;
        ref.read(activePersonaProvider.notifier).state = 'manager';
        ref.read(searchToolProvider.notifier).state = SearchTool.voice;
        // Reset
        resetAllDials(ref);
        checks.add(TestCheck(
          name: 'openDial → none',
          pass: ref.read(openDialProvider) == OpenDial.none,
          got: ref.read(openDialProvider).name,
        ));
        checks.add(TestCheck(
          name: 'activePersona → null',
          pass: ref.read(activePersonaProvider) == null,
          got: '${ref.read(activePersonaProvider)}',
        ));
        checks.add(TestCheck(
          name: 'searchTool → null',
          pass: ref.read(searchToolProvider) == null,
        ));
        // Restore
        ref.read(openDialProvider.notifier).state = bd;
        ref.read(activePersonaProvider.notifier).state = ap;
        ref.read(searchToolProvider.notifier).state = st;
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
