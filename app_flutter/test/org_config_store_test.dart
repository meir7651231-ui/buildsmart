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

  // ── V6 — the deploy-baked COMPANY lane (owner → company → default) ──
  const companyDiveOff = '{"v":1,"modules":{"dive":false}}';

  test('V6: no owner saved + companyJson → the company slice boots', () async {
    SharedPreferences.setMockInitialValues({});
    final c = await hydrateOrgConfig(enabled: true, companyJson: companyDiveOff);
    expect(moduleOn(c, 'dive'), isFalse, reason: 'the baked slice is in force');
    expect(moduleOn(c, 'chat'), isTrue);
  });

  test('V6: a saved owner BEATS the company slice — whole-doc, not a merge',
      () async {
    SharedPreferences.setMockInitialValues({
      kOrgConfigKey: encodeOrgConfig(const OrgConfig(modules: {'chat': false})),
    });
    final c = await hydrateOrgConfig(enabled: true, companyJson: companyDiveOff);
    expect(moduleOn(c, 'chat'), isFalse, reason: 'the owner lane won');
    expect(moduleOn(c, 'dive'), isTrue,
        reason: 'whole-doc replace: the company dive-off does NOT bleed in');
  });

  test('V6: corrupt owner + companyJson → the company slice (not the '
      'default), blob still NOT cleared', () async {
    SharedPreferences.setMockInitialValues({kOrgConfigKey: 'garbage{'});
    final c = await hydrateOrgConfig(enabled: true, companyJson: companyDiveOff);
    expect(moduleOn(c, 'dive'), isFalse, reason: 'fell to the company lane');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(kOrgConfigKey), 'garbage{');
  });

  test('un-overridden provider = the default (the whole suite = today)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(identical(container.read(orgConfigProvider), kDefaultOrgConfig),
        isTrue);
  });
}
