// Theme-flash fix (POLISH, cold-start): app settings are pre-hydrated from prefs
// BEFORE the first frame and the notifier is seeded, so a dark-theme user never
// renders a light frame first. Pins the two seams: loadAppSettings() reads the
// persisted value, and a seeded notifier starts at it (no defaults flash).
import 'dart:convert';

import 'package:buildsmart/state/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('a seeded notifier starts at the seed synchronously (no defaults flash)',
      () {
    final seed = AppSettings.defaults.copyWith(theme: BsTheme.dark);
    final n = AppSettingsNotifier(null, seed);
    addTearDown(n.dispose);
    // Immediately — no async gap — the state is the seed, not AppSettings.defaults.
    expect(n.state.theme, BsTheme.dark);
  });

  test('loadAppSettings returns the persisted value', () async {
    final custom = AppSettings.defaults.copyWith(theme: BsTheme.dark);
    SharedPreferences.setMockInitialValues(
        {'bs.settings.v1': jsonEncode(custom.toJson())});
    final loaded = await loadAppSettings();
    expect(loaded.theme, BsTheme.dark);
  });

  test('loadAppSettings returns defaults when absent/corrupt', () async {
    SharedPreferences.setMockInitialValues({});
    expect((await loadAppSettings()).toJson(), AppSettings.defaults.toJson());
    SharedPreferences.setMockInitialValues({'bs.settings.v1': '{bad json'});
    expect((await loadAppSettings()).toJson(), AppSettings.defaults.toJson());
  });
}
