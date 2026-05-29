// Roadmap step 30 (card-level) — cardReadinessScore.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
        expect(cardReadinessScore(p).score, greaterThanOrEqualTo(40),
            reason: p.sku);
      }
    }
  });
}
