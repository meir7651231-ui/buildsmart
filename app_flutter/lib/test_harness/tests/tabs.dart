import 'package:buildsmart/screens/catalog_screen.dart'
    show catalogDrillCatProvider, catalogSectionProvider;
import 'package:buildsmart/screens/store_screen.dart' show StoreSection, storeSectionProvider;
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/test_harness/types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tab-navigation tests — round-trip through every tab state and restore.
List<TestResult> testTabs(WidgetRef ref) {
  return [
    _runOne(
      id: 'tabs:main',
      label: 'mainTab — מעבר בין 4 הטאבים',
      area: 'בוטטום־נב',
      run: () {
        final checks = <TestCheck>[];
        final before = ref.read(mainTabProvider);
        for (var i = 0; i < 4; i++) {
          ref.read(mainTabProvider.notifier).state = i;
          final got = ref.read(mainTabProvider);
          checks.add(TestCheck(
            name: 'מעבר לטאב $i עובד',
            pass: got == i,
            expected: '$i',
            got: '$got',
          ));
        }
        ref.read(mainTabProvider.notifier).state = before;
        checks.add(TestCheck(
          name: 'שחזור למצב המקורי',
          pass: ref.read(mainTabProvider) == before,
          expected: '$before',
          got: '${ref.read(mainTabProvider)}',
        ));
        return checks;
      },
    ),
    _runOne(
      id: 'tabs:store',
      label: 'storeSection — 4 סקשנים של החנות',
      area: 'חנות',
      run: () {
        final checks = <TestCheck>[];
        final before = ref.read(storeSectionProvider);
        for (final s in StoreSection.values) {
          ref.read(storeSectionProvider.notifier).state = s;
          final got = ref.read(storeSectionProvider);
          checks.add(TestCheck(
            name: 'מעבר ל-${s.name}',
            pass: got == s,
            expected: s.name,
            got: got.name,
          ));
        }
        ref.read(storeSectionProvider.notifier).state = before;
        return checks;
      },
    ),
    _runOne(
      id: 'tabs:menu',
      label: 'menuTab — 4 טאבים של תפריט',
      area: 'תפריט',
      run: () {
        final checks = <TestCheck>[];
        final before = ref.read(menuTabProvider);
        for (final t in MenuTab.values) {
          ref.read(menuTabProvider.notifier).state = t;
          final got = ref.read(menuTabProvider);
          checks.add(TestCheck(
            name: 'מעבר ל-${t.name}',
            pass: got == t,
            expected: t.name,
            got: '${got?.name}',
          ));
        }
        ref.read(menuTabProvider.notifier).state = null;
        checks.add(TestCheck(
          name: 'איפוס לשורש (null)',
          pass: ref.read(menuTabProvider) == null,
          expected: 'null',
          got: '${ref.read(menuTabProvider)?.name}',
        ));
        ref.read(menuTabProvider.notifier).state = before;
        return checks;
      },
    ),
    _runOne(
      id: 'tabs:catalogSection',
      label: 'catalogSection — מעבר בין סקשנים',
      area: 'קטלוג',
      run: () {
        final checks = <TestCheck>[];
        final before = ref.read(catalogSectionProvider);
        const candidates = ['הכל', 'מועדפים', 'קטגוריות', 'עץ חכם', 'הכל'];
        for (final s in candidates) {
          ref.read(catalogSectionProvider.notifier).state = s;
          final got = ref.read(catalogSectionProvider);
          checks.add(TestCheck(
            name: 'מעבר ל-"$s"',
            pass: got == s,
            expected: s,
            got: got,
          ));
        }
        ref.read(catalogSectionProvider.notifier).state = before;
        return checks;
      },
    ),
    _runOne(
      id: 'tabs:catalogDrillCat',
      label: 'catalogDrillCat — drill לקטגוריה ושחזור',
      area: 'קטלוג',
      run: () {
        final checks = <TestCheck>[];
        final before = ref.read(catalogDrillCatProvider);
        const testCat = 'ניקוז וצנרת';
        ref.read(catalogDrillCatProvider.notifier).state = testCat;
        checks.add(TestCheck(
          name: 'drill ל-"$testCat" נשמר',
          pass: ref.read(catalogDrillCatProvider) == testCat,
          expected: testCat,
          got: ref.read(catalogDrillCatProvider) ?? 'null',
        ));
        ref.read(catalogDrillCatProvider.notifier).state = null;
        checks.add(TestCheck(
          name: 'pop לשורש (null)',
          pass: ref.read(catalogDrillCatProvider) == null,
          expected: 'null',
          got: '${ref.read(catalogDrillCatProvider)}',
        ));
        ref.read(catalogDrillCatProvider.notifier).state = before;
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
    category: TestCategory.tabs,
    label: label,
    area: area,
    checks: checks,
  );
}
