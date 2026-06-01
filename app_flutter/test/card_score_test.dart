// Roadmap step 30 (card-level) — cardReadinessScore.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/data/polyroll_specs.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:flutter_test/flutter_test.dart';

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
    for (final p in kLipskeyCatalog) {
      final r = cardReadinessScore(p);
      expect(r.score, inInclusiveRange(0, 100), reason: p.sku);
      expect(bands, contains(r.label));
      // band boundaries
      if (r.score >= 80) expect(r.label, 'מצוין');
      if (r.score < 30) expect(r.label, 'חלקי');
    }
  });

  test('a product with a verified spec scores at least the spec weight', () {
    for (final p in kLipskeyCatalog) {
      if (kVerifiedSpecs[p.sku] != null) {
        // Spec weight is +25 in the raised-bar formula (was +40). A spec'd
        // product is guaranteed at least the spec weight; richer signals
        // (compat/standards/install) lift it further.
        expect(cardReadinessScore(p).score, greaterThanOrEqualTo(25),
            reason: p.sku);
      }
    }
  });
}
