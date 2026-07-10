// PlainDive continued-drill (rings 4+) — proves the layman drill keeps narrowing
// PAST the type ring, by size/material/…, in plain words, and TERMINATES for every
// leaf (the multi-size infinite-loop — a ½×⅜ product re-offering "½" forever — is
// fixed by consuming each axis once).
//
//   flutter test test/features/ring_dive/plain_dive_narrow_test.dart

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/features/ring_dive/plain_dive.dart';
import 'package:flutter_test/flutter_test.dart';

/// Simulate the drill: from [node], keep picking the FIRST value of each narrowing
/// ring until [plainNextAxis] says stop. Returns how many rings ran and how many
/// products remain.
({int rings, int finalCount}) _drill(PlainNode node) {
  var products = plainProductsFor(node);
  final used = <String>{};
  var rings = 0;
  while (rings < 20) {
    final next = plainNextAxis(products, usedAxes: used);
    if (next == null) break;
    products = plainFilterBy(products, next.axis, next.values.first);
    used.add(next.axis);
    rings++;
  }
  return (rings: rings, finalCount: products.length);
}

void main() {
  test('continued-drill TERMINATES for every leaf (no size-loop)', () {
    for (final n in kPlainDict) {
      final r = _drill(n);
      expect(r.rings, lessThan(20),
          reason: '${n.slang} never terminated — an axis was re-offered');
      // At most one ring per narrow axis (size/material/angle/color/type) = ≤5.
      expect(r.rings, lessThanOrEqualTo(5),
          reason: '${n.slang} ran more rings than there are axes');
    }
  });

  test('narrowing REDUCES a large family toward a handful', () {
    final valve = kPlainDict.firstWhere((n) => n.technical == 'ברז כדורי');
    final start = plainProductsFor(valve).length;
    final r = _drill(valve);
    expect(start, greaterThan(10), reason: 'ball-valve family starts large');
    expect(r.finalCount, lessThan(start), reason: 'the drill narrowed it');
    expect(r.finalCount, lessThanOrEqualTo(6),
        reason: 'ball-valve narrows to a few by size');
  });

  test('every leaf ends smaller than (or equal to) it started', () {
    for (final n in kPlainDict) {
      final start = plainProductsFor(n).length;
      final r = _drill(n);
      expect(r.finalCount, lessThanOrEqualTo(start),
          reason: '${n.slang} grew during the drill (impossible)');
    }
  });

  test('plainFilterBy keeps only products carrying the value', () {
    final valve = kPlainDict.firstWhere((n) => n.technical == 'ברז כדורי');
    final all = plainProductsFor(valve);
    final next = plainNextAxis(all)!;
    final kept = plainFilterBy(all, next.axis, next.values.first);
    expect(kept, isNotEmpty);
    expect(kept.length, lessThan(all.length));
  });

  test('plain size labels speak inches; other axes pass through', () {
    expect(plainAxisLabel('size', '½"'), 'חצי צול');
    expect(plainAxisLabel('size', '1"'), 'צול');
    expect(plainAxisLabel('color', 'לבן'), 'לבן');
    expect(plainAxisTitle('size'), 'איזה גודל?');
  });

  test('plainNextAxis returns null at zero/one product', () {
    expect(plainNextAxis(const <LipskeyCatalogProduct>[]), isNull);
  });

  // ── adversarial-swarm fix regressions ───────────────────────────────────────

  test('FIX-A caliber isolation: 16mm node does not reach DN160 fittings', () {
    final n16 = kPlainDict.firstWhere((n) => n.technical == '16');
    final p16 = plainProductsFor(n16);
    expect(p16, isNotEmpty, reason: '16mm still reaches its own products');
    expect(p16.where((p) => p.nameHe.contains('160')), isEmpty,
        reason: 'a bare "16" must not startsWith-match "160" 6-inch parts');
  });

  test('FIX-C size ring ascends by DN and drops cm/meter twins', () {
    final ball = kPlainDict.firstWhere((n) => n.technical == 'ברז כדורי');
    final ring = plainNextAxis(plainProductsFor(ball));
    expect(ring?.axis, 'size');
    final dns = <int>[
      for (final v in ring!.values)
        if (RegExp(r'^DN\d+$').hasMatch(v)) int.parse(v.substring(2)),
    ];
    expect(dns, [...dns]..sort(), reason: 'DN sizes read small→large, not lexical');

    final nil = kPlainDict.firstWhere((n) => n.technical == 'ברז ניל');
    final nilVals = plainNextAxis(plainProductsFor(nil))!.values;
    expect(nilVals.where((v) => v.contains('מ׳')), isEmpty,
        reason: 'the 0.15 מ׳ twin collapses into 15 ס"מ');
  });

  test('FIX-F elbow collapses to one generic ברך leaf', () {
    final elbows = kPlainDict.where((n) => n.slang.startsWith('ברך')).toList();
    expect(elbows.length, 1, reason: 'the 45°/90° leaves merged into one');
    expect(elbows.single.english, 'Elbow', reason: 'generic, not "Elbow 90"');
    expect(plainProductsFor(elbows.single).length, greaterThan(50));
  });

  test('FIX-B type axis is reachable — a PPR size bucket splits by "איזה סוג?"',
      () {
    final ppr = kPlainDict.firstWhere((n) => n.technical == 'PPR');
    final all = plainProductsFor(ppr);
    final sizeRing = plainNextAxis(all)!;
    expect(sizeRing.axis, 'size');
    var sawType = false;
    for (final v in sizeRing.values) {
      final bucket = plainFilterBy(all, 'size', v);
      if (plainNextAxis(bucket, usedAxes: {'size'})?.axis == 'type') {
        sawType = true;
        break;
      }
    }
    expect(sawType, isTrue,
        reason: 'a big single-caliber family narrows by kind, not a long dump');
  });
}
