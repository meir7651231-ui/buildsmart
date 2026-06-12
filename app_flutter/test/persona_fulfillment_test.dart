// T5 — DEFERRED PERSONA FULFILLMENT — unit coverage for the side-car that backs
// the store picking sheet, the missing-item hold loop, split shipments and the
// courier POD (lib/state/persona_fulfillment.dart). The notifier is exercised
// directly with persist:false for the pure state-machine assertions, and the
// JSON round-trip is pinned separately (T5.5 persistence shape).
//
// COURIER v2 (#86.6): capturePod is now Future<bool> (honest rollback on a
// storage failure) and atomically stamps `courierUser` ('cu' in the compact
// side-car row); stampCourier stamps it at the courierAdvance moments. The
// prefs-backed groups below additionally pin the F-35 merge-on-write guard
// (the #24 load-race family, state_loadrace_guards_test.dart pattern) and the
// F-5 per-record corruption containment (worker_attendance_test.dart pattern).

import 'dart:convert';

import 'package:buildsmart/state/persona_fulfillment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 60));

/// The `{orderId: dataUrl}` POD-photo side-map contract (the single stored
/// home of the photo bytes — lib keeps its constant private on purpose, the
/// string IS the cross-reader contract).
const String _podPhotosKey = 'bs.pod-photos.v1';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  FulfillmentNotifier fn() => FulfillmentNotifier(persist: false);

  group('T5.1 picking — line pick toggling', () {
    test('an unknown order behaves exactly like pre-T5 (empty record)', () {
      final n = fn();
      final f = n.of('BS-1042');
      expect(f.lineStatus, isEmpty);
      expect(f.heldForMissing, isFalse);
      expect(f.splitInto, 1);
      expect(f.podCaptured, isFalse);
      expect(f.courierUser, isNull,
          reason: 'no attribution is ever invented (#86.6)');
    });

    test('pickLine marks a line picked, and toggling returns to pending', () {
      final n = fn();
      n.pickLine('BS-1042', 0);
      expect(n.of('BS-1042').lineStatus[0], LineStatus.picked);
      n.pickLine('BS-1042', 0);
      expect(n.of('BS-1042').lineStatus[0], LineStatus.pending);
    });
  });

  group('T5.2 missing-item hold loop', () {
    test('flagging missing holds the order; loop releases it on resolve', () {
      final n = fn();
      // Flag line 2 missing → newly held, line is pendingDecision.
      final newlyHeld = n.missLine('BS-1042', 2);
      expect(newlyHeld, isTrue);
      expect(n.of('BS-1042').heldForMissing, isTrue);
      expect(n.of('BS-1042').lineStatus[2], LineStatus.pendingDecision);
      expect(n.of('BS-1042').hasMissing, isTrue);

      // Contractor proceeds-without → line cancelled, hold released, resolved.
      n.proceedWithout('BS-1042', 2);
      expect(n.of('BS-1042').lineStatus[2], LineStatus.cancelled);
      expect(n.of('BS-1042').heldForMissing, isFalse);
      expect(n.of('BS-1042').missingResolved, isTrue);
    });

    test('replace path releases the hold and marks the line replaced', () {
      final n = fn();
      n.missLine('BS-1041', 0);
      expect(n.of('BS-1041').heldForMissing, isTrue);
      n.replaceLine('BS-1041', 0);
      expect(n.of('BS-1041').lineStatus[0], LineStatus.replaced);
      expect(n.of('BS-1041').heldForMissing, isFalse);
      expect(n.of('BS-1041').missingResolved, isTrue);
    });

    test('un-flagging a missing line clears the hold when none still pends', () {
      final n = fn();
      n.missLine('BS-1040', 1); // held
      expect(n.of('BS-1040').heldForMissing, isTrue);
      n.missLine('BS-1040', 1); // toggle off
      expect(n.of('BS-1040').lineStatus[1], LineStatus.pending);
      expect(n.of('BS-1040').heldForMissing, isFalse);
    });

    test('two missing lines stay held until BOTH are resolved', () {
      final n = fn();
      n.missLine('BS-1040', 0);
      n.missLine('BS-1040', 1);
      expect(n.of('BS-1040').heldForMissing, isTrue);
      n.proceedWithout('BS-1040', 0);
      expect(n.of('BS-1040').heldForMissing, isTrue, reason: 'line 1 still pends');
      n.replaceLine('BS-1040', 1);
      expect(n.of('BS-1040').heldForMissing, isFalse);
    });
  });

  group('T5.3 split shipments — round-robin plan', () {
    test('split into N produces a 1-based round-robin plan; 1 clears it', () {
      final n = fn();
      n.split('BS-1042', 7, 3);
      final f = n.of('BS-1042');
      expect(f.splitInto, 3);
      expect(f.splitPlan, [1, 2, 3, 1, 2, 3, 1]);
      // Collapse back to a single package.
      n.split('BS-1042', 7, 1);
      expect(n.of('BS-1042').splitInto, 1);
      expect(n.of('BS-1042').splitPlan, isEmpty);
    });
  });

  group('T5.4 POD — courier proof-of-delivery flags', () {
    test('capturePod / captureSignature set their flags independently',
        () async {
      final n = fn();
      // POD stores the REAL photo data-URL (podPhoto); podCaptured is the
      // derived back-compat getter (photo != null). capturePod is now
      // Future<bool> — with persist:false nothing can fail, so it must be
      // true (the in-memory write always lands).
      expect(await n.capturePod('BS-1039', 'data:image/png;base64,AAAA'),
          isTrue);
      expect(n.of('BS-1039').podCaptured, isTrue);
      expect(n.of('BS-1039').podPhoto, startsWith('data:image'));
      expect(n.of('BS-1039').podSigned, isFalse);
      n.captureSignature('BS-1039');
      expect(n.of('BS-1039').podSigned, isTrue);
    });
  });

  group('#86.6 courierUser — אטריבוציה של שליח על הרשומה', () {
    test('capturePod חותם courierUser אטומית יחד עם התמונה', () async {
      final n = fn();
      expect(
        await n.capturePod(
          'BS-1039',
          'data:image/png;base64,AAAA',
          courierUser: 'noam',
        ),
        isTrue,
      );
      final f = n.of('BS-1039');
      expect(f.podPhoto, 'data:image/png;base64,AAAA');
      expect(f.courierUser, 'noam',
          reason: 'one mutation — the photo and its courier land together');
    });

    test('capturePod בלי session שליח → הרשומה נשארת לא-משויכת (null)',
        () async {
      final n = fn();
      expect(
          await n.capturePod('BS-1039', 'data:image/png;base64,AAAA'), isTrue);
      expect(n.of('BS-1039').courierUser, isNull,
          reason: 'a non-courier flow (persona portal) is never attributed');
    });

    test('stampCourier מציב username בלי לגעת בשדות ה-POD', () async {
      final n = fn();
      await n.capturePod('BS-1039', 'data:image/png;base64,AAAA');
      n.captureSignature('BS-1039');
      n.stampCourier('BS-1039', 'noam');
      final f = n.of('BS-1039');
      expect(f.courierUser, 'noam');
      expect(f.podPhoto, 'data:image/png;base64,AAAA',
          reason: 'copyWith keeps the captured photo');
      expect(f.podSigned, isTrue, reason: 'copyWith keeps the signature');
      expect(f.podCaptured, isTrue);
    });

    test('stampCourier על הזמנה ללא רשומה יוצר רשומה עם השליח בלבד', () {
      final n = fn();
      n.stampCourier('BS-1038', 'noam');
      final f = n.of('BS-1038');
      expect(f.courierUser, 'noam');
      expect(f.podCaptured, isFalse);
      expect(f.podSigned, isFalse);
      expect(f.lineStatus, isEmpty);
    });
  });

  group('T5.5 persistence — JSON round-trip preserves all fields', () {
    test('toJson/fromJson is lossless for a fully-populated record', () {
      const f = Fulfillment(
        lineStatus: {
          0: LineStatus.picked,
          1: LineStatus.missing,
          2: LineStatus.replaced,
        },
        heldForMissing: true,
        missingResolved: true,
        splitInto: 2,
        splitPlan: [1, 2, 1],
        podPhoto: 'data:image/png;base64,AAAA',
        podSigned: true,
        courierUser: 'noam',
      );
      expect(f.toJson()['cu'], 'noam',
          reason: 'courierUser rides the compact side-car row as cu (#86.6)');
      final back = Fulfillment.fromJson(f.toJson());
      expect(back.lineStatus, f.lineStatus);
      expect(back.heldForMissing, isTrue);
      expect(back.missingResolved, isTrue);
      expect(back.splitInto, 2);
      expect(back.splitPlan, [1, 2, 1]);
      expect(back.podCaptured, isTrue);
      expect(back.podSigned, isTrue);
      expect(back.courierUser, 'noam');
    });

    test('an empty record serializes to {} and round-trips to empty', () {
      const f = Fulfillment();
      expect(f.toJson(), isEmpty);
      final back = Fulfillment.fromJson(const {});
      expect(back.lineStatus, isEmpty);
      expect(back.splitInto, 1);
      expect(back.heldForMissing, isFalse);
      expect(back.courierUser, isNull);
    });

    test('back-compat — payload ישן בלי cu נשאר לא-משויך (null)', () {
      // A pre-#86.6 persisted row: POD flags only, no attribution key at all.
      final back = Fulfillment.fromJson(const {
        'sig': true,
        'podCaptured': true,
      });
      expect(back.courierUser, isNull,
          reason: 'honest: never invented for legacy records');
      expect(back.podSigned, isTrue);
      expect(back.podCaptured, isTrue, reason: 'the rest of the row is kept');
    });

    test('cu בטיפוס שגוי (5) מתדרדר ל-null בלי להפיל את שאר הרשומה', () {
      final back = Fulfillment.fromJson(const {
        'cu': 5,
        'held': true,
        'plan': [1, 2],
      });
      expect(back.courierUser, isNull,
          reason: 'a non-String cu degrades per-field, never throws');
      expect(back.heldForMissing, isTrue);
      expect(back.splitPlan, [1, 2]);
    });
  });

  group('T5.5 persistence — prefs side-car + bs.pod-photos.v1 (real persist)',
      () {
    test(
        'capturePod כותב שורה קומפקטית (cu+podCaptured, בלי bytes) + תמונה '
        'בצד-מפה, וריסטרט מהדרט הכל בחזרה', () async {
      SharedPreferences.setMockInitialValues({});
      const url = 'data:image/png;base64,AAAA';
      final c1 = ProviderContainer();
      final n1 = c1.read(fulfillmentProvider.notifier);
      await _settle(); // let _load finish reading the (empty) disk

      expect(await n1.capturePod('BS-1039', url, courierUser: 'noam'), isTrue,
          reason: 'the write must actually land before reporting success');

      final prefs = await SharedPreferences.getInstance();
      final side =
          jsonDecode(prefs.getString(kFulfillmentKey)!) as Map<String, dynamic>;
      final row = side['BS-1039'] as Map<String, dynamic>;
      expect(row['cu'], 'noam');
      expect(row['podCaptured'], true);
      expect(row.containsKey('pod'), isFalse,
          reason: 'single-copy: the bytes live ONLY in bs.pod-photos.v1');
      final pods =
          jsonDecode(prefs.getString(_podPhotosKey)!) as Map<String, dynamic>;
      expect(pods['BS-1039'], url,
          reason: 'the side-map is the single stored home of the data-URL');
      c1.dispose();

      // Fresh container = simulated restart. Providers are LAZY — touch it so
      // the notifier (and its _load()) actually starts, then settle.
      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      c2.read(fulfillmentProvider);
      await _settle();
      final f = c2.read(fulfillmentProvider.notifier).of('BS-1039');
      expect(f.podCaptured, isTrue);
      expect(f.podPhoto, url,
          reason: 'podPhoto is hydrated back from bs.pod-photos.v1');
      expect(f.courierUser, 'noam',
          reason: 'the attribution survives the restart round-trip');
    });

    test(
        'F-35 merge-on-write — מוטציה מוקדמת (לפני שה-_load קרא דיסק) לא '
        'דורסת רשומות של הזמנות אחרות, והכתיבה הטרייה שורדת (#24)', () async {
      // Seed an OLD persisted side-car with ANOTHER order's record, mutate
      // synchronously before the lazy notifier's async _load() resolves.
      SharedPreferences.setMockInitialValues({
        kFulfillmentKey: jsonEncode({
          'BS-OLD': {'sig': true, 'cu': 'dana'},
        }),
      });
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(fulfillmentProvider.notifier);

      n.captureSignature('BS-NEW'); // synchronous write BEFORE _load resolves
      await _settle();

      // In memory: the fresh write survived (#24) AND the disk record was
      // folded under it.
      expect(n.of('BS-NEW').podSigned, isTrue,
          reason: 'the fresh mutation must survive the late prefs load');
      expect(n.of('BS-OLD').podSigned, isTrue,
          reason: 'the seeded record is folded under, not clobbered');
      expect(n.of('BS-OLD').courierUser, 'dana',
          reason: 'cu round-trips from a seeded disk payload too');

      // On disk: the early _persist merged-on-write — BOTH records present.
      final prefs = await SharedPreferences.getInstance();
      final side =
          jsonDecode(prefs.getString(kFulfillmentKey)!) as Map<String, dynamic>;
      expect(side.keys, containsAll(<String>['BS-OLD', 'BS-NEW']),
          reason: 'merge-on-write: an early row never wipes the others (F-35)');
      expect((side['BS-OLD'] as Map<String, dynamic>)['cu'], 'dana');
    });

    test(
        'F-5 — רשומה פגומה אחת נזרקת לבדה ולא מאבדת את שאר ה-side-car',
        () async {
      SharedPreferences.setMockInitialValues({
        kFulfillmentKey: jsonEncode({
          'BS-GOOD': {'sig': true, 'cu': 'noam'},
          'BS-RAW': 42, // not a map at all → dropped on its own
          'BS-PART': {
            // corrupt line key + corrupt cu — per-field degradation
            'ls': {'oops': 'picked', '1': 'missing'},
            'cu': 5,
          },
        }),
      });
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(fulfillmentProvider.notifier);
      c.read(fulfillmentProvider); // lazy — start its _load()
      await _settle();

      final all = c.read(fulfillmentProvider);
      expect(all.keys, containsAll(<String>['BS-GOOD', 'BS-PART']),
          reason: 'the healthy records survive the corrupt sibling');
      expect(all.containsKey('BS-RAW'), isFalse,
          reason: 'only the non-map record is dropped');
      expect(n.of('BS-GOOD').podSigned, isTrue);
      expect(n.of('BS-GOOD').courierUser, 'noam');
      expect(n.of('BS-PART').lineStatus, {1: LineStatus.missing},
          reason: 'the corrupt line KEY is skipped, the valid line is kept');
      expect(n.of('BS-PART').courierUser, isNull,
          reason: 'corrupt cu degrades to null inside its own record');
    });

    test('payload פגום לגמרי — טעינה נשארת ריקה, בלי קריסה, והמחברת שמישה',
        () async {
      SharedPreferences.setMockInitialValues({kFulfillmentKey: '{not json'});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(fulfillmentProvider); // lazy — start its _load()
      await _settle();

      expect(c.read(fulfillmentProvider), isEmpty,
          reason: 'a corrupt payload is dropped, never thrown');
      final n = c.read(fulfillmentProvider.notifier);
      n.stampCourier('BS-1039', 'noam');
      expect(n.of('BS-1039').courierUser, 'noam',
          reason: 'the notifier stays usable after a corrupt load');
    });
  });
}
