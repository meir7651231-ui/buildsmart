import 'package:buildsmart/features/card_keyboard/hop_graph.dart';
import 'package:buildsmart/features/word_finder/word_finder_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('build() populates at least one kit edge', () {
    final g = HopGraph.build();
    final hasKit = divePoolBySku.keys.any(
      (a) => g
          .neighborsOf(a)
          .any((b) => g.kindsBetween(a, b).contains(EdgeKind.kit)),
    );
    expect(hasKit, isTrue);
  });

  test('NO kit edge crosses a WaterSystem (exhaustive)', () {
    final g = HopGraph.build();
    for (final a in divePoolBySku.keys) {
      for (final b in g.neighborsOf(a)) {
        if (g.kindsBetween(a, b).contains(EdgeKind.kit)) {
          expect(
            crossesSystem(a, b),
            isFalse,
            reason: 'kit edge $a -> $b crosses supply<->drainage',
          );
        }
      }
    }
  });

  test('kit edges are symmetric (co-membership)', () {
    final g = HopGraph.build();
    for (final a in divePoolBySku.keys) {
      for (final b in g.neighborsOf(a)) {
        if (g.kindsBetween(a, b).contains(EdgeKind.kit)) {
          expect(
            g.kindsBetween(b, a).contains(EdgeKind.kit),
            isTrue,
            reason: 'kit edge $a -> $b is not symmetric',
          );
        }
      }
    }
  });
}
