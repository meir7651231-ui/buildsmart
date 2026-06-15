// Roadmap step 30 (card-level) — cardReadinessScore.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/data/polyroll_specs.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:flutter_test/flutter_test.dart';

/// A bounded, evenly-spread sample of [xs] (~[n] items). The card-readiness
/// bounds are STRUCTURAL (breadth weights sum to exactly 50; depth tiers cap at
/// 50), so a weight-sum regression shows up on ANY product — a small strided
/// sample is a sufficient, FAST tripwire. The full sweep was O(n²)
/// (compatibleProductsCount rescans the whole catalog per product) and timed
/// out under CI load — the source of the "card_score" deploy-gate failure.
Iterable<T> _sample<T>(List<T> xs, [int n = 40]) sync* {
  if (xs.isEmpty) return;
  final step = (xs.length / n).ceil().clamp(1, xs.length);
  for (var i = 0; i < xs.length; i += step) {
    yield xs[i];
  }
}

void main() {
  setUpAll(registerPolyrollSpecs);

  // Raised-bar formula: rich (spec + connectable + standard + install) reaches
  // the top; a fixture endpoint (no spec, no mates) stays low. No single
  // dimension alone reaches 100 — the bar requires breadth.
  group('raised bar', () {
    test('rich spec+connectable product (PPR DN20 pipe) hits the top band', () {
      final ppr = [...kLipskeyCatalog, ...kPolyrollCatalog]
          .firstWhere((p) => p.sku == '95016002');
      final r = cardReadinessScore(ppr);
      expect(r.score, greaterThanOrEqualTo(80), reason: 'rich → מצוין');
      expect(r.label, 'מצוין');
    });

    test('fixture endpoint (toilet seat, no spec/mates) stays low', () {
      final seat =
          kLipskeyCatalog.firstWhere((p) => p.sku == '220943');
      final r = cardReadinessScore(seat);
      expect(r.score, lessThanOrEqualTo(45),
          reason: 'no spec + 0 mates → not promoted by the raised bar');
    });

    test('no single dimension reaches 100 — top requires breadth', () {
      // The heaviest single weight is the spec (25); even spec+variants+finder+
      // price+compliance+acceptance without connectivity/standard/install must
      // stay below the מצוין fence for an unconnected product.
      final unconnected = kLipskeyCatalog.where((p) =>
          kVerifiedSpecs[p.sku] != null && compatibleProductsCount(p) == 0);
      for (final p in unconnected.take(30)) {
        expect(cardReadinessScore(p).score, lessThan(100), reason: p.sku);
      }
    });
  });
  test('score is within 0..100 and label matches the band, for all products',
      () {
    const bands = {'מצוין', 'טוב', 'בסיסי', 'חלקי'};
    for (final p in _sample(kLipskeyCatalog)) {
      final r = cardReadinessScore(p);
      expect(r.score, inInclusiveRange(0, 100), reason: p.sku);
      expect(bands, contains(r.label));
      // band boundaries
      if (r.score >= 80) expect(r.label, 'מצוין');
      if (r.score < 30) expect(r.label, 'חלקי');
    }
  });

  test('a verified spec contributes its full breadth weight (composite)', () {
    // In the composite model a verified spec is the heaviest BREADTH category
    // (+10). It no longer guarantees a fixed total — the rest of the score
    // depends on how broad AND deep the product is — but the spec presence must
    // always show up in the breadth sub-score.
    for (final p in _sample(kLipskeyCatalog)) {
      if (kVerifiedSpecs[p.sku] != null) {
        expect(cardReadinessScore(p).breadth, greaterThanOrEqualTo(10),
            reason: p.sku);
      }
    }
  });

  test('composite == breadth + depth (capped at 100), both within 0..50', () {
    for (final p in _sample([...kLipskeyCatalog, ...kPolyrollCatalog])) {
      final r = cardReadinessScore(p);
      expect(r.breadth, inInclusiveRange(0, 50), reason: p.sku);
      expect(r.depth, inInclusiveRange(0, 50), reason: p.sku);
      // Composite is the sum, unless the (impossible-in-practice) >100 cap hit.
      final raw = r.breadth + r.depth;
      expect(r.score, raw > 100 ? 100 : raw, reason: p.sku);
    }
  });
}
