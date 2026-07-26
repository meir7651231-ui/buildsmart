// Giant-system Phase 1 / V1 — the store tier: hydration honors the arming
// flag (injectable — dart-defines never reach the suite), corrupt prefs
// degrade to the default WITHOUT clearing (iron-rule-1), persist is
// quota-honest, and the provider's un-overridden default is today's world.

import 'package:buildsmart/config/org_config.dart';
import 'package:buildsmart/state/org_config_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('disabled (the shipped default) → the default config, zero reads', () async {
    SharedPreferences.setMockInitialValues(
        {kOrgConfigKey: encodeOrgConfig(const OrgConfig(orgName: 'זר'))});
    final c = await hydrateOrgConfig(enabled: false);
    expect(identical(c, kDefaultOrgConfig), isTrue,
        reason: 'flag OFF must not even look at the blob');
  });

  test('enabled + missing → default; + valid → decoded', () async {
    SharedPreferences.setMockInitialValues({});
    expect(identical(await hydrateOrgConfig(enabled: true), kDefaultOrgConfig),
        isTrue);
    SharedPreferences.setMockInitialValues(
        {kOrgConfigKey: encodeOrgConfig(const OrgConfig(orgName: 'אלפא'))});
    expect((await hydrateOrgConfig(enabled: true)).orgName, 'אלפא');
  });

  test('enabled + corrupt → default, no throw, blob NOT cleared', () async {
    SharedPreferences.setMockInitialValues({kOrgConfigKey: 'garbage{'});
    final c = await hydrateOrgConfig(enabled: true);
    expect(identical(c, kDefaultOrgConfig), isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(kOrgConfigKey), 'garbage{',
        reason: 'ignored, never cleared — awaiting a fixed write');
  });

  test('persist round-trips; clear removes', () async {
    SharedPreferences.setMockInitialValues({});
    const c = OrgConfig(slug: 's1', modules: {'finance': false});
    expect(await persistOrgConfig(c), isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(kOrgConfigKey), encodeOrgConfig(c));
    await clearOrgConfig();
    expect(prefs.getString(kOrgConfigKey), isNull);
  });

  test('un-overridden provider = the default (the whole suite = today)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(identical(container.read(orgConfigProvider), kDefaultOrgConfig),
        isTrue);
  });
}
