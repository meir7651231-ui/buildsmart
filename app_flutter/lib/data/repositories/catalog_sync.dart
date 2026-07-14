// CATALOG SYNC GATE (SPEC-catalog-to-server · C1.6 — the download-once cache).
//
// The cache pattern the whole migration rests on: the catalog (+ the slice) is pulled
// ONCE, persisted locally, and re-synced ONLY when the server's version changes. So a
// second app-open re-downloads NOTHING (0 catalog fetches) — it serves the persisted
// copy — and a price/product change (a new version) triggers exactly one re-sync.
//
// The gate is storage-agnostic: it persists through a tiny [CatalogKvStore] seam (a
// fake map in tests; SharedPreferences/Hive in prod, wired at the 1-B cutover) and
// pulls through injected `readServerVersion` (a cheap meta read) + `fetchAll` (the
// paged browse). Item (de)serialisation reuses the repo's `toDoc`/`fromDoc`.
//
// GATING: referenced only by the gated seam + tests → tree-shakes out of OFF.

import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteDoc;

/// A minimal persistent string KV — the only two ops the gate needs. A fake map in
/// tests; a SharedPreferences/Hive adapter in prod (added at 1-B).
abstract class CatalogKvStore {
  String? read(String key);
  Future<void> write(String key, String value);
}

/// Decides, on each open, whether to serve the persisted catalog or re-sync from the
/// server — by comparing the server's catalog VERSION to the last-synced one.
class CatalogSyncGate {
  CatalogSyncGate({
    required this.kv,
    required this.readServerVersion,
    required this.fetchAll,
    required this.toDoc,
    required this.fromDoc,
    this.bundledFallback,
  });

  /// C5.5 — the LAST resort: the bundled const catalog. When the server is down AND
  /// there is no cache (a cold offline start), the app serves this instead of
  /// bricking — server → cache → bundled, never a blank screen. Null ⇒ the old
  /// behaviour (surface the error). In prod this is `() => kCatalogProducts`.
  final List<LipskeyCatalogProduct> Function()? bundledFallback;

  /// The persistence seam.
  final CatalogKvStore kv;

  /// A CHEAP freshness read — the `catalog_meta/version` doc (one tiny field), NOT the
  /// whole catalog. Returns the server's current catalog version tag.
  final Future<String> Function() readServerVersion;

  /// The EXPENSIVE read — the paged browse of the whole (slice) catalog. Called ONLY
  /// on a first open or a version change.
  final Future<List<LipskeyCatalogProduct>> Function() fetchAll;

  /// Reused from `FirebaseAuthoredProductsRepository` — the same doc shape everywhere.
  final Map<String, dynamic> Function(LipskeyCatalogProduct) toDoc;
  final LipskeyCatalogProduct Function(RemoteDoc) fromDoc;

  static const String kVersionKey = 'catalog.syncedVersion';
  static const String kItemsKey = 'catalog.items';

  /// How many times [open] ran the EXPENSIVE [fetchAll] — the C1.6 metric (0 on an
  /// unchanged second open).
  int fetchAllCalls = 0;

  /// Open the catalog. Serves the persisted copy with ZERO catalog fetches when the
  /// server version is unchanged (C1.6) OR when the network is down (C1.10 — a stale
  /// cache beats a blank screen); re-syncs exactly once on a first open or a version
  /// bump (C1.9). A cold start with no network + no cache is the only case that
  /// surfaces the error (there is genuinely nothing to show).
  Future<List<LipskeyCatalogProduct>> open() async {
    final cached = kv.read(kItemsKey);
    final syncedVersion = kv.read(kVersionKey);

    // The cheap freshness read — null if offline (we then can't verify freshness).
    String? serverVersion;
    try {
      serverVersion = await readServerVersion();
    } on Object {
      serverVersion = null;
    }

    // Unchanged, or offline-but-cached → the local copy, ZERO catalog fetches.
    if (cached != null &&
        (serverVersion == null || serverVersion == syncedVersion)) {
      return _decode(cached);
    }

    // First open or a version bump → one re-sync, then persist.
    try {
      final items = await fetchAll();
      fetchAllCalls++;
      await kv.write(kItemsKey, _encode(items));
      if (serverVersion != null) await kv.write(kVersionKey, serverVersion);
      return items;
    } on Object {
      // The fetch failed (dropped mid-open). Fallback chain (C5.5): a stale cache
      // beats a blank screen; failing that, the bundled catalog beats bricking.
      if (cached != null) return _decode(cached);
      final bundled = bundledFallback;
      if (bundled != null) return bundled(); // server↓ + no cache → bundled
      rethrow; // no cache + no bundled fallback — nothing to serve, surface it.
    }
  }

  String _encode(List<LipskeyCatalogProduct> items) =>
      jsonEncode(<Map<String, dynamic>>[for (final p in items) toDoc(p)]);

  List<LipskeyCatalogProduct> _decode(String raw) {
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return <LipskeyCatalogProduct>[
      for (final j in list) fromDoc(RemoteDoc((j['sku'] as String?) ?? '', j)),
    ];
  }
}
