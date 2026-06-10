// ─────────────────────────────────────────────────────────────────────────────
// LocalOrdersRepository — the T6.2 local implementation of [OrdersRepository].
//
// SERVER-READY FOUNDATION (Track T6.2 + T6.3). This wraps the EXISTING shared
// orders engine (`ordersEngineProvider` / `OrdersEngineNotifier`,
// `state/orders_engine.dart`) — it adds NO new data and changes NO value. Every
// read returns exactly what `ref.read(ordersEngineProvider)` returns today and
// every write delegates verbatim to the engine notifier, so the contractor /
// store / courier / manager numbers stay byte-for-byte identical. When orders
// move to a real backend, only THIS class swaps (the providers + UI are unchanged).
//
// The engine's SEED (the four seed orders, lifted from `kManagerOrderSeed`) is
// exposed via the extra concrete [seed] method so the engine can obtain its
// genesis list THROUGH this repository (T6.3) — a const-only accessor that does
// NOT read the engine, keeping the engine↔repository wiring acyclic.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/orders_firebase.dart';
import 'package:buildsmart/data/repositories/orders_repository.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The local (in-memory + SharedPreferences) implementation of
/// [OrdersRepository], backed by the live `ordersEngineProvider`. Holds a [Ref]
/// so reads/writes flow through the single shared engine — there is exactly one
/// live order list and this is the contract every role reads & mutates through.
class LocalOrdersRepository implements OrdersRepository {
  const LocalOrdersRepository(this._ref);

  final Ref _ref;

  OrdersEngineNotifier get _engine => _ref.read(ordersEngineProvider.notifier);

  /// The four seed orders — the genesis list the engine starts from. Lifted
  /// from `kManagerOrderSeed` via [kOrdersEngineSeed] (the single seed source of
  /// truth); const-only, so reading it never touches the engine (T6.3-safe).
  List<Order> seed() => kOrdersEngineSeed;

  @override
  List<Order> all() => _ref.read(ordersEngineProvider);

  @override
  Order? byId(String id) {
    for (final o in _ref.read(ordersEngineProvider)) {
      if (o.id == id) return o;
    }
    return null;
  }

  @override
  List<Order> open() =>
      _ref.read(ordersEngineProvider).where((o) => o.isOpen).toList();

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
  }) =>
      _engine.placeOrder(
        who: who,
        site: site,
        items: items,
        sum: sum,
        id: id,
        createdAt: createdAt,
        lines: lines,
        shipTo: shipTo,
        notes: notes,
      );

  @override
  void advance(String orderId) => _engine.advance(orderId);

  @override
  void setStage(String orderId, String stage) => _engine.setStage(orderId, stage);

  @override
  void resetToSeed() => _engine.resetToSeed();
}

/// The orders repository provider — the server-ready seam the engine reads its
/// seed through (T6.3) and the remote impl swaps in behind (S2.3). When Firebase
/// is initialised (the real app, `main()` calls `Firebase.initializeApp`) the
/// Firestore-backed [FirebaseOrdersRepository] is used — it `attach()`es its
/// `snapshots()` listener and is disposed with the provider. When Firebase is
/// NOT initialised (the entire Firebase-free test suite) the in-memory
/// [LocalOrdersRepository] is used, so tests never touch Firestore. Both satisfy
/// the same sync [OrdersRepository] contract → providers + UI are unchanged.
final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  if (useFirebaseBackend) {
    final repo = FirebaseOrdersRepository()..attach();
    ref.onDispose(repo.dispose);
    return repo;
  }
  return LocalOrdersRepository(ref);
});
