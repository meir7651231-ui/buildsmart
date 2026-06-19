// Unit tests for the PURE quick-pad ranking engine (quick_pad_engine.dart) —
// the DIVERSE-LIST "ערב-רב" quick re-order pad.
//
// Pure-Dart assertions — no widgets pumped. SKUs below are REAL members of the
// deduped kDivePool (the Lipskey "מחסום/סיפון" family, verified present), so the
// engine's "drop skus not in pool" and product-resolution paths exercise live
// catalog data, not fixtures. The adversarial byte-verify the swarm requires:
// an unknown sku must NOT leak into the pad, and a sku in two sources must
// appear ONCE under its highest source.

import 'package:buildsmart/features/word_finder/dive_pool.dart';
import 'package:buildsmart/features/word_finder/quick_pad_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Real skus from kDivePool (Lipskey catalog, "מחסום (סיפון)" family).
  const skuFav = '217861';
  const skuFreq = '213055';
  const skuRecent = '218553';
  const skuShared = '116632'; // placed in BOTH favorites and recents below
  const skuUnknown = 'NOPE-DOES-NOT-EXIST-999';

  setUpAll(() {
    // Guard the fixtures: if the catalog ever drops these skus the test should
    // fail loudly here, not silently degrade the assertions below.
    final pool = {for (final p in kDivePool) p.sku};
    for (final s in [skuFav, skuFreq, skuRecent, skuShared]) {
      expect(pool.contains(s), isTrue,
          reason: 'fixture sku $s must exist in kDivePool');
    }
    expect(pool.contains(skuUnknown), isFalse);
  });

  group('quickLabel', () {
    test('returns a non-empty SHORT word for a known product (not full name)',
        () {
      final p = kDivePool.firstWhere((p) => p.sku == skuFav);
      final label = quickLabel(p);
      expect(label.trim(), isNotEmpty);
      // Short = a single leading word, strictly shorter than the technical name.
      expect(label.length, lessThan(p.nameHe.length));
      expect(label.contains(' '), isFalse,
          reason: 'label should be one short token, got "$label"');
    });
  });

  group('quickPicks', () {
    test('orders favorites before frequent before recent', () {
      final picks = quickPicks(
        favSkus: {skuFav},
        frequentSkus: const [skuFreq],
        recentSkus: const [skuRecent],
      );
      expect(picks.map((q) => q.product.sku).toList(),
          [skuFav, skuFreq, skuRecent]);
      expect(picks.map((q) => q.source).toList(),
          ['favorite', 'frequent', 'recent']);
      // Every emitted pick carries a non-empty short label.
      for (final q in picks) {
        expect(q.label.trim(), isNotEmpty);
      }
    });

    test('dedupes a sku present in both favorites and recents (fav wins)', () {
      final picks = quickPicks(
        favSkus: {skuShared},
        recentSkus: const [skuShared, skuRecent],
      );
      final skus = picks.map((q) => q.product.sku).toList();
      // skuShared appears exactly once...
      expect(skus.where((s) => s == skuShared).length, 1);
      // ...and under the favorite source (the higher priority).
      expect(picks.firstWhere((q) => q.product.sku == skuShared).source,
          'favorite');
      // The genuinely-recent-only sku still comes through.
      expect(skus.contains(skuRecent), isTrue);
      expect(skus, [skuShared, skuRecent]);
    });

    test('drops skus not present in kDivePool', () {
      final picks = quickPicks(
        favSkus: {skuUnknown, skuFav},
        recentSkus: const [skuUnknown],
      );
      final skus = picks.map((q) => q.product.sku).toList();
      expect(skus.contains(skuUnknown), isFalse);
      expect(skus, [skuFav]); // only the real favorite survives
    });

    test('respects the cap', () {
      final picks = quickPicks(
        favSkus: {skuFav, skuFreq, skuRecent, skuShared},
        cap: 2,
      );
      expect(picks.length, 2);
    });

    test('returns an empty list for empty inputs', () {
      expect(quickPicks(favSkus: const {}), isEmpty);
    });
  });
}
