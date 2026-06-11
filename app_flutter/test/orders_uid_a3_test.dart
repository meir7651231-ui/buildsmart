// A3 (launch uid-migration) — focused coverage for the additive, display-neutral
// `contractorUid` on [Order]. The field stamps a signed-in contractor's
// `auth.uid` on new orders (A4 will later SCOPE the orders listen on it); [who]
// still drives every UI, so the field must be ZERO-regression:
//   • written ONLY when non-empty — the four seed orders + every legacy/seed doc
//     (which carry no uid) round-trip byte-identical, in BOTH the local JSON
//     shape ([Order.toJson]/[Order.fromJson]) and the Firestore doc shape
//     ([FirebaseOrdersRepository.toDoc]/[fromDoc]);
//   • read back losslessly when present, defaulting to '' when absent;
//   • PRESERVED across [Order.copyWith] — advance()/setStage() (which both go
//     through copyWith) must never drop the contractor's uid.
//
// No Firebase here: the repo's toDoc/fromDoc are pure mappers, exercised by
// round-tripping through a hand-built [RemoteDoc] (`RemoteDoc(id, toDoc(o))`),
// the same construction pattern the cache base feeds `fromDoc` — see
// `test/site_firebase_repo_test.dart`.

import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/orders_firebase.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Order.toJson/fromJson — contractorUid (local JSON shape)', () {
    test('a uid is WRITTEN and round-trips losslessly when non-empty', () {
      const o = Order(
        id: 'BS-1042',
        who: 'יוסי כהן',
        site: 'מגדל הרצליה',
        items: 7,
        sum: 1240,
        stage: 'new',
        contractorUid: 'u-7',
      );
      final json = o.toJson();
      expect(json['contractorUid'], 'u-7', reason: 'present when non-empty');

      final back = Order.fromJson(json);
      expect(back.contractorUid, 'u-7');
      // The display fields are untouched (the field is additive).
      expect(back.who, 'יוסי כהן');
      expect(back.id, 'BS-1042');
      expect(back.stage, 'new');
    });

    test('an EMPTY uid is OMITTED from the JSON (seed/legacy parity)', () {
      const o = Order(
        id: 'BS-1041',
        who: 'משה אברהם',
        site: 'אתר',
        items: 3,
        sum: 900,
        stage: 'preparing',
      );
      expect(o.contractorUid, '', reason: 'defaults to empty');
      expect(
        o.toJson().containsKey('contractorUid'),
        isFalse,
        reason: 'omitted when empty → byte-identical to a pre-A3 payload',
      );
    });

    test("fromJson DEFAULTS to '' when the key is absent (legacy doc)", () {
      // A pre-A3 / seed JSON payload carries no contractorUid at all.
      final back = Order.fromJson(const {
        'id': 'BS-1039',
        'who': 'דנה לוי',
        'site': 'אתר ישן',
        'items': 2,
        'sum': 400,
        'stage': 'delivered',
      });
      expect(back.contractorUid, '', reason: 'zero-regression default');
    });
  });

  group('FirebaseOrdersRepository.toDoc/fromDoc — contractorUid (Firestore shape)', () {
    final repo = FirebaseOrdersRepository();

    test('a uid is WRITTEN to the doc and round-trips through fromDoc', () {
      final o = Order(
        id: 'BS-1042',
        who: 'יוסי כהן',
        site: 'מגדל הרצליה',
        items: 7,
        sum: 1240,
        stage: 'new',
        createdAt: DateTime.parse('2026-06-11T10:00:00.000'),
        contractorUid: 'u-7',
      );
      final doc = repo.toDoc(o);
      expect(doc['contractorUid'], 'u-7', reason: 'present when non-empty');

      // Inverse mapping: the doc-id becomes `id`; the field comes off `data`.
      final back = repo.fromDoc(RemoteDoc(o.id, doc));
      expect(back.contractorUid, 'u-7');
      expect(back.who, 'יוסי כהן'); // contractorId → who, untouched
      expect(back.id, 'BS-1042');
    });

    test('an EMPTY uid is OMITTED from the doc (seed/legacy parity)', () {
      const o = Order(
        id: 'BS-1041',
        who: 'משה אברהם',
        site: 'אתר',
        items: 3,
        sum: 900,
        stage: 'preparing',
      );
      expect(
        repo.toDoc(o).containsKey('contractorUid'),
        isFalse,
        reason: 'omitted when empty → seed doc round-trips unchanged',
      );
    });

    test("fromDoc DEFAULTS to '' when the field is absent (legacy doc)", () {
      // A seed/legacy Firestore doc (or one written pre-A3) has no contractorUid.
      const doc = RemoteDoc('BS-1040', {
        'contractorId': 'דנה לוי',
        'siteAddress': 'אתר ישן',
        'items': 2,
        'sum': 400,
        'stage': 'ready',
      });
      expect(repo.fromDoc(doc).contractorUid, '', reason: 'zero-regression');
    });
  });

  group('Order.copyWith — contractorUid is PRESERVED', () {
    test('a stage advance (copyWith) keeps the contractor uid', () {
      const o = Order(
        id: 'BS-9',
        who: 'קבלן',
        site: 'אתר',
        items: 1,
        sum: 100,
        stage: 'new',
        contractorUid: 'u-9',
      );
      // setStage/advance both build the next order via copyWith(stage: …).
      final advanced = o.copyWith(stage: 'packing');
      expect(advanced.stage, 'packing');
      expect(
        advanced.contractorUid,
        'u-9',
        reason: 'advance/setStage must NOT drop the uid',
      );
    });

    test('copyWith of a uid-less order stays uid-less (no spurious value)', () {
      const o = Order(
        id: 'BS-10',
        who: 'קבלן',
        site: 'אתר',
        items: 1,
        sum: 100,
        stage: 'new',
      );
      expect(o.copyWith(stage: 'ready').contractorUid, '');
    });
  });
}
