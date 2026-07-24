// ─────────────────────────────────────────────────────────────────────────────
// FirebaseCustomersRepository — the S3.C Firestore-backed implementation of
// [CustomersRepository], built on the offline-first cache base
// ([FirestoreCachedRepo]). It is a DROP-IN for [LocalCustomersRepository]: the
// providers + UI are unchanged — only which class the `customersRepositoryProvider`
// returns changes (see the provider switch in `customers_local.dart`). Modelled
// structurally on the S2.3 pilot `orders_firebase.dart`.
//
// HOW THE BRIDGE IS HELD (the whole reason this task exists):
//   • reads (`all`/`byName`/`creditLimit`) are SYNCHRONOUS, served from the
//     in-memory cache the base maintains from a Firestore `snapshots()` listener;
//   • a credit-affecting change updates the cache OPTIMISTICALLY (instant for the
//     UI) via the base's `upsert`/`replaceAll`, and fires the matching Firestore
//     write in the background — a write failure is logged, never thrown.
//
// WHAT THIS DOMAIN IS (the difference from orders): the manager's 👥 לקוחות view
// is NOT a static CRUD seed — it is the buyer aggregates DERIVED from the shared
// orders engine, folded through `mgrCustomerList` (`logic/manager_dashboard.dart`)
// plus the deterministic `contractorCredit` ceiling. So the EXISTING
// [CustomersRepository] interface is a derived READ surface (`all`/`byName`/
// `creditLimit`) — it carries NO write methods, and this repo invents none. The
// base's optimistic writes exist for fresh-backend seeding (`onFirstSnapshotEmpty`)
// and to keep a credit-affecting `upsert` sync-visible; the live derivation in
// the local path stays the source of those aggregates.
//
// SEED CONTRACT (offline-first, fresh-backend-safe) — same shape as the pilot:
//   • the cache is BORN with the four seed customers (`mgrCustomerList()` over
//     `kManagerOrderSeed`) so the app is non-empty before snapshot 1 — byte-for-byte
//     the list `LocalCustomersRepository.all()` returns on the seed engine;
//   • a FIRST snapshot that arrives EMPTY (fresh Firestore) → `pushCacheToRemote`
//     seeds the backend from that seed (the four legacy customers appear server-side);
//
// FIELD MAPPING (Dart `ManagerCustomer` ⇄ Firestore doc) per
// `knowledge/firestore-schema.md` `customers/{id} {name, phone, creditLimit, used,
// balance, ownerId}` — the model keeps its aggregate field names (like `Order`
// keeps who/site); the doc uses the SSOT credit names:
//   name→name (doc-id) · totalSpend→used (₪ used of credit) · creditLimit→creditLimit
//   · balance = creditLimit-totalSpend (derived SSOT field) · orderCount carried as
//   an extra field (so `all()` returns a full aggregate without a join, mirroring
//   how `orders` carries `items`) · ownerId→ownerId (A11 — see below). The schema's
//   `phone` has no model counterpart: `toDoc` omits it, `fromDoc` ignores it.
//
// A11 (launch uid-migration) — `ownerId` is now MAPPED through `ManagerCustomer.
// ownerId` (forward-ready), written GUARDED (only when non-empty) and read
// tolerantly (default '') — the A3 `contractorUid` discipline. The customer list
// is DERIVED from the orders engine (`mgrCustomerList` over `Order.who` display
// names, not uids) and the [CustomersRepository] interface carries NO public
// write method that creates a customer doc — so the MODEL's `ownerId` is always
// '' on this path. C2 (stage-2 iron-rule-2, the orders-A3 precedent) therefore
// stamps the SESSION uid instead: the provider injects [ownerUid] from
// `currentUidProvider` (the same stamp source as orders A3 / chat A8) and
// [toDoc] writes it whenever the model carries no owner of its own — so any doc
// this repo ever writes (the dev-seed push / an optimistic upsert) lands
// owner-stamped, giving the `ownerId` read branch in `firestore.rules` and the
// (ownerId ASC, used DESC) composite index (firestore.indexes.json #4) real
// bytes to match. Signed-out / Firebase-free → '' → omitted, and the seed
// round-trips byte-identical (zero regression). A doc that ALREADY carries an
// owner (round-tripped via [fromDoc], which stays tolerant of a missing
// `ownerId`) keeps it — the stamp never clobbers a real owner. The matching
// owner-SCOPED listen is gated in the provider (customers_local.dart, behind
// `kUidScopedQueries`).
//
// Comment density/voice mirrors `orders_firebase.dart` — the S2.3 template.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart' show kServerCallables;
import 'package:buildsmart/data/repositories/customers_repository.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/order_functions.dart';
import 'package:buildsmart/logic/manager_dashboard.dart';
import 'package:flutter/foundation.dart';

/// The Firestore document-id field-map mapper lives inline here (not in the
/// model) so the legacy [ManagerCustomer] aggregate stays untouched — drop-in is
/// preserved, exactly as `orders_firebase.dart` keeps the `Order` model untouched.
class FirebaseCustomersRepository extends FirestoreCachedRepo<ManagerCustomer>
    implements CustomersRepository {
  /// Constructs the repo over the `customers` collection. The real Firestore
  /// instance is resolved LAZILY by [FirestoreCollectionSource] (never here), so
  /// construction does not require Firebase to be initialised. Pass [source] in
  /// tests to drive the cache with a fake.
  ///
  /// A13 — [serverCallables] + [functions] mirror the local impl: the credit
  /// callable is routed only when the flag is ON (default the compile-time
  /// [kServerCallables]) AND a gateway is bound. OFF / no gateway → the sync
  /// client derivation (byte-identical).
  ///
  /// C2 — [ownerUid] is the session's `auth.uid` (injected by the provider from
  /// `currentUidProvider`; '' when signed-out / Firebase-free / in tests), the
  /// uid [toDoc] stamps as `ownerId` when the model carries no owner of its own
  /// — the A3 `contractorUid` stamp, taken at construction because this derived
  /// surface has no `placeOrder`-style write call-site to stamp at.
  FirebaseCustomersRepository({
    RemoteCollectionSource? source,
    bool? serverCallables,
    OrderFunctionsGateway? functions,
    String ownerUid = '',
  })  : _serverCallables = serverCallables,
        _functions = functions,
        _ownerUid = ownerUid,
        super(source ?? FirestoreCollectionSource('customers'));

  /// A13 — null means "use the compile-time default" ([kServerCallables]).
  final bool? _serverCallables;

  /// A13 — the injectable callable seam (null off the live backend).
  final OrderFunctionsGateway? _functions;

  /// C2 — the session uid [toDoc] stamps as `ownerId` ('' = nothing to stamp).
  final String _ownerUid;

  // ── base contract: seed · mapping · ordering · fresh-backend hook ───────────

  /// The cache is born with the four seed customers — `mgrCustomerList()` folded
  /// over `kManagerOrderSeed` (the no-arg fold is exactly what
  /// `LocalCustomersRepository.all()` returns on the seed engine). Identical
  /// genesis numbers to the local path, so the app is non-empty before snapshot 1.
  @override
  List<ManagerCustomer> get seed => mgrCustomerList();

  /// doc-id = the buyer name (the natural key — `byName` keys on it and the
  /// aggregate groups by buyer `who`/name).
  @override
  String idOf(ManagerCustomer value) => value.name;

  /// `ManagerCustomer` → Firestore doc. Maps to the SSOT credit field names
  /// (`totalSpend`→`used`, `balance` derived) per the `customers` schema; the
  /// name is the doc-id, not a field. `orderCount` is carried as an extra field
  /// so `all()` returns a full aggregate without a join (mirrors how `orders`
  /// carries `items`). A11/C2 — `ownerId` is written GUARDED (only when a
  /// non-empty uid is known — the A3 `contractorUid` discipline): the model's
  /// own owner wins (a doc round-tripped through [fromDoc] keeps its real owner
  /// — the stamp never clobbers it), else the injected session [_ownerUid] is
  /// stamped. Both empty (signed-out / Firebase-free / tests) → omitted, and
  /// the seed round-trips byte-identical (zero regression). The schema's
  /// `phone` carries no model value, so it is omitted (tolerant).
  @override
  Map<String, dynamic> toDoc(ManagerCustomer c) => {
        'name': c.name,
        'used': c.totalSpend,
        'creditLimit': c.creditLimit,
        'balance': c.creditLimit - c.totalSpend,
        'orderCount': c.orderCount,
        if (c.ownerId.isNotEmpty)
          'ownerId': c.ownerId
        else if (_ownerUid.isNotEmpty)
          'ownerId': _ownerUid,
      };

  /// Firestore doc → `ManagerCustomer`. Inverse of [toDoc]: the doc-id becomes
  /// `name`, `used`→`totalSpend`, `creditLimit`→`creditLimit`, `orderCount`→
  /// `orderCount` (defaulting to 0 when an externally-written doc omits it).
  /// A11 — `ownerId` is read tolerantly (default '' when a legacy/seed doc omits
  /// it — the zero-regression default; forward-ready for a console/server doc
  /// that carries it). `balance`/`phone` are ignored (the aggregate derives
  /// them / carries no such field). THROWS on a structurally-bad doc (missing
  /// `creditLimit`/`used`) — the base catches that per-doc and skips it.
  @override
  ManagerCustomer fromDoc(RemoteDoc doc) {
    final j = doc.data;
    return ManagerCustomer(
      name: (j['name'] as String?) ?? doc.id,
      orderCount: (j['orderCount'] as num?)?.toInt() ?? 0,
      totalSpend: (j['used'] as num).toInt(),
      creditLimit: (j['creditLimit'] as num).toInt(),
      ownerId: (j['ownerId'] as String?) ?? '',
    );
  }

  /// Restore the aggregate's spend-desc ordering. Firestore returns documents in
  /// doc-id order; the 👥 לקוחות list expects buyers sorted by spend descending
  /// (the `mgrCustomerList` sort, `logic/manager_dashboard.dart`). Tie-broken by
  /// name desc for a stable order across snapshots.
  @override
  List<ManagerCustomer> sortBy(List<ManagerCustomer> items) {
    return List<ManagerCustomer>.of(items)
      ..sort((a, b) {
        final c = b.totalSpend.compareTo(a.totalSpend); // higher spend first
        if (c != 0) return c;
        return b.name.compareTo(a.name);
      });
  }

  /// Fresh backend (first snapshot empty) → seed the remote from the local seed
  /// the cache was born with, so the four legacy customers exist server-side.
  @override
  void onFirstSnapshotEmpty() => pushCacheToRemote();

  // ── reads (SYNCHRONOUS — served from the cache) ─────────────────────────────

  @override
  List<ManagerCustomer> all() => cached();

  @override
  ManagerCustomer? byName(String name) {
    for (final c in cached()) {
      if (c.name == name) return c;
    }
    return null;
  }

  /// The contractor's credit ceiling. On the live Firebase backend there is NO
  /// real credit source for this synchronous read, and the local `contractorCredit`
  /// ceiling is a FABRICATED deterministic hash (a per-name number in the
  /// 30,000–120,000 ₪ band) — it MUST NOT be shown to a real signed-in user as if
  /// it were their actual approved credit. This repo runs ONLY when the backend
  /// is ON (the provider routes here only when `useFirebaseBackend` is true), so
  /// returning 0 unconditionally is correct. The REAL credit path is
  /// [computeCredit], which (with the callable gateway bound) returns the
  /// server-canonical aggregate; it is intentionally left unchanged.
  @override
  int creditLimit(String name) => 0;

  /// A13 — the server-canonical credit aggregate.
  ///
  /// The server callable is the ONLY real source of a credit ceiling here. When
  /// it is unavailable — callable unbound, flag off, or the call threw — this
  /// falls back to a limit of ZERO, matching the deliberate choice already made
  /// by the synchronous [creditLimit] above, and for the same reason.
  ///
  /// IT USED TO FALL BACK TO `contractorCredit(name)`, and that was the bug. That
  /// helper is a hash of the person's NAME bucketed into the 30,000–120,000 ₪
  /// band; it is a demo prop, not a credit decision. Its doc comment called this
  /// path "never a faked success" while the code underneath it fabricated exactly
  /// that — a per-name number, stable across reloads, rendered by
  /// `credit_explain_screen` under the heading "the REAL credit figures". A
  /// manager reading ₪85,000 next to a contractor's name has no way to tell it
  /// from an approved limit, and approving an order against it is the whole
  /// damage. A degraded read must look degraded: showing nothing is recoverable,
  /// showing a confident wrong number is not.
  ///
  /// Local/demo builds are untouched — `LocalCustomersRepository` keeps the
  /// derivation, and this repo is constructed only when the backend is live.
  @override
  Future<CreditResult> computeCredit(String name) async {
    final fns = _functions;
    if ((_serverCallables ?? kServerCallables) && fns != null) {
      try {
        return await fns.computeCredit(name);
      } on OrderFunctionsException catch (e) {
        debugPrint('Customers(fb): computeCredit failed (no local invention): $e');
      }
    }
    final c = byName(name);
    // `used` and `orderCount` are real — they are folded from this contractor's
    // own orders — so they stay. Only the ceiling was ever invented, and with no
    // ceiling there is no balance and no percentage to report: a "0% used" next
    // to a real spend would be a second invented claim.
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
