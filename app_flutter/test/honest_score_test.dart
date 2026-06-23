// Guards the honest two-axis product score (v6.x):
//   • cardReadinessScore  — install/CONNECTION readiness (gated on a verified
//     connection spec). A non-connecting auxiliary is CORRECTLY low.
//   • dataCompletenessScore — spec-FREE catalog-listing completeness, so a part
//     whose listing is full reads high even when it never joins the pipe.
// Plus the R8-safe mounting guidance for clamps/hangers/grab bars (real mount
// steps, never a fabricated connection spec).
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  LipskeyCatalogProduct bySku(String sku) =>
      kLipskeyCatalog.firstWhere((p) => p.sku == sku);

  group('Honest two-axis score', () {
    test('non-connecting kit: low install-readiness, listing NOT slandered', () {
      final p = bySku('186466'); // ערכה אוניברסלית — no verified connection
      expect(cardReadinessScore(p).score < 30, isTrue,
          reason: 'cannot plumb with it → low install chip');
      expect(dataCompletenessScore(p).score >= 55, isTrue,
          reason: 'its catalog listing is complete → fair data chip');
    });
    test('a real connecting fitting scores well on BOTH axes', () {
      final p = bySku('77381040');
      expect(cardReadinessScore(p).score >= 80, isTrue);
      expect(dataCompletenessScore(p).score >= 55, isTrue);
    });
    test('dataCompletenessScore is spec-free and bounded 0..100', () {
      for (final p in kLipskeyCatalog.take(60)) {
        final d = dataCompletenessScore(p);
        expect(d.score >= 0 && d.score <= 100, isTrue, reason: p.sku);
      }
    });
  });

  group('R8-safe mount guidance for non-connecting auxiliaries', () {
    test('clamps / hangers / grab bars get real mounting tools + tips', () {
      expect(installToolsFor(bySku('77006080')).isNotEmpty, isTrue); // אומגה 1/2"
      expect(installToolsFor(bySku('77775289')).isNotEmpty, isTrue); // ידית אחיזה
      expect(installTipsFor(bySku('77006080')).isNotEmpty, isTrue);
    });
    test('they still carry NO verified connection spec (low-is-correct lock)', () {
      // Guard against future inflation: a clamp must never gain a fake spec that
      // would make it falsely "mate" with fittings in the install engine.
      expect(compatibleProductsCount(bySku('77006080')), 0);
    });
  });
}
