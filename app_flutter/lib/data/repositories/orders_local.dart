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
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show FirestoreCollectionSource;
import 'package:buildsmart/data/repositories/orders_firebase.dart';
import 'package:buildsmart/data/repositories/orders_repository.dart';
import 'package:buildsmart/state/auth_state.dart'
    show currentOrgIdProvider, currentUidProvider, roleProvider;
import 'package:buildsmart/state/orders_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart'
    show CollectionReference, Filter, Query;
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A5 — the OWN-leg ownership field each role's scoped orders query filters on.
/// These are the SINGLE SOURCE the [_ordersScopeFor] branches build their
/// `where(... == uid)` from, so a test can pin them WITHOUT a live Firestore
/// (the `Filter`/`Query` the builder returns is otherwise un-introspectable).
/// They MUST equal the field names `orders_firebase toDoc` writes AND the
/// composite-index field names in `firestore.indexes.json` — a guard test
/// asserts all three agree (a mismatch is the silent empty-scope bug class).
///
/// ⚠️ The contractor keys on `contractorUid` (the LANDED A3 ownership uid =
/// the placer's auth.uid), NOT `contractorId` (the display name `Order.who`) —
/// keying on the name would never equal an auth.uid → the scoped listen would
/// match nothing → the contractor would never see their own orders.
const String kOrdersContractorScopeField = 'contractorUid';
const String kOrdersStoreScopeField = 'storeUid';
const String kOrdersCourierScopeField = 'courierUid';

/// A5 — the OWN-leg scope field for [role] in the [_ordersScopeFor] dialect
/// (null role = contractor / main app). Pure → unit-testable; the real scope
/// builder uses the SAME constants, so this is a faithful descriptor of the
/// live wiring, not a parallel copy. Manager/admin scope on nothing (the god
/// view) → null.
/// stage-3.3 St4 — the org layer (kOrgScopedQueries) sits ABOVE this uid layer.
@visibleForTesting
String? debugOrdersScopeField(String? role) {
  switch (role) {
    case 'store':
      return kOrdersStoreScopeField;
    case 'courier':
      return kOrdersCourierScopeField;
    case 'manager':
    case 'admin':
      return null; // unscoped — the whole collection
    default: // contractor (null) + any unknown/exotic role
      return kOrdersContractorScopeField;
  }
}

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
    String contractorUid = '',
    String customerPhone = '',
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
        contractorUid: contractorUid,
        customerPhone: customerPhone,
      );

  @override
  void advance(String orderId) => _engine.advance(orderId);

  @override
  void setStage(String orderId, String stage) => _engine.setStage(orderId, stage);

  @override
  void claimStore(String orderId, String uid) =>
      _engine.claimStore(orderId, uid);

  @override
  void claimCourier(String orderId, String uid) =>
      _engine.claimCourier(orderId, uid);

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
    // A5 — UID-SCOPED listen (behind `kUidScopedQueries`, default OFF). With the
    // flag OFF the source is constructed with NO scope → the WHOLE-collection
    // listen, BYTE-IDENTICAL to today (the zero-regression invariant). Only when
    // the flag is ON *and* a uid is known do we build a role-scoped query the
    // Security Rules can prove (pool ∪ own for store/courier; own for the
    // contractor; manager/admin stay unscoped — the god view).
    final scope = kUidScopedQueries
        ? _ordersScopeFor(
            role: ref.watch(roleProvider),
            uid: ref.watch(currentUidProvider),
            // stage-3.3 St4 — flag-gated so with ORG_SCOPED_QUERIES OFF (the
            // default) NO org watch executes and the call is byte-identical.
            orgId: kOrgScopedQueries ? ref.watch(currentOrgIdProvider) : null,
          )
        : null;
    final repo = FirebaseOrdersRepository(
      source: scope == null
          ? FirestoreCollectionSource('orders')
          : FirestoreCollectionSource('orders', scope: scope),
    )..attach();
    ref.onDispose(repo.dispose);
    return repo;
  }
  return LocalOrdersRepository(ref);
});

/// A5 — the store stages a pool order can sit in while still un-claimed and
/// store-actionable (`new→preparing→ready`, the store's chain). A pool listen
/// is constrained to these so an un-claimed *delivered* order is NOT surfaced to
/// every store.
const List<String> _kStorePoolStages = ['new', 'preparing', 'ready'];

/// A5 — the courier stages a pool order can sit in while still un-claimed and
/// courier-actionable. An un-claimed order enters the courier pool at `ready`
/// (the store handed it off); `pickup`/`transit` are included so a claim that
/// has not yet landed in the cache still matches.
const List<String> _kCourierPoolStages = ['ready', 'pickup', 'transit'];

/// A5 — build the role-scoped orders [Query], or `null` for NO scope (the whole
/// collection — manager/admin, or any case where there is no uid to scope to so
/// we must NOT silently hide the contractor's seed/legacy data). The builder is
/// what `FirestoreCollectionSource(scope:)` calls with the live
/// `CollectionReference`. Each branch is exactly what the matching Security Rule
/// proves (see `firestore.rules` orders read):
///   • contractor → `contractorUid == uid`;
///   • store      → pool (`storeUid=='' AND stage in store-stages`) ∪ own
///                  (`storeUid == uid`) via `Filter.or`;
///   • courier    → analogous on `courierUid`;
///   • manager/admin / unknown-role / no-uid → null (unscoped).
Query<Map<String, dynamic>> Function(
        CollectionReference<Map<String, dynamic>>)?
    _ordersScopeFor(
        {required String? role, required String? uid, String? orgId}) {
  if (uid == null || uid.isEmpty) return null; // no identity → do not hide data
  // stage-3.3 St4 — the ORG layer sits ABOVE the uid layer: when the flag is
  // ON and the session carries an orgId claim, every NON-god role prefers the
  // org-wide tenant scope (`orgId == claim`) the St5 rules branch proves;
  // manager/admin keep the god view below, and with the flag OFF (default) /
  // no claim every role falls through to the uid branches VERBATIM.
  if (kOrgScopedQueries &&
      orgId != null &&
      orgId.isNotEmpty &&
      role != 'manager' &&
      role != 'admin') {
    return (c) => c.where('orgId', isEqualTo: orgId);
  }
  switch (role) {
    case 'store':
      return (c) => c.where(
            Filter.or(
              Filter.and(
                Filter(kOrdersStoreScopeField, isEqualTo: ''),
                Filter('stage', whereIn: _kStorePoolStages),
              ),
              Filter(kOrdersStoreScopeField, isEqualTo: uid),
            ),
          );
    case 'courier':
      return (c) => c.where(
            Filter.or(
              Filter.and(
                Filter(kOrdersCourierScopeField, isEqualTo: ''),
                Filter('stage', whereIn: _kCourierPoolStages),
              ),
              Filter(kOrdersCourierScopeField, isEqualTo: uid),
            ),
          );
    case 'manager':
    case 'admin':
      return null; // god view — the whole collection
    case null: // the contractor / main app (roleProvider's null dialect)
      return (c) => c.where(kOrdersContractorScopeField, isEqualTo: uid);
    default:
      // An unknown/exotic role (e.g. 'worker') gets the contractor-style own
      // scope on contractorUid — never an unscoped god listen.
      return (c) => c.where(kOrdersContractorScopeField, isEqualTo: uid);
  }
}

/// A6 — does [o] belong in a [role]'s pool∪own view for [uid]? The CLIENT-side
/// twin of [_ordersScopeFor] (same predicate, evaluated over the in-memory
/// [Order]): pool (un-claimed in a role-stage) ∪ own (claimed by [uid]). Used by
/// the store/courier dashboards so the on-screen list is pool∪own even on the
/// un-scoped local path. Pure → unit-testable.
bool orderVisibleToRole(Order o, {required String? role, required String uid}) {
  switch (role) {
    case 'store':
      return (o.storeUid.isEmpty && _kStorePoolStages.contains(o.stage)) ||
          o.storeUid == uid;
    case 'courier':
      return (o.courierUid.isEmpty && _kCourierPoolStages.contains(o.stage)) ||
          o.courierUid == uid;
    default:
      return true; // other roles are not pool-scoped here
  }
}

/// A6 — the set of order ids a store/courier dashboard should SHOW, or `null`
/// for "show everything" (today's behavior). Returns null unless the flag is ON
/// *and* there is a uid *and* the role is store/courier — so with
/// `kUidScopedQueries` OFF (or signed-out, or any other role) the dashboards are
/// byte-identical to today. The store/courier screens intersect their
/// `sysOrders` list with this set when it is non-null.
final visibleOrderIdsProvider = Provider<Set<String>?>((ref) {
  if (!kUidScopedQueries) return null;
  final uid = ref.watch(currentUidProvider);
  if (uid == null || uid.isEmpty) return null;
  final role = ref.watch(roleProvider);
  if (role != 'store' && role != 'courier') return null;
  return {
    for (final o in ref.watch(ordersEngineProvider))
      if (orderVisibleToRole(o, role: role, uid: uid)) o.id,
  };
});
