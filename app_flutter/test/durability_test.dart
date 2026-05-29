// Roadmap step 15 — durabilityRatingFor (heuristic 1-5).
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stars are 1..5 and reason non-empty for every spec product; null else',
      () {
    for (final p in kLipskeyCatalog) {
      final r = durabilityRatingFor(p);
      if (kVerifiedSpecs[p.sku] == null) {
        expect(r, isNull, reason: p.sku);
        continue;
      }
      expect(r, isNotNull, reason: p.sku);
      expect(r!.stars, inInclusiveRange(1, 5), reason: p.sku);
      expect(r.reason, isNotEmpty);
    }
  });

  test('a metallic, hot-rated product scores above a cold-only one', () {
    int? metalHot;
    int? cold;
    for (final p in kLipskeyCatalog) {
      final s = kVerifiedSpecs[p.sku];
      if (s == null) continue;
      if ({'נחושת', 'פליז', 'פלדה'}.contains(s.material) && s.maxTempC >= 90) {
        metalHot ??= durabilityRatingFor(p)!.stars;
      }
      if (s.maxTempC < 60) cold ??= durabilityRatingFor(p)!.stars;
    }
    if (metalHot != null && cold != null) {
      expect(metalHot, greaterThan(cold));
    }
  });
}
