import 'package:buildsmart/data/variant_families.dart';
import 'package:buildsmart/features/card_keyboard/hop_graph.dart';
import 'package:buildsmart/features/word_finder/word_finder_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('build() makes the members of an in-pool variant family pairwise adjacent',
      () {
    final g = HopGraph.build();
    final fams = allVariantFamilies()
        .where((f) =>
            f.products.where((p) => divePoolBySku.containsKey(p.sku)).length >= 2)
        .toList();
    expect(fams, isNotEmpty, reason: 'expected >=1 in-pool variant family');
    final members = fams.first.products
        .where((p) => divePoolBySku.containsKey(p.sku))
        .map((p) => p.sku)
        .toList();
    final a = members[0];
    final b = members[1];
    expect(g.kindsBetween(a, b).contains(EdgeKind.variant), isTrue);
    expect(g.kindsBetween(b, a).contains(EdgeKind.variant), isTrue);
  });

  test('every variant edge is symmetric (a clique within the family)', () {
    final g = HopGraph.build();
    for (final a in divePoolBySku.keys) {
      for (final b in g.neighborsOf(a)) {
        if (g.kindsBetween(a, b).contains(EdgeKind.variant)) {
          expect(
            g.kindsBetween(b, a).contains(EdgeKind.variant),
            isTrue,
            reason: 'variant edge $a -> $b is not symmetric',
          );
        }
      }
    }
  });
}
