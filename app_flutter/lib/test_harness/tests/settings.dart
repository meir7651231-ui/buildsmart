import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/test_harness/types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

List<TestResult> testSettings(WidgetRef ref) {
  return [
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
