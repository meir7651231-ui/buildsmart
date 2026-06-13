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
// tolerantly (default '') — the A3 `contractorUid` discipline. ⚠️ FINDING: on
// THIS path `ownerId` is ALWAYS '' — the customer list is DERIVED from the orders
// engine (`mgrCustomerList` over `Order.who` display names, not uids) and the
// [CustomersRepository] interface carries NO public write method that creates a
// customer doc. So there is currently NOWHERE to stamp an owner uid (no write
// path is fabricated). The field is wired through end-to-end so that (a) a doc
// the schema/console writes with `ownerId` round-trips losslessly, and (b) a
// FUTURE customer-write path can stamp it from `currentUidProvider`. Until then
// every `toDoc` omits it and the seed round-trips byte-identical (zero
// regression). The eventual `ownerId` scoping activates later via the firestore
// rules (forward-ready, just landed).
//
// Comment density/voice mirrors `orders_firebase.dart` — the S2.3 template.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/customers_repository.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/logic/manager_dashboard.dart';

/// The Firestore document-id field-map mapper lives inline here (not in the
/// model) so the legacy [ManagerCustomer] aggregate stays untouched — drop-in is
/// preserved, exactly as `orders_firebase.dart` keeps the `Order` model untouched.
class FirebaseCustomersRepository extends FirestoreCachedRepo<ManagerCustomer>
    implements CustomersRepository {
  /// Constructs the repo over the `customers` collection. The real Firestore
  /// instance is resolved LAZILY by [FirestoreCollectionSource] (never here), so
  /// construction does not require Firebase to be initialised. Pass [source] in
  /// tests to drive the cache with a fake.
  FirebaseCustomersRepository({RemoteCollectionSource? source})
      : super(source ?? FirestoreCollectionSource('customers'));

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
  /// carries `items`). A11 — `ownerId` is written GUARDED (only when non-empty);
  /// on this derived path it is always '' (see the header finding), so it is
  /// omitted and the seed round-trips byte-identical (zero regression). The
  /// schema's `phone` carries no model value, so it is omitted (tolerant).
  @override
  Map<String, dynamic> toDoc(ManagerCustomer c) => {
        'name': c.name,
        'used': c.totalSpend,
        'creditLimit': c.creditLimit,
        'balance': c.creditLimit - c.totalSpend,
        'orderCount': c.orderCount,
        if (c.ownerId.isNotEmpty) 'ownerId': c.ownerId,
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

  /// The contractor's credit ceiling — a deterministic per-name value in the
  /// 30,000–120,000 ₪ band. Verbatim port of `LocalCustomersRepository.creditLimit`:
  /// it delegates to the pure `contractorCredit(name)` (`logic/manager_dashboard.dart`),
  /// NOT a Firestore read — the ceiling is a deterministic hash, identical on
  /// every path, so the local and remote impls return byte-for-byte the same value.
  @override
  int creditLimit(String name) => contractorCredit(name);
}
