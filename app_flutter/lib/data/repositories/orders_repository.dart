// ─────────────────────────────────────────────────────────────────────────────
// OrdersRepository — the read/write surface for the shared orders engine.
//
// SERVER-READY FOUNDATION (Track T6.1). This is the ABSTRACT interface only;
// the local implementation (T6.2) and the provider refactor (T6.3) come later.
// When orders move to a real backend the only thing that swaps is the
// implementation behind this contract — the providers + UI stay unchanged.
//
// CURRENT BACKING (what T6.2's local impl will wrap): the in-memory +
// SharedPreferences-backed orders engine in `state/orders_engine.dart`
// (`ordersEngineProvider` / `OrdersEngineNotifier`), seeded from
// `kManagerOrderSeed` (`logic/manager_dashboard.dart`). The store/courier
// projection in `state/sys_orders.dart` derives from the same list, so this
// interface is the single source of truth every role reads & mutates.
//
// Method surface mirrors what those providers expose today:
//   • read   — the live list, lookup-by-id, the "open orders" predicate.
//   • write  — placeOrder (contractor) · advance (next stage) · setStage
//              (manager god-step) · resetToSeed (tests / demo reset).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/state/orders_engine.dart' show Order, OrderLineItem;

/// Server-ready contract over the shared orders engine. The current backing is
/// `state/orders_engine.dart` (`ordersEngineProvider`); a future remote impl
/// drops in behind this same interface (swap-implementation-only).
abstract class OrdersRepository {
  /// The full live order list every role reads (contractor · store · courier ·
  /// manager). Mirrors `ref.watch(ordersEngineProvider)`.
  List<Order> all();

  /// The order with [id], or null if none. Mirrors the engine's id lookup.
  Order? byId(String id);

  /// Orders whose stage is not `delivered` — the legacy "open order" predicate
  /// (`Order.isOpen`). Used by the manager dashboard's 🚚 הזמנות פתוחות tile.
  List<Order> open();

  /// Contractor places a new order — it enters the flow at stage `new` (the
  /// first of `kManagerOrderFlow`). Returns the created order. Mirrors
  /// `OrdersEngineNotifier.placeOrder`. When [id] is omitted the next `BS-####`
  /// is auto-assigned. [lines]/[shipTo]/[notes] are captured at checkout.
  /// [customerPhone] is the placer's (contractor's) phone, stamped so an order
  /// card can show the 📞/💬 contact buttons (additive, default '' → no buttons).
  Order placeOrder({
    required String who,
    required String site,
    required int items,
    required int sum,
    String? id,
    DateTime? createdAt,
    List<OrderLineItem> lines,
    String shipTo,
    String notes,
    String contractorUid,
    String customerPhone,
    String customerEmail,
  });

  /// Advance [orderId] to the NEXT stage in `kManagerOrderFlow` — a no-op once
  /// `delivered`. Mirrors `OrdersEngineNotifier.advance` (legacy mgrAdvanceOrder).
  void advance(String orderId);

  /// Manager "god-step": set [orderId] to ANY [stage] in the flow. Unknown
  /// stage / unknown id is ignored. Mirrors `OrdersEngineNotifier.setStage`.
  void setStage(String orderId, String stage);

  /// A4 (claim-on-first-advance) — CLAIM [orderId] for the STORE [uid]: stamp
  /// `storeUid = uid` ONLY when it is currently empty (no-steal — an order
  /// already claimed by another store is left untouched; a manager reassigns
  /// server-side). Empty [uid] no-ops. Mirrors `OrdersEngineNotifier.claimStore`.
  void claimStore(String orderId, String uid);

  /// A4 — CLAIM [orderId] for the COURIER [uid] (courier analogue of
  /// [claimStore]). Mirrors `OrdersEngineNotifier.claimCourier`.
  void claimCourier(String orderId, String uid);

  /// Reset to the four seed orders (tests / a future "demo reset"). Mirrors
  /// `OrdersEngineNotifier.resetToSeed`.
  void resetToSeed();
}
