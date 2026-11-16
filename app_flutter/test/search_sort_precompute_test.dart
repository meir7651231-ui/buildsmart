// Nightly 2026-11-16 — search ranking computes each product's relevance ONCE
// (sortedByScoreDesc), not on every comparison, and the order is unchanged.

import 'package:buildsmart/data/catalog_source.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/features/global_search/prediction_ranking.dart';
import 'package:buildsmart/screens/catalog_screen.dart';
import 'package:flutter_test/flutter_test.dart';

const _queries = [
  'מושב',
  'שירותים',
  'סיפון',
  'ברז',
  'צינור 50',
  'אסלה',
  'מחבר',
  'ניקוז',
  'פקק',
  'זווית 45',
];

List<LipskeyCatalogProduct> _candidates(String q) => resolvedCatalogProducts
    .where((p) => catalogProductMatchesQuery(p, q, requireAll: false))
    .toList();

void main() {
  group('sortedByScoreDesc', () {
    test('calls each key function exactly once per item', () {
      var primaryCalls = 0;
      var secondaryCalls = 0;
      final items = List<int>.generate(500, (i) => (i * 7919) % 97);
      final out = sortedByScoreDesc<int>(
        items,
        (x) {
          primaryCalls++;
          return x ~/ 10;
        },
        secondary: (x) {
          secondaryCalls++;
          return x;
        },
      );
      expect(primaryCalls, items.length);
      expect(secondaryCalls, items.length);
      // Descending by primary, ties descending by secondary.
      for (var i = 1; i < out.length; i++) {
        final a = out[i - 1];
        final b = out[i];
        expect(a ~/ 10 >= b ~/ 10, isTrue);
        if (a ~/ 10 == b ~/ 10) expect(a >= b, isTrue);
      }
    });

    test('empty input → empty output', () {
      expect(sortedByScoreDesc<int>(const [], (x) => x), isEmpty);
    });
  });

  test('catalog relevance order is IDENTICAL to the old per-compare sort', () {
    for (final q in _queries) {
      final pool = _candidates(q);
      final old = [...pool]..sort(
          (a, b) => searchRelevance(b, q).compareTo(searchRelevance(a, q)));
      final now = sortedByScoreDesc(pool, (p) => searchRelevance(p, q));
      expect(now.map((p) => p.sku).toList(), old.map((p) => p.sku).toList(),
          reason: 'order changed for "$q" (${pool.length} candidates)');
    }
  });

  test('prediction tie-break order is IDENTICAL too', () {
    for (final q in _queries) {
      final pool = _candidates(q);
      int tie(LipskeyCatalogProduct p) =>
          nameAffinity(p, q) + productProminence(p);
      final old = [...pool]..sort((a, b) {
          final byRel =
              searchRelevance(b, q).compareTo(searchRelevance(a, q));
          if (byRel != 0) return byRel;
          return tie(b).compareTo(tie(a));
        });
      final now = sortedByScoreDesc(
        pool,
        (p) => searchRelevance(p, q),
        secondary: tie,
      );
      expect(now.map((p) => p.sku).toList(), old.map((p) => p.sku).toList(),
          reason: 'order changed for "$q"');
    }
  });

  test('the catalog actually yields big candidate pools (non-vacuous)', () {
    final sizes = [for (final q in _queries) _candidates(q).length];
    expect(sizes.reduce((a, b) => a > b ? a : b), greaterThan(50));
  });
}
