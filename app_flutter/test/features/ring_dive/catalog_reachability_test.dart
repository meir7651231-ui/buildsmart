// REACHABILITY — proves the axis-dive never silently drops a product.
//
// The owner's worry (from PlainDive, where 57% fell during narrowing): when I
// filter, do products that LACK an axis fall away with no path back?
//
// The guarantees this test checks on the REAL pool:
//   1) The root "📋 הצג" lists 100% of the pool (nothing is unreachable).
//   2) There is at least one FULL-COVERAGE axis (every product has it) — so a
//      lossless drill path exists for every single product.
//   3) Every product is reachable by drilling that anchor axis to its own value.
//   4) The core invariant: constraining by an axis a product HAS never drops it
//      (you only ever lose a product by filtering an axis it genuinely lacks).
//
//   flutter test test/features/ring_dive/catalog_reachability_test.dart

import 'package:buildsmart/features/ring_dive/catalog_axes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final pool = catPool;
  final total = pool.length;

  test('root shows every product — הצג at the top = 100%', () {
    expect(catMatching(const <String, String>{}).length, total);
  });

  test('there is a full-coverage anchor axis → a lossless path to every product',
      () {
    final anchors = <String>[
      for (final a in kCatAxes)
        if (pool.every((p) => p.axes.containsKey(a.id))) a.id,
    ];
    // ignore: avoid_print
    print('FULL-COVERAGE axes (every product has them): $anchors');
    expect(anchors, isNotEmpty,
        reason: 'at least one axis every product has → nobody drops when you '
            'drill it');
  });

  test('every product is reachable by drilling the anchor axis', () {
    String? anchor;
    for (final a in kCatAxes) {
      if (pool.every((p) => p.axes.containsKey(a.id))) {
        anchor = a.id;
        break;
      }
    }
    expect(anchor, isNotNull);
    for (final p in pool) {
      final v = p.axes[anchor]!.first;
      final matched = catMatching(<String, String>{anchor!: v});
      expect(matched.any((q) => q.sku == p.sku), isTrue,
          reason: '${p.sku} unreachable via $anchor=$v');
    }
  });

  test('constraining by an axis a product HAS never drops it (spot-check)', () {
    final sample = pool.length <= 120 ? pool : pool.take(120).toList();
    for (final p in sample) {
      for (final ax in p.axes.keys) {
        for (final v in p.axes[ax]!) {
          final matched = catMatching(<String, String>{ax: v});
          expect(matched.any((q) => q.sku == p.sku), isTrue,
              reason: 'product ${p.sku} dropped by its own $ax=$v');
        }
      }
    }
  });

  test('coverage report per axis (which filters are lossy)', () {
    // ignore: avoid_print
    print('POOL: $total products');
    for (final a in kCatAxes) {
      final n = pool.where((p) => p.axes.containsKey(a.id)).length;
      final pct = (100 * n / total).round();
      // ignore: avoid_print
      print('${a.id.padRight(12)} ${pct.toString().padLeft(3)}%  ($n/$total)');
    }
  });
}
