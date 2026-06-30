import 'package:buildsmart/features/card_keyboard/hop_graph.dart';
import 'package:buildsmart/features/word_finder/word_finder_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reachWithin / hopsBetween basics', () {
    final g = HopGraph.build();
    final src =
        divePoolBySku.keys.firstWhere((s) => g.neighborsOf(s).isNotEmpty);
    final r1 = g.reachWithin(src, 1);
    expect(r1.contains(src), isFalse); // excludes src
    expect(r1, g.neighborsOf(src).toSet()); // 1-hop == direct neighbours
    final n = g.neighborsOf(src).first;
    expect(g.hopsBetween(src, n), 1);
    expect(g.hopsBetween(src, src), 0);
    // reachWithin is monotone in maxHops.
    expect(g.reachWithin(src, 4).length, greaterThanOrEqualTo(r1.length));
  });

  test('hopsBetween is null or within maxHops', () {
    final g = HopGraph.build();
    final a = divePoolBySku.keys.first;
    final b = divePoolBySku.keys.last;
    final d = g.hopsBetween(a, b);
    expect(d == null || (d >= 0 && d <= 4), isTrue);
  });

  test('MEASURE current connectivity (instrument — NOT asserting <=4 yet)', () {
    final g = HopGraph.build();
    final nodes = divePoolBySku.keys.toList();
    var isolated = 0;
    for (final s in nodes) {
      if (g.neighborsOf(s).isEmpty) isolated++;
    }
    final step = (nodes.length / 120).ceil().clamp(1, nodes.length);
    var samples = 0;
    var sumReach = 0;
    for (var i = 0; i < nodes.length; i += step) {
      samples++;
      sumReach += g.reachWithin(nodes[i], 4).length;
    }
    final avgReach4 = samples == 0 ? 0 : (sumReach / samples).round();
    // Surface the pre-superHub diameter health so it is visible in the log (this is
    // a diagnostic measurement, not production code).
    // ignore: avoid_print
    print('hop_reach MEASURE: ${nodes.length} nodes, $isolated isolated '
        '(0 out-edges); sample avg reachWithin4 = $avgReach4. A LOW reach / HIGH '
        'isolated here is EXPECTED pre-superHub (P8 builds the <=4 backbone).');
    // Sanity only — the <=4 assertion lands with the superHub backbone (P8).
    expect(isolated, greaterThanOrEqualTo(0));
    expect(avgReach4, greaterThanOrEqualTo(0));
  });
}
