import 'package:buildsmart/features/card_keyboard/hop_graph.dart';
import 'package:buildsmart/features/word_finder/word_finder_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('skeleton node-set == divePoolBySku.keys (real products only, no virtual nodes)',
      () {
    final g = HopGraph.skeleton();
    expect(g.nodes.toSet(), divePoolBySku.keys.toSet());
  });

  test('EdgeKind has exactly the 4 navigational kinds', () {
    expect(EdgeKind.values.length, 4);
    expect(
      EdgeKind.values,
      containsAll(<EdgeKind>[
        EdgeKind.compat,
        EdgeKind.variant,
        EdgeKind.kit,
        EdgeKind.category,
      ]),
    );
  });

  test('the skeleton has no edges (the <=4 claim is not asserted yet)', () {
    final g = HopGraph.skeleton();
    final a = divePoolBySku.keys.first;
    final b = divePoolBySku.keys.elementAt(1);
    expect(g.neighborsOf(a), isEmpty);
    expect(g.kindsBetween(a, b), isEmpty);
  });
}
