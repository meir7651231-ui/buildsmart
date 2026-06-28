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

  test('every sampled source reaches the WHOLE universe within 4 hops', () {
    final g = HopGraph.build();
    final nodes = divePoolBySku.keys.toList();
    final target = nodes.length - 1; // everything except the source
    final stride = (nodes.length / 30).ceil();
    var worst = target;
    for (var i = 0; i < nodes.length; i += stride) {
      final reach = g.reachWithin(nodes[i], 4).length;
      if (reach < worst) worst = reach;
      expect(reach, target,
          reason: '${nodes[i]} reaches $reach/$target within 4 hops');
    }
    print('HUB: ${nodes.length} nodes, worst-source reachWithin4 = $worst '
        '(== $target means full <=4 connectivity)');
  });
}
