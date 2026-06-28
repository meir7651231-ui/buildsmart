import 'package:buildsmart/features/card_keyboard/hop_graph.dart';
import 'package:buildsmart/features/word_finder/word_finder_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('skeleton node-set == divePoolBySku.keys (real products only, no virtual nodes)',
      () {
    final g = HopGraph.skeleton();
    expect(g.nodes.toSet(), divePoolBySku.keys.toSet());
  });

  test('EdgeKind has exactly the 5 navigational kinds (incl. the P8.73 hub)', () {
    expect(EdgeKind.values.length, 5);
    expect(
      EdgeKind.values,
      containsAll(<EdgeKind>[
        EdgeKind.compat,
        EdgeKind.variant,
        EdgeKind.kit,
        EdgeKind.category,
        EdgeKind.hub,
      ]),
    );
  });

  test('the skeleton has no edges (the populated graph carries them)', () {
    final g = HopGraph.skeleton();
    final a = divePoolBySku.keys.first;
    final b = divePoolBySku.keys.elementAt(1);
    expect(g.neighborsOf(a), isEmpty);
    expect(g.kindsBetween(a, b), isEmpty);
  });
}
