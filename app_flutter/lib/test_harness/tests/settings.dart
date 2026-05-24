import 'package:buildsmart/data/settings_tree.dart';
import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/test_harness/types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

List<TestResult> testSettings(WidgetRef ref) {
  return [
    _runResult(
      id: 'settings:groups',
      label: 'kSettingsGroups — 10 קבוצות הגדרות',
      area: 'מבנה',
      run: () {
        final checks = <TestCheck>[];

        checks.add(TestCheck(
          name: 'kSettingsGroups מכיל 10 קבוצות',
          pass: kSettingsGroups.length == 10,
          expected: '10',
          got: '${kSettingsGroups.length}',
        ));

        const expectedIds = [
          'account', 'notifications', 'display', 'accessibility',
          'security', 'support', 'delivery', 'region', 'about', 'reset',
        ];
        for (final eid in expectedIds) {
          final found = kSettingsGroups.any((g) => g.id == eid);
          checks.add(TestCheck(
            name: 'קבוצה "$eid" קיימת',
            pass: found,
          ));
        }

        for (final g in kSettingsGroups) {
          checks.add(TestCheck(
            name: '${g.id}: id לא ריק',
            pass: g.id.isNotEmpty,
            got: g.id,
          ));
          checks.add(TestCheck(
            name: '${g.id}: label לא ריק',
            pass: g.label.isNotEmpty,
            got: g.label,
          ));
          checks.add(TestCheck(
            name: '${g.id}: emoji לא ריק',
            pass: g.emoji.isNotEmpty,
            got: g.emoji,
          ));
        }

        // reset is isAction (no children)
        final reset = kSettingsGroups.firstWhere((g) => g.id == 'reset');
        checks.add(TestCheck(
          name: 'reset.isAction == true',
          pass: reset.isAction,
        ));
        checks.add(TestCheck(
          name: 'reset.children ריק',
          pass: reset.children.isEmpty,
          got: '${reset.children.length}',
        ));

        // No duplicate group ids
        final ids = kSettingsGroups.map((g) => g.id).toList();
        final idSet = ids.toSet();
        checks.add(TestCheck(
          name: 'אין כפילות group ids',
          pass: idSet.length == ids.length,
          expected: '${ids.length}',
          got: '${idSet.length}',
        ));
        return checks;
      },
    ),
    _runResult(
      id: 'settings:walk',
      label: 'walkSettings — ניווט בעץ הגדרות',
      area: 'לוגיקה',
      run: () {
        final checks = <TestCheck>[];

        // Root of security → 1 child (מרכז האבטחה)
        final secRoot = walkSettings('security', const []);
        checks.add(TestCheck(
          name: 'walkSettings(security, []) → 1 ילד (מרכז האבטחה)',
          pass: secRoot.current.length == 1,
          expected: '1',
          got: '${secRoot.current.length}',
        ));

        // Drill into security hub
        final secHub = walkSettings('security', const ['מרכז האבטחה']);
        checks.add(TestCheck(
          name: 'walkSettings(security, [מרכז האבטחה]) anchors = 1',
          pass: secHub.anchors.length == 1,
        ));
        final hubItems = secHub.current.map((n) => n.label).toList();
        checks.add(TestCheck(
          name: 'אימות דו-שלבי ב-hub האבטחה',
          pass: hubItems.contains('אימות דו-שלבי'),
          detail: hubItems.join(', '),
        ));

        // Drill into display → ערכת נושא → 2 sub-nodes
        final theme = walkSettings('display', const ['ערכת נושא']);
        checks.add(TestCheck(
          name: 'walkSettings(display, [ערכת נושא]) → 2 ילדים',
          pass: theme.current.length == 2,
          expected: '2',
          got: '${theme.current.length}',
        ));

        // Unknown group → empty current
        final bad = walkSettings('__none__', const []);
        checks.add(TestCheck(
          name: 'walkSettings עם group לא קיים → ריק',
          pass: bad.current.isEmpty,
        ));

        // Root of region → 3 children (שפה, יחידות, מטבע)
        final region = walkSettings('region', const []);
        checks.add(TestCheck(
          name: 'walkSettings(region, []) → 3 ילדים',
          pass: region.current.length == 3,
          expected: '3',
          got: '${region.current.length}',
        ));
        return checks;
      },
    ),
    _runResult(
      id: 'settings:defaults',
      label: 'AppSettings.defaults — ערכי ברירת מחדל',
      area: 'state',
      run: () {
        final checks = <TestCheck>[];
        final d = AppSettings.defaults;

        checks.add(TestCheck(
          name: 'theme = light',
          pass: d.theme == BsTheme.light,
          got: d.theme.name,
        ));
        checks.add(TestCheck(
          name: 'textSize = medium',
          pass: d.textSize == BsTextSize.medium,
          got: d.textSize.name,
        ));
        checks.add(TestCheck(
          name: 'lang = he',
          pass: d.lang == BsLang.he,
          got: d.lang.name,
        ));
        checks.add(TestCheck(
          name: 'units = metric',
          pass: d.units == BsUnits.metric,
          got: d.units.name,
        ));
        checks.add(TestCheck(
          name: 'currency = ils',
          pass: d.currency == BsCurrency.ils,
          got: d.currency.name,
        ));
        checks.add(TestCheck(
          name: 'sessionTimeout = m15',
          pass: d.sessionTimeout == BsSessionTimeout.m15,
          got: d.sessionTimeout.name,
        ));
        checks.add(TestCheck(
          name: 'notifShipments = true',
          pass: d.notifShipments,
        ));
        checks.add(TestCheck(
          name: 'notifDeals = true',
          pass: d.notifDeals,
        ));
        checks.add(TestCheck(
          name: 'privMarketing = false (opted-out by default)',
          pass: !d.privMarketing,
        ));
        checks.add(TestCheck(
          name: 'reduceMotion = false',
          pass: !d.reduceMotion,
        ));
        checks.add(TestCheck(
          name: 'highContrast = false',
          pass: !d.highContrast,
        ));
        checks.add(TestCheck(
          name: 'twoFA = false',
          pass: !d.twoFA,
        ));
        return checks;
      },
    ),
    _runResult(
      id: 'settings:copyWith',
      label: 'AppSettings.copyWith — round-trip',
      area: 'state',
      run: () {
        final checks = <TestCheck>[];
        final original = AppSettings.defaults;

        // Change theme to dark
        final dark = original.copyWith(theme: BsTheme.dark);
        checks.add(TestCheck(
          name: 'copyWith(theme:dark) → dark',
          pass: dark.theme == BsTheme.dark,
          got: dark.theme.name,
        ));
        checks.add(TestCheck(
          name: 'copyWith(theme:dark) — שאר השדות ללא שינוי (lang)',
          pass: dark.lang == original.lang,
          got: dark.lang.name,
        ));

        // Change lang to ar
        final arabic = original.copyWith(lang: BsLang.ar);
        checks.add(TestCheck(
          name: 'copyWith(lang:ar) → ar',
          pass: arabic.lang == BsLang.ar,
          got: arabic.lang.name,
        ));
        checks.add(TestCheck(
          name: 'copyWith(lang:ar) — theme לא השתנה',
          pass: arabic.theme == original.theme,
        ));

        // Double copyWith
        final multi = original.copyWith(
          theme: BsTheme.dark,
          textSize: BsTextSize.large,
          express: true,
        );
        checks.add(TestCheck(
          name: 'copyWith מרובה: theme=dark',
          pass: multi.theme == BsTheme.dark,
        ));
        checks.add(TestCheck(
          name: 'copyWith מרובה: textSize=large',
          pass: multi.textSize == BsTextSize.large,
        ));
        checks.add(TestCheck(
          name: 'copyWith מרובה: express=true',
          pass: multi.express,
        ));
        checks.add(TestCheck(
          name: 'copyWith מרובה: lang נשאר he',
          pass: multi.lang == BsLang.he,
        ));
        return checks;
      },
    ),
    _runResult(
      id: 'settings:appSettingsProvider',
      label: 'appSettingsProvider — קריאה מה-state',
      area: 'state',
      run: () {
        final checks = <TestCheck>[];
        final current = ref.read(appSettingsProvider);
        checks.add(TestCheck(
          name: 'appSettingsProvider מחזיר AppSettings',
          pass: current is AppSettings,
        ));
        // Values are within valid enum range (basic sanity)
        checks.add(TestCheck(
          name: 'theme הוא ערך חוקי',
          pass: BsTheme.values.contains(current.theme),
          got: current.theme.name,
        ));
        checks.add(TestCheck(
          name: 'lang הוא ערך חוקי',
          pass: BsLang.values.contains(current.lang),
          got: current.lang.name,
        ));
        checks.add(TestCheck(
          name: 'textSize הוא ערך חוקי',
          pass: BsTextSize.values.contains(current.textSize),
          got: current.textSize.name,
        ));
        return checks;
      },
    ),
  ];
}

TestResult _runResult({
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
    category: TestCategory.settings,
    label: label,
    area: area,
    checks: checks,
  );
}
