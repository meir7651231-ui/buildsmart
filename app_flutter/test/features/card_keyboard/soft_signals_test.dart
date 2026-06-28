// P9.82-83: softTilt (the inert-when-anchorless multiplier), softAnchor (the
// pool-size gate that keeps it inert until convergence), and kitSkusFor (resolved kit
// members for the recipe anchor). All pure — tested in isolation.

import 'package:buildsmart/data/smart_tree.dart' show kSmartProducts;
import 'package:buildsmart/features/card_keyboard/soft_signals.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
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

  group('softAnchor', () {
    test('the full universe is wide → no anchor (softTilt stays inert)', () {
      expect(softAnchor(kDivePool), isNull);
    });

    test('a near-convergence pool yields its skus as the anchor', () {
      final pool = kDivePool.take(2).toList();
      expect(softAnchor(pool), {pool[0].sku, pool[1].sku});
    });

    test('a single (converged) or empty pool has no anchor', () {
      expect(softAnchor(kDivePool.take(1).toList()), isNull);
      expect(softAnchor(const []), isNull);
    });

    test('the near-convergence boundary is inclusive then drops off', () {
      expect(softAnchor(kDivePool.take(kNearConvergence).toList()), isNotNull);
      expect(softAnchor(kDivePool.take(kNearConvergence + 1).toList()), isNull);
    });
  });

  group('kitSkusFor', () {
    test('at least one recipe resolves to a non-empty kit', () {
      expect(kSmartProducts.any((r) => kitSkusFor(r).isNotEmpty), isTrue);
    });
  });
}
