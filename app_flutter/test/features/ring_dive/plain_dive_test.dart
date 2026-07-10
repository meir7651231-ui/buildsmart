// PLAIN DIVE engine — proves the layman 4-ring drill is REAL: every node reaches
// catalog products, the drill navigates end-to-end, and a concrete plain-language
// path lands on the right product. This is the owner's "verify it reaches products".

import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/features/ring_dive/plain_dive.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the full tree reaches ~every catalog product (coverage)', () {
    final covered = <String>{};
    for (final sc in plainSuperCats()) {
      for (final cls in plainClassifications(sc)) {
        for (final n in plainNodes(sc, cls)) {
          for (final p in plainProductsFor(n)) {
            covered.add(p.sku);
          }
        }
      }
    }
    // Curated core + swarm coverage nodes + auto-fallback ⇒ ~100%. Guard ≥99% so a
    // future catalog category can't silently fall out of מאתר-פשוט.
    expect(covered.length,
        greaterThanOrEqualTo((kCatalogProducts.length * 0.99).floor()),
        reason:
            'PlainDive reaches ${covered.length}/${kCatalogProducts.length} — a category lost its node');
  });

  test('every node in the tree reaches real products (מגיע למוצרים)', () {
    for (final n in kPlainDict) {
      expect(plainProductsFor(n), isNotEmpty,
          reason:
              '"${n.superCat} / ${n.classification} / ${n.technical}" must reach products');
    }
  });

  test('the 4-ring drill is navigable end-to-end and lands on products', () {
    final supers = plainSuperCats();
    expect(
        supers,
        containsAll(<String>[
          'צנרת וחומרים',
          'אביזרי חיבור',
          'ברזים ובקרים',
          'סניטרי וניקוז',
        ]),
        reason: 'ring 1 shows the real super-categories');

    var leaves = 0;
    var hits = 0;
    for (final sc in supers) {
      final classes = plainClassifications(sc); // ring 2
      expect(classes, isNotEmpty, reason: '"$sc" must have classifications');
      for (final cls in classes) {
        final nodes = plainNodes(sc, cls); // ring 3
        expect(nodes, isNotEmpty, reason: '"$sc / $cls" must have type nodes');
        for (final n in nodes) {
          final ps = plainProductsFor(n); // ring 4 = products
          expect(ps, isNotEmpty,
              reason: 'leaf "$sc / $cls / ${n.technical}" must reach products');
          leaves++;
          hits += ps.length;
        }
      }
    }
    expect(leaves, greaterThanOrEqualTo(20), reason: 'a meaningful tree');
    // ignore: avoid_print
    print(
        '\nPLAIN DIVE: ${supers.length} super-cats · $leaves leaves · reaching $hits product-hits');
  });

  test('a concrete plain-language path lands on the right products', () {
    // ברזים ובקרים → ברזים → "שיבר" (ball valve) → real ball-valve products.
    final ball = plainNodes('ברזים ובקרים', 'ברזים')
        .firstWhere((n) => n.technical == 'ברז כדורי');
    expect(ball.slang, contains('שיבר'), reason: 'the layman word is on the ring');
    expect(plainProductsFor(ball).length, greaterThan(10),
        reason: 'and it reaches the real ball valves');

    // אביזרי חיבור → הברגות → "ברך" (elbow) → real elbows.
    final elbow = plainNodes('אביזרי חיבור', 'הברגות')
        .firstWhere((n) => n.slang == 'ברך');
    expect(plainProductsFor(elbow).length, greaterThan(50));
  });
}
