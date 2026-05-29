// Roadmap step 27 — adapterSuggestionFor (bridging adapter recommendation).
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('empty line → null', () {
    final p = kLipskeyCatalog.firstWhere((x) => compatibleProductsFor(x).isNotEmpty);
    expect(adapterSuggestionFor(p, const []), isNull);
  });

  test('already-connecting line item → null (no adapter needed)', () {
    final p = kLipskeyCatalog.firstWhere((x) => compatibleProductsFor(x).isNotEmpty);
    final mate = compatibleProductsFor(p).first;
    expect(adapterSuggestionFor(p, [mate]), isNull);
  });

  test('when a suggestion is returned it mates BOTH the product and a line item',
      () {
    // Search for any (product, foreign line-item) pair that yields a bridge.
    var verified = 0;
    outer:
    for (final p in kLipskeyCatalog) {
      final pMates = compatibleProductsFor(p);
      if (pMates.isEmpty) continue;
      final pMateSkus = pMates.map((e) => e.sku).toSet();
      // pick a line item that p does NOT directly connect to
      for (final lp in kLipskeyCatalog) {
        if (lp.sku == p.sku || pMateSkus.contains(lp.sku)) continue;
        final adapter = adapterSuggestionFor(p, [lp]);
        if (adapter != null) {
          // adapter mates p
          expect(compatibleProductsFor(p).map((e) => e.sku), contains(adapter.sku));
          // adapter mates lp
          expect(compatibleProductsFor(adapter).map((e) => e.sku),
              contains(lp.sku));
          verified++;
          if (verified >= 3) break outer;
        }
      }
    }
    // The catalog should contain at least one real bridging case.
    expect(verified, greaterThan(0));
  });
}
