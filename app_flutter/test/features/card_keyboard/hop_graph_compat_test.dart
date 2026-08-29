import 'package:buildsmart/features/card_keyboard/hop_graph.dart';
import 'package:buildsmart/features/word_finder/word_finder_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('build() populates compat edges', () {
    final g = HopGraph.build();
    final hasCompat = divePoolBySku.keys.any(
      (sku) => g
          .neighborsOf(sku)
          .any((n) => g.kindsBetween(sku, n).contains(EdgeKind.compat)),
    );
    expect(hasCompat, isTrue);
  });

  test('NO compat edge crosses a WaterSystem (exhaustive)', () {
    final g = HopGraph.build();
    for (final a in divePoolBySku.keys) {
      for (final b in g.neighborsOf(a)) {
        if (g.kindsBetween(a, b).contains(EdgeKind.compat)) {
          expect(
            crossesSystem(a, b),
            isFalse,
            reason: 'compat edge $a -> $b crosses supply<->drainage',
          );
        }
      }
    }
  });

  test('every edge is real: no self-loop, neighbour is a node', () {
    final g = HopGraph.build();
    final nodes = divePoolBySku.keys.toSet();
    for (final a in divePoolBySku.keys) {
      for (final b in g.neighborsOf(a)) {
        expect(b == a, isFalse);
        expect(nodes.contains(b), isTrue);
      }
    }
  });
}
