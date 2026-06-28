// P8.73: the hub-clique backbone makes the <=4 contract hold BY CONSTRUCTION — one
// real-product rep per group, every product <-> its rep, reps a clique. So no node
// is isolated and any two products are <=3 hops apart.
// ignore_for_file: avoid_print

import 'package:buildsmart/features/card_keyboard/hop_graph.dart';
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show divePoolBySku;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('NO isolated node — every product hops to its group rep', () {
    final g = HopGraph.build();
    final isolated =
        divePoolBySku.keys.where((s) => g.neighborsOf(s).isEmpty).toList();
    expect(isolated, isEmpty,
        reason: 'the hub backbone must leave zero isolated products');
  });

  test('EVERY source reaches the WHOLE universe within 4 hops (exhaustive)', () {
    // Swarm-review (high): was a ~30-source STRIDE sample, so a regression that isolated a
    // non-sampled node would pass green. Single-source BFS over the whole node-set is cheap
    // here, so we wash ALL of them and pin the true worst source — no blind spots.
    final g = HopGraph.build();
    final nodes = divePoolBySku.keys.toList();
    final target = nodes.length - 1; // everything except the source
    var worst = target;
    String? worstNode;
    for (final s in nodes) {
      final reach = g.reachWithin(s, 4).length;
      if (reach < worst) {
        worst = reach;
        worstNode = s;
      }
    }
    expect(worst, target,
        reason: 'worst source $worstNode reaches $worst/$target within 4 hops — '
            'one unreachable node breaks the <=4 contract');
    print('HUB: ${nodes.length} nodes, EXHAUSTIVE worst-source reachWithin4 = '
        '$worst (== $target means full <=4 connectivity)');
  });
}
