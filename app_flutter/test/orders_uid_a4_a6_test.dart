// A4–A6 (launch uid · multi-user order ownership) — focused coverage for the
// claim-on-first-advance + shared-pool model (SPEC-A4-A6-order-ownership.md).
//
// THE MODEL under test:
//   • A4 — additive `storeUid`/`courierUid` on [Order] (mirror `contractorUid`:
//     written only when non-empty, round-trip lossless, preserved by copyWith);
//     CLAIM-on-first-advance: the first store/courier party to advance an order
//     out of the shared pool stamps its uid; a SECOND party cannot re-stamp
//     (no-steal); an empty uid (signed-out) never claims (zero regression).
//   • A5 — `kUidScopedQueries` (compile-time, default FALSE) gates the scoped
//     orders listen. With it OFF every consumer is byte-identical to today; the
//     scope's per-role pool∪own SEMANTICS are pinned via the pure client twin
//     [orderVisibleToRole].
//   • A6 — the store/courier dashboards intersect their list with
//     [visibleOrderIdsProvider]; OFF (or signed-out / other role) ⇒ null ⇒ the
//     full list (today's behavior).
//
// No Firebase: the claim/no-steal is exercised on the local [OrdersEngineNotifier]
// AND on the [FirebaseOrdersRepository] driven by a hand-rolled fake source (the
// realtime_wiring_test fake), and the doc round-trip through `toDoc`/`fromDoc`.

import 'dart:async';

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/orders_firebase.dart';
import 'package:buildsmart/data/repositories/orders_local.dart';
import 'package:buildsmart/state/auth_state.dart'
    show currentUidProvider, roleProvider;
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The S2 base-test fake source (verbatim shape, records writes).
class _FakeSource implements RemoteCollectionSource {
  final _controller = StreamController<List<RemoteDoc>>.broadcast();
  final List<MapEntry<String, Map<String, dynamic>>> sets = [];
  final List<String> deletes = [];

  void emit(List<RemoteDoc> docs) => _controller.add(docs);

  @override
  Stream<List<RemoteDoc>> snapshots() => _controller.stream;

  @override
  Future<void> set(String id, Map<String, dynamic> data) async =>
      sets.add(MapEntry(id, data));

  @override
  Future<void> delete(String id) async => deletes.add(id);

  Future<void> close() => _controller.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ── A4 · model: storeUid/courierUid mirror contractorUid (additive) ─────────
  group('A4 · Order storeUid/courierUid round-trip (local JSON + Firestore doc)', () {
    test('non-empty uids are WRITTEN + round-trip in BOTH shapes', () {
      const o = Order(
        id: 'BS-1042',
        who: 'יוסי כהן',
        site: 'מגדל הרצליה',
        items: 7,
        sum: 1240,
        stage: 'ready',
        contractorUid: 'u-c',
        storeUid: 'u-s',
        courierUid: 'u-k',
      );

      // local JSON shape
      final json = o.toJson();
      expect(json['storeUid'], 'u-s');
      expect(json['courierUid'], 'u-k');
      final back = Order.fromJson(json);
      expect(back.storeUid, 'u-s');
      expect(back.courierUid, 'u-k');
      expect(back.contractorUid, 'u-c'); // A3 untouched
      expect(back.who, 'יוסי כהן');

      // Firestore doc shape
      final repo = FirebaseOrdersRepository();
      final doc = repo.toDoc(o);
      expect(doc['storeUid'], 'u-s');
      expect(doc['courierUid'], 'u-k');
      final docBack = repo.fromDoc(RemoteDoc(o.id, doc));
      expect(docBack.storeUid, 'u-s');
      expect(docBack.courierUid, 'u-k');
    });

    test('EMPTY uids are OMITTED (seed/legacy parity) in BOTH shapes', () {
      const o = Order(
        id: 'BS-1041',
        who: 'משה',
        site: 'אתר',
        items: 3,
        sum: 900,
        stage: 'new',
      );
      expect(o.toJson().containsKey('storeUid'), isFalse);
      expect(o.toJson().containsKey('courierUid'), isFalse);
      final repo = FirebaseOrdersRepository();
      expect(repo.toDoc(o).containsKey('storeUid'), isFalse);
      expect(repo.toDoc(o).containsKey('courierUid'), isFalse);
    });

    test("absent fields DEFAULT to '' (legacy doc → zero regression)", () {
      final back = Order.fromJson(const {
        'id': 'BS-1039',
        'who': 'דנה',
        'site': 'אתר',
        'items': 2,
        'sum': 400,
        'stage': 'delivered',
      });
      expect(back.storeUid, '');
      expect(back.courierUid, '');
      final repo = FirebaseOrdersRepository();
      final docBack = repo.fromDoc(const RemoteDoc('BS-1040', {
        'contractorId': 'דנה',
        'siteAddress': 'אתר',
        'items': 2,
        'sum': 400,
        'stage': 'ready',
      }));
      expect(docBack.storeUid, '');
      expect(docBack.courierUid, '');
    });

    test('copyWith PRESERVES both claim uids across a stage advance', () {
      const o = Order(
        id: 'BS-9',
        who: 'קבלן',
        site: 'אתר',
        items: 1,
        sum: 100,
        stage: 'preparing',
        storeUid: 'u-s',
        courierUid: 'u-k',
      );
      final adv = o.copyWith(stage: 'ready');
      expect(adv.storeUid, 'u-s', reason: 'advance must not drop the store claim');
      expect(adv.courierUid, 'u-k');
    });
  });

  // ── A4 · claim-on-first-advance + no-steal (local engine) ───────────────────
  group('A4 · claim-on-first-advance + no-steal (OrdersEngineNotifier)', () {
    OrdersEngineNotifier engineWith(List<Order> seed) {
      final e = OrdersEngineNotifier(persist: false, seed: seed);
      addTearDown(e.dispose);
      return e;
    }

    test('first store claim STAMPS storeUid; a different store CANNOT steal it',
        () {
      final e = engineWith(const [
        Order(id: 'O1', who: 'c', site: 's', items: 1, sum: 1, stage: 'new'),
      ]);
      // First store party claims.
      e.claimStore('O1', 'store-a');
      expect(e.state.single.storeUid, 'store-a');

      // A SECOND store tries to claim → no-steal: untouched.
      e.claimStore('O1', 'store-b');
      expect(e.state.single.storeUid, 'store-a',
          reason: 'no-steal: an already-claimed order is never re-stamped');
    });

    test('an EMPTY uid never claims (signed-out / Firebase-free — zero regression)',
        () {
      final e = engineWith(const [
        Order(id: 'O1', who: 'c', site: 's', items: 1, sum: 1, stage: 'new'),
      ]);
      e.claimStore('O1', '');
      e.claimCourier('O1', '');
      expect(e.state.single.storeUid, '');
      expect(e.state.single.courierUid, '');
    });

    test('courier claim is the analogue: first stamps, second cannot steal', () {
      final e = engineWith(const [
        Order(
            id: 'O1', who: 'c', site: 's', items: 1, sum: 1, stage: 'pickup'),
      ]);
      e.claimCourier('O1', 'k-a');
      expect(e.state.single.courierUid, 'k-a');
      e.claimCourier('O1', 'k-b');
      expect(e.state.single.courierUid, 'k-a');
    });

    test('a same-uid re-claim is a harmless no-op', () {
      final e = engineWith(const [
        Order(id: 'O1', who: 'c', site: 's', items: 1, sum: 1, stage: 'new'),
      ]);
      e..claimStore('O1', 'store-a')..claimStore('O1', 'store-a');
      expect(e.state.single.storeUid, 'store-a');
    });
  });

  // ── A4 · claim through the Firestore-backed repo (fake source) ──────────────
  group('A4 · claim through FirebaseOrdersRepository (fake source)', () {
    test('first claim upserts storeUid + records a merge write; steal is a no-op',
        () async {
      final src = _FakeSource();
      final repo = FirebaseOrdersRepository(source: src)..attach();
      addTearDown(src.close);
      addTearDown(repo.dispose);
      // Seed a single un-claimed order into the cache via a snapshot.
      src.emit(const [
        RemoteDoc('BS-1', {
          'contractorId': 'c',
          'siteAddress': 's',
          'items': 1,
          'sum': 1,
          'stage': 'new',
        }),
      ]);
      await Future<void>.delayed(Duration.zero);

      repo.claimStore('BS-1', 'store-a');
      expect(repo.byId('BS-1')!.storeUid, 'store-a'); // optimistic, same frame
      repo.claimStore('BS-1', 'store-b');
      expect(repo.byId('BS-1')!.storeUid, 'store-a'); // no-steal

      await Future<void>.delayed(Duration.zero);
      final writes = src.sets.where((e) => e.key == 'BS-1').toList();
      expect(writes, isNotEmpty);
      expect(writes.last.value['storeUid'], 'store-a');
    });
  });

  // ── A4 · storeAdvance/courierAdvance claim through sysOrders (uid seam) ──────
  group('A4 · sysOrders advance claims via currentUidProvider', () {
    test('storeAdvance stamps storeUid from the current uid; OFF-uid no-claim',
        () {
      // With a uid present, the first storeAdvance claims.
      final c1 = ProviderContainer(overrides: [
        currentUidProvider.overrideWithValue('store-a'),
      ]);
      addTearDown(c1.dispose);
      // seed BS-1042 is `new`; storeAdvance → preparing + claim.
      c1.read(sysOrdersProvider.notifier).storeAdvance('BS-1042');
      final claimed =
          c1.read(ordersEngineProvider).firstWhere((o) => o.id == 'BS-1042');
      expect(claimed.storeUid, 'store-a');
      expect(claimed.stage, 'preparing');

      // With NO uid (today/sign-out), storeAdvance still advances but never
      // claims — zero regression.
      final c2 = ProviderContainer(overrides: [
        currentUidProvider.overrideWithValue(null),
      ]);
      addTearDown(c2.dispose);
      c2.read(sysOrdersProvider.notifier).storeAdvance('BS-1042');
      final unclaimed =
          c2.read(ordersEngineProvider).firstWhere((o) => o.id == 'BS-1042');
      expect(unclaimed.storeUid, '');
      expect(unclaimed.stage, 'preparing');
    });
  });

  // ── A5 · flag default + scope SEMANTICS (pure client twin) ──────────────────
  group('A5 · kUidScopedQueries default OFF (zero-regression lock)', () {
    test('the compile-time flag is FALSE in tests', () {
      expect(kUidScopedQueries, isFalse);
    });

    test('visibleOrderIdsProvider is NULL with the flag OFF (full list today)',
        () {
      final c = ProviderContainer(overrides: [
        currentUidProvider.overrideWithValue('store-a'),
        roleProvider.overrideWithValue('store'),
      ]);
      addTearDown(c.dispose);
      // Flag is OFF → null regardless of uid/role → dashboards show everything.
      expect(c.read(visibleOrderIdsProvider), isNull);
    });
  });

  group('A5/A6 · orderVisibleToRole — pool∪own per role (the scope semantics)',
      () {
    Order at(String stage, {String storeUid = '', String courierUid = ''}) =>
        Order(
          id: 'X',
          who: 'c',
          site: 's',
          items: 1,
          sum: 1,
          stage: stage,
          storeUid: storeUid,
          courierUid: courierUid,
        );

    test('store: pool = un-claimed in a store stage; own = storeUid==uid', () {
      // pool — un-claimed, store stage
      expect(orderVisibleToRole(at('new'), role: 'store', uid: 'me'), isTrue);
      expect(
          orderVisibleToRole(at('ready'), role: 'store', uid: 'me'), isTrue);
      // own — claimed by me at any stage
      expect(
          orderVisibleToRole(at('transit', storeUid: 'me'),
              role: 'store', uid: 'me'),
          isTrue);
      // NOT mine + claimed by another → hidden (out of pool)
      expect(
          orderVisibleToRole(at('preparing', storeUid: 'other'),
              role: 'store', uid: 'me'),
          isFalse);
      // un-claimed but a non-store stage (delivered) → NOT in the store pool
      expect(orderVisibleToRole(at('delivered'), role: 'store', uid: 'me'),
          isFalse);
    });

    test('courier: pool = un-claimed in ready/pickup/transit; own = courierUid',
        () {
      expect(
          orderVisibleToRole(at('ready'), role: 'courier', uid: 'me'), isTrue);
      expect(
          orderVisibleToRole(at('transit', courierUid: 'me'),
              role: 'courier', uid: 'me'),
          isTrue);
      expect(
          orderVisibleToRole(at('transit', courierUid: 'other'),
              role: 'courier', uid: 'me'),
          isFalse);
      // un-claimed `new` is a store stage, NOT a courier pool stage
      expect(
          orderVisibleToRole(at('new'), role: 'courier', uid: 'me'), isFalse);
    });
  });
}
