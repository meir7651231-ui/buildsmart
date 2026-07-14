// C1.6 + C1.10 — the download-once cache gate (SPEC-catalog-to-server).
//
// C1.6: a first open fetches + persists; a SECOND open (app restart, unchanged
// server) re-downloads NOTHING (0 catalog fetches) — it serves the persisted copy; a
// server VERSION bump triggers exactly one re-sync (the C1.9 mechanism).
// C1.10: OFFLINE (the reads throw) with a cache → the app still works from the cache;
// a cold start with no cache + no network is the only case that surfaces the error.
//
// Fakes only — the KV is an in-memory map, `fetchAll`/`readServerVersion` are counting
// closures. toDoc/fromDoc are the real repo mappers (pure, no Firebase).

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/repositories/authored_products_firebase.dart'
    show FirebaseAuthoredProductsRepository;
import 'package:buildsmart/data/repositories/catalog_slice.dart';
import 'package:buildsmart/data/repositories/catalog_sync.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeKv implements CatalogKvStore {
  final Map<String, String> m = {};

  @override
  String? read(String key) => m[key];

  @override
  Future<void> write(String key, String value) async {
    m[key] = value;
  }
}

/// A shared fake "server" — a mutable version + a catalog-fetch counter — with a
/// factory that builds fresh [CatalogSyncGate]s (a new app-open) over one persistent
/// [kv].
class _Backend {
  _Backend(this.kv);
  final _FakeKv kv;
  final FirebaseAuthoredProductsRepository repo =
      FirebaseAuthoredProductsRepository();

  String version = 'v1';
  int catalogFetches = 0;
  bool online = true;

  Future<String> _readVersion() async {
    if (!online) throw StateError('offline');
    return version;
  }

  Future<List<LipskeyCatalogProduct>> _fetchAll() async {
    if (!online) throw StateError('offline');
    catalogFetches++;
    return c1SliceProducts();
  }

  CatalogSyncGate openGate({List<LipskeyCatalogProduct> Function()? bundled}) =>
      CatalogSyncGate(
        kv: kv,
        readServerVersion: _readVersion,
        fetchAll: _fetchAll,
        toDoc: repo.toDoc,
        fromDoc: repo.fromDoc,
        bundledFallback: bundled,
      );
}

void main() {
  test('C1.6 — open 1 fetches + persists; open 2 (unchanged) = 0 catalog fetches',
      () async {
    final b = _Backend(_FakeKv());

    final g1 = b.openGate();
    final items1 = await g1.open();
    expect(items1, hasLength(20));
    expect(g1.fetchAllCalls, 1);
    expect(b.catalogFetches, 1);

    // App restart (new gate, same persistent kv), nothing changed on the server.
    final g2 = b.openGate();
    final items2 = await g2.open();
    expect(items2, hasLength(20));
    expect(g2.fetchAllCalls, 0, reason: 'second open serves the local cache');
    expect(b.catalogFetches, 1, reason: 'the catalog was NOT re-downloaded');
    expect(items2.map((p) => p.sku).toSet(), kC1SliceSkus.toSet());
  });

  test('C1.6/C1.9 — a server version bump triggers exactly one re-sync', () async {
    final b = _Backend(_FakeKv());

    await b.openGate().open(); // v1 → fetch
    await b.openGate().open(); // v1 → cache
    expect(b.catalogFetches, 1);

    b.version = 'v2'; // a product / price changed on the server → new version tag
    final g = b.openGate();
    await g.open();
    expect(g.fetchAllCalls, 1, reason: 'a version bump re-syncs — no app release');
    expect(b.catalogFetches, 2);

    await b.openGate().open(); // v2 → cache again
    expect(b.catalogFetches, 2);
  });

  test('C1.10 — OFFLINE with a warm cache → works from cache, 0 fetches', () async {
    final b = _Backend(_FakeKv());
    await b.openGate().open(); // warm the cache online
    expect(b.catalogFetches, 1);

    b.online = false; // airplane mode — both reads throw
    final g = b.openGate();
    final items = await g.open();

    expect(items, hasLength(20), reason: 'served from the persisted cache offline');
    expect(g.fetchAllCalls, 0);
    expect(b.catalogFetches, 1, reason: 'no network hit while offline');
  });

  test('C1.10 — cold start OFFLINE with NO cache → surfaces the error (honest)',
      () async {
    final b = _Backend(_FakeKv())..online = false;
    expect(b.openGate().open(), throwsA(isA<StateError>()));
  });

  test('C5.5 — cold OFFLINE + no cache BUT a bundled fallback → serves bundled '
      '(never bricks)', () async {
    final b = _Backend(_FakeKv())..online = false; // kill-server
    final bundled = c1SliceProducts();
    final items = await b.openGate(bundled: () => bundled).open();
    expect(items, hasLength(20), reason: 'server↓ + no cache → the bundled catalog');
    expect(b.catalogFetches, 0);
  });

  test('C5.5 — the fallback chain: server → cache → bundled (each level covers)',
      () async {
    final b = _Backend(_FakeKv());
    final bundled = c1SliceProducts();

    // 1) server up → server (and caches).
    await b.openGate(bundled: () => bundled).open();
    expect(b.catalogFetches, 1);

    // 2) server down, cache warm → cache (0 fetch), bundled untouched.
    b.online = false;
    final cached = await b.openGate(bundled: () => bundled).open();
    expect(cached, hasLength(20));
    expect(b.catalogFetches, 1);

    // 3) server down, cache wiped → bundled.
    b.kv.m.clear();
    final fell = await b.openGate(bundled: () => bundled).open();
    expect(fell, hasLength(20));
    expect(b.catalogFetches, 1, reason: 'never hit the dead server');
  });
}
