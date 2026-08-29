// Unified card-keyboard (#38) Phase 3 — soft signals (anchor rule + suggestions).
//
// The anchor rule (build-plan §1.5) + the consequence that the soft signals are
// INERT during the merge (the merge only runs on a large pool, where anchorOf is
// always null). The "what connects" suggestion accessor delegates to the verified
// connectionsFor (no parallel compatibility logic).

import 'package:buildsmart/features/card_keyboard/card_soft.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show
        connectionsFor,
        distinctCardCount,
        distinctProducts,
        kShowProductsThreshold;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('anchorOf (build-plan §1.5)', () {
    test('empty pool → null', () {
      expect(anchorOf(const []), isNull);
    });

    test('single distinct card → the resolved product', () {
      final one = distinctProducts(kDivePool).take(1).toList();
      expect(distinctCardCount(one), 1, reason: 'sanity: one distinct card');
      expect(anchorOf(one), one.first);
    });

    test('large pool (> threshold cards) → null → soft INERT in the merge', () {
      // The merge only runs when distinctCardCount > kShowProductsThreshold, and
      // there the anchor is ALWAYS null — so the soft signals never tilt the
      // merge (§1.5 "anchor == null → skip"). This is the inert-in-merge property.
      expect(
        distinctCardCount(kDivePool),
        greaterThan(kShowProductsThreshold),
      );
      expect(anchorOf(kDivePool), isNull);
    });
  });

  group('softSuggestionsFor', () {
    test('delegates EXACTLY to the verified connectionsFor', () {
      final p = kDivePool.first;
      expect(
        softSuggestionsFor(p).map((x) => x.sku).toList(),
        connectionsFor(p).map((x) => x.sku).toList(),
      );
    });

    test('a valid connection anchor yields a non-empty suggestion list', () {
      final anchor = kDivePool.firstWhere(
        (p) => connectionsFor(p).isNotEmpty,
        orElse: () => kDivePool.first,
      );
      if (connectionsFor(anchor).isNotEmpty) {
        expect(softSuggestionsFor(anchor), isNotEmpty,
            reason: 'the card surfaces the verified compatible parts');
      }
    });
  });
}
