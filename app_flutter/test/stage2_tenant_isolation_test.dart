// STAGE-2 · iron-rule #2 — "לא דולף בין דיירים": tenant A's data is never
// visible to tenant B (DIRECTIVE-buildsmart-clean.md §2.2).
//
// The app's tenant unit today is the USER (contractorUid / storeUid /
// participantUids) — full orgId isolation is the stage-3.3 initiative; these
// tests pin the load-bearing pieces of the EXISTING lattice so they cannot
// silently regress, at three levels:
//   1. RULES-FILE conformance — the server rules keep their isolation
//      load-bearers (file-reading idiom: orders_sync_scope_index_diag_test
//      reads repo-root files relative to app_flutter/).
//   2. The PURE scoping twins — the query-scope field per role and the
//      pool-visibility filter (A never admits B's claimed work).
//   3. The CACHE over a SCOPED source — only the scoped snapshot's docs exist
//      in the cache (no seed bleed-through, no foreign docs), and a scoped
//      first-empty means genuinely-zero (the honest-empty contract).
//
// What CANNOT be proven here (documented owner/CI handoff — see WIRING):
// live-server rule enforcement (the rules_test emulator suite + deploy).

import 'dart:async';
import 'dart:io';

import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/orders_firebase.dart';
import 'package:buildsmart/data/repositories/orders_local.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSource implements RemoteCollectionSource {
  final _controller = StreamController<List<RemoteDoc>>.broadcast();

  void emit(List<RemoteDoc> docs) => _controller.add(docs);

  @override
  Stream<List<RemoteDoc>> snapshots() => _controller.stream;

  @override
  Future<void> set(String id, Map<String, dynamic> data) async {}

  @override
  Future<void> delete(String id) async {}

  bool scoped = false;

  @override
  bool get isScoped => scoped;

  Future<void> close() => _controller.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('1 · firestore.rules keeps its isolation load-bearers', () {
    final rules = File('../firestore.rules').readAsStringSync();

    test('users self-writes cannot mint privilege (freeze list intact)', () {
      expect(
        rules,
        contains("['role', 'roles', 'storeUid', 'orgId', 'status']"),
        reason: 'the users update-freeze list is the no-self-privilege gate',
      );
    });

    test('order ownership keys on contractorUid (the auth-truth field)', () {
      expect(rules, contains('contractorUid'));
    });

    test('chat reads are participant-scoped (participantUids)', () {
      expect(rules, contains('participantUids'));
    });

    test('customers carries the ownerId isolation branch', () {
      expect(
        rules,
        contains("resource.data.get('ownerId', '') == request.auth.uid"),
        reason: 'the forward-ready owner-scoped read the client now stamps',
      );
    });

    test('material_requests + financeBudget have explicit blocks (stage-2 C1)',
        () {
      expect(rules, contains('match /material_requests/'),
          reason: 'was silently denied by the catch-all');
      expect(rules, contains('match /financeBudget/'),
          reason: 'was silently denied by the catch-all');
    });

    test('deny-by-default catch-all is the last word', () {
      expect(rules, contains('match /{document=**}'));
      final tail = rules.substring(rules.indexOf('match /{document=**}'));
      expect(tail, contains('if false'));
    });

    test('exactly ONE public read exists and it is studioConfigLive', () {
      final matches = 'allow read: if true;'.allMatches(rules).toList();
      expect(matches, hasLength(1),
          reason: 'a second public read = a new leak surface');
      final block = rules.indexOf('match /studioConfigLive/');
      expect(block, isNot(-1));
      expect(matches.single.start, greaterThan(block),
          reason: 'the sole public read belongs to the published-config doc');
    });
  });

  group('2 · pure scoping twins — A never admits B', () {
    test('per-role scope field: contractor scoped by contractorUid; '
        'manager/admin unscoped by design (role-gated server-side)', () {
      expect(debugOrdersScopeField(null), 'contractorUid');
      expect(debugOrdersScopeField('store'), isNotNull);
      expect(debugOrdersScopeField('courier'), isNotNull);
      expect(debugOrdersScopeField('manager'), isNull);
      expect(debugOrdersScopeField('admin'), isNull);
    });

    test("store A never sees an order CLAIMED by store B", () {
      const claimedByB = Order(
        id: 'BS-B1',
        who: 'קבלן כלשהו',
        site: 'אתר',
        items: 1,
        sum: 100,
        stage: 'ready',
        storeUid: 'uid-B',
      );
      expect(
        orderVisibleToRole(claimedByB, role: 'store', uid: 'uid-A'),
        isFalse,
        reason: "B's claimed order must be invisible to store A",
      );
      expect(
        orderVisibleToRole(claimedByB, role: 'store', uid: 'uid-B'),
        isTrue,
        reason: 'the claimant keeps seeing their own work',
      );
    });

    test("courier A never sees a delivery CLAIMED by courier B", () {
      const claimedByB = Order(
        id: 'BS-B2',
        who: 'קבלן כלשהו',
        site: 'אתר',
        items: 1,
        sum: 100,
        stage: 'transit',
        courierUid: 'uid-B',
      );
      expect(
        orderVisibleToRole(claimedByB, role: 'courier', uid: 'uid-A'),
        isFalse,
      );
      expect(
        orderVisibleToRole(claimedByB, role: 'courier', uid: 'uid-B'),
        isTrue,
      );
    });
  });

  group('3 · the cache over a SCOPED source holds ONLY the scoped docs', () {
    test("contractor A's scoped listen yields exactly A's orders — no seed "
        'bleed-through, no foreign docs', () async {
      final src = _FakeSource()..scoped = true;
      final repo = FirebaseOrdersRepository(source: src)..attach();
      addTearDown(src.close);
      addTearDown(repo.dispose);

      const a1 = Order(
        id: 'BS-A1',
        who: 'קבלן א',
        site: 'אתר א',
        items: 1,
        sum: 100,
        stage: 'new',
        contractorUid: 'uid-A',
      );
      const a2 = Order(
        id: 'BS-A2',
        who: 'קבלן א',
        site: 'אתר א',
        items: 2,
        sum: 200,
        stage: 'new',
        contractorUid: 'uid-A',
      );
      // The scoped server query returns ONLY A's docs (that is what a
      // where('contractorUid'==uid-A) listen emits) — the cache must mirror
      // it exactly.
      src.emit([
        RemoteDoc('BS-A1', repo.toDoc(a1)),
        RemoteDoc('BS-A2', repo.toDoc(a2)),
      ]);
      await Future<void>.delayed(Duration.zero);

      final cached = repo.cached();
      expect(cached.length, 2);
      expect(cached.map((o) => o.id).toSet(), {'BS-A1', 'BS-A2'});
      expect(
        cached.every((o) => o.contractorUid == 'uid-A'),
        isTrue,
        reason: 'nothing outside the scoped snapshot may exist in the cache',
      );
    });

    test('scoped FIRST-EMPTY means genuinely zero — the seed is blanked, '
        'no placeholder data is shown as the user\'s own', () async {
      final src = _FakeSource()..scoped = true;
      final repo = FirebaseOrdersRepository(source: src)..attach();
      addTearDown(src.close);
      addTearDown(repo.dispose);

      expect(repo.cached(), isNotEmpty, reason: 'born seeded (pre-snapshot)');
      src.emit(const []);
      await Future<void>.delayed(Duration.zero);
      expect(
        repo.cached(),
        isEmpty,
        reason: 'a scoped empty = this user truly has zero docs — showing the '
            'seed would present foreign/demo data as theirs',
      );
    });
  });
}
