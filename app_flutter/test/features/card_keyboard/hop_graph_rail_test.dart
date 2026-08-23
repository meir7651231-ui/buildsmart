// P8.77/79: rankedNeighborsOf is the on-screen 'related' rail's edge order — most
// meaningful relation first (variant > kit > compat > category), the isolation hub
// last. It is a PERMUTATION of neighborsOf, so the <=4 census proven over the graph
// (hop_graph_hub_test) holds for the rail verbatim, and it is NEVER empty (no
// dead-end product) because the hub backbone guarantees >=1 neighbour.

import 'package:buildsmart/features/card_keyboard/hop_graph.dart';
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show divePoolBySku;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rankedNeighborsOf is never empty — no dead-end product (incl. hot water)',
      () {
    final g = HopGraph.build();
    final dead =
        divePoolBySku.keys.where((s) => g.rankedNeighborsOf(s).isEmpty).toList();
    expect(dead, isEmpty,
        reason: 'the hub backbone guarantees >=1 rail neighbour per product');
  });

  test('rankedNeighborsOf surfaces a meaningful relation above the hub fallback',
      () {
    final g = HopGraph.build();
    // a product that HAS a non-hub (meaningful) neighbour
    final sku = divePoolBySku.keys.firstWhere((s) => g
        .neighborsOf(s)
        .any((n) => g.kindsBetween(s, n).any((k) => k != EdgeKind.hub)));
    final first = g.rankedNeighborsOf(sku).first;
    expect(g.kindsBetween(sku, first).any((k) => k != EdgeKind.hub), isTrue,
        reason: 'the rail must rank a real relation above the hub fallback');
  });

  test('rankedNeighborsOf is a permutation of neighborsOf (rail edges == graph edges)',
      () {
    final g = HopGraph.build();
    final nodes = divePoolBySku.keys.toList();
    final stride = (nodes.length / 50).ceil();
    for (var i = 0; i < nodes.length; i += stride) {
      final s = nodes[i];
      final ranked = g.rankedNeighborsOf(s);
      expect(ranked.toSet(), g.neighborsOf(s).toSet());
      expect(ranked.length, g.neighborsOf(s).length, reason: 'no duplicate');
    }
  });
}
