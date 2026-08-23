import 'package:buildsmart/features/card_keyboard/hop_graph.dart';
import 'package:buildsmart/features/word_finder/word_finder_engine.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, List<String>> _byCat() {
  final byCat = <String, List<String>>{};
  for (final e in divePoolBySku.entries) {
    final c = e.value.categoryHe;
    if (c.isEmpty) continue;
    (byCat[c] ??= <String>[]).add(e.key);
  }
  return byCat;
}

void main() {
  test('two same-categoryHe same-system products are category-adjacent', () {
    final g = HopGraph.build();
    var found = false;
    for (final skus in _byCat().values) {
      for (var i = 0; i < skus.length && !found; i++) {
        for (var j = i + 1; j < skus.length && !found; j++) {
          if (!crossesSystem(skus[i], skus[j])) {
            expect(
              g.kindsBetween(skus[i], skus[j]).contains(EdgeKind.category),
              isTrue,
            );
            found = true;
          }
        }
      }
      if (found) break;
    }
    expect(found, isTrue, reason: 'expected a same-category same-system pair');
  });

  test('NO category edge crosses a WaterSystem (exhaustive)', () {
    final g = HopGraph.build();
    for (final a in divePoolBySku.keys) {
      for (final b in g.neighborsOf(a)) {
        if (g.kindsBetween(a, b).contains(EdgeKind.category)) {
          expect(
            crossesSystem(a, b),
            isFalse,
            reason: 'category edge $a -> $b crosses supply<->drainage',
          );
        }
      }
    }
  });

  test('every categorised node with a same-system peer has >=1 category edge', () {
    final g = HopGraph.build();
    for (final skus in _byCat().values) {
      for (final a in skus) {
        final hasPeer = skus.any((b) => b != a && !crossesSystem(a, b));
        if (!hasPeer) continue;
        final hasCatEdge = g
            .neighborsOf(a)
            .any((n) => g.kindsBetween(a, n).contains(EdgeKind.category));
        expect(hasCatEdge, isTrue,
            reason: '$a has a same-system category peer but no category edge');
      }
    }
  });

  test('graph scale is sane (all 4 kinds present, edge count bounded)', () {
    final g = HopGraph.build();
    final kinds = <EdgeKind>{};
    var edges = 0;
    for (final a in divePoolBySku.keys) {
      for (final b in g.neighborsOf(a)) {
        edges++;
        kinds.addAll(g.kindsBetween(a, b));
      }
    }
    // Surface the edge count so a pathological category-clique blow-up is visible
    // in the test log (this is a diagnostic test, not production code).
    // ignore: avoid_print
    print('hop_graph scale: $edges directed edges over ${divePoolBySku.length} '
        'nodes; kinds=$kinds');
    expect(kinds, containsAll(EdgeKind.values));
    // A full directed graph over ~1300 nodes would be ~1.7M edges; assert we are
    // well under that (a pathological category clique would approach it).
    expect(edges, lessThan(900000),
        reason: 'edge count $edges — category clique may be blowing up');
  });
}
