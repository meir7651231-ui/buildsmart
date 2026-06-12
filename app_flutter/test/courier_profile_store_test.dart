// Guard tests for #86.1 · courier profile store — lib/state/courier_profile_store.dart.
// The store is the worker_profile_store clone for the courier's אזור-אישי: a
// `username → CourierProfile` overrides-map persisted under
// 'bs.courier-profile.v1'. Covered here (the worker_attendance_test idioms):
//   • save → restart round-trip (providers are LAZY — touch before settle),
//   • corrupt payload → empty map, the store stays usable,
//   • per-username isolation (ran's edits never leak to omer),
//   • preferredHaul validation at BOTH seams — fromJson (load) and save —
//     an unknown id decays honestly to '' (never an invented kHaulTypes.first),
//   • the ticket-#24 race (a synchronous save before _load resolves survives),
//   • a FAILED persist rolls the state back (the debugPersistOverride hook).
import 'dart:convert';

import 'package:buildsmart/state/courier_profile_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 60));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('normalizeHaul — מזהה חוקי עובר כמו-שהוא, כל השאר דועך ל-"" (כנות)', () {
    expect(CourierProfile.normalizeHaul('small'), 'small');
    expect(CourierProfile.normalizeHaul('van'), 'van');
    expect(CourierProfile.normalizeHaul('truck'), 'truck');
    // Unknown ids, the Hebrew NAME (not the id), '', null and non-strings all
    // decay to '' — the honest "no vehicle chosen", never kHaulTypes.first.
    expect(CourierProfile.normalizeHaul('rocket'), '');
    expect(CourierProfile.normalizeHaul('משאית'), '');
    expect(CourierProfile.normalizeHaul(''), '');
    expect(CourierProfile.normalizeHaul(null), '');
    expect(CourierProfile.normalizeHaul(42), '');
  });

  test('round-trip — save נשמר תחת bs.courier-profile.v1 ושורד ריסטרט מדומה',
      () async {
    SharedPreferences.setMockInitialValues({});
    final c1 = ProviderContainer();
    final ok = await c1.read(courierProfileProvider.notifier).save(
          'ran',
          const CourierProfile(
            displayName: 'רן המהיר',
            phone: '0501234567',
            preferredHaul: 'van',
            photo: 'data:image/png;base64,AAA=',
          ),
        );
    expect(ok, true, reason: 'a healthy persist must report success');
    c1.dispose();

    // Byte-verify the persisted payload — the haul ID, never the Hebrew name.
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kCourierProfileKey);
    expect(raw, isNotNull);
    final persisted = (jsonDecode(raw!) as Map<String, dynamic>)['ran'] as Map;
    expect(persisted['preferredHaul'], 'van');

    // Fresh container = fresh store → must reload from prefs. Providers are
    // lazy — touch it so the store (and its _load()) actually starts.
    final c2 = ProviderContainer();
    addTearDown(c2.dispose);
    c2.read(courierProfileProvider);
    await _settle();

    final p = c2.read(courierProfileProvider)['ran'];
    expect(p, isNotNull, reason: 'the profile must survive an app restart');
    expect(p!.displayName, 'רן המהיר');
    expect(p.phone, '0501234567');
    expect(p.preferredHaul, 'van');
    expect(p.photo, 'data:image/png;base64,AAA=');
  });

  test('payload פגום — הטעינה משאירה מפה ריקה והחנות נשארת שמישה', () async {
    SharedPreferences.setMockInitialValues({kCourierProfileKey: '{not json'});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(courierProfileProvider); // lazy — start its _load()
    await _settle();

    expect(c.read(courierProfileProvider), isEmpty,
        reason: 'a corrupt payload is dropped, never thrown');
    final ok = await c
        .read(courierProfileProvider.notifier)
        .save('ran', const CourierProfile(displayName: 'רן'));
    expect(ok, true, reason: 'the store stays usable after a corrupt load');
    expect(c.read(courierProfileProvider)['ran']?.displayName, 'רן');
  });

  test('בידוד per-username — עריכה חוזרת של ran לא נוגעת ב-omer', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(courierProfileProvider.notifier);

    expect(
      await n.save('ran',
          const CourierProfile(displayName: 'רן', phone: '0501111111')),
      true,
    );
    expect(
      await n.save('omer',
          const CourierProfile(displayName: 'עומר', preferredHaul: 'truck')),
      true,
    );
    expect(c.read(courierProfileProvider).length, 2);

    // Re-editing ran must leave omer's overrides byte-identical.
    expect(
      await n.save('ran',
          const CourierProfile(displayName: 'רן ב׳', phone: '0502222222')),
      true,
    );
    final m = c.read(courierProfileProvider);
    expect(m['ran']?.displayName, 'רן ב׳');
    expect(m['ran']?.phone, '0502222222');
    expect(m['omer']?.displayName, 'עומר',
        reason: 'omer\'s profile is untouched by ran\'s edit');
    expect(m['omer']?.preferredHaul, 'truck');
    expect(m['omer']?.phone, '');
  });

  test('preferredHaul לא-חוקי בתפר הטעינה — fromJson דועך ל-"" בלי להמציא רכב',
      () async {
    SharedPreferences.setMockInitialValues({
      kCourierProfileKey: jsonEncode({
        'ran': {
          'displayName': 'רן',
          'phone': '0501234567',
          'preferredHaul': 'משאית', // the Hebrew NAME — not a valid haul id
          'photo': 42, // not a string — must decay to null, not crash
        },
      }),
    });
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(courierProfileProvider);
    await _settle();

    final p = c.read(courierProfileProvider)['ran'];
    expect(p, isNotNull);
    expect(p!.preferredHaul, '',
        reason: 'an unknown persisted haul decays honestly to "" — never '
            'an invented kHaulTypes.first');
    expect(p.photo, isNull, reason: 'a non-string photo decays to null');
    expect(p.displayName, 'רן', reason: 'the valid fields stay intact');
    expect(p.phone, '0501234567');
  });

  test('preferredHaul לא-חוקי בתפר הכתיבה — save מנרמל ל-"" גם בזיכרון וגם בדיסק',
      () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(courierProfileProvider.notifier);

    expect(
      await n.save('ran',
          const CourierProfile(displayName: 'רן', preferredHaul: 'rocket')),
      true,
    );
    expect(c.read(courierProfileProvider)['ran']?.preferredHaul, '',
        reason: 'a save can never smuggle an unknown haul id into state');

    final prefs = await SharedPreferences.getInstance();
    final persisted = (jsonDecode(prefs.getString(kCourierProfileKey)!)
        as Map<String, dynamic>)['ran'] as Map;
    expect(persisted['preferredHaul'], '',
        reason: 'the normalized value is what actually persists');
  });

  test('late _load does not clobber a fresh save (#24 race guard)', () async {
    // Seed an OLD persisted profile, mutate synchronously before the lazy
    // store's async _load() resolves, then assert the fresh write SURVIVED.
    SharedPreferences.setMockInitialValues({
      kCourierProfileKey: jsonEncode(
          {'ran': const CourierProfile(displayName: 'ישן').toJson()}),
    });
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(courierProfileProvider.notifier);

    // save() mutates state synchronously before its first await — exactly
    // the user-write-before-prefs-resolve race of ticket #24.
    final pending = n.save('ran', const CourierProfile(displayName: 'חדש'));
    await _settle();

    expect(c.read(courierProfileProvider)['ran']?.displayName, 'חדש',
        reason: 'the fresh save must survive the late prefs load (#24)');
    expect(await pending, true);
  });

  test('save כושל → rollback מלא — המצב משוחזר ושאר המשתמשים לא נפגעים',
      () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(courierProfileProvider.notifier);

    // A healthy save first — omer's profile must survive the later failure.
    expect(
      await n.save('omer', const CourierProfile(displayName: 'עומר')),
      true,
    );

    final before = c.read(courierProfileProvider);
    n.debugPersistOverride = () async => false; // simulated quota failure
    final ok = await n.save(
      'ran',
      const CourierProfile(
        displayName: 'רן',
        photo: 'data:image/png;base64,HUGE',
      ),
    );
    expect(ok, false, reason: 'a failed persist must be reported honestly');

    final after = c.read(courierProfileProvider);
    expect(identical(after, before), isTrue,
        reason: 'the rollback restores the exact pre-save state object');
    expect(after.containsKey('ran'), isFalse,
        reason: 'the failed profile never lingers in memory');
    expect(after['omer']?.displayName, 'עומר',
        reason: 'other usernames are untouched by the rollback');

    // The persisted payload was never polluted with the failed write.
    final prefs = await SharedPreferences.getInstance();
    final persisted = jsonDecode(prefs.getString(kCourierProfileKey)!)
        as Map<String, dynamic>;
    expect(persisted.keys.toList(), ['omer']);

    // The store recovers — clearing the hook lets the next save land.
    n.debugPersistOverride = null;
    expect(await n.save('ran', const CourierProfile(displayName: 'רן')), true);
    expect(c.read(courierProfileProvider)['ran']?.displayName, 'רן');
    expect(c.read(courierProfileProvider)['omer']?.displayName, 'עומר');
  });
}
