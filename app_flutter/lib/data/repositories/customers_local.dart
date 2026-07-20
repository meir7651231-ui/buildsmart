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

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/customers_firebase.dart';
import 'package:buildsmart/data/repositories/customers_repository.dart';
import 'package:buildsmart/data/repositories/order_functions.dart';
import 'package:buildsmart/logic/manager_dashboard.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The local implementation of [CustomersRepository], backed by the live
/// `ordersEngineProvider`. Holds a [Ref] so the aggregates always reflect the
/// live orders — identical to what `managerCustomersProvider` computed inline.
class LocalCustomersRepository implements CustomersRepository {
  /// A13 — [serverCallables] gates routing [computeCredit] through the
  /// `computeCredit` callable (the server-canonical credit). Defaults to the
  /// compile-time [kServerCallables] (OFF) so the provider passes nothing and
  /// production gates EXACTLY on that flag; a test injects `serverCallables:
  /// true` + a fake [functions] gateway to drive the ON branch. [functions] is
  /// the callable seam (null off the live backend → the flag is inert).
  const LocalCustomersRepository(
    this._ref, {
    bool? serverCallables,
    OrderFunctionsGateway? functions,
  })  : _serverCallables = serverCallables,
        _functions = functions;

  final Ref _ref;

  /// A13 — null means "use the compile-time default" ([kServerCallables]); a
  /// test passes an explicit bool. Resolved in [_useCallable] so a const
  /// constructor stays possible.
  final bool? _serverCallables;

  /// A13 — the injectable callable seam (null off the live backend / in tests
  /// that do not exercise the ON branch).
  final OrderFunctionsGateway? _functions;

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

  // fake-data-sweep 1א: no local ceiling — "לא רשומה" unless the server (computeCredit) provides a real one. Mirrors FirebaseCustomersRepository.creditLimit()==0.
  @override
  int creditLimit(String name) => 0;

  /// A13 — whether the server-canonical credit path is active: the flag (the
  /// injected bool, else the compile-time [kServerCallables]) AND a bound
  /// callable gateway. OFF on the local path / in tests by default → byte-identical.
  bool get _useCallable =>
      (_serverCallables ?? kServerCallables) && _functions != null;

  /// A13 — the server-canonical contractor credit aggregate for [name].
  ///
  /// • OFF (default) / no gateway → returns the local aggregate ([_localCredit]):
  ///   the REAL `used` + `orderCount` folded from this contractor's own orders,
  ///   and a ZERO ceiling ("לא רשומה") — so `creditLimit`/`balance`/`pct` are 0.
  ///   No network. (fake-data-sweep 1א — the demo name-hash ceiling is never
  ///   surfaced.)
  /// • ON + a bound gateway → calls the `computeCredit` callable for the
  ///   server-canonical numbers. A [OrderFunctionsException] (not deployed /
  ///   permission) is caught and FALLS BACK to the same local derivation —
  ///   honest (the manager still sees a number), never a faked server success.
  ///
  /// This is the forward-ready hook a future async credit surface reads once the
  /// flag is flipped; mirrors FirebaseCustomersRepository.computeCredit's honest
  /// no-ceiling fallback.
  @override
  Future<CreditResult> computeCredit(String name) async {
    final fns = _functions;
    if (_useCallable && fns != null) {
      try {
        return await fns.computeCredit(name);
      } on OrderFunctionsException catch (e) {
        debugPrint('Customers: computeCredit failed (local fallback): $e');
        // fall through to the local derivation
      }
    }
    return _localCredit(name);
  }

  /// The client-side credit aggregate — the REAL numbers the manager can trust:
  /// `used` + `orderCount` folded from this contractor's own orders. There is NO
  /// local credit source, so the ceiling is 0 ("לא רשומה") and `balance`/`pct`
  /// are 0 too — a real credit figure arrives only from the server
  /// (`computeCredit` callable). This is the OFF result and the graceful fallback
  /// when the callable fails. Mirrors FirebaseCustomersRepository's no-record
  /// result (customers_firebase.dart).
  CreditResult _localCredit(String name) {
    final c = byName(name);
    // fake-data-sweep 1א: `used` and `orderCount` stay REAL (folded from this
    // contractor's own orders). With no local ceiling there is no balance and no
    // percentage to report (a "0% used" next to a real spend would be a second
    // invented claim); the demo name-hash ceiling is never surfaced.
    return CreditResult(
      name: name,
      creditLimit: 0,
      used: c?.totalSpend ?? 0,
      balance: 0,
      pct: 0,
      orderCount: c?.orderCount ?? 0,
    );
  }
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
  if (useFirebaseBackend) {
    // A13 — inject the callable seam so the Firestore impl can reach the
    // `computeCredit` callable (mirrors the local branch below; `serverCallables`
    // is left at its compile-time default). Without this the gateway is null and
    // the credit callable is unreachable even when the flag is ON.
    final repo =
        FirebaseCustomersRepository(
            functions: ref.read(orderFunctionsGatewayProvider),
          )
          ..attach();
    ref.onDispose(repo.dispose);
    return repo;
  }
  // A13 — inject the callable seam (null off the live backend → the flag is
  // inert; `serverCallables` is left at its compile-time default). When ON +
  // bound, `computeCredit` routes through the `computeCredit` callable.
  return LocalCustomersRepository(
    ref,
    functions: ref.read(orderFunctionsGatewayProvider),
  );
});
