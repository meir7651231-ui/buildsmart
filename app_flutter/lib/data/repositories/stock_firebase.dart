// ─────────────────────────────────────────────────────────────────────────────
// FirebaseStockRepository — the S3.T Firestore-backed implementation of
// [StockRepository], built on the offline-first cache base
// ([FirestoreCachedRepo]). It is a DROP-IN for [LocalStockRepository]: the
// providers + UI are unchanged — only which class the `stockRepositoryProvider`
// returns changes (see the provider switch in `stock_local.dart`).
//
// TWO SURFACES, ONE CLASS — stock has a SPLIT nature, and this repo keeps the
// split byte-for-byte faithful:
//
//   1. The const-backed ANALYTICS reads (`totalProducts`/`catalogCount`/
//      `accessoryCount`/`availableCount`/`categoryCounts`/`stores`/
//      `activeStores`/`supplierStores`/`haulTypes`) mirror the manager analytics
//      + supplier seeds. These are STATIC data that never changes at runtime, so
//      — exactly like the catalog (S3.K) — they are NOT in Firestore: they stay
//      byte-identical to [LocalStockRepository], delegating to the very same
//      consts (`managerAnalytics`, `kManagerCatalogCategories`, `kManagerStores`,
//      `kStores`, `kHaulTypes`). Loading them from Firestore would only add reads
//      + latency on data that is bundled and immutable (the SSOT §אזהרות warning).
//
//   2. The mutable INVENTORY (the 📦 "המלאי שלי" two-tab screen: name →
//      'warehouse'|'site', flipped by `move`) IS the part that belongs on the
//      server — this is the `stock/{id} {sku, name, qty, location, projectId}`
//      collection. It rides the cache-pattern: a `snapshots()` listener feeds an
//      in-memory cache, sync reads (`stockDemo()`) serve from it, and `move`
//      updates the cache OPTIMISTICALLY + fires the Firestore write in the
//      background (a write failure is logged, never thrown).
//
// DOC-ID STRATEGY (the headline gotcha): the inventory is keyed by Hebrew item
// NAME, and several names contain `/` (e.g. `ברז ניל זוויתי 1/2"`) — which is
// FORBIDDEN in a Firestore document id. So the name can NOT be the doc-id.
// Instead we assign a stable surrogate id `STK-##` in SEED ORDER (doc-id order =
// seed order): `STK-00`, `STK-01`, … one per `kStockDemo` entry. `fromDoc` sets
// `sku == id` (the SSOT `sku` field IS this surrogate). The real item name and
// location are plain fields, so the `/` lives safely in field data, never the id.
//
// `move` SEMANTICS ARE A VERBATIM PORT of `StockNotifier.move`
// (`screens/stock_screen.dart`): look the item up BY NAME; if unknown → no-op;
// else flip `'warehouse'`⇄`'site'` ('warehouse' → 'site', anything-else →
// 'warehouse', matching the local `cur == 'warehouse' ? 'site' : 'warehouse'`).
// The flip is an optimistic [upsert] (replace-by-id, position preserved) + a
// background Firestore `set`.
//
// SEED CONTRACT (offline-first, fresh-backend-safe):
//   • the cache is BORN with `kStockDemo` mapped to `STK-##` items (the 📦 screen
//     is non-empty before snapshot 1 — identical 11 rows to the local path);
//   • a FIRST snapshot that arrives EMPTY (fresh Firestore) → `pushCacheToRemote`
//     seeds the backend from that seed (the 11 inventory rows appear server-side);
//   • doc-id order = seed order, so `sortBy` re-imposes seed order after every
//     snapshot (Firestore returns docs in doc-id order = `STK-00…STK-10`).
//
// Comment density/voice mirrors `orders_firebase.dart` — the S2.3 pilot this copies.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/phaseb_seeds.dart' show kStockDemo;
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/stock_repository.dart';
import 'package:buildsmart/data/supplier_data.dart'
    show HaulType, StoreInfo, kHaulTypes;
import 'package:buildsmart/logic/manager_dashboard.dart' show ManagerStore;

/// One inventory row as the cache base stores it — the model `T` of the
/// `FirestoreCachedRepo<StockItem>`. `id` is the surrogate `STK-##` doc-id (the
/// SSOT `sku`); `name` is the Hebrew item name (may contain `/`); `location` is
/// `'warehouse'` | `'site'`. `projectId` rounds out the schema row (unused by the
/// current 📦 screen, kept so the doc matches `stock/{id}` and round-trips).
class StockItem {
  const StockItem({
    required this.id,
    required this.name,
    required this.location,
    this.qty = 1,
    this.projectId = '',
  });

  /// Surrogate doc-id (`STK-##`) — equals the SSOT `sku`. Stable across runs
  /// because it is assigned in seed order (see [_seedItems]).
  final String id;

  /// The Hebrew item name (the key the 📦 screen + `move` address rows by). May
  /// contain `/` — which is why it is a FIELD, never the doc-id.
  final String name;

  /// `'warehouse'` | `'site'` — the tab the row appears under; flipped by `move`.
  final String location;

  /// Quantity (schema `qty`). The 📦 screen does not surface it; defaults to 1.
  final int qty;

  /// Owning project (schema `projectId`). Empty for the demo seed.
  final String projectId;

  /// Flip helper — returns a copy with [location] replaced (used by `move`).
  StockItem withLocation(String next) => StockItem(
        id: id,
        name: name,
        location: next,
        qty: qty,
        projectId: projectId,
      );
}

/// The Firestore-backed [StockRepository]. The analytics reads stay const (NOT
/// Firestore — byte-identical to `LocalStockRepository`); the mutable inventory
/// rides the cache base.
class FirebaseStockRepository extends FirestoreCachedRepo<StockItem>
    implements StockRepository {
  /// Constructs the repo over the `stock` collection. The real Firestore
  /// instance is resolved LAZILY by [FirestoreCollectionSource] (never here), so
  /// construction does not require Firebase to be initialised. Pass [source] in
  /// tests to drive the cache with a fake.
  FirebaseStockRepository({RemoteCollectionSource? source})
      : super(source ?? FirestoreCollectionSource('stock'));

  // ── base contract: seed · mapping · ordering · fresh-backend hook ───────────

  /// The 11-row inventory seed mapped to `STK-##` items in SEED ORDER. Lifted
  /// from [kStockDemo] (the single seed source of truth) so the cache is born
  /// with the exact same inventory the local path starts from — identical 11 rows.
  @override
  List<StockItem> get seed => _seedItems;

  /// doc-id = the surrogate `STK-##` (== `sku`). Hebrew names with `/` can NOT be
  /// doc-ids, so the surrogate is the id everywhere the base writes/de-dups.
  @override
  String idOf(StockItem value) => value.id;

  /// `StockItem` → Firestore doc, per `stock/{id} {sku, name, qty, location,
  /// projectId}`. `sku` equals the doc-id (the surrogate) so a re-decode sets it
  /// back; the `/`-bearing `name` lives safely in field data.
  @override
  Map<String, dynamic> toDoc(StockItem v) => {
        'sku': v.id,
        'name': v.name,
        'qty': v.qty,
        'location': v.location,
        'projectId': v.projectId,
      };

  /// Firestore doc → `StockItem`. Inverse of [toDoc]: `sku` is the surrogate
  /// id — so the doc-id IS the `sku` (per the deliverable note). `name`/`location`
  /// are required; `qty`/`projectId` are tolerated-optional. THROWS on a
  /// structurally-bad doc (missing name/location) — the base catches that
  /// per-doc and skips it (never blanks the inventory list).
  @override
  StockItem fromDoc(RemoteDoc doc) {
    final j = doc.data;
    return StockItem(
      id: doc.id, // sku == id
      name: j['name'] as String,
      location: j['location'] as String,
      qty: (j['qty'] as num?)?.toInt() ?? 1,
      projectId: (j['projectId'] as String?) ?? '',
    );
  }

  /// Restore SEED ORDER. Firestore returns documents in doc-id order, and our
  /// doc-ids (`STK-00`, `STK-01`, …) were assigned in seed order — so a plain
  /// ascending sort by id reproduces `kStockDemo`'s ordering exactly (and keeps
  /// it stable after any `move`, which only flips a row's location, not its id).
  @override
  List<StockItem> sortBy(List<StockItem> items) =>
      List<StockItem>.of(items)..sort((a, b) => a.id.compareTo(b.id));

  /// Fresh backend (first snapshot empty) → seed the remote from the local seed
  /// the cache was born with, so the 11 inventory rows exist server-side.
  @override
  void onFirstSnapshotEmpty() => pushCacheToRemote();

  // ── inventory: sync read + verbatim `move` (the Firestore-backed surface) ───

  /// The live inventory as the 📦 screen consumes it: `name → 'warehouse'|'site'`,
  /// in seed order. Served SYNCHRONOUSLY from the cache (no await) — this is the
  /// drop-in replacement for `LocalStockRepository.stockDemo`; the screen's
  /// `StockNotifier` seeds from it identically (same 11-row map either way).
  Map<String, String> stockDemo() => {
        for (final it in cached()) it.name: it.location,
      };

  /// Verbatim port of `StockNotifier.move` over the cache: look up the row BY
  /// NAME; if the name is unknown → NO-OP; else flip `'warehouse'`⇄`'site'`
  /// (`cur == 'warehouse' ? 'site' : 'warehouse'`). The flip is an optimistic
  /// [upsert] (replace-by-id → the row keeps its seed position) + a background
  /// Firestore `set`; a write failure is logged, never thrown.
  void move(String name) {
    StockItem? cur;
    for (final it in cached()) {
      if (it.name == name) {
        cur = it;
        break;
      }
    }
    if (cur == null) return; // unknown name → no-op (verbatim)
    final next = cur.location == 'warehouse' ? 'site' : 'warehouse';
    upsert(cur.withLocation(next), prepend: false); // replace-by-id, in place
  }

  // ── analytics DATA reads (no real source yet → EMPTY/ZERO on the live backend)
  // On the live Firebase backend there is NO real inventory/store source for
  // these aggregates, so the const demo figures (202 products, 148 accessories,
  // the per-category counts, the three seed stores) MUST NOT be shown to a real
  // signed-in user as if they were their own numbers. This repo runs ONLY when
  // the backend is ON (the provider routes here only when `useFirebaseBackend`
  // is true), so returning empty/zero unconditionally is correct — a real user
  // sees an honest empty dashboard, not invented counts or fake supplier stores.
  //
  // `categoryCounts` is gated too: it is a map of category→FABRICATED count
  // (e.g. 148), not a static reference type. `haulTypes`, by contrast, is KEPT:
  // it is a STATIC reference TYPE list (the courier vehicle kinds small/van/
  // truck + their surcharge — config-like options, not a count or inventory of
  // the user's data), so it is honest to surface on the live backend.

  @override
  int totalProducts() => 0;

  @override
  int catalogCount() => 0;

  @override
  int accessoryCount() => 0;

  @override
  int availableCount() => 0;

  @override
  Map<String, int> categoryCounts() => const {};

  @override
  List<ManagerStore> stores() => const [];

  @override
  int activeStores() => 0;

  @override
  List<StoreInfo> supplierStores() => const [];

  @override
  List<HaulType> haulTypes() => kHaulTypes;
}

/// The 11-row `kStockDemo` map projected to `STK-##` [StockItem]s in SEED ORDER.
/// Computed ONCE (top-level final, not const — `kStockDemo.entries` order is the
/// insertion order of the const map). doc-id `STK-${i}` (zero-padded to 2) =
/// seed index, so doc-id order == seed order and `sku == id`. This is the genesis
/// the cache is born with on a Firebase-backed run.
final List<StockItem> _seedItems = () {
  final entries = kStockDemo.entries.toList(growable: false);
  return [
    for (var i = 0; i < entries.length; i++)
      StockItem(
        id: 'STK-${i.toString().padLeft(2, '0')}',
        name: entries[i].key,
        location: entries[i].value,
      ),
  ];
}();
