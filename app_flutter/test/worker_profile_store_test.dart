// #104 guard tests · worker profile store — lib/state/worker_profile_store.dart.
// The store is a `username → WorkerProfile` overrides-map persisted under
// 'bs.worker-profile.v1'. These tests cover ONLY the #104 additions and the
// store seams they ride on (the courier_profile_store_test idioms):
//   • round-trip of the new fields — toJson/fromJson preserves
//     idNumber/address/emergencyName/emergencyPhone across a simulated restart,
//     byte-verified in the persisted payload;
//   • back-compat — a v1 payload saved BEFORE #104 (no new keys) loads each new
//     field as '' (honest empty override), never a crash;
//   • per-username isolation — re-editing ran never touches omer's record;
//   • corrupt payload → empty map, the store stays usable;
//   • the ticket-#24 race — a synchronous save before _load resolves survives.
import 'dart:convert';

import 'package:buildsmart/state/worker_profile_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 60));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorkerProfile JSON — #104 fields', () {
    test('round-trip — toJson/fromJson שומר את כל ארבעת השדות החדשים', () {
      const p = WorkerProfile(
        name: 'רן',
        phone: '0501234567',
        specialty: 'אינסטלטור',
        photo: 'data:image/png;base64,AAA=',
        idNumber: '123456789',
        address: 'הרצל 10, תל אביב',
        emergencyName: 'דנה',
        emergencyPhone: '0529998888',
      );
      final back = WorkerProfile.fromJson(p.toJson());
      expect(back.idNumber, '123456789');
      expect(back.address, 'הרצל 10, תל אביב');
      expect(back.emergencyName, 'דנה');
      expect(back.emergencyPhone, '0529998888');
      // the pre-#104 fields are still carried losslessly through the round-trip
      expect(back.name, 'רן');
      expect(back.phone, '0501234567');
      expect(back.specialty, 'אינסטלטור');
      expect(back.photo, 'data:image/png;base64,AAA=');
    });

    test('toJson — המפתחות החדשים אכן נכתבים לפיילואד (byte-level)', () {
      const p = WorkerProfile(
        idNumber: '987654321',
        address: 'אבן גבירול 5',
        emergencyName: 'יוסי',
        emergencyPhone: '0541112222',
      );
      final j = p.toJson();
      expect(j['idNumber'], '987654321');
      expect(j['address'], 'אבן גבירול 5');
      expect(j['emergencyName'], 'יוסי');
      expect(j['emergencyPhone'], '0541112222');
    });

    test('back-compat — פיילואד ישן בלי השדות החדשים נטען כמחרוזת ריקה', () {
      // A v1 record saved BEFORE #104 — only the original four keys exist.
      final legacy = <String, dynamic>{
        'name': 'עומר',
        'phone': '0507654321',
        'specialty': 'חשמלאי',
        'photo': null,
      };
      final p = WorkerProfile.fromJson(legacy);
      // every #104 field decodes to the honest empty override — no crash.
      expect(p.idNumber, '');
      expect(p.address, '');
      expect(p.emergencyName, '');
      expect(p.emergencyPhone, '');
      // the legacy data itself is preserved verbatim.
      expect(p.name, 'עומר');
      expect(p.phone, '0507654321');
      expect(p.specialty, 'חשמלאי');
      expect(p.photo, isNull);
    });

    test('back-compat — ערכי null מפורשים בשדות החדשים דועכים ל-"" בלי קריסה', () {
      final j = <String, dynamic>{
        'name': 'רן',
        'idNumber': null,
        'address': null,
        'emergencyName': null,
        'emergencyPhone': null,
      };
      final p = WorkerProfile.fromJson(j);
      expect(p.idNumber, '');
      expect(p.address, '');
      expect(p.emergencyName, '');
      expect(p.emergencyPhone, '');
      expect(p.name, 'רן');
    });
  });

  group('WorkerProfileStore — persistence of #104 fields', () {
    test('round-trip — save נשמר תחת bs.worker-profile.v1 ושורד ריסטרט מדומה',
        () async {
      SharedPreferences.setMockInitialValues({});
      final c1 = ProviderContainer();
      final ok = await c1.read(workerProfileProvider.notifier).save(
            'ran',
            const WorkerProfile(
              name: 'רן',
              phone: '0501234567',
              specialty: 'אינסטלטור',
              idNumber: '123456789',
              address: 'הרצל 10',
              emergencyName: 'דנה',
              emergencyPhone: '0529998888',
            ),
          );
      expect(ok, true, reason: 'a healthy persist must report success');
      c1.dispose();

      // Byte-verify the persisted payload carries the #104 fields.
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kWorkerProfileKey);
      expect(raw, isNotNull);
      final persisted =
          (jsonDecode(raw!) as Map<String, dynamic>)['ran'] as Map;
      expect(persisted['idNumber'], '123456789');
      expect(persisted['address'], 'הרצל 10');
      expect(persisted['emergencyName'], 'דנה');
      expect(persisted['emergencyPhone'], '0529998888');

      // Fresh container = fresh store → must reload from prefs. Providers are
      // lazy — touch it so the store (and its _load()) actually starts.
      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      c2.read(workerProfileProvider);
      await _settle();

      final p = c2.read(workerProfileProvider)['ran'];
      expect(p, isNotNull, reason: 'the profile must survive an app restart');
      expect(p!.idNumber, '123456789');
      expect(p.address, 'הרצל 10');
      expect(p.emergencyName, 'דנה');
      expect(p.emergencyPhone, '0529998888');
      // the rest survives too.
      expect(p.name, 'רן');
      expect(p.phone, '0501234567');
      expect(p.specialty, 'אינסטלטור');
    });

    test('back-compat דרך הדיסק — payload ישן ללא שדות #104 נטען כ-"" בלי קריסה',
        () async {
      // Seed prefs with a v1 record that PRE-DATES #104 (only old keys).
      SharedPreferences.setMockInitialValues({
        kWorkerProfileKey: jsonEncode({
          'ran': {
            'name': 'רן',
            'phone': '0501234567',
            'specialty': 'אינסטלטור',
            'photo': null,
          },
        }),
      });
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(workerProfileProvider); // lazy — start its _load()
      await _settle();

      final p = c.read(workerProfileProvider)['ran'];
      expect(p, isNotNull, reason: 'an old record still loads (no crash)');
      expect(p!.idNumber, '');
      expect(p.address, '');
      expect(p.emergencyName, '');
      expect(p.emergencyPhone, '');
      expect(p.name, 'רן', reason: 'the legacy fields stay intact');
      expect(p.specialty, 'אינסטלטור');
    });

    test('payload פגום — הטעינה משאירה מפה ריקה והחנות נשארת שמישה', () async {
      SharedPreferences.setMockInitialValues({kWorkerProfileKey: '{not json'});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(workerProfileProvider); // lazy — start its _load()
      await _settle();

      expect(c.read(workerProfileProvider), isEmpty,
          reason: 'a corrupt payload is dropped, never thrown');
      final ok = await c
          .read(workerProfileProvider.notifier)
          .save('ran', const WorkerProfile(name: 'רן', phone: '0501234567'));
      expect(ok, true, reason: 'the store stays usable after a corrupt load');
      expect(c.read(workerProfileProvider)['ran']?.name, 'רן');
    });

    test('בידוד per-username — עריכה חוזרת של ran לא נוגעת בשדות #104 של omer',
        () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(workerProfileProvider.notifier);

      expect(
        await n.save(
          'ran',
          const WorkerProfile(
            name: 'רן',
            idNumber: '111111111',
            address: 'הרצל 1',
          ),
        ),
        true,
      );
      expect(
        await n.save(
          'omer',
          const WorkerProfile(
            name: 'עומר',
            idNumber: '222222222',
            emergencyName: 'מירי',
            emergencyPhone: '0523334444',
          ),
        ),
        true,
      );
      expect(c.read(workerProfileProvider).length, 2);

      // Re-editing ran must leave omer's #104 fields byte-identical.
      expect(
        await n.save(
          'ran',
          const WorkerProfile(name: 'רן ב׳', idNumber: '999999999'),
        ),
        true,
      );
      final m = c.read(workerProfileProvider);
      expect(m['ran']?.name, 'רן ב׳');
      expect(m['ran']?.idNumber, '999999999');
      expect(m['ran']?.address, '',
          reason: 'ran\'s own address was cleared by the second save');
      expect(m['omer']?.name, 'עומר',
          reason: 'omer\'s profile is untouched by ran\'s edit');
      expect(m['omer']?.idNumber, '222222222');
      expect(m['omer']?.emergencyName, 'מירי');
      expect(m['omer']?.emergencyPhone, '0523334444');
    });

    test('late _load does not clobber a fresh save (#24 race guard)', () async {
      // Seed an OLD persisted profile, mutate synchronously before the lazy
      // store's async _load() resolves, then assert the fresh write SURVIVED.
      SharedPreferences.setMockInitialValues({
        kWorkerProfileKey: jsonEncode(
            {'ran': const WorkerProfile(name: 'ישן').toJson()}),
      });
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(workerProfileProvider.notifier);

      // save() mutates state synchronously before its first await — exactly
      // the user-write-before-prefs-resolve race of ticket #24.
      final pending = n.save(
        'ran',
        const WorkerProfile(name: 'חדש', idNumber: '123456789'),
      );
      await _settle();

      final p = c.read(workerProfileProvider)['ran'];
      expect(p?.name, 'חדש',
          reason: 'the fresh save must survive the late prefs load (#24)');
      expect(p?.idNumber, '123456789',
          reason: 'the fresh #104 field survives the race too');
      expect(await pending, true);
    });
  });
}
