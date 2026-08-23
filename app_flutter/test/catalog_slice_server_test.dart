// C1.5 — the app pulls the SLICE from the server (SPEC-catalog-to-server).
//
// Seeds a fake authored source with the 20 slice docs (via `toDoc` — the same shape
// the C1.2 migration writes), then drains `CatalogPagedBrowse.paged` (the SERVER
// path) and proves the 20 come back as `LipskeyCatalogProduct`s equal to the bundled
// slice. This is the "app shows 20 from server" DoD, test-backed (decision 1-A):
// nothing production-wired yet (the engine cutover is C2) — the browse seam yields the
// slice from a fake Firestore. Fake source — no Firebase.

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/paged_query.dart' show Cursor;
import 'package:buildsmart/data/repositories/authored_products_firebase.dart';
import 'package:buildsmart/data/repositories/catalog_paged.dart';
import 'package:buildsmart/data/repositories/catalog_slice.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteDoc;
import 'package:flutter_test/flutter_test.dart';

/// A hand-rolled fake [AuthoredProductsSource] — an in-memory `sku → field-map` store
/// that slices paged reads by cursor (the `catalog_paged_test` idiom).
class _FakeAuthoredSource implements AuthoredProductsSource {
  final Map<String, Map<String, dynamic>> docs = {};
  int pageCalls = 0;

  @override
  bool get isSinglePage => false;

  @override
  Future<List<RemoteDoc>> page({required int limit, Cursor? after}) async {
    pageCalls++;
    final live = docs.entries.where((e) => e.value['active'] != false).toList()
      ..sort((a, b) {
        final an = (a.value['nameHe'] as String?) ?? a.key;
        final bn = (b.value['nameHe'] as String?) ?? b.key;
        final c = an.compareTo(bn);
        return c != 0 ? c : a.key.compareTo(b.key);
      });
    final start = after == null
        ? 0
        : live.indexWhere((e) => e.key == after.lastDocId) + 1;
    return live
        .skip(start)
        .take(limit)
        .map((e) => RemoteDoc(e.key, e.value))
        .toList(growable: false);
  }

  @override
  Future<RemoteDoc?> get(String sku) async {
    final d = docs[sku];
    return d == null ? null : RemoteDoc(sku, d);
  }

  @override
  Future<void> set(String sku, Map<String, dynamic> data) async {
    docs[sku] = <String, dynamic>{...?docs[sku], ...data};
  }

  @override
  Future<void> setPricing(
      String sku, String audience, Map<String, dynamic> data) async {}
}

/// Page through the whole browse (cursor-threaded) → the full item list.
Future<List<LipskeyCatalogProduct>> _drainAll(CatalogPagedBrowse b) async {
  final out = <LipskeyCatalogProduct>[];
  Cursor? cursor;
  var more = true;
  while (more) {
    final p = await b.page(after: cursor);
    out.addAll(p.items);
    more = p.hasMore;
    cursor = p.cursor;
  }
  return out;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('C1.5 — the 20 slice products flow through the SERVER (paged) browse',
      () async {
    final source = _FakeAuthoredSource();
    final repo = FirebaseAuthoredProductsRepository(source: source);
    // Seed the fake `catalogProducts` with the 20 via toDoc (== the C1.2 migration).
    for (final p in c1SliceProducts()) {
      source.docs[p.sku] = repo.toDoc(p);
    }

    final browse = CatalogPagedBrowse.paged(repo, cache: CatalogPageCache());
    expect(browse.isPaged, isTrue, reason: 'the SERVER path, not bundled');

    final items = await _drainAll(browse);

    expect(items, hasLength(20), reason: 'all 20 pulled from the server');
    expect(items.map((p) => p.sku).toSet(), kC1SliceSkus.toSet());

    // The server-browsed products equal the bundled slice (fromDoc round-trip).
    final bundled = {for (final p in c1SliceProducts()) p.sku: p};
    for (final p in items) {
      final b = bundled[p.sku]!;
      expect(p.nameHe, b.nameHe, reason: '${p.sku} nameHe');
      expect(p.categoryHe, b.categoryHe, reason: '${p.sku} categoryHe');
      expect(p.brand, b.brand, reason: '${p.sku} brand');
    }
  });
}
