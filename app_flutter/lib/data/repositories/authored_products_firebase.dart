// ─────────────────────────────────────────────────────────────────────────────
// FirebaseAuthoredProductsRepository — Studio Pillar 5 · Step 60 (R1-6 / R1-9 canonical).
//
// ⚠️ SCOPE (S3.K reconciliation — owner decision): this is the AUTHORED-products
// store — the NEW products the Studio's trade-builder creates (e.g. a whole
// electrician trade), held server-side in the `catalogProducts/{sku}` Firestore
// collection so it can grow to 10Ks of SKUs. It is DELIBERATELY DISTINCT from —
// and named OUTSIDE the `catalog_*` namespace of — the STATIC 1,877-product
// Lipskey catalog (`kCatalogProducts` const), which stays bundled + R2 CDN at
// ZERO DB cost per the locked S3.K decision (see `catalog_static_guard_test`).
// That is WHY this file may legitimately touch Firestore while the `catalog_*.dart`
// repos may not — the static catalog and the authored superset are two data sets.
//
// The store grows past a single listen (10Ks of SKUs), so it is BROWSED by CURSOR
// PAGING, never listened-to as a whole (the §1.6 trap: a whole-collection
// `snapshots()` over 10K docs is a memory + egress bomb). DORMANT until the flags
// flip — see the dormancy note below.
//
// WHAT THIS STEP BUILDS (exactly the four things the detail spec names):
//   1. BROWSE (paged) — [browse] runs a [PagedQuery] (step 53) over the neutral
//      paged seam; page size is capped at 40 by the helper. The query filters
//      `active == true`, so a tombstoned product never surfaces in browse.
//   2. MAPPER — [toDoc]/[fromDoc] between `LipskeyCatalogProduct` (UNCHANGED) and
//      the Firestore field-map. Server/scale fields (`tradeId`/`version`/
//      `updatedAt`/`nameTokens`) are written ONLY when non-empty — exactly the
//      `orders_firebase.dart:70` idiom (`contractorUid`/`storeUid` guarded). The
//      mapper is TOLERANT (every read null-falls-back — a malformed doc decodes
//      to a default, never throws, so one bad row can't tear a page).
//   3. PRICE in a ROLE-SCOPED SUB-DOC (R1-6) — the price is NEVER in the public
//      doc [toDoc]; it is written separately to `catalogProducts/{sku}/pricing/
//      {audience}` via [setPrice]. The public doc is world-readable WITHOUT a
//      price, so a competing store / an unauthorised customer cannot read the
//      contractor price by scanning the collection. The `pricing/{aud}` sub-doc
//      is claim-gated by the rule that lands in step 65.
//   4. TOMBSTONE ARCHIVE (R1-9) — deletion is SOFT: [archive] merges
//      `active:false` + `tombstone:true` (+ optional `replacedBy`); it is a `set`,
//      NOT a hard delete (this seam has NO delete method by design — the absence is
//      the guarantee). A hard delete would leave orphan ids in the `nameTokens` /
//      `tradeId` of referencing docs; the soft tombstone lets the step-63 fan-out
//      clean those references. [resolveReplacement] follows a `replacedBy` chain
//      with a visited-set CYCLE-GUARD + depth cap (A→B→A can't hang).
//
// doc-id = SKU (a natural key) ⇒ every [upsert] is IDEMPOTENT and [productForSku]
// is a SINGLE `get`, not a query.
//
// WHY THIS FILE IMPORTS `cloud_firestore` DIRECTLY (the base's `_firebase` repos
// do NOT — they delegate to `FirestoreCollectionSource`): the base seam
// ([RemoteCollectionSource]) speaks only a WHOLE-collection `snapshots()` + a
// doc-id `set`/`delete`. Step 60 needs two shapes the base seam cannot express — a
// bounded `startAfter` + `limit` PAGE query, and a single-doc `get` — so this
// adapter file is the real adapter that touches `cloud_firestore` (allowed: it is
// THE `_firebase`/adapter file). It resolves `FirebaseFirestore.instance` LAZILY —
// never at construction — exactly like `FirestoreCollectionSource`
// (`firestore_cached_repo.dart:117`), so merely constructing the repo (a provider
// read) never requires Firebase. The NEUTRAL seam ([AuthoredProductsSource]) keeps the
// repo + its tests Firebase-free: a hand-rolled fake drives every unit test with
// zero new packages, and only [FirestoreAuthoredProductsSource] imports a live Firestore.
//
// DORMANT / byte-identical when OFF: NOTHING wires this yet. The catalog provider
// stays [LocalCatalogRepository] (`catalog_local.dart:103`, UNCHANGED), so today's
// build is byte-identical by NON-CONSUMPTION. A later step gates the swap on
// `useCatalogServerSearch` (`kCatalogServerSearch && useFirebaseBackend`) +
// `kCatalogBaseUrl`; until then this class is compiler-reachable but never built.
//
// Comment density/voice mirrors `orders_firebase.dart` / `studio_config_firebase.dart`.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/paged_query.dart';
import 'package:buildsmart/data/repositories/backend.dart'
    show kSeedFreshBackend, useFirebaseBackend;
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteDoc;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint, immutable;

/// The NEUTRAL catalog remote seam. Extends the paged read-port [PagedSource]
/// (step 53) with the two POINT operations `catalogProducts` also needs — a
/// single-doc [get] (for `productForSku` / the `replacedBy` walk) and a merge
/// [set] (idempotent upsert + partial tombstone) — plus the role-scoped
/// [setPricing] write to the `pricing/{audience}` sub-doc (R1-6). Speaks only
/// neutral [RemoteDoc]s + a [Cursor]: a hand-rolled fake drives the tests, and
/// only the real [FirestoreAuthoredProductsSource] imports a live `cloud_firestore`.
///
/// NOTE: there is deliberately NO `delete` — deletion is a tombstone `set`
/// (R1-9), so the seam offers no hard-delete to misuse.
abstract class AuthoredProductsSource implements PagedSource {
  /// Fetch the single `catalogProducts/{sku}` doc, or null when it is missing.
  /// A tombstoned (archived) doc still EXISTS (soft-delete), so this returns it —
  /// the caller decides whether an `active:false` product is relevant.
  Future<RemoteDoc?> get(String sku);

  /// Create-or-MERGE the `catalogProducts/{sku}` doc with [data]. Merge semantics
  /// (not overwrite) so a partial write — e.g. the tombstone `{active:false,…}` —
  /// keeps the product's existing fields, and a re-[upsert] by the natural SKU key
  /// is idempotent.
  Future<void> set(String sku, Map<String, dynamic> data);

  /// Write the role-scoped PRICE doc `catalogProducts/{sku}/pricing/{audience}`
  /// (R1-6). Kept OUT of [set] on purpose: the public doc must never carry a
  /// price. Merge semantics so a price update never clears sibling audiences.
  Future<void> setPricing(
    String sku,
    String audience,
    Map<String, dynamic> data,
  );
}

/// Studio Pillar 5 · Step 61 (R2-9) — the STAGING seam for the OFF-by-default
/// catalog seed importer.
///
/// Kept SEPARATE from [AuthoredProductsSource] (the browse/point seam) so the
/// one-shot dev/emulator seed path does NOT widen the read seam every consumer
/// implements — the real [FirestoreAuthoredProductsSource] implements BOTH, while a
/// hand-rolled fake drives the seed test Firebase-free and the step-60 browse fake
/// stays untouched. Speaks only neutral [RemoteDoc]s + plain field-maps.
///
/// The R2-9 invariant this seam exists to make possible: a bulk import NEVER writes
/// straight to the live `catalogProducts` collection. It [stagePending]s every row
/// into a `catalogPending/{batchId}` DRAFT, records progress via [setPendingMeta] (a
/// resumable cursor), and only AFTER the whole batch is staged does the importer
/// read it back ([pendingItems]) and [setLive] each row — so a mid-batch abort can
/// never leave a half-public catalog.
abstract class CatalogSeedSink {
  /// Stage one product into the pending DRAFT
  /// (`catalogPending/{batchId}/items/{sku}`) — never the live collection. Merge
  /// semantics; doc-id = SKU ⇒ idempotent.
  Future<void> stagePending(
    String batchId,
    String sku,
    Map<String, dynamic> data,
  );

  /// The pending batch META doc (`catalogPending/{batchId}`) — carries the resume
  /// `cursor`, the `complete` flag (written LAST), and the `aborted` flag. Null when
  /// the batch has never been staged.
  Future<RemoteDoc?> pendingMeta(String batchId);

  /// Merge the pending batch META (progress cursor / complete / aborted).
  Future<void> setPendingMeta(String batchId, Map<String, dynamic> data);

  /// Every staged item of the batch — the source the flip publishes to live.
  Future<List<RemoteDoc>> pendingItems(String batchId);

  /// The FLIP write — publish one fully-staged product to the LIVE
  /// `catalogProducts/{sku}`. Reached ONLY after the batch's `complete` flag is set.
  Future<void> setLive(String sku, Map<String, dynamic> data);
}

/// The REAL Firestore adapter for the catalog seam. Resolves
/// `FirebaseFirestore.instance` LAZILY (never in the constructor — a `const` ctor
/// with a nullable injected instance), so constructing the repo does not require
/// Firebase; the instance is touched only on the first read/write. Maps a live
/// `QueryDocumentSnapshot` down to a neutral [RemoteDoc] for the paged helper.
///
/// The [Cursor] → Firestore translation lives HERE and NOWHERE else: [page]
/// resumes with `startAfter([sortValue, docId])` — a VALUE-based cursor, never an
/// `offset` (which would pay to read+skip every preceding page) and never a
/// `startAfterDocument` (the neutral [Cursor] carries no `DocumentSnapshot`, by
/// design, to keep the seam Firebase-free). The trailing doc-id in the cursor
/// tuple disambiguates ties on `nameHe`, so paging never skips or duplicates a row.
class FirestoreAuthoredProductsSource
    implements AuthoredProductsSource, CatalogSeedSink {
  /// [firestore] is injectable (DI/tests); null ⇒ the singleton is resolved
  /// lazily on first use. [tradeId] optionally scopes browse to one Pillar-2
  /// trade (index #8 — `tradeId ASC, nameHe ASC`); empty (default) pages the whole
  /// active catalog. `const` so the repo's default source is a compile-time const.
  const FirestoreAuthoredProductsSource({
    FirebaseFirestore? firestore,
    String tradeId = '',
  })  : _injected = firestore,
        _tradeId = tradeId;

  final FirebaseFirestore? _injected;
  final String _tradeId;

  /// The order-by field for browse — `nameHe` (index #8/#9). The [Cursor]'s
  /// `sortValue` carries this field's value for the last row of the previous page.
  static const String _orderField = 'nameHe';

  FirebaseFirestore get _db => _injected ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirebaseAuthoredProductsRepository.kCollection);

  /// A real backend always PAGES (never a single local page).
  @override
  bool get isSinglePage => false;

  @override
  Future<List<RemoteDoc>> page({required int limit, Cursor? after}) async {
    // Filter tombstones server-side (R1-9): `active == true` — a doc MISSING the
    // field is (correctly) excluded, which is why [toDoc] always stamps `active`.
    var q = _col.where('active', isEqualTo: true);
    if (_tradeId.isNotEmpty) {
      q = q.where('tradeId', isEqualTo: _tradeId);
    }
    // Order by nameHe, doc-id-tiebroken (index #8/#9) so the cursor is total.
    q = q.orderBy(_orderField).orderBy(FieldPath.documentId);
    if (after != null) {
      // Cursor → startAfter: VALUE-based ([sortValue, docId]) — NEVER `offset`,
      // NEVER `startAfterDocument`. The tuple matches the (nameHe, id) order above,
      // so resumption is exact even when several products share a `nameHe`.
      q = q.startAfter(<Object?>[after.sortValue, after.lastDocId]);
    }
    final snap = await q.limit(limit).get();
    return snap.docs
        .map((d) => RemoteDoc(d.id, d.data()))
        .toList(growable: false);
  }

  @override
  Future<RemoteDoc?> get(String sku) async {
    final snap = await _col.doc(sku).get();
    final data = snap.data();
    return data == null ? null : RemoteDoc(snap.id, data);
  }

  @override
  Future<void> set(String sku, Map<String, dynamic> data) =>
      _col.doc(sku).set(data, SetOptions(merge: true));

  @override
  Future<void> setPricing(
    String sku,
    String audience,
    Map<String, dynamic> data,
  ) =>
      _col
          .doc(sku)
          .collection('pricing')
          .doc(audience)
          .set(data, SetOptions(merge: true));

  // ── Step 61 (R2-9): the staging-batch writes ────────────────────────────────

  /// The `catalogPending` staging collection (a SIBLING of `catalogProducts`, never
  /// touched on a normal build — only the dev/emulator seed importer writes here).
  CollectionReference<Map<String, dynamic>> get _pending =>
      _db.collection(FirebaseAuthoredProductsRepository.kPendingCollection);

  /// The staged-items sub-collection of one batch (`catalogPending/{batchId}/items`).
  CollectionReference<Map<String, dynamic>> _pendingItemsCol(String batchId) =>
      _pending.doc(batchId).collection('items');

  @override
  Future<void> stagePending(
    String batchId,
    String sku,
    Map<String, dynamic> data,
  ) =>
      _pendingItemsCol(batchId).doc(sku).set(data, SetOptions(merge: true));

  @override
  Future<RemoteDoc?> pendingMeta(String batchId) async {
    final snap = await _pending.doc(batchId).get();
    final data = snap.data();
    return data == null ? null : RemoteDoc(snap.id, data);
  }

  @override
  Future<void> setPendingMeta(String batchId, Map<String, dynamic> data) =>
      _pending.doc(batchId).set(data, SetOptions(merge: true));

  @override
  Future<List<RemoteDoc>> pendingItems(String batchId) async {
    final snap = await _pendingItemsCol(batchId).get();
    return snap.docs
        .map((d) => RemoteDoc(d.id, d.data()))
        .toList(growable: false);
  }

  @override
  Future<void> setLive(String sku, Map<String, dynamic> data) =>
      _col.doc(sku).set(data, SetOptions(merge: true));
}

/// The Firestore-backed catalog access layer (Step 60). Holds a neutral
/// [AuthoredProductsSource]; the mapper + the archive/price shapes are pure, so the
/// whole surface is driven by a fake in tests. NOT a [ChangeNotifier] and NOT a
/// whole-collection cache: browse is a PULLED page, not a listen (§1.6).
class FirebaseAuthoredProductsRepository {
  /// Pass [source] in tests to drive every path with a fake; the default is the
  /// real lazy Firestore adapter (dormant until a provider wires this repo).
  /// [seedSink] (Step 61) is the staging sink for the OFF-by-default seed importer —
  /// injected as a fake in the seed test; the default is the same lazy Firestore
  /// adapter, never touched unless [seedCatalog] actually runs.
  FirebaseAuthoredProductsRepository({
    AuthoredProductsSource? source,
    CatalogSeedSink? seedSink,
  })  : _source = source ?? const FirestoreAuthoredProductsSource(),
        _seedSink = seedSink ?? const FirestoreAuthoredProductsSource();

  final AuthoredProductsSource _source;

  /// Step 61 — the OFF-by-default seed importer's staging sink (R2-9). The default
  /// lazy Firestore adapter resolves Firebase only when [seedCatalog] runs, so
  /// merely constructing the repo (a provider read) never requires Firebase and the
  /// shipped build stays dormant.
  final CatalogSeedSink _seedSink;

  /// The real collection name — SKU is the doc-id (natural key).
  static const String kCollection = 'catalogProducts';

  /// Step 61 — the STAGING collection the seed importer drafts into before the flip
  /// to [kCollection] (R2-9). A batch lives at `catalogPending/{batchId}`, its rows
  /// at `catalogPending/{batchId}/items/{sku}`.
  static const String kPendingCollection = 'catalogPending';

  /// The default seed batch id — one canonical dev/emulator seed run.
  static const String kDefaultSeedBatch = 'seed';

  /// Browse page size — the [PagedQuery] hard cap (40); no page ever asks the
  /// backend for more (§6 cost guardrail).
  static const int pageSize = PagedQuery.maxLimit;

  /// The `replacedBy` chain [resolveReplacement] follows, depth-capped so a long
  /// (or adversarial) chain can never spin — paired with the visited-set cycle
  /// guard (R1-9, addition-b).
  static const int maxReplacementDepth = 8;

  // ── mapper (pure — no I/O; the round-trip the tests pin) ─────────────────────

  /// doc-id = `product.sku` (the natural key → idempotent upsert).
  String idOf(LipskeyCatalogProduct value) => value.sku;

  /// `LipskeyCatalogProduct` → the PUBLIC `catalogProducts/{sku}` field-map.
  ///
  /// The base product fields are always written; the nullable model fields
  /// (`color`/`qtyPack`/`dims`/images…) are written only when present, so a
  /// sparse product round-trips unchanged. The SERVER/SCALE fields
  /// ([tradeId]/[version]/[updatedAt]/[nameTokens]) are written ONLY when non-empty
  /// — the `orders_firebase.dart:70` guarded-field idiom.
  ///
  /// `active` is ALWAYS stamped (default true): the browse query filters
  /// `active == true`, and Firestore excludes docs MISSING the field, so a live
  /// product must carry it explicitly.
  ///
  /// `price` is DELIBERATELY ABSENT (R1-6) — it lives only in the role-scoped
  /// `pricing/{audience}` sub-doc ([setPrice]); the public doc is world-readable
  /// without it. `nameTokens` is normally omitted too: the step-63 Admin-SDK
  /// indexer OWNS it (derived from `nameHe`); the client never fabricates tokens
  /// (governance #84) — the guarded param exists only so a caller that already has
  /// them can pass them, and an empty list writes nothing.
  Map<String, dynamic> toDoc(
    LipskeyCatalogProduct p, {
    String tradeId = '',
    bool active = true,
    int version = 0,
    String updatedAt = '',
    List<String> nameTokens = const [],
  }) =>
      <String, dynamic>{
        'sku': p.sku,
        'nameHe': p.nameHe,
        'nameEn': p.nameEn,
        'brand': p.brand,
        'categoryHe': p.categoryHe,
        'categoryEn': p.categoryEn,
        'categoryEmoji': p.categoryEmoji,
        'page': p.page,
        'active': active,
        if (p.color != null) 'color': p.color,
        if (p.qtyPack != null) 'qtyPack': p.qtyPack,
        if (p.qtyPallet != null) 'qtyPallet': p.qtyPallet,
        if (p.dims != null) 'dims': p.dims,
        if (p.imageFile != null) 'imageFile': p.imageFile,
        if (p.imageFiles != null && p.imageFiles!.isNotEmpty)
          'imageFiles': p.imageFiles,
        if (p.specImageFile != null) 'specImageFile': p.specImageFile,
        if (p.specImageFiles != null && p.specImageFiles!.isNotEmpty)
          'specImageFiles': p.specImageFiles,
        // Server/scale fields — guarded (orders_firebase:70), so pre-scale docs
        // round-trip unchanged and the server `nameTokens` is never clobbered.
        if (tradeId.isNotEmpty) 'tradeId': tradeId,
        if (version > 0) 'version': version,
        if (updatedAt.isNotEmpty) 'updatedAt': updatedAt,
        if (nameTokens.isNotEmpty) 'nameTokens': nameTokens,
        // 'price' is intentionally NOT here — R1-6 (see [setPrice]).
      };

  /// PUBLIC `catalogProducts/{sku}` doc → `LipskeyCatalogProduct`. Inverse of
  /// [toDoc]. TOLERANT: every field null-falls-back to the model's default, so a
  /// malformed / partial doc decodes to a sane product rather than THROWING — the
  /// paged path maps a page without a per-doc skip-guard, so a throwing mapper
  /// would tear the whole page (the R2-7 "never brick" spirit, applied to browse).
  /// The server/scale fields (`tradeId`/`active`/`version`/`nameTokens`) are NOT on
  /// the model (which is unchanged), so they are read-and-ignored here.
  LipskeyCatalogProduct fromDoc(RemoteDoc doc) {
    final j = doc.data;
    return LipskeyCatalogProduct(
      sku: (j['sku'] as String?) ?? doc.id,
      nameHe: (j['nameHe'] as String?) ?? '',
      nameEn: (j['nameEn'] as String?) ?? '',
      color: j['color'] as String?,
      qtyPack: (j['qtyPack'] as num?)?.toInt(),
      qtyPallet: (j['qtyPallet'] as num?)?.toInt(),
      categoryHe: (j['categoryHe'] as String?) ?? '',
      categoryEn: (j['categoryEn'] as String?) ?? '',
      categoryEmoji: (j['categoryEmoji'] as String?) ?? '',
      page: (j['page'] as num?)?.toInt() ?? 0,
      dims: (j['dims'] as Map?)?.cast<String, dynamic>(),
      imageFile: j['imageFile'] as String?,
      imageFiles: (j['imageFiles'] as List?)?.cast<String>(),
      specImageFile: j['specImageFile'] as String?,
      specImageFiles: (j['specImageFiles'] as List?)?.cast<String>(),
      brand: (j['brand'] as String?) ?? 'ליפסקי',
    );
  }

  /// The role-scoped PRICE sub-doc shape (R1-6) — the ONLY place a price lives.
  /// Written to `catalogProducts/{sku}/pricing/{audience}` by [setPrice]; read is
  /// claim-gated (`isManager() || hasRole(audience)`, step 65).
  static Map<String, dynamic> pricingDoc({
    required int price,
    String currency = 'ILS',
    String updatedAt = '',
    String updatedBy = '',
  }) =>
      <String, dynamic>{
        'price': price,
        'currency': currency,
        if (updatedAt.isNotEmpty) 'updatedAt': updatedAt,
        if (updatedBy.isNotEmpty) 'updatedBy': updatedBy,
      };

  /// The TOMBSTONE merge-shape (R1-9) — `active:false` (drops it from browse) +
  /// `tombstone:true`, plus an optional `replacedBy` pointer + `tombstonedAt`. A
  /// `set(merge)` of this, NOT a delete, so the doc survives for the step-63
  /// fan-out to clean its `nameTokens`/`catalogTokenFreq` — no orphan id.
  static Map<String, dynamic> tombstoneDoc({
    String replacedBy = '',
    String tombstonedAt = '',
  }) =>
      <String, dynamic>{
        'active': false,
        'tombstone': true,
        if (tombstonedAt.isNotEmpty) 'tombstonedAt': tombstonedAt,
        if (replacedBy.isNotEmpty) 'replacedBy': replacedBy,
      };

  // ── browse (paged — the whole point) ─────────────────────────────────────────

  /// Fetch one browse PAGE, resuming AFTER [after] (null = the first page).
  /// Filters `active == true` (tombstones excluded, R1-9) and orders by `nameHe`.
  /// Returns a [PagedResult] whose [PagedResult.cursor] threads into the next call
  /// and whose [PagedResult.hasMore] drives the sentinel footer (twin of `capped`,
  /// `catalog_screen.dart:2267`). [limit] is clamped to [pageSize] (40) by the
  /// helper. This is a PULL — never a whole-collection listen (§1.6).
  Future<PagedResult<LipskeyCatalogProduct>> browse({
    Cursor? after,
    int limit = pageSize,
  }) {
    final query = PagedQuery<LipskeyCatalogProduct>(
      source: _source,
      fromDoc: fromDoc,
      // The cursor's sort value = the row's `nameHe` (the order-by field); the
      // real adapter feeds it back as `startAfter([nameHe, id])`.
      sortValueOf: (doc) => doc.data['nameHe'] ?? doc.id,
      limit: limit,
    );
    return query.page(after: after);
  }

  /// The single product with this [sku] — a SINGLE `get` (doc-id = SKU), not a
  /// query. Returns null when the doc is missing. A tombstoned product still
  /// resolves (soft-delete), so a caller can surface its `replacedBy`.
  Future<LipskeyCatalogProduct?> productForSku(String sku) async {
    final doc = await _source.get(sku);
    return doc == null ? null : fromDoc(doc);
  }

  // ── writes (guarded — a failure is logged, never thrown into the UI) ─────────

  /// Idempotent upsert of [p] (doc-id = its SKU) into the PUBLIC collection. The
  /// price is NOT written here (R1-6 — use [setPrice]). Guarded: a write failure
  /// is swallowed + logged, never thrown.
  Future<void> upsert(
    LipskeyCatalogProduct p, {
    String tradeId = '',
    int version = 0,
    String updatedAt = '',
  }) =>
      _guard(
        () => _source.set(
          idOf(p),
          toDoc(p, tradeId: tradeId, version: version, updatedAt: updatedAt),
        ),
      );

  /// Write the role-scoped price for [sku] × [audience] to the `pricing/{audience}`
  /// sub-doc (R1-6) — NEVER the public doc. Guarded.
  Future<void> setPrice(
    String sku,
    String audience, {
    required int price,
    String currency = 'ILS',
    String updatedAt = '',
    String updatedBy = '',
  }) =>
      _guard(
        () => _source.setPricing(
          sku,
          audience,
          pricingDoc(
            price: price,
            currency: currency,
            updatedAt: updatedAt,
            updatedBy: updatedBy,
          ),
        ),
      );

  /// ARCHIVE [sku] — a TOMBSTONE `set` (`active:false` + `tombstone:true`, optional
  /// [replacedBy]), NOT a hard delete (R1-9). The doc survives (still gettable) for
  /// the step-63 fan-out to clean its references. Guarded.
  Future<void> archive(
    String sku, {
    String replacedBy = '',
    String tombstonedAt = '',
  }) =>
      _guard(
        () => _source.set(
          sku,
          tombstoneDoc(replacedBy: replacedBy, tombstonedAt: tombstonedAt),
        ),
      );

  // ── replacement resolver (R1-9, addition-b — cycle-guard + depth cap) ────────

  /// Follow the `replacedBy` chain from [sku] to the product that supersedes it,
  /// returning the terminal (non-replaced / missing) SKU. A visited-set CYCLE
  /// GUARD breaks an A→B→A loop (returns the current link rather than spinning),
  /// and [maxReplacementDepth] caps a long chain. Each hop is a single [get].
  Future<String> resolveReplacement(String sku) async {
    final visited = <String>{sku};
    var current = sku;
    for (var depth = 0; depth < maxReplacementDepth; depth++) {
      final doc = await _source.get(current);
      if (doc == null) return current; // missing → this is as far as it goes
      final next = (doc.data['replacedBy'] as String?) ?? '';
      if (next.isEmpty) return current; // terminal — a live (non-replaced) product
      if (!visited.add(next)) return current; // cycle — stop at the current link
      current = next;
    }
    return current; // depth cap reached — return the deepest link reached
  }

  // ── seed importer (Step 61 · R2-9 — stage-to-pending, flip-on-FULL-success) ──

  /// OFF-by-default bulk seed of [products] into the catalog. Dev/emulator ONLY —
  /// PROD NEVER auto-seeds: when the backend is live ([live]) and the deliberate
  /// [seedFresh] opt-in is off, this SHORT-CIRCUITS to [SeedStatus.skipped] having
  /// written NOTHING (honest-empty — real backend data is never shadowed by a demo
  /// seed). This is the injectable twin of the `pushCacheToRemote` guard
  /// (`firestore_cached_repo.dart:328`, `useFirebaseBackend && !kSeedFreshBackend`):
  /// [live]/[seedFresh] default to the live globals, and a define-less test drives
  /// the ON branch by passing them explicitly (the `serverCallables` testability
  /// idiom). With [live] false (the shipped/test default) the seed runs against the
  /// injected sink exactly as before — byte-identical to today.
  ///
  /// R2-9 safety (a mid-batch abort must never leave a HALF-PUBLIC catalog):
  ///   • STAGE-TO-PENDING — every row is written to `catalogPending/{batchId}` (a
  ///     DRAFT), never straight to the live collection.
  ///   • FLIP-ON-FULL-SUCCESS — the `complete` flag is written LAST; only then are
  ///     the staged rows published to live [kCollection]. An abort BEFORE complete
  ///     leaves the live catalog exactly as it was.
  ///   • RESUMABLE CURSOR — progress is saved after EVERY row, so a re-run resumes
  ///     from the last staged SKU rather than restarting from zero.
  ///   • TOMBSTONE PARTIALS — an aborted batch is marked `aborted:true` (not left
  ///     half-live) and can be resumed or cleaned.
  /// doc-id = SKU ⇒ the whole path is idempotent (a double run publishes ONE row
  /// per SKU, never duplicates).
  ///
  /// [onStaged] is a TEST SEAM only: invoked after each row is staged (with the
  /// running count); throwing from it simulates a mid-batch failure so the abort
  /// path is covered without a real backend.
  Future<SeedOutcome> seedCatalog(
    List<LipskeyCatalogProduct> products, {
    String batchId = kDefaultSeedBatch,
    bool? live,
    bool? seedFresh,
    Future<void> Function(int stagedSoFar)? onStaged,
  }) async {
    final isLive = live ?? useFirebaseBackend;
    final optedIn = seedFresh ?? kSeedFreshBackend;
    // R2-9 / S1 gate: a live backend never auto-seeds — honest-empty, ZERO writes.
    if (isLive && !optedIn) return const SeedOutcome.skipped();

    // A batch already fully staged in a prior run just (re-)flips — idempotent.
    final meta = await _seedSink.pendingMeta(batchId);
    if (meta?.data['complete'] == true) return _flip(batchId);

    // Resume: skip everything at or before the saved cursor (SKU order is total).
    final resumeAfter = (meta?.data['cursor'] as String?) ?? '';
    final ordered = [...products]..sort((a, b) => a.sku.compareTo(b.sku));

    var staged = 0;
    var lastSku = resumeAfter;
    try {
      for (final p in ordered) {
        if (resumeAfter.isNotEmpty && p.sku.compareTo(resumeAfter) <= 0) {
          continue; // already staged in a prior run — resume past it
        }
        await _seedSink.stagePending(batchId, p.sku, toDoc(p));
        lastSku = p.sku;
        staged++;
        // Persist progress AFTER the row (a crash here ⇒ resume from lastSku).
        await _seedSink.setPendingMeta(
          batchId,
          <String, dynamic>{'cursor': lastSku, 'aborted': false},
        );
        if (onStaged != null) await onStaged(staged);
      }
    } on Object catch (e) {
      // R2-9: mark the batch aborted + keep the cursor, and DO NOT flip — the live
      // catalog is untouched (staging never wrote to it), so no half-public catalog.
      await _guard(
        () => _seedSink.setPendingMeta(
          batchId,
          <String, dynamic>{'aborted': true, 'cursor': lastSku},
        ),
      );
      debugPrint('seedCatalog: aborted mid-batch at "$lastSku" (ignored): $e');
      return SeedOutcome.aborted(staged: staged, cursor: lastSku);
    }

    // Full success — the complete flag is written LAST, gating the flip.
    await _seedSink.setPendingMeta(
      batchId,
      <String, dynamic>{'complete': true, 'aborted': false},
    );
    return _flip(batchId);
  }

  /// Publish a fully-staged batch to the live collection — ONLY when its `complete`
  /// flag is set (defense-in-depth: an incomplete batch never flips). Each staged
  /// row is [CatalogSeedSink.setLive]'d by its SKU doc-id, so the flip is idempotent.
  Future<SeedOutcome> _flip(String batchId) async {
    final meta = await _seedSink.pendingMeta(batchId);
    if (meta?.data['complete'] != true) {
      return const SeedOutcome.aborted(staged: 0, cursor: '');
    }
    final items = await _seedSink.pendingItems(batchId);
    for (final it in items) {
      await _seedSink.setLive(it.id, it.data);
    }
    return SeedOutcome.flipped(count: items.length);
  }

  /// Run a background remote write, swallowing + logging any failure — a write
  /// (offline / rules rejection) must never throw into the UI. Returns the guarded
  /// future so a caller/test may await settling.
  Future<void> _guard(Future<void> Function() write) async {
    try {
      await write();
    } on Object catch (e) {
      debugPrint('FirebaseAuthoredProductsRepository: write failed (ignored): $e');
    }
  }
}

/// The three terminal outcomes of [FirebaseAuthoredProductsRepository.seedCatalog]
/// (Step 61).
enum SeedStatus {
  /// The honest-empty gate fired — a live backend without the `seedFresh` opt-in.
  /// NOTHING was staged or flipped (real data is never shadowed by a demo seed).
  skipped,

  /// The batch staged fully, the `complete` flag was set, and every row was
  /// published to the live catalog.
  flipped,

  /// The batch aborted mid-stage — the live catalog is UNCHANGED and the pending
  /// batch is marked `aborted` with a resume [SeedOutcome.cursor].
  aborted,
}

/// The immutable result of a seed run (Step 61).
@immutable
class SeedOutcome {
  const SeedOutcome._(
    this.status, {
    this.count = 0,
    this.staged = 0,
    this.cursor = '',
  });

  /// The honest-empty gate fired — zero writes.
  const SeedOutcome.skipped() : this._(SeedStatus.skipped);

  /// [count] rows were published to the live catalog.
  const SeedOutcome.flipped({required int count})
      : this._(SeedStatus.flipped, count: count);

  /// [staged] rows were staged before the abort; [cursor] is the resume point.
  const SeedOutcome.aborted({required int staged, required String cursor})
      : this._(SeedStatus.aborted, staged: staged, cursor: cursor);

  final SeedStatus status;

  /// Rows published to live (meaningful only for [SeedStatus.flipped]).
  final int count;

  /// Rows staged before an abort (meaningful only for [SeedStatus.aborted]).
  final int staged;

  /// The resume cursor after an abort — the last staged SKU.
  final String cursor;
}
