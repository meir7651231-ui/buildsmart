// OFFLINE BATCH-ORDER QUEUE (S9.2) — unit coverage for the EXPLICIT offline
// queue in `logic/offline_order_queue.dart`.
//
// NO Firebase, NO connectivity plugin: the offline-suspect seam
// ([connectivityProbeProvider]) is overridden per test, the orders seam
// ([ordersRepositoryProvider]) is overridden with a hand-rolled recording fake,
// and SharedPreferences runs on its mock store — so this suite stays
// Firebase-free-green like everything else.
//
// Pins (the S9.2 contract):
//   • INERT WHEN ONLINE (the production default — assume-online probe):
//     maybeEnqueue intercepts nothing, persists nothing;
//   • offline-suspect → maybeEnqueue captures the FULL placeOrder parameter
//     set (who/site/items/sum/lines/shipTo/notes) + queuedAt;
//   • drainQueue replays FIFO through the `ordersRepositoryProvider` seam,
//     with NO id (assigned at replay) and `createdAt = queuedAt`;
//   • the queue SURVIVES RESTART (prefs roundtrip under `bs.offline-orders.v1`);
//   • NO DOUBLE-PLACE — a second/concurrent drain replays nothing;
//   • a drain while still offline-suspect keeps the queue intact;
//   • a corrupt persisted payload is dropped (logged), never throws.

import 'package:buildsmart/data/repositories/orders_local.dart';
import 'package:buildsmart/data/repositories/orders_repository.dart';
import 'package:buildsmart/logic/manager_dashboard.dart' show kManagerOrderFlow;
import 'package:buildsmart/logic/offline_order_queue.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A hand-rolled recording [OrdersRepository] fake — captures every
/// `placeOrder` call (the replay surface) in arrival order; the rest of the
/// interface is inert (the queue must never touch it).
class _RecordingOrdersRepo implements OrdersRepository {
  final List<Order> placed = [];

  @override
  Order placeOrder({
    required String who,
    required String site,
    required int items,
    required int sum,
    String? id,
    DateTime? createdAt,
    List<OrderLineItem> lines = const [],
    String shipTo = '',
    String notes = '',
  }) {
    final order = Order(
      id: id ?? 'BS-${2000 + placed.length}',
      who: who,
      site: site,
      items: items,
      sum: sum,
      stage: kManagerOrderFlow.first,
      createdAt: createdAt,
      lines: lines,
      shipTo: shipTo,
      notes: notes,
    );
    placed.add(order);
    return order;
  }

  @override
  List<Order> all() => List.unmodifiable(placed);

  @override
  Order? byId(String id) => null;

  @override
  List<Order> open() => const [];

  @override
  void advance(String orderId) {}

  @override
  void setStage(String orderId, String stage) {}

  @override
  void resetToSeed() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// A container with the two seams overridden: the recording orders repo and
  /// a probe returning [online]. Prefs mock is seeded by the caller.
  ({ProviderContainer container, _RecordingOrdersRepo repo}) harness({
    required bool online,
  }) {
    final repo = _RecordingOrdersRepo();
    final container = ProviderContainer(
      overrides: [
        ordersRepositoryProvider.overrideWithValue(repo),
        connectivityProbeProvider.overrideWithValue(() => online),
      ],
    );
    addTearDown(container.dispose);
    return (container: container, repo: repo);
  }

  OfflineOrderIntent intent(
    String who, {
    int sum = 100,
    List<OrderLineItem> lines = const [],
    String shipTo = '',
    String notes = '',
  }) =>
      OfflineOrderIntent(
        who: who,
        site: 'אתר בדיקה',
        items: 2,
        sum: sum,
        queuedAt: DateTime.parse('2026-06-10T08:00:00.000'),
        lines: lines,
        shipTo: shipTo,
        notes: notes,
      );

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('INERT when online (the production default): nothing intercepted, '
      'nothing persisted', () async {
    final h = harness(online: true);
    final q = h.container.read(offlineOrderQueueProvider);

    expect(q.offlineSuspect, isFalse);
    final intercepted =
        q.maybeEnqueue(who: 'קבלן', site: 'אתר', items: 1, sum: 50);
    expect(intercepted, isFalse); // caller proceeds with the normal placeOrder
    await pumpEventQueue();

    expect(await q.pending(), isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(kOfflineOrdersKey), isNull); // key never written
    expect(h.repo.placed, isEmpty);
  });

  test('offline-suspect → maybeEnqueue intercepts and persists the FULL '
      'intent under bs.offline-orders.v1', () async {
    final h = harness(online: false);
    final q = h.container.read(offlineOrderQueueProvider);

    expect(q.offlineSuspect, isTrue);
    final intercepted = q.maybeEnqueue(
      who: 'קבלן א',
      site: 'מגדל הרצליה',
      items: 3,
      sum: 740,
      lines: const [
        OrderLineItem(name: 'צינור PPR', emoji: '🟦', qty: 3, price: 740),
      ],
      shipTo: 'שער ב',
      notes: 'להתקשר לפני',
    );
    expect(intercepted, isTrue); // queued — the caller must NOT place
    await pumpEventQueue(); // settle the guarded background persist

    final pending = await q.pending();
    expect(pending, hasLength(1));
    final p = pending.single;
    expect(p.who, 'קבלן א');
    expect(p.site, 'מגדל הרצליה');
    expect(p.items, 3);
    expect(p.sum, 740);
    expect(p.lines.single.name, 'צינור PPR');
    expect(p.shipTo, 'שער ב');
    expect(p.notes, 'להתקשר לפני');
    expect(p.queuedAt, isNotNull);
    // Persisted under the VERSIONED key — and nothing was placed.
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(kOfflineOrdersKey), isNotEmpty);
    expect(h.repo.placed, isEmpty);
  });

  test('drainQueue replays FIFO through the orders seam — full param set, '
      'createdAt = queuedAt, no id passed — and clears the queue', () async {
    final h = harness(online: true);
    final q = h.container.read(offlineOrderQueueProvider);

    await q.enqueue(intent('ראשון'));
    await q.enqueue(
      intent(
        'שני',
        sum: 200,
        lines: const [
          OrderLineItem(name: 'מחבר', emoji: '🔩', qty: 1, price: 200),
        ],
        shipTo: 'רמפה',
        notes: 'דחוף',
      ),
    );
    await q.enqueue(intent('שלישי', sum: 300));

    final replayed = await q.drainQueue();
    expect(replayed, 3);

    // FIFO order preserved (enqueue order == replay order).
    expect(h.repo.placed.map((o) => o.who).toList(), ['ראשון', 'שני', 'שלישי']);
    final second = h.repo.placed[1];
    expect(second.sum, 200);
    expect(second.lines.single.name, 'מחבר');
    expect(second.shipTo, 'רמפה');
    expect(second.notes, 'דחוף');
    // queuedAt replayed as createdAt (the order's true placement time)…
    expect(second.createdAt, DateTime.parse('2026-06-10T08:00:00.000'));
    // …and the id came from the REPOSITORY at replay (none was queued).
    expect(second.id, 'BS-2001');
    // Queue fully cleared.
    expect(await q.pending(), isEmpty);
  });

  test('the queue SURVIVES RESTART: enqueue in one container, drain after a '
      '"restart" (fresh container, same prefs store)', () async {
    // Session 1 — offline: two orders queued, app killed before reconnect.
    final before = harness(online: false);
    final q1 = before.container.read(offlineOrderQueueProvider);
    expect(
      q1.maybeEnqueue(who: 'קבלן', site: 'אתר', items: 1, sum: 60),
      isTrue,
    );
    expect(
      q1.maybeEnqueue(who: 'קבלן', site: 'אתר', items: 2, sum: 90),
      isTrue,
    );
    await pumpEventQueue();
    expect(before.repo.placed, isEmpty);

    // Session 2 — a NEW container (the mock prefs store persists, like disk).
    final after = harness(online: true);
    final q2 = after.container.read(offlineOrderQueueProvider);
    expect(await q2.pending(), hasLength(2)); // prefs roundtrip survived
    expect(await q2.drainQueue(), 2);
    expect(after.repo.placed.map((o) => o.sum).toList(), [60, 90]);
    expect(await q2.pending(), isEmpty);
  });

  test('NO DOUBLE-PLACE: a second drain (sequential or concurrent) replays '
      'nothing more', () async {
    final h = harness(online: true);
    final q = h.container.read(offlineOrderQueueProvider);
    await q.enqueue(intent('יחיד'));

    // Concurrent: fire two drains without awaiting the first — the
    // reentrancy guard makes the overlapping one a no-op.
    final results = await Future.wait([q.drainQueue(), q.drainQueue()]);
    expect(results.where((n) => n > 0), hasLength(1));
    expect(h.repo.placed, hasLength(1)); // placed exactly once

    // Sequential: a later drain finds an empty queue.
    expect(await q.drainQueue(), 0);
    expect(h.repo.placed, hasLength(1));
  });

  test('a drain while STILL offline-suspect keeps the queue intact '
      '(replays only בחזרת-רשת)', () async {
    final h = harness(online: false);
    final q = h.container.read(offlineOrderQueueProvider);
    await q.enqueue(intent('ממתין'));

    expect(await q.drainQueue(), 0);
    expect(h.repo.placed, isEmpty); // the seam was never touched
    expect(await q.pending(), hasLength(1)); // intent still queued
  });

  test('a CORRUPT persisted payload is dropped (never throws); a corrupt '
      'ENTRY is skipped while the rest of the queue survives', () async {
    // Whole-payload corruption → empty queue, drain is a quiet no-op.
    SharedPreferences.setMockInitialValues(<String, Object>{
      kOfflineOrdersKey: '{not json[',
    });
    final h1 = harness(online: true);
    final q1 = h1.container.read(offlineOrderQueueProvider);
    expect(await q1.pending(), isEmpty);
    expect(await q1.drainQueue(), 0);
    expect(h1.repo.placed, isEmpty);

    // One bad ENTRY among good ones → only the bad one is skipped.
    SharedPreferences.setMockInitialValues(<String, Object>{
      kOfflineOrdersKey:
          '[{"who":"תקין","site":"אתר","items":1,"sum":10,'
          '"queuedAt":"2026-06-10T08:00:00.000"},{"bad":"entry"}]',
    });
    final h2 = harness(online: true);
    final q2 = h2.container.read(offlineOrderQueueProvider);
    expect(await q2.pending(), hasLength(1));
    expect(await q2.drainQueue(), 1);
    expect(h2.repo.placed.single.who, 'תקין');
  });

  test('intent JSON round-trip mirrors Order.toJson field economy '
      '(optional fields written only when non-empty)', () {
    // Bare intent: optional fields omitted from the payload.
    final bare = intent('מי').toJson();
    expect(bare.containsKey('lines'), isFalse);
    expect(bare.containsKey('shipTo'), isFalse);
    expect(bare.containsKey('notes'), isFalse);
    final bareBack = OfflineOrderIntent.fromJson(bare);
    expect(bareBack.who, 'מי');
    expect(bareBack.lines, isEmpty);
    expect(bareBack.shipTo, '');
    expect(bareBack.notes, '');

    // Full intent: everything round-trips.
    final full = OfflineOrderIntent.fromJson(
      intent(
        'מלא',
        lines: const [
          OrderLineItem(name: 'ברז', emoji: '🚰', qty: 2, price: 84),
        ],
        shipTo: 'קומה 3',
        notes: 'שביר',
      ).toJson(),
    );
    expect(full.lines.single.emoji, '🚰');
    expect(full.lines.single.qty, 2);
    expect(full.shipTo, 'קומה 3');
    expect(full.notes, 'שביר');
    expect(full.queuedAt, DateTime.parse('2026-06-10T08:00:00.000'));
  });

  test('engine init path drains the queue on app start (the S9.2 wiring): '
      'a queued intent lands in the orders engine', () async {
    // Queue an intent BEFORE the engine exists (the offline session)…
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final offline = harness(online: false);
    expect(
      offline.container
          .read(offlineOrderQueueProvider)
          .maybeEnqueue(who: 'קבלן אופליין', site: 'אתר', items: 1, sum: 77),
      isTrue,
    );
    await pumpEventQueue();

    // …then "restart": a fresh container on the REAL provider graph (local
    // repo path — Firebase-free). Reading the engine fires the init drain.
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final engine = container.read(ordersEngineProvider.notifier);
    await pumpEventQueue(); // the drain's prefs await defers it past build

    expect(
      engine.state.map((o) => o.who),
      contains('קבלן אופליין'), // replayed through the seam into the engine
    );
    expect(
      await container.read(offlineOrderQueueProvider).pending(),
      isEmpty,
    );
  });
}
