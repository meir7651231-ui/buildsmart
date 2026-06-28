// P9.82-83: softTilt (the inert-when-anchorless multiplier), softAnchor (the
// pool-size gate that keeps it inert until convergence), and kitSkusFor (resolved kit
// members for the recipe anchor). All pure — tested in isolation.

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/smart_tree.dart' show kSmartProducts;
import 'package:buildsmart/features/card_keyboard/soft_signals.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show distinctCardCount;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('softTilt', () {
    test('no anchor → inert (exactly 1.0)', () {
      expect(softTilt(), 1.0);
    });

    test('any single anchor lifts above 1.0', () {
      expect(softTilt(connection: true), greaterThan(1.0));
      expect(softTilt(recipe: true), greaterThan(1.0));
      expect(softTilt(history: true), greaterThan(1.0));
    });

    test('anchors ordered by strength: connection > recipe > history', () {
      expect(softTilt(connection: true), greaterThan(softTilt(recipe: true)));
      expect(softTilt(recipe: true), greaterThan(softTilt(history: true)));
    });

    test('more anchors → monotonically higher, never above the cap', () {
      final one = softTilt(connection: true);
      final two = softTilt(connection: true, recipe: true);
      final all = softTilt(connection: true, recipe: true, history: true);
      expect(two, greaterThan(one));
      expect(all, greaterThanOrEqualTo(two));
      expect(all, lessThanOrEqualTo(kMaxSoftTilt));
    });
  });

  group('softAnchor (gated on distinctCardCount, not raw row count)', () {
    test('the full universe is wide → no anchor (softTilt stays inert)', () {
      expect(softAnchor(kDivePool), isNull);
    });

    test('a single (converged) or empty pool has no anchor', () {
      expect(softAnchor(kDivePool.take(1).toList()), isNull);
      expect(softAnchor(const []), isNull);
    });

    test('engages EXACTLY on the distinctCardCount window [2, kNearConvergence]',
        () {
      for (final k in [0, 1, 2, 4, 8, 16, 24, 40, 80, kDivePool.length]) {
        final pool = kDivePool.take(k).toList();
        final n = distinctCardCount(pool);
        final inWindow = n >= 2 && n <= kNearConvergence;
        expect(softAnchor(pool) != null, inWindow,
            reason: 'take=$k → distinctCardCount=$n, window [2,$kNearConvergence]');
      }
    });

    test('when engaged, the anchor is every sku in the pool', () {
      var pool = <LipskeyCatalogProduct>[];
      for (var k = 2; k <= kDivePool.length; k++) {
        final p = kDivePool.take(k).toList();
        final n = distinctCardCount(p);
        if (n >= 2 && n <= kNearConvergence) {
          pool = p;
          break;
        }
      }
      expect(pool, isNotEmpty, reason: 'a near-convergence pool must exist');
      expect(softAnchor(pool), {for (final p in pool) p.sku});
    });
  });

  group('kitSkusFor', () {
    test('at least one recipe resolves to a non-empty kit', () {
      expect(kSmartProducts.any((r) => kitSkusFor(r).isNotEmpty), isTrue);
    });
  });
}
