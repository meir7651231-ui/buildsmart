// PRODUCT-PREDICTION BASELINE vs IMPROVED (measurement, not a pass/fail spec).
//
// Owner's real goal: the keyboard must be a CANNON at predicting WHICH PRODUCT
// you want. This types every distinct product's name WORD BY WORD and records how
// many words it takes to reach the TOP-1 / TOP-4 of the ranked results — for TWO
// rankings, side by side:
//   • BASE     = searchRelevance only (today's live sort).
//   • IMPROVED = searchRelevance, then productProminence as the tie-breaker
//                (image · verified specs · dive pool · brevity · page).
// Fewer words / more early-top-4 = a better predictor. The delta PROVES the
// improvement in numbers, not feel.
//
//   flutter test test/features/prediction/prediction_baseline_test.dart

import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/features/global_search/prediction_ranking.dart'
    show nameAffinity, productProminence;
import 'package:buildsmart/screens/catalog_screen.dart'
    show catalogProductMatchesQuery, searchRelevance;
import 'package:flutter_test/flutter_test.dart';

List<String> _words(String name) =>
    name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

class _Acc {
  final toTop1 = <int>[];
  final toTop4 = <int>[];
  int top1Ever = 0;
  int top4Ever = 0;
  int top4Within1 = 0;
  int top4Within2 = 0;
  int neverTop4 = 0;
}

void main() {
  test('BASELINE vs IMPROVED — words to reach the target product', () {
    final targets = <String>{
      for (final p in kCatalogProducts)
        if (p.nameHe.trim().isNotEmpty) p.nameHe.trim(),
    }.toList();

    // For a query, rank distinct names two ways sharing ONE match pass.
    ({List<String> base, List<String> improved}) rankedFor(String query) {
      final rel = <String, int>{};
      final bonus = <String, int>{};
      for (final p in kCatalogProducts) {
        if (!catalogProductMatchesQuery(p, query)) continue;
        final n = p.nameHe.trim();
        final r = searchRelevance(p, query);
        if (r > (rel[n] ?? -1)) rel[n] = r;
        final b = nameAffinity(p, query) + productProminence(p);
        if (b > (bonus[n] ?? -1)) bonus[n] = b;
      }
      final names = rel.keys.toList();
      final base = [...names]
        ..sort((a, b) {
          final byRel = rel[b]!.compareTo(rel[a]!);
          return byRel != 0 ? byRel : a.compareTo(b);
        });
      final improved = [...names]
        ..sort((a, b) {
          final byRel = rel[b]!.compareTo(rel[a]!);
          if (byRel != 0) return byRel;
          final byBonus = bonus[b]!.compareTo(bonus[a]!);
          return byBonus != 0 ? byBonus : a.compareTo(b);
        });
      return (base: base, improved: improved);
    }

    const maxWords = 5;
    final base = _Acc();
    final imp = _Acc();

    void record(_Acc acc, List<String> ranked, String target, int k,
        List<int> firstTop1, List<int> firstTop4) {
      final rank = ranked.indexOf(target);
      if (rank == 0 && firstTop1[0] < 0) firstTop1[0] = k;
      if (rank >= 0 && rank < 4 && firstTop4[0] < 0) firstTop4[0] = k;
    }

    for (final target in targets) {
      final words = _words(target);
      if (words.isEmpty) continue;
      final cap = words.length < maxWords ? words.length : maxWords;
      final bT1 = [-1], bT4 = [-1], iT1 = [-1], iT4 = [-1];
      for (var k = 1; k <= cap; k++) {
        final r = rankedFor(words.take(k).join(' '));
        record(base, r.base, target, k, bT1, bT4);
        record(imp, r.improved, target, k, iT1, iT4);
        if (bT1[0] > 0 && bT4[0] > 0 && iT1[0] > 0 && iT4[0] > 0) break;
      }
      void tally(_Acc a, List<int> t1, List<int> t4) {
        if (t1[0] > 0) {
          a.top1Ever++;
          a.toTop1.add(t1[0]);
        }
        if (t4[0] > 0) {
          a.top4Ever++;
          a.toTop4.add(t4[0]);
          if (t4[0] <= 1) a.top4Within1++;
          if (t4[0] <= 2) a.top4Within2++;
        } else {
          a.neverTop4++;
        }
      }

      tally(base, bT1, bT4);
      tally(imp, iT1, iT4);
    }

    final n = targets.length;
    String pct(int x) => '${(100 * x / n).round()}%';
    String avg(List<int> xs) => xs.isEmpty
        ? '—'
        : (xs.reduce((a, b) => a + b) / xs.length).toStringAsFixed(2);
    void report(String label, _Acc a) {
      // ignore: avoid_print
      print('── $label ──');
      // ignore: avoid_print
      print('  TOP-1 : ${a.top1Ever} (${pct(a.top1Ever)}) · avg ${avg(a.toTop1)} words');
      // ignore: avoid_print
      print('  TOP-4 : ${a.top4Ever} (${pct(a.top4Ever)}) · avg ${avg(a.toTop4)} words');
      // ignore: avoid_print
      print('  TOP-4 after 1 word : ${a.top4Within1} (${pct(a.top4Within1)})');
      // ignore: avoid_print
      print('  TOP-4 after ≤2 words: ${a.top4Within2} (${pct(a.top4Within2)})');
      // ignore: avoid_print
      print('  NEVER top-4        : ${a.neverTop4} (${pct(a.neverTop4)})');
    }

    // ignore: avoid_print
    print('\n══════ PRODUCT-PREDICTION: BASE vs IMPROVED ($n products) ══════');
    report('BASE (relevance only)', base);
    report('IMPROVED (+ prominence tie-break)', imp);
    // ignore: avoid_print
    print('  Δ TOP-4 after 1 word : ${imp.top4Within1 - base.top4Within1} products');
    // ignore: avoid_print
    print('  Δ NEVER top-4        : ${imp.neverTop4 - base.neverTop4} products');
    // ignore: avoid_print
    print('══════════════════════════════════════════════════════════════\n');

    // Guard: the improvement must NOT regress early prediction.
    expect(imp.top4Within1, greaterThanOrEqualTo(base.top4Within1),
        reason: 'prominence tie-break must not reduce top-4-after-1-word');
    expect(imp.top4Within2, greaterThanOrEqualTo(base.top4Within2));
  });
}
