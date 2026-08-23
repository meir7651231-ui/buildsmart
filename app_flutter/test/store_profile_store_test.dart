// Guard tests for #87.1 · פרופיל-עסק ספק — lib/state/store_profile_store.dart.
// The store must be airtight: per-username round-trip under
// 'bs.store-profile.v1' survives a simulated restart, a corrupt payload
// honestly degrades to an empty map, lipskey↔demo never leak into each other,
// the one-time F-18.3 migration from the legacy GLOBAL
// 'bs.supplier-settings.v1' record seeds IN-MEMORY only (the legacy key is
// never deleted and never rewritten; it materializes under the new keyed map
// only after the first save()), a failing persist rolls the state back
// (debugPersistOverride — the F-9 hook), and a late _load() never clobbers a
// fresh save (the ticket-#24 race, mirrored from state_loadrace_guards_test).
// Also #87.3: kStoreCertPresets is exactly the two presets, and
// storeCertsProvider writes ONLY to 'bs.store-certs.v1' — the worker and
// courier wallets stay untouched (the shared `demo` username must not leak).
import 'dart:convert';

import 'package:buildsmart/state/courier_hr.dart' show kCourierCertsKey;
import 'package:buildsmart/state/store_profile_store.dart';
import 'package:buildsmart/state/worker_certs.dart' show kWorkerCertsKey;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 60));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('byte-honest keys + kStoreCertPresets is EXACTLY the two presets', () {
    expect(kStoreProfileKey, 'bs.store-profile.v1');
    expect(kLegacySupplierSettingsKey, 'bs.supplier-settings.v1');
    expect(kStoreCertsKey, 'bs.store-certs.v1');
    expect(kStoreCertPresets, orderedEquals(['רישיון עסק', 'ביטוח עסק']),
        reason: 'preset chips pre-fill the NAME only — exactly these two, '
            'in this order (אין המצאות)');
  });

  test(
      'round-trip per-username — the profile survives a simulated restart '
      'under bs.store-profile.v1', () async {
    SharedPreferences.setMockInitialValues({});
    final c1 = ProviderContainer();
    final n1 = c1.read(storeProfileProvider.notifier);
    const saved = StoreProfile(
      businessName: 'ליפסקי צנרת ואינסטלציה',
      phone: '0521112233',
      address: 'הר הברזל 7, ירושלים',
      businessId: '512345678',
      logo: 'data:image/png;base64,AAA=',
    );
    expect(await n1.save('lipskey', saved), true,
        reason: 'an awaited save() against mock prefs must report success');
    c1.dispose();

    // Fresh container = fresh notifier → must reload from prefs. Providers
    // are lazy — touch it so the notifier (and its _load()) actually starts.
    final c2 = ProviderContainer();
    addTearDown(c2.dispose);
    c2.read(storeProfileProvider);
    await _settle();

    final m = c2.read(storeProfileProvider);
    final p = m['lipskey'];
    expect(p, isNotNull, reason: 'the persisted profile must survive restart');
    expect(p!.businessName, saved.businessName);
    expect(p.phone, saved.phone);
    expect(p.address, saved.address);
    expect(p.businessId, saved.businessId);
    expect(p.logo, saved.logo, reason: 'the logo data-URL round-trips intact');
    expect(m.containsKey('demo'), false,
        reason: 'no legacy record exists — nothing may be invented for demo');
  });

  test('בידוד lipskey↔demo — neither profile ever leaks to the other',
      () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(storeProfileProvider.notifier);

    const lipskey = StoreProfile(
      businessName: 'ליפסקי',
      phone: '0501111111',
      logo: 'data:image/png;base64,LLL=',
    );
    expect(await n.save('lipskey', lipskey), true);
    expect(c.read(storeProfileProvider)['demo'], isNull,
        reason: 'saving lipskey must NOT create/overwrite a demo record — '
            'the screen falls back to const StoreProfile() honestly');

    const demo = StoreProfile(businessName: 'חנות הדגמה', phone: '0502222222');
    expect(await n.save('demo', demo), true);

    final m = c.read(storeProfileProvider);
    expect(m['lipskey']?.businessName, 'ליפסקי',
        reason: "demo's save must not touch lipskey's record");
    expect(m['lipskey']?.phone, '0501111111');
    expect(m['lipskey']?.logo, 'data:image/png;base64,LLL=');
    expect(m['demo']?.businessName, 'חנות הדגמה');
    expect(m['demo']?.logo, isNull,
        reason: "lipskey's logo must not bleed into demo");

    // The isolation also survives a restart (per-username keyed map on disk).
    final c2 = ProviderContainer();
    addTearDown(c2.dispose);
    c2.read(storeProfileProvider);
    await _settle();
    final m2 = c2.read(storeProfileProvider);
    expect(m2['lipskey']?.businessName, 'ליפסקי');
    expect(m2['demo']?.businessName, 'חנות הדגמה');
  });

  test('corrupt persisted payload → empty map, no crash, store stays usable',
      () async {
    SharedPreferences.setMockInitialValues({kStoreProfileKey: '{לא json'});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(storeProfileProvider); // lazy — start its _load()
    await _settle();

    expect(c.read(storeProfileProvider), isEmpty,
        reason: 'a corrupt payload is dropped, never thrown');

    final n = c.read(storeProfileProvider.notifier);
    expect(await n.save('lipskey', const StoreProfile(businessName: 'חדש')),
        true,
        reason: 'the notifier stays usable after a corrupt load');
    expect(c.read(storeProfileProvider)['lipskey']?.businessName, 'חדש');
  });

  test(
      'defensive decode — wrong-typed fields fall back to honest empties; '
      'a non-Map entry is dropped', () async {
    SharedPreferences.setMockInitialValues({
      kStoreProfileKey: jsonEncode({
        'lipskey': {'name': 5, 'phone': ['x'], 'bid': true, 'logo': 7},
        'demo': 'not-a-map',
      }),
    });
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(storeProfileProvider);
    await _settle();

    final m = c.read(storeProfileProvider);
    final p = m['lipskey'];
    expect(p, isNotNull);
    expect(p!.businessName, '',
        reason: 'a wrong-typed field decodes to its empty default — '
            'the UI then falls back to the session displayName');
    expect(p.phone, '');
    expect(p.businessId, '');
    expect(p.logo, isNull);
    expect(m.containsKey('demo'), false,
        reason: 'an entry whose value is not a Map is dropped, not invented');
  });

  test(
      'מיגרציה כנה (F-18.3) — legacy seeds IN-MEMORY for store users + demo; '
      'the legacy key is neither deleted nor rewritten; the new key '
      'materializes only after save()', () async {
    final legacyRaw = jsonEncode({
      'name': 'ליפסקי הגלובלי',
      'phone': '0509998877',
      'address': 'דרך חברון 1, ירושלים',
      'bid': '511111111',
      'hours': 'א׳-ה׳ 08:00-17:00', // legacy-only field — must be ignored
    });
    SharedPreferences.setMockInitialValues({
      kLegacySupplierSettingsKey: legacyRaw,
    });
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(storeProfileProvider.notifier);
    await _settle();

    final m = c.read(storeProfileProvider);
    expect(m['lipskey']?.businessName, 'ליפסקי הגלובלי',
        reason: 'lipskey really did see the global record before — seeded');
    expect(m['lipskey']?.phone, '0509998877');
    expect(m['lipskey']?.address, 'דרך חברון 1, ירושלים');
    expect(m['lipskey']?.businessId, '511111111');
    expect(m['lipskey']?.logo, isNull,
        reason: 'no logo in the legacy record → none is invented');
    expect(m['demo']?.businessName, 'ליפסקי הגלובלי',
        reason: 'the shared demo store session saw the global record too');
    expect(m.containsKey('ran'), false,
        reason: 'worker usernames never get a store-profile seed');
    expect(m.containsKey('dudi'), false,
        reason: 'courier usernames never get a store-profile seed');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(kStoreProfileKey), isNull,
        reason: 'the migration is IN-MEMORY on load — the new key must not '
            'be written before the supplier actually saves');
    expect(prefs.getString(kLegacySupplierSettingsKey), legacyRaw,
        reason: 'the legacy key is NEVER deleted or rewritten by this store');

    // First save() materializes the keyed map (the seeded entries included).
    final edited = m['lipskey']!.copyWith(phone: '0501231234');
    expect(await n.save('lipskey', edited), true);

    final raw = prefs.getString(kStoreProfileKey);
    expect(raw, isNotNull,
        reason: 'after the first save() the new keyed map must exist');
    final decoded = jsonDecode(raw!) as Map<String, dynamic>;
    expect((decoded['lipskey'] as Map?)?['phone'], '0501231234',
        reason: 'the edit lands under the new per-username key');
    expect((decoded['lipskey'] as Map?)?['name'], 'ליפסקי הגלובלי',
        reason: 'copyWith keeps the migrated fields the supplier did not edit');
    expect((decoded['demo'] as Map?)?['name'], 'ליפסקי הגלובלי',
        reason: 'the in-memory demo seed materializes with the same write');
    expect(prefs.getString(kLegacySupplierSettingsKey), legacyRaw,
        reason: 'save() must still leave the legacy record byte-identical');
  });

  test('מיגרציה — an existing entry under the NEW key beats the legacy seed',
      () async {
    SharedPreferences.setMockInitialValues({
      kStoreProfileKey: jsonEncode({
        'lipskey': {'name': 'שלי כבר', 'phone': '0503334444'},
      }),
      kLegacySupplierSettingsKey: jsonEncode({'name': 'גלובלי ישן'}),
    });
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(storeProfileProvider);
    await _settle();

    final m = c.read(storeProfileProvider);
    expect(m['lipskey']?.businessName, 'שלי כבר',
        reason: 'a username that already migrated keeps its OWN record');
    expect(m['lipskey']?.phone, '0503334444');
    expect(m['demo']?.businessName, 'גלובלי ישן',
        reason: 'usernames without an entry still get the legacy seed');
  });

  test('corrupt / non-Map legacy payload — no migration, no crash', () async {
    SharedPreferences.setMockInitialValues({
      kLegacySupplierSettingsKey: '<<שבור',
    });
    final c1 = ProviderContainer();
    addTearDown(c1.dispose);
    c1.read(storeProfileProvider);
    await _settle();
    expect(c1.read(storeProfileProvider), isEmpty,
        reason: 'a corrupt legacy record is skipped honestly — no seeding');

    // A decodable-but-wrong-shape legacy value (a list) is equally skipped.
    SharedPreferences.setMockInitialValues({
      kLegacySupplierSettingsKey: jsonEncode([1, 2, 3]),
    });
    final c2 = ProviderContainer();
    addTearDown(c2.dispose);
    c2.read(storeProfileProvider);
    await _settle();
    expect(c2.read(storeProfileProvider), isEmpty,
        reason: 'a non-Map legacy payload must not seed anything');
  });

  test(
      'save כושל (debugPersistOverride → false) — returns false and rolls '
      'the in-memory state back', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(storeProfileProvider.notifier);
    await _settle();

    // Establish a real saved baseline first (rollback must restore IT, not {}).
    const v1 = StoreProfile(businessName: 'ליפסקי', phone: '0501111111');
    expect(await n.save('lipskey', v1), true);

    // Now the quota "fails" — e.g. an oversized logo data-URL on web.
    n.debugPersistOverride = () async => false;
    const v2 = StoreProfile(
      businessName: 'ליפסקי',
      phone: '0501111111',
      logo: 'data:image/png;base64,HUGE=',
    );
    expect(await n.save('lipskey', v2), false,
        reason: 'a failed persist must NOT pretend the profile was saved');
    expect(c.read(storeProfileProvider)['lipskey']?.logo, isNull,
        reason: 'the in-memory state rolls back to the last SAVED profile');
    expect(c.read(storeProfileProvider)['lipskey']?.phone, '0501111111',
        reason: 'rollback restores the previous record, not an empty map');

    final prefs = await SharedPreferences.getInstance();
    final onDisk = jsonDecode(prefs.getString(kStoreProfileKey)!)
        as Map<String, dynamic>;
    expect((onDisk['lipskey'] as Map?)?.containsKey('logo'), false,
        reason: 'the failed write left the persisted record at v1');

    // The store recovers once persisting works again.
    n.debugPersistOverride = () async => true;
    expect(await n.save('lipskey', v2), true);
    expect(c.read(storeProfileProvider)['lipskey']?.logo,
        'data:image/png;base64,HUGE=');
  });

  test('מירוץ #24 — a late _load() does not clobber a fresh save()', () async {
    // Seed an OLD persisted map, mutate synchronously before the lazy
    // notifier's async _load() resolves, then assert the fresh write SURVIVED.
    SharedPreferences.setMockInitialValues({
      kStoreProfileKey: jsonEncode({
        'lipskey': {'name': 'ישן מהדיסק', 'phone': '0500000000'},
      }),
    });
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(storeProfileProvider.notifier);

    // Synchronous kick-off BEFORE the async _load resolves — exactly the race.
    final pending =
        n.save('lipskey', const StoreProfile(businessName: 'טרי מהמשתמש'));
    await _settle();

    expect(c.read(storeProfileProvider)['lipskey']?.businessName,
        'טרי מהמשתמש',
        reason: 'the fresh save must survive the late prefs load (#24)');
    expect(await pending, true);
  });

  test(
      '#87.3 storeCertsProvider writes ONLY bs.store-certs.v1 — the worker '
      'and courier wallets stay untouched', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(storeCertsProvider.notifier);
    await _settle(); // let its lazy _load() finish first

    final cert = await n.add(
      username: 'lipskey',
      name: kStoreCertPresets.first, // 'רישיון עסק' — the preset chip flow
      issuer: 'עיריית ירושלים',
      expiry: DateTime(2027, 3),
    );
    expect(cert, isNotNull, reason: 'add() against mock prefs must succeed');
    expect(c.read(storeCertsProvider).length, 1);
    expect(c.read(storeCertsProvider).single.name, 'רישיון עסק');
    expect(c.read(storeCertsProvider).single.username, 'lipskey');

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kStoreCertsKey);
    expect(raw, isNotNull,
        reason: 'the store wallet persists under bs.store-certs.v1');
    expect(raw, contains('רישיון עסק'));
    expect(prefs.getString(kWorkerCertsKey), isNull,
        reason: 'bs.worker-certs.v1 must stay clean — the shared demo '
            'username would otherwise leak certificates across boards');
    expect(prefs.getString(kCourierCertsKey), isNull,
        reason: 'bs.courier-certs.v1 must stay clean too');
  });
}
