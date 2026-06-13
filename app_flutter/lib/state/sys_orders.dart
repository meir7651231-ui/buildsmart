// Shared cross-role order state — now a LIVE VIEW over the single
// `ordersEngineProvider` (the manager's keystone engine), so the store and
// courier role-apps share ONE source of truth with the contractor AND the
// manager: advancing an order as the store/courier is reflected live in the
// manager's dashboard, and a contractor-placed order shows up live for the
// store. Previously this engine kept its own parallel list; it now derives from
// `ordersEngineProvider` (verified 1:1 — same four seed orders, same stages,
// same flow new→preparing→ready→pickup→transit→delivered) and delegates every
// mutation to it.
//
// Mapping: the engine `Order` (stage = `kManagerOrderFlow` String) → `SysOrder`
// (stage = `OrderStage` enum) plus the store/courier-only fields `haul` + `lines`,
// looked up by order id from [kSysOrdersSeed] (orders placed at runtime default
// to a small haul + their captured lines).
//
// Who advances which transitions (proto 06 §1.1):
//   • Supplier  `storeAdvance`   — new→preparing→ready
//   • Courier   `courierAdvance` — ready→pickup→transit→delivered
//   • Contractor places + Manager god-steps via the engine directly.

import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/state/auth_state.dart' show currentUidProvider;
import 'package:buildsmart/state/orders_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `kManagerOrderFlow` String stage → [OrderStage] enum. Unknown → newOrder.
OrderStage _stageFromFlow(String s) => switch (s) {
  'new' => OrderStage.newOrder,
  'preparing' => OrderStage.preparing,
  'ready' => OrderStage.ready,
  'pickup' => OrderStage.pickup,
  'transit' => OrderStage.transit,
  'delivered' => OrderStage.delivered,
  _ => OrderStage.newOrder,
};

/// Store/courier-only metadata (haul + line items) the slim engine [Order]
/// doesn't carry — seeded by id from [kSysOrdersSeed].
typedef _Meta = ({String haul, List<OrderLine> lines});

final Map<String, _Meta> _seedMeta = {
  for (final o in kSysOrdersSeed) o.id: (haul: o.haul, lines: o.lines),
};

class SysOrdersNotifier extends StateNotifier<List<SysOrder>> {
  SysOrdersNotifier(this._ref) : super(const []) {
    // Mirror the shared engine live — every engine change re-derives this view,
    // so the store/courier screens update the instant the contractor places an
    // order or the manager god-steps one.
    _ref.listen<List<Order>>(
      ordersEngineProvider,
      (_, next) => state = _derive(next),
      fireImmediately: true,
    );
  }

  final Ref _ref;

  /// Metadata for orders placed at runtime via [simulateIncomingOrder].
  final Map<String, _Meta> _runtimeMeta = {};
  int _simSeq = 0;

  List<SysOrder> _derive(List<Order> orders) =>
      orders.map(_toSysOrder).toList(growable: false);

  SysOrder _toSysOrder(Order o) {
    final meta = _runtimeMeta[o.id] ?? _seedMeta[o.id];
    return SysOrder(
      id: o.id,
      who: o.who,
      site: o.site,
      items: o.items,
      sum: o.sum,
      stage: _stageFromFlow(o.stage),
      haul: meta?.haul ?? 'small',
      // Contractor-placed orders carry their captured lines on the engine Order
      // itself (no _seedMeta/_runtimeMeta entry) — fall back to those so the
      // store/courier projection shows the real items, not a blank list.
      lines: meta?.lines ?? o.lines.map((l) => OrderLine(l.name, l.qty)).toList(),
    );
  }

  Order? _orderById(String id) {
    for (final o in _ref.read(ordersEngineProvider)) {
      if (o.id == id) return o;
    }
    return null;
  }

  /// Supplier-owned advance: new→preparing→ready→pickup. The store hands the
  /// order off to the courier at `ready` ("מסור לשליח" → pickup). No-op from
  /// `pickup` on (the courier owns it). Delegates to the shared engine → manager sees it.
  void storeAdvance(String id) {
    final o = _orderById(id);
    if (o == null) return;
    if (o.stage == 'new' || o.stage == 'preparing' || o.stage == 'ready') {
      // A4 (claim-on-first-advance) — the first store party to advance an order
      // out of the shared pool CLAIMS it (`storeUid = acting uid`); no-steal +
      // empty-uid (signed-out / Firebase-free) no-op live in `claimStore`, so
      // this is zero-regression on today's path. Claim BEFORE advancing so the
      // order is owned the moment it leaves the pool.
      _ref
          .read(ordersEngineProvider.notifier)
          .claimStore(id, _ref.read(currentUidProvider) ?? '');
      _ref.read(ordersEngineProvider.notifier).advance(id);
    }
  }

  /// Courier-owned advance: pickup→transit→delivered. The courier confirms
  /// receipt of the handed-off order at `pickup`, then delivers. No-op on `ready`
  /// (the store owns the hand-off — two-step). Delegates to the shared engine.
  void courierAdvance(String id) {
    final o = _orderById(id);
    if (o == null) return;
    if (o.stage == 'pickup' || o.stage == 'transit') {
      // A4 — the courier analogue of the store claim in [storeAdvance]: the
      // first courier party to advance the order CLAIMS it (`courierUid`),
      // no-steal + empty-uid guarded in `claimCourier` (zero-regression).
      _ref
          .read(ordersEngineProvider.notifier)
          .claimCourier(id, _ref.read(currentUidProvider) ?? '');
      _ref.read(ordersEngineProvider.notifier).advance(id);
    }
  }

  /// Demo tool — places a fresh incoming `new` order THROUGH the shared engine
  /// (so the manager sees it immediately) and registers its store/courier
  /// metadata. Returns the new order id.
  String simulateIncomingOrder() {
    final n = _simSeq++;
    // Engine-persisted lines (OrderLineItem) so a simulated order keeps its items
    // across a reload via _toSysOrder's engine-lines fallback (audit M4). Prices
    // sum to the order total (354); haul stays the demo default 'small'.
    const lines = [
      OrderLineItem(name: 'ברז לכיור', emoji: '🚰', qty: 2, price: 118),
      OrderLineItem(name: 'סרט טפלון', emoji: '🧻', qty: 3, price: 36),
      OrderLineItem(name: 'סיליקון סניטרי', emoji: '🧴', qty: 1, price: 200),
    ];
    final order = _ref.read(ordersEngineProvider.notifier).placeOrder(
      who: kSimCustomers[n % kSimCustomers.length],
      site: kSimSites[n % kSimSites.length],
      items: lines.length,
      sum: 354,
      lines: lines,
    );
    _runtimeMeta[order.id] = (
      haul: 'small',
      lines: lines.map((l) => OrderLine(l.name, l.qty)).toList(),
    );
    return order.id;
  }
}

/// The shared order list — a live projection of [ordersEngineProvider] into the
/// store/courier [SysOrder] shape. Every mutation delegates to the engine, so
/// all roles (contractor · store · courier · manager) share ONE source of truth.
final sysOrdersProvider =
    StateNotifierProvider<SysOrdersNotifier, List<SysOrder>>(
      (ref) => SysOrdersNotifier(ref),
    );
