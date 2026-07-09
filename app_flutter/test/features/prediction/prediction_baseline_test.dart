// PRODUCT-PREDICTION BASELINE (measurement, not a pass/fail spec).
//
// Owner's real goal: the keyboard must be a CANNON at predicting WHICH PRODUCT
// you want. Before "improving in the air", this measures the current ranking:
// for every distinct product, we type its name WORD BY WORD (the natural way a
// user narrows) and record how many words it takes for that product to reach the
// TOP-1 and the TOP-4 of the ranked results (searchRelevance — the live panel
// sort). Fewer words = a better predictor.
//
// Re-run after each engine change to PROVE improvement with numbers, not feel:
//   flutter test test/features/prediction/prediction_baseline_test.dart
//
// The metrics are printed; a loose guard only catches gross regressions.

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/screens/catalog_screen.dart'
    show catalogProductMatchesQuery, searchRelevance;
import 'package:flutter_test/flutter_test.dart';

List<String> _words(String name) =>
    name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

void main() {
  test('BASELINE — words to reach the target product (top-1 / top-4)', () {
    // Collapse variants: a "product" the user wants is a distinct name (a card).
    final byName = <String, bool>{};
    for (final p in kCatalogProducts) {
      final n = p.nameHe.trim();
      if (n.isNotEmpty) byName[n] = true;
    }
    final targets = byName.keys.toList();

    // Ranking for a query = distinct matching names, best searchRelevance first.
    List<String> rankedNamesFor(String query) {
      final best = <String, int>{};
      for (final p in kCatalogProducts) {
        if (!catalogProductMatchesQuery(p, query)) continue;
        final n = p.nameHe.trim();
        final r = searchRelevance(p, query);
        if (r > (best[n] ?? -1)) best[n] = r;
      }
      final entries = best.entries.toList()
        ..sort((a, b) {
          final byRel = b.value.compareTo(a.value);
          return byRel != 0 ? byRel : a.key.compareTo(b.key);
        });
      return [for (final e in entries) e.key];
    }

    const maxWords = 5;
    final toTop1 = <int>[];
    final toTop4 = <int>[];
    var top1Ever = 0;
    var top4Ever = 0;
    var top4Within1 = 0;
    var top4Within2 = 0;
    var neverTop4 = 0;

    for (final target in targets) {
      final words = _words(target);
      if (words.isEmpty) continue;
      var firstTop1 = -1;
      var firstTop4 = -1;
      final cap = words.length < maxWords ? words.length : maxWords;
      for (var k = 1; k <= cap; k++) {
        final ranked = rankedNamesFor(words.take(k).join(' '));
        final rank = ranked.indexOf(target);
        if (rank == 0 && firstTop1 < 0) firstTop1 = k;
        if (rank >= 0 && rank < 4 && firstTop4 < 0) firstTop4 = k;
        if (firstTop1 > 0 && firstTop4 > 0) break;
      }
      if (firstTop1 > 0) {
        top1Ever++;
        toTop1.add(firstTop1);
      }
      if (firstTop4 > 0) {
        top4Ever++;
        toTop4.add(firstTop4);
        if (firstTop4 <= 1) top4Within1++;
        if (firstTop4 <= 2) top4Within2++;
      } else {
        neverTop4++;
      }
    }

    final n = targets.length;
    String pct(int x) => '${(100 * x / n).round()}%';
    String avg(List<int> xs) =>
        xs.isEmpty ? '—' : (xs.reduce((a, b) => a + b) / xs.length).toStringAsFixed(2);

    // ignore: avoid_print
    print('\n══════ PRODUCT-PREDICTION BASELINE ══════');
    // ignore: avoid_print
    print('distinct products (targets): $n');
    // ignore: avoid_print
    print('reach TOP-1 : $top1Ever (${pct(top1Ever)}) · avg words ${avg(toTop1)}');
    // ignore: avoid_print
    print('reach TOP-4 : $top4Ever (${pct(top4Ever)}) · avg words ${avg(toTop4)}');
    // ignore: avoid_print
    print('TOP-4 after 1 word : $top4Within1 (${pct(top4Within1)})   ← early-predict power');
    // ignore: avoid_print
    print('TOP-4 after ≤2 words: $top4Within2 (${pct(top4Within2)})');
    // ignore: avoid_print
    print('NEVER top-4 (≤$maxWords words): $neverTop4 (${pct(neverTop4)})');
    // ignore: avoid_print
    print('═════════════════════════════════════════\n');

    // Loose guard — only fails on a gross regression, not to gate the number.
    expect(top4Ever / n, greaterThan(0.5),
        reason: 'sanity: most products should reach top-4 within their name');
  });
}
