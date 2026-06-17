/// PURE unit coverage of the 7th engine — the CONNECTION-PLANNER
/// ("מה מתחבר לזה" / connection-planner): `connectionsFor` + `isConnectionAnchor`
/// in `word_finder_engine.dart`.
///
/// No Flutter widgets are pumped; this is plain Dart logic over the finder's
/// pure primitives and the REAL catalog/compat/verified-spec data. `flutter_test`
/// is used only for `test`/`expect`/`group` (the project's standard harness,
/// same as `word_finder_engine_test.dart`).
///
/// FIXTURES (verified against the data files, NOT invented):
///  • '217861'     — American bottle trap, PVC, ends DN32×DN32. In kCompatCatalog
///                   AND has a kVerifiedSpec → a VALID anchor. Known DN32-PVC
///                   mates: '213055', '218553' (same category, same ends).
///  • '171026'     — toilet seat ('מושבי אסלה', a kNonConnectorCategory). In the
///                   catalog/compat union but DELIBERATELY without a spec →
///                   hasSpec=false → NOT an anchor.
///  • '6001602200' — a Polyroll sku: in kDivePool but NOT in kCompatCatalog and
///                   without a spec → inCompat=false → NOT an anchor.
library;

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart'
    show divePoolIndex, kDivePool;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A sku→product lookup over the REAL union pool, built once for the fixtures.
  final bySku = {for (final p in kDivePool) p.sku: p};

  LipskeyCatalogProduct product(String sku) {
    final p = bySku[sku];
    expect(p, isNotNull, reason: 'fixture sku $sku must exist in kDivePool');
    return p!;
  }

  group('connectionsFor — a known anchor yields known-compatible parts', () {
    // Resolve via the raw map (NOT product(), which uses expect() and would
    // throw OutsideTestException here in the group body, before any test runs).
    final anchor = bySku['217861']!; // PVC DN32×DN32 bottle trap

    test('the anchor is a valid connection anchor', () {
      expect(isConnectionAnchor(anchor), isTrue,
          reason: '217861 is inCompat AND has a verified spec');
    });

    test('yields a non-empty compatible set', () {
      expect(connectionsFor(anchor), isNotEmpty,
          reason: 'a DN32 PVC trap mates the DN32 drainage family');
    });

    test('contains the known DN32 mates and excludes the anchor itself', () {
      final skus = connectionsFor(anchor).map((p) => p.sku).toSet();
      expect(skus, contains('213055'),
          reason: 'another DN32 PVC part must be offered as a connection');
      expect(skus, contains('218553'),
          reason: 'another DN32 PVC part must be offered as a connection');
      expect(skus, isNot(contains('217861')),
          reason: 'a product never lists itself as a connection '
              '(canConnect rejects a.sku == b.sku)');
    });

    test('every returned part is distinct from the anchor', () {
      for (final p in connectionsFor(anchor)) {
        expect(p.sku, isNot(anchor.sku));
      }
    });
  });

  group('connectionsFor — a non-anchor yields EMPTY', () {
    test('an uncovered product (toilet seat, no spec) → empty + not anchor', () {
      final seat = product('171026'); // 'מושבי אסלה' — no verified spec
      expect(isConnectionAnchor(seat), isFalse,
          reason: 'no verified spec → not a confident anchor');
      expect(connectionsFor(seat), isEmpty,
          reason: 'a non-anchor must not surface name-inference guesses');
    });

    test('an out-of-compat product (Polyroll) → empty + not anchor', () {
      final poly = product('6001602200'); // not in kCompatCatalog
      expect(isConnectionAnchor(poly), isFalse,
          reason: 'outside kCompatCatalog → can never be an anchor');
      expect(connectionsFor(poly), isEmpty);
    });
  });

  group('connectionsFor — faithful wrapper + anchor-gate invariants', () {
    test('an anchor result is non-trivial AND self-consistent', () {
      // For a valid anchor, connectionsFor returns a non-empty set whose members
      // are all real catalog products distinct from the anchor — the contract the
      // UI relies on. (We assert the SHAPE here rather than re-deriving the exact
      // compat list, which is install_engine's own tested responsibility.)
      final anchor = product('217861');
      final parts = connectionsFor(anchor);
      expect(parts, isNotEmpty);
      final poolSkus = {for (final p in kDivePool) p.sku};
      for (final p in parts) {
        expect(poolSkus, contains(p.sku),
            reason: 'every connection is a real pooled product');
      }
    });

    test('a non-anchor is empty regardless of tempC', () {
      final seat = product('171026');
      expect(connectionsFor(seat, tempC: 20), isEmpty);
      expect(connectionsFor(seat, tempC: 60), isEmpty,
          reason: 'the anchor gate is temperature-independent');
    });

    test('isConnectionAnchor agrees with divePoolIndex (inCompat && hasSpec)', () {
      // Spot-check the gate against the precomputed membership for the fixtures.
      for (final sku in const ['217861', '171026', '6001602200']) {
        final m = divePoolIndex[sku];
        final expected = m != null && m.inCompat && m.hasSpec;
        expect(isConnectionAnchor(product(sku)), expected,
            reason: 'gate for $sku must equal inCompat && hasSpec');
      }
    });
  });

  group('connection-planner feasibility — anchors are not sparse', () {
    test('a large fraction of the pool are valid anchors', () {
      // FEASIBILITY in-code: the 7th engine is only worth surfacing if many
      // reached products are anchors. Count them over the real union pool.
      final anchors =
          kDivePool.where(isConnectionAnchor).length;
      // Lower bound chosen well under the measured count (~890) so the test is a
      // stable floor, not a brittle exact match.
      expect(anchors, greaterThan(500),
          reason: 'most catalog flow-connectors carry a verified spec, so the '
              'connection-planner has a rich set of anchors to offer');
      expect(anchors, lessThan(kDivePool.length),
          reason: 'fixtures/accessories/uncovered products are NOT anchors');
    });

    test('at least one anchor yields a non-empty set (engine is useful)', () {
      final anchored = kDivePool.where(isConnectionAnchor);
      final anyNonEmpty =
          anchored.any((a) => connectionsFor(a).isNotEmpty);
      expect(anyNonEmpty, isTrue,
          reason: 'compatibleWith returns addable parts for real anchors');
    });
  });
}
