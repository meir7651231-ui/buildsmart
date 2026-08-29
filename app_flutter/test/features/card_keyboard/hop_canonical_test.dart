// P9.90: hopsBetween, reachWithin and rankedNeighborsOf all read ONE canonical graph
// (HopGraph.build()) — there is no separate distance graph. So the rail's reachability and
// the <=4 distance metric must AGREE, and the <=4 contract holds via that single graph.

import 'package:buildsmart/features/card_keyboard/hop_graph.dart';
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show divePoolBySku;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hopsBetween agrees with reachWithin on the ONE canonical graph', () {
    final g = HopGraph.build();
    final nodes = divePoolBySku.keys.toList();
    final stride = (nodes.length / 20).ceil();
    for (var i = 0; i < nodes.length; i += stride) {
      final src = nodes[i];
      final reach4 = g.reachWithin(src, 4);
      for (var j = 0; j < nodes.length; j += stride * 3) {
        final dst = nodes[j];
        if (src == dst) continue;
        final d = g.hopsBetween(src, dst); // default maxHops is 4
        expect(d != null, reach4.contains(dst),
            reason: 'hopsBetween and reachWithin must read the same graph');
      }
    }
  });

  test('the <=4 contract holds via the canonical graph (every sampled source)', () {
    final g = HopGraph.build();
    final nodes = divePoolBySku.keys.toList();
    final stride = (nodes.length / 15).ceil();
    for (var i = 0; i < nodes.length; i += stride) {
      final reach4 = g.reachWithin(nodes[i], 4);
      expect(reach4.length, nodes.length - 1,
          reason: '${nodes[i]} must reach every other product within 4 hops');
    }
  });

  test('rankedNeighborsOf is the 1-hop slice of the same graph', () {
    final g = HopGraph.build();
    final nodes = divePoolBySku.keys.toList();
    final stride = (nodes.length / 40).ceil();
    for (var i = 0; i < nodes.length; i += stride) {
      final src = nodes[i];
      expect(g.rankedNeighborsOf(src).toSet(), g.reachWithin(src, 1),
          reason: 'the rail edges ARE the 1-hop neighbours of the census graph');
    }
  });
}
