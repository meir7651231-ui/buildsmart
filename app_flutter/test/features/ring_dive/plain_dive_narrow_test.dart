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

  test('FIX-C every size ring ascends by DN and drops cm/meter twins', () {
    // Size is no longer guaranteed FIRST (it is skipped when some products lack a
    // size, so none is stranded) — so verify the property on EVERY size ring the
    // greedy drill actually surfaces.
    var sawSize = false;
    for (final n in kPlainDict) {
      var products = plainProductsFor(n);
      final used = <String>{};
      var g = 0;
      while (g++ < 12) {
        final next = plainNextAxis(products, usedAxes: used);
        if (next == null) break;
        if (next.axis == 'size') {
          sawSize = true;
          final dns = <int>[
            for (final v in next.values)
              if (RegExp(r'^DN\d+$').hasMatch(v)) int.parse(v.substring(2)),
          ];
          expect(dns, [...dns]..sort(), reason: 'DN sizes ascend, not lexical');
          expect(next.values.where((v) => v.contains('מ׳')), isEmpty,
              reason: 'cm/meter twins collapse into one chip');
        }
        products = plainFilterBy(products, next.axis, next.values.first);
        used.add(next.axis);
      }
    }
    expect(sawSize, isTrue, reason: 'the drill does surface size rings');
  });

  test('FIX-F elbow collapses to one generic ברך leaf', () {
    final elbows = kPlainDict.where((n) => n.slang.startsWith('ברך')).toList();
    expect(elbows.length, 1, reason: 'the 45°/90° leaves merged into one');
    expect(elbows.single.english, 'Elbow', reason: 'generic, not "Elbow 90"');
    expect(plainProductsFor(elbows.single).length, greaterThan(50));
  });

  test('FIX-B the "איזה סוג?" type axis fires somewhere in the drill', () {
    var sawType = false;
    for (final n in kPlainDict) {
      var products = plainProductsFor(n);
      final used = <String>{};
      var g = 0;
      while (g++ < 12) {
        final next = plainNextAxis(products, usedAxes: used);
        if (next == null) break;
        if (next.axis == 'type') sawType = true;
        products = plainFilterBy(products, next.axis, next.values.first);
        used.add(next.axis);
      }
    }
    expect(sawType, isTrue,
        reason: 'big families split by kind instead of dumping a long list');
  });

  test('REACH: no ring ever strands a product (narrowing is loss-free)', () {
    // The real coverage guarantee, stated as the INVARIANT that gives it: at every
    // ring, the union of filtering by ALL offered values must equal the current set
    // (no product lacks a value on an offered axis). If that holds at every state,
    // every product reaches a final list — verified here on each node's greedy path.
    for (final sc in plainSuperCats()) {
      for (final cls in plainClassifications(sc)) {
        for (final n in plainNodes(sc, cls)) {
          var products = plainProductsFor(n);
          final used = <String>{};
          var g = 0;
          while (g++ < 12) {
            final next = plainNextAxis(products, usedAxes: used);
            if (next == null) break;
            final union = <String>{};
            for (final v in next.values) {
              for (final p in plainFilterBy(products, next.axis, v)) {
                union.add(p.sku);
              }
            }
            for (final p in products) {
              expect(union.contains(p.sku), isTrue,
                  reason: '${n.slang}: "${p.nameHe}" stranded by ${next.axis}');
            }
            products = plainFilterBy(products, next.axis, next.values.first);
            used.add(next.axis);
          }
        }
      }
    }
  });
}
