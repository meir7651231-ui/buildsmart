// C2.6 (+ C2.5 perf) — ALL engines on the FULL server catalog == baked.
//
// C2.6: builds the WHOLE catalog the way the app would after migration (every product
// bundled → toDoc → fromDoc) and proves the DIVE engine (catFindAxes / catOptsFor /
// catMatching — shared by ring/plain/axis) and the SEARCH engine (fuzzySearchProducts)
// give IDENTICAL results on it as on the baked catalog. Compat is covered by C2.2's
// round-trip invariant; standards/tools/global-search read the same pool, so the
// source-agnostic proof carries. No engine is touched (decision 4: injection).
//
// C2.5 perf: a test-backed proxy — the full toDoc+fromDoc round-trip of ~1,879
// products must complete well under a generous bound (no pathological O(n²)). The
// LIVE Firestore fetch+cache target is an owner decision (flagged), measured at 1-B.

import 'package:buildsmart/data/fuzzy_search.dart' show fuzzySearchProducts;
import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/data/repositories/authored_products_firebase.dart'
    show FirebaseAuthoredProductsRepository;
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteDoc;
import 'package:buildsmart/features/ring_dive/catalog_axes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repo = FirebaseAuthoredProductsRepository();

  // The whole catalog after a full server round-trip, vs the baked catalog.
  final server = <LipskeyCatalogProduct>[
    for (final p in kCatalogProducts)
      repo.fromDoc(RemoteDoc(p.sku, repo.toDoc(p))),
  ];
  final serverPool = [for (final p in server) CatProduct(p)];
  final bakedPool = [for (final p in kCatalogProducts) CatProduct(p)];

  test('C2.6 — DIVE on the FULL server catalog is identical to baked', () {
    final axes = catFindAxes(const <String, String>{}, bakedPool);
    expect(catFindAxes(const <String, String>{}, serverPool), axes);
    expect(axes, isNotEmpty);

    // Every axis's value options match across the whole catalog.
    for (final ax in axes) {
      expect(
        catOptsFor(ax, const <String, String>{}, serverPool, serverPool),
        catOptsFor(ax, const <String, String>{}, bakedPool, bakedPool),
        reason: 'axis "$ax" options drifted at full scale',
      );
    }

    // A two-step dive (pick the top axis's first value, then re-ask) matches.
    final axis = axes.first;
    final value =
        catOptsFor(axis, const <String, String>{}, bakedPool, bakedPool).first;
    final cons = <String, String>{axis: value};
    expect(
      catMatching(cons, serverPool).map((c) => c.sku).toSet(),
      catMatching(cons, bakedPool).map((c) => c.sku).toSet(),
      reason: 'dive result drifted at full scale',
    );
    final next = catFindAxes(cons, bakedPool);
    expect(catFindAxes(cons, serverPool), next, reason: 'next-axis set drifted');
  });

  test('C2.6 — SEARCH on the FULL server catalog is identical to baked', () {
    for (final q in const [
      'ברז',
      'מחבר',
      'צינור',
      'מסעף',
      'HDPE',
      'נחושת',
      'אסלה',
      'ברך',
    ]) {
      final s = fuzzySearchProducts(q, products: server).map((p) => p.sku);
      final b = fuzzySearchProducts(q, products: kCatalogProducts)
          .map((p) => p.sku);
      expect(s.toList(), b.toList(), reason: 'search "$q" drifted at full scale');
      expect(b, isNotEmpty, reason: '"$q" should hit the catalog');
    }
  });

  test('C2.5 (perf proxy) — full toDoc+fromDoc round-trip is well under budget', () {
    final sw = Stopwatch()..start();
    var n = 0;
    for (final p in kCatalogProducts) {
      repo.fromDoc(RemoteDoc(p.sku, repo.toDoc(p)));
      n++;
    }
    sw.stop();
    expect(n, kCatalogProducts.length);
    // Generous ceiling — proves the migration/read path is linear & fast (a real
    // regression like accidental O(n²) would blow past it). The LIVE Firestore
    // fetch+cache target is an owner decision (C2.5), measured at the 1-B cutover.
    expect(sw.elapsedMilliseconds, lessThan(3000),
        reason: 'full-catalog round-trip took ${sw.elapsedMilliseconds}ms');
  });
}
