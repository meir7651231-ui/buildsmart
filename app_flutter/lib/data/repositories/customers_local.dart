// ─────────────────────────────────────────────────────────────────────────────
// LocalCustomersRepository — the T6.2 local implementation of
// [CustomersRepository].
//
// SERVER-READY FOUNDATION (Track T6.2 + T6.3). The manager's customer view is
// NOT a static seed — it is the buyer aggregates DERIVED from the shared orders
// engine (`ordersEngineProvider`) folded through `mgrCustomerList`
// (`logic/manager_dashboard.dart`), plus the deterministic `contractorCredit`
// ceiling. This class encapsulates exactly that derivation, returning the SAME
// list `managerCustomersProvider` returns today (sorted by spend, desc) — no
// value changes. A future CRM backend swaps in behind this contract.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/customers_firebase.dart';
import 'package:buildsmart/data/repositories/customers_repository.dart';
import 'package:buildsmart/logic/manager_dashboard.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The local implementation of [CustomersRepository], backed by the live
/// `ordersEngineProvider`. Holds a [Ref] so the aggregates always reflect the
/// live orders — identical to what `managerCustomersProvider` computed inline.
class LocalCustomersRepository implements CustomersRepository {
  const LocalCustomersRepository(this._ref);

  final Ref _ref;

  @override
  List<ManagerCustomer> all() => aggregate(_ref.read(ordersEngineProvider));

  /// The group-by-buyer derivation over a given [orders] list — the verbatim
  /// `mgrCustomerList` fold (sorted by spend, desc). Exposed (beyond the
  /// interface) so the reactive provider can hand in the orders it `watch`es,
  /// keeping the read-path's live dependency explicit. [all] uses it over the
  /// engine's current list.
  List<ManagerCustomer> aggregate(List<Order> orders) => mgrCustomerList(
        orders.map((o) => o.toManagerOrder()).toList(growable: false),
      );

  @override
  ManagerCustomer? byName(String name) {
    for (final c in all()) {
      if (c.name == name) return c;
    }
    return null;
  }

  @override
  int creditLimit(String name) => contractorCredit(name);
}

/// The customers repository provider — the server-ready seam the manager's
/// 👥 לקוחות aggregates flow through (T6.3) and the remote impl swaps in behind
/// (S3.C). When Firebase is initialised (the real app, `main()` calls
/// `Firebase.initializeApp`) the Firestore-backed [FirebaseCustomersRepository]
/// is used — it `attach()`es its `snapshots()` listener and is disposed with the
/// provider. When Firebase is NOT initialised (the entire Firebase-free test
/// suite) the in-memory [LocalCustomersRepository] is used, so tests never touch
/// Firestore. Both satisfy the same sync [CustomersRepository] contract →
/// providers + UI are unchanged. (Copies the `ordersRepositoryProvider` switch in
/// `orders_local.dart`.) `managerCustomersProvider` already branches on
/// `is LocalCustomersRepository`: the local impl folds the watched live orders via
/// `aggregate(orders)`, the Firestore impl serves its cached aggregates via `all()`.
final customersRepositoryProvider = Provider<CustomersRepository>((ref) {
  if (Firebase.apps.isNotEmpty) {
    final repo = FirebaseCustomersRepository()..attach();
    ref.onDispose(repo.dispose);
    return repo;
  }
  return LocalCustomersRepository(ref);
});
