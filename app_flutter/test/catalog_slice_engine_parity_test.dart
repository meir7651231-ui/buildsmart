// C1.7 — the ENGINES on server data == baked (SPEC-catalog-to-server · the GATE).
//
// Builds the "server" products the way the app really would — bundled → toDoc →
// fromDoc (the C1.2 migration + the browse round-trip) — and proves the DIVE engine
// (axis: catFindAxes / catOptsFor / catMatching, shared by ring/plain/axis) and the
// SEARCH engine (fuzzySearchProducts) produce IDENTICAL results on it as on the
// bundled slice. Because it round-trips through the real serializer, a dropped field
// the engine reads (e.g. `dims`, which drives the diameter/length axes) would make the
// two diverge — so this genuinely proves the source swap is invisible to the engines,
// WITHOUT touching one engine (decision 4: injection, not production cutover).

import 'package:buildsmart/data/fuzzy_search.dart' show fuzzySearchProducts;
import 'package:buildsmart/data/repositories/authored_products_firebase.dart'
    show FirebaseAuthoredProductsRepository;
import 'package:buildsmart/data/repositories/catalog_slice.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteDoc;
import 'package:buildsmart/features/ring_dive/catalog_axes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repo = FirebaseAuthoredProductsRepository();

  // The bundled slice, and the SAME 20 after a full server round-trip.
  final bundled = c1SliceProducts();
  final server = [
    for (final p in bundled) repo.fromDoc(RemoteDoc(p.sku, repo.toDoc(p))),
  ];
  final bundledPool = [for (final p in bundled) CatProduct(p)];
  final serverPool = [for (final p in server) CatProduct(p)];

  test('C1.7 — DIVE: axis selector + value wheels + a dive are identical', () {
    // The first wheel — which axes still split the slice — must match.
    final axesBundled = catFindAxes(const <String, String>{}, bundledPool);
    expect(catFindAxes(const <String, String>{}, serverPool), axesBundled);
    expect(axesBundled, isNotEmpty, reason: 'the slice is diverse enough to dive');

    // Every axis's VALUE options (the second wheel) must match — this is where a
    // dropped `dims` field would surface (diameter/length/angle axes read dims).
    for (final ax in axesBundled) {
      expect(
        catOptsFor(ax, const <String, String>{}, serverPool, serverPool),
        catOptsFor(ax, const <String, String>{}, bundledPool, bundledPool),
        reason: 'axis "$ax" value options drifted',
      );
    }

    // A real dive: pick the top axis's first value → the matched sets must match.
    final axis = axesBundled.first;
    final value =
        catOptsFor(axis, const <String, String>{}, bundledPool, bundledPool).first;
    final cons = <String, String>{axis: value};
    expect(
      catMatching(cons, serverPool).map((c) => c.sku).toSet(),
      catMatching(cons, bundledPool).map((c) => c.sku).toSet(),
      reason: 'the dive result drifted after the server round-trip',
    );
  });

  test('C1.7 — SEARCH: fuzzy results are identical on server data', () {
    for (final q in const ['מסעף', 'HDPE', 'נחושת', 'ברז', 'צווארון', 'מתאם']) {
      expect(
        fuzzySearchProducts(q, products: server).map((p) => p.sku).toList(),
        fuzzySearchProducts(q, products: bundled).map((p) => p.sku).toList(),
        reason: 'search "$q" drifted',
      );
    }
  });
}
