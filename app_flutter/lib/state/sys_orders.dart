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

  /// Supplier-owned advance: new→preparing→ready. No-op once `ready` (the
  /// courier takes over). Delegates to the shared engine → the manager sees it.
  void storeAdvance(String id) {
    final o = _orderById(id);
    if (o == null) return;
    if (o.stage == 'new' || o.stage == 'preparing') {
      _ref.read(ordersEngineProvider.notifier).advance(id);
    }
  }

  /// Courier-owned advance: ready→pickup→transit→delivered. No-op outside that
  /// window. Delegates to the shared engine → the manager sees it.
  void courierAdvance(String id) {
    final o = _orderById(id);
    if (o == null) return;
    if (o.stage == 'ready' || o.stage == 'pickup' || o.stage == 'transit') {
      _ref.read(ordersEngineProvider.notifier).advance(id);
    }
  }

  /// Demo tool — places a fresh incoming `new` order THROUGH the shared engine
  /// (so the manager sees it immediately) and registers its store/courier
  /// metadata. Returns the new order id.
  String simulateIncomingOrder() {
    final n = _simSeq++;
    const lines = [
      OrderLine('ברז לכיור', 2),
      OrderLine('סרט טפלון', 3),
      OrderLine('סיליקון סניטרי', 1),
    ];
    final items = lines.length;
    final order = _ref.read(ordersEngineProvider.notifier).placeOrder(
      who: kSimCustomers[n % kSimCustomers.length],
      site: kSimSites[n % kSimSites.length],
      items: items,
      sum: 354,
    );
    _runtimeMeta[order.id] = (haul: 'small', lines: lines);
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
