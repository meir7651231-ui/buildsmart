// ─────────────────────────────────────────────────────────────────────────────
// FirebaseOrdersRepository — the S2.3 PILOT that proves the cache-pattern. It is
// the Firestore-backed implementation of [OrdersRepository], built on the
// offline-first cache base ([FirestoreCachedRepo]). It is a DROP-IN for
// [LocalOrdersRepository]: the providers + UI are unchanged — only which class
// the `ordersRepositoryProvider` returns changes (see the provider switch in
// `orders_local.dart`).
//
// HOW THE BRIDGE IS HELD (the whole reason this task exists):
//   • reads (`all`/`byId`/`open`) are SYNCHRONOUS, served from the in-memory
//     cache the base maintains from a Firestore `snapshots()` listener;
//   • writes (`placeOrder`/`advance`/`setStage`/`resetToSeed`) update the cache
//     OPTIMISTICALLY (instant for the UI) and fire the matching Firestore write
//     in the background — a write failure is logged, never thrown.
//
// WRITE SEMANTICS ARE VERBATIM PORTS of `OrdersEngineNotifier`
// (`state/orders_engine.dart`) so every contractor/store/courier/manager number
// stays byte-for-byte identical to the local path:
//   • `_nextId()` → next `BS-####` above the current max (else timestamp id);
//   • `placeOrder` → new order at `kManagerOrderFlow.first` ('new'), prepended;
//   • `advance`    → next stage in `kManagerOrderFlow`, no-op once `delivered`;
//   • `setStage`   → manager god-step, ignores unknown stage / unknown id / no-op.
//
// SEED CONTRACT (offline-first, fresh-backend-safe):
//   • the cache is BORN with `kOrdersEngineSeed` (app non-empty before snapshot 1);
//   • a FIRST snapshot that arrives EMPTY (fresh Firestore) → `pushCacheToRemote`
//     seeds the backend from that seed (the four legacy orders appear server-side);
//   • `resetToSeed` → `replaceAll(seed)`.
//
// FIELD MAPPING (Dart `Order` ⇄ Firestore doc) per `knowledge/firestore-schema.md`:
//   who→contractorId · site→siteAddress · createdAt→ts (ISO-8601) · id = doc-id.
//
// Comment density/voice mirrors `orders_local.dart` — this pilot is the template
// the 6 parallel S3 repos copy.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/orders_repository.dart';
import 'package:buildsmart/logic/manager_dashboard.dart' show kManagerOrderFlow;
import 'package:buildsmart/state/orders_engine.dart';

/// The Firestore document-id field-map mapper lives inline here (not in the
/// model) so the legacy [Order] model stays untouched — drop-in is preserved.
class FirebaseOrdersRepository extends FirestoreCachedRepo<Order>
    implements OrdersRepository {
  /// Constructs the repo over the `orders` collection. The real Firestore
  /// instance is resolved LAZILY by [FirestoreCollectionSource] (never here), so
  /// construction does not require Firebase to be initialised. Pass [source] in
  /// tests to drive the cache with a fake.
  FirebaseOrdersRepository({RemoteCollectionSource? source})
      : super(source ?? FirestoreCollectionSource('orders'));

  // ── base contract: seed · mapping · ordering · fresh-backend hook ───────────

  /// The cache is born with the four seed orders (lifted from `kManagerOrderSeed`
  /// via `kOrdersEngineSeed`) so the app is non-empty before the first snapshot —
  /// identical genesis to the local engine.
  @override
  List<Order> get seed => kOrdersEngineSeed;

  /// doc-id = `order.id` (e.g. `BS-1042`).
  @override
  String idOf(Order value) => value.id;

  /// `Order` → Firestore doc. Maps to the SSOT field names (who→contractorId,
  /// site→siteAddress, createdAt→ts ISO-8601); the id is the doc-id, not a field.
  /// Optional `lines`/`shipTo`/`notes` are written only when non-empty so the
  /// seed round-trips backward-compatibly (mirrors `Order.toJson`).
  @override
  Map<String, dynamic> toDoc(Order o) => {
        'contractorId': o.who,
        'siteAddress': o.site,
        'items': o.items,
        'sum': o.sum,
        'stage': o.stage,
        if (o.createdAt != null) 'ts': o.createdAt!.toIso8601String(),
        if (o.lines.isNotEmpty)
          'lines': o.lines.map((l) => l.toJson()).toList(),
        if (o.shipTo.isNotEmpty) 'shipTo': o.shipTo,
        if (o.notes.isNotEmpty) 'notes': o.notes,
        if (o.contractorUid.isNotEmpty) 'contractorUid': o.contractorUid,
        // A4 (claim-on-first-advance) — the claiming store/courier uids, written
        // only when non-empty so the seed + every pre-A4 doc round-trips
        // unchanged (mirrors `contractorUid`). The `set(merge:true)` write path
        // never clears them either.
        if (o.storeUid.isNotEmpty) 'storeUid': o.storeUid,
        if (o.courierUid.isNotEmpty) 'courierUid': o.courierUid,
        // The placer's phone for the order card's 📞/💬 — written only when
        // non-empty so the seed + every legacy doc round-trips unchanged.
        if (o.customerPhone.isNotEmpty) 'customerPhone': o.customerPhone,
      };

  /// Firestore doc → `Order`. Inverse of [toDoc]: the doc-id becomes `id`,
  /// contractorId→who, siteAddress→site, ts→createdAt. Tolerant of the legacy
  /// JSON shape too (who/site/createdAt) so a doc seeded from `Order.toJson`
  /// also decodes. THROWS on a structurally-bad doc (missing required field) —
  /// the base catches that per-doc and skips it.
  @override
  Order fromDoc(RemoteDoc doc) {
    final j = doc.data;
    final tsRaw = (j['ts'] ?? j['createdAt']) as String?;
    return Order(
      id: doc.id,
      who: (j['contractorId'] ?? j['who']) as String,
      site: (j['siteAddress'] ?? j['site']) as String,
      items: (j['items'] as num).toInt(),
      sum: (j['sum'] as num).toInt(),
      stage: j['stage'] as String,
      createdAt: tsRaw == null ? null : DateTime.tryParse(tsRaw),
      lines: j['lines'] == null
          ? const []
          : (j['lines'] as List<dynamic>)
              .map((e) => OrderLineItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      shipTo: (j['shipTo'] as String?) ?? '',
      notes: (j['notes'] as String?) ?? '',
      contractorUid: (j['contractorUid'] as String?) ?? '',
      storeUid: (j['storeUid'] as String?) ?? '',
      courierUid: (j['courierUid'] as String?) ?? '',
      customerPhone: (j['customerPhone'] as String?) ?? '',
    );
  }

  /// Restore the engine's newest-first ordering. Firestore returns documents in
  /// doc-id order; the UI expects newly-placed orders on top (the engine
  /// prepends). Sort by `createdAt` desc with nulls (the seed) last, tie-broken
  /// by id desc — which reproduces the seed order exactly (BS-1042…BS-1039) and
  /// keeps any placed order (timestamped) at the front.
  @override
  List<Order> sortBy(List<Order> items) {
    return List<Order>.of(items)
      ..sort((a, b) {
        final at = a.createdAt;
        final bt = b.createdAt;
        if (at != null && bt != null) {
          final c = bt.compareTo(at); // newer first
          if (c != 0) return c;
        } else if (at != null) {
          return -1; // timestamped before seed
        } else if (bt != null) {
          return 1;
        }
        return b.id.compareTo(a.id); // stable: higher BS-#### first
      });
  }

  /// Fresh backend (first snapshot empty) → seed the remote from the local seed
  /// the cache was born with, so the four legacy orders exist server-side.
  @override
  void onFirstSnapshotEmpty() => pushCacheToRemote();

  // ── reads (SYNCHRONOUS — served from the cache) ─────────────────────────────

  @override
  List<Order> all() => cached();

  @override
  Order? byId(String id) {
    for (final o in cached()) {
      if (o.id == id) return o;
    }
    return null;
  }

  @override
  List<Order> open() => cached().where((o) => o.isOpen).toList();

  // ── writes (optimistic cache + background Firestore) ────────────────────────

  /// Verbatim port of `OrdersEngineNotifier._nextId` over the cache: next
  /// `BS-####` above the current max, else a timestamp-based fallback id.
  String _nextId() {
    final re = RegExp(r'^BS-(\d+)$');
    var maxN = 0;
    for (final o in cached()) {
      final m = re.firstMatch(o.id);
      if (m != null) {
        final n = int.tryParse(m.group(1)!) ?? 0;
        if (n > maxN) maxN = n;
      }
    }
    return maxN > 0
        ? 'BS-${maxN + 1}'
        : 'BS-${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Contractor places a new order at `kManagerOrderFlow.first` ('new'),
  /// prepended (newest-first) — verbatim port of `OrdersEngineNotifier.placeOrder`.
  /// Optimistically inserted into the cache and written to Firestore in the
  /// background. Returns the created order.
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
  }) {
    final order = Order(
      id: id ?? _nextId(),
      who: who,
      site: site,
      items: items,
      sum: sum,
      stage: kManagerOrderFlow.first, // 'new'
      createdAt: createdAt ?? DateTime.now(),
      lines: lines,
      shipTo: shipTo,
      notes: notes,
      contractorUid: contractorUid,
      customerPhone: customerPhone,
    );
    upsert(order); // optimistic prepend + background set
    return order;
  }

  /// Advance [orderId] to the NEXT stage in `kManagerOrderFlow` — a no-op once
  /// `delivered`. Verbatim port of `OrdersEngineNotifier.advance`:
  /// `cur=flow.indexOf(stage)`; if `cur<0 || cur>=len-1` do nothing, else
  /// `setStage(flow[cur+1])`.
  @override
  void advance(String orderId) {
    final o = byId(orderId);
    if (o == null) return;
    final cur = kManagerOrderFlow.indexOf(o.stage);
    if (cur < 0 || cur >= kManagerOrderFlow.length - 1) return;
    setStage(orderId, kManagerOrderFlow[cur + 1]);
  }

  /// Manager "god-step": set [orderId] to ANY [stage] in the flow. Ignores an
  /// unknown stage / unknown id / a no-op (same stage) — verbatim port of
  /// `OrdersEngineNotifier.setStage`. The optimistic upsert replaces by id, so
  /// the order keeps its position; `sortBy` re-orders if needed.
  @override
  void setStage(String orderId, String stage) {
    if (!kManagerOrderFlow.contains(stage)) return;
    final o = byId(orderId);
    if (o == null) return;
    if (o.stage == stage) return;
    upsert(o.copyWith(stage: stage));
  }

  /// A13 (launch server-connect) — apply an OPTIMISTIC LOCAL stage update for
  /// [orderId] to [stage] WITHOUT a direct Firestore write. Used only on the
  /// `kServerCallables`-ON path, AFTER the `advanceOrderStage` callable has done
  /// the canonical write server-side: the client mirrors the new stage into the
  /// cache for instant UX, but fires NO `set` — a direct stage write would be
  /// reverted by the `revertIllegalOrderStageWrite` trigger (the callable is the
  /// sanctioned path). A later `snapshots()` event reconciles. Ignores an
  /// unknown id / a no-op (same stage). Distinct from [setStage], which is the
  /// OFF-path direct optimistic write (cache + background `set`).
  void applyServerStage(String orderId, String stage) {
    final o = byId(orderId);
    if (o == null) return;
    if (o.stage == stage) return;
    upsertLocalOnly(o.copyWith(stage: stage));
  }

  /// A4 (claim-on-first-advance) — CLAIM [orderId] for the STORE [uid] over the
  /// cache: stamp `storeUid = uid` ONLY when currently empty (NO-STEAL — an
  /// order already claimed by another store is left untouched; empty [uid]
  /// no-ops; a same-uid re-claim is a no-op). The optimistic `upsert` mirrors
  /// the claim into the engine synchronously and fires the background
  /// `set(merge:true)` write — verbatim port of `OrdersEngineNotifier.claimStore`.
  @override
  void claimStore(String orderId, String uid) {
    if (uid.isEmpty) return;
    final o = byId(orderId);
    if (o == null) return;
    if (o.storeUid.isNotEmpty) return; // already claimed — no-steal
    upsert(o.copyWith(storeUid: uid));
  }

  /// A4 — CLAIM [orderId] for the COURIER [uid] (courier analogue of
  /// [claimStore]). Verbatim port of `OrdersEngineNotifier.claimCourier`.
  @override
  void claimCourier(String orderId, String uid) {
    if (uid.isEmpty) return;
    final o = byId(orderId);
    if (o == null) return;
    if (o.courierUid.isNotEmpty) return; // already claimed — no-steal
    upsert(o.copyWith(courierUid: uid));
  }

  /// Reset to the four seed orders — verbatim port of
  /// `OrdersEngineNotifier.resetToSeed`, as a whole-cache optimistic replace
  /// that also re-writes the seed to the remote.
  @override
  void resetToSeed() => replaceAll(seed);
}
