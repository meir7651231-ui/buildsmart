// Shared cross-role order state — the Flutter port of the prototype's
// `SYS_ORDERS` engine (proto 06 §1). One source of truth that BOTH the store
// and courier role-apps watch, so advancing an order in one persona is
// reflected live in the other (the prototype achieved this via a shared
// localStorage key + cross-tab `storage` event; here it is a Riverpod
// StateNotifier all persona screens read).
//
// Who advances which transitions (proto 06 §1.1):
//   • Supplier  `storeAdvance`   — new→preparing→ready
//   • Courier   `courierAdvance` — ready→pickup→transit→delivered
//   • Manager   (god-mode, any single step) — deferred to PLAN-manager.
//
// Deferred (not Phase-1 scope): localStorage persistence, the picking-sheet
// line state machine, the missing-item hold loop, split-shipment jobs, POD.

import 'package:buildsmart/data/supplier_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SysOrdersNotifier extends StateNotifier<List<SysOrder>> {
  SysOrdersNotifier() : super(List<SysOrder>.of(kSysOrdersSeed));

  /// Supplier-owned advance: new→preparing→ready (`storeAdvance` [L17386]).
  /// No-op once the order reaches `ready` (the courier takes over from there).
  void storeAdvance(String id) => _apply(id, _storeNext);

  /// Courier-owned advance: ready→pickup→transit→delivered
  /// (`courierAdvance` [L18226]). No-op outside that window.
  void courierAdvance(String id) => _apply(id, _courierNext);

  int _simSeq = 0;

  /// Demo tool — prepends a fresh incoming `new` order to the queue
  /// (`simulateIncomingOrder` [L17161]; simplified to a deterministic line
  /// subset + counter id, no `Math.random`). Returns the new order id.
  String simulateIncomingOrder() {
    final n = _simSeq++;
    const lines = [
      OrderLine('ברז לכיור', 2),
      OrderLine('סרט טפלון', 3),
      OrderLine('סיליקון סניטרי', 1),
    ];
    final items = lines.fold<int>(0, (a, l) => a + l.qty);
    final order = SysOrder(
      id: 'BS-${1100 + n}',
      who: kSimCustomers[n % kSimCustomers.length],
      site: kSimSites[n % kSimSites.length],
      items: items,
      sum: 354,
      stage: OrderStage.newOrder,
      haul: 'small',
      lines: lines,
    );
    state = [order, ...state];
    return order.id;
  }

  void _apply(String id, OrderStage? Function(OrderStage) next) {
    state = [
      for (final o in state)
        if (o.id == id)
          o.copyWith(stage: next(o.stage) ?? o.stage)
        else
          o,
    ];
  }

  static OrderStage? _storeNext(OrderStage s) => switch (s) {
    OrderStage.newOrder => OrderStage.preparing,
    OrderStage.preparing => OrderStage.ready,
    _ => null,
  };

  static OrderStage? _courierNext(OrderStage s) => switch (s) {
    OrderStage.ready => OrderStage.pickup,
    OrderStage.pickup => OrderStage.transit,
    OrderStage.transit => OrderStage.delivered,
    _ => null,
  };
}

/// The shared order list. Seeded from [kSysOrdersSeed]; mutated by the store
/// and courier role-apps via [SysOrdersNotifier].
final sysOrdersProvider =
    StateNotifierProvider<SysOrdersNotifier, List<SysOrder>>(
      (ref) => SysOrdersNotifier(),
    );
