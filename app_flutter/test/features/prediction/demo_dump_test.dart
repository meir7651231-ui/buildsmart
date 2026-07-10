// Not a test — a DATA DUMP for the owner-facing demo. Finds the most dramatic
// real (anchor, query) case where staging the anchor lifts a physically-mating
// product from buried to the top, and prints both rankings with real names so the
// demo widget shows TRUE catalog data, not invented examples.
//
//   flutter test test/features/prediction/demo_dump_test.dart

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/data/related_info.dart'
    show compatibleProductsFor, connectionJoint;
import 'package:buildsmart/features/global_search/prediction_ranking.dart'
    show contextCompatibleSkus, matesBoost, nameAffinity, productProminence;
import 'package:buildsmart/screens/catalog_screen.dart'
    show catalogProductMatchesQuery, searchRelevance;
import 'package:flutter_test/flutter_test.dart';

String _head(String s) {
  for (final w in s.trim().split(RegExp(r'\s+'))) {
    if (w.isNotEmpty) return w;
  }
  return '';
}

void main() {
  test('DUMP a vivid real before/after for the demo', () {
    List<LipskeyCatalogProduct> ranked(
        String query, int Function(LipskeyCatalogProduct) bonusOf) {
      final best = <String, LipskeyCatalogProduct>{};
      final rel = <String, int>{};
      final bon = <String, int>{};
      for (final p in kCatalogProducts) {
        if (!catalogProductMatchesQuery(p, query)) continue;
        final n = p.nameHe.trim();
        final r = searchRelevance(p, query);
        if (r > (rel[n] ?? -1)) {
          rel[n] = r;
          best[n] = p;
        }
        final b = bonusOf(p);
        if (b > (bon[n] ?? -1)) bon[n] = b;
      }
      final names = rel.keys.toList()
        ..sort((a, b) {
          final byRel = rel[b]!.compareTo(rel[a]!);
          if (byRel != 0) return byRel;
          final byBon = bon[b]!.compareTo(bon[a]!);
          return byBon != 0 ? byBon : a.compareTo(b);
        });
      return [for (final n in names) best[n]!];
    }

    // Hunt for the pair with the biggest lift where the target reaches #0/#1 with
    // context and was ≥6 without — a case the eye immediately reads as "wow".
    ({
      LipskeyCatalogProduct anchor,
      LipskeyCatalogProduct target,
      String query,
      int rank0,
      List<LipskeyCatalogProduct> base,
      List<LipskeyCatalogProduct> boost
    })? best;
    var bestGain = 0;

    var scanned = 0;
    outer:
    for (final anchor in kCatalogProducts) {
      final compat = compatibleProductsFor(anchor);
      if (compat.isEmpty) continue;
      for (final target in compat.take(3)) {
        final q = _head(target.nameHe);
        if (q.length < 2) continue;
        final base = ranked(q, (p) => nameAffinity(p, q) + productProminence(p));
        final rank0 = base.indexWhere((p) => p.sku == target.sku);
        if (rank0 < 6) continue; // want a clearly-buried target
        final mates = contextCompatibleSkus([anchor]);
        final boost = ranked(
            q,
            (p) =>
                nameAffinity(p, q) + productProminence(p) + matesBoost(p, mates));
        final rank1 = boost.indexWhere((p) => p.sku == target.sku);
        if (rank1 > 1) continue; // want it to reach the very top
        final gain = rank0 - rank1;
        if (gain > bestGain) {
          bestGain = gain;
          best = (
            anchor: anchor,
            target: target,
            query: q,
            rank0: rank0,
            base: base,
            boost: boost
          );
        }
        if (++scanned >= 4000) break outer;
      }
    }

    expect(best, isNotNull, reason: 'expected a vivid demo pair');
    final b = best!;
    String row(LipskeyCatalogProduct p, {bool star = false}) {
      final joint = connectionJoint(b.anchor, p);
      final tag = joint != null ? '  ⟵ מתחבר (${joint.size})' : '';
      return '${star ? '★' : ' '} ${p.nameHe}${star ? tag : ''}';
    }

    // ignore: avoid_print
    print('\n╔══ DEMO DUMP ══╗');
    // ignore: avoid_print
    print('ANCHOR (in cart): ${b.anchor.nameHe}  [${b.anchor.sku}]');
    // ignore: avoid_print
    print('QUERY typed     : "${b.query}"');
    // ignore: avoid_print
    print('TARGET (mates)  : ${b.target.nameHe}  — was #${b.rank0}, now #0/#1');
    // ignore: avoid_print
    print('\n── BEFORE (no cart) top-8 ──');
    for (var i = 0; i < 8 && i < b.base.length; i++) {
      // ignore: avoid_print
      print('$i.${row(b.base[i], star: b.base[i].sku == b.target.sku)}');
    }
    // ignore: avoid_print
    print('\n── AFTER (anchor staged) top-8 ──');
    for (var i = 0; i < 8 && i < b.boost.length; i++) {
      // ignore: avoid_print
      print('$i.${row(b.boost[i], star: b.boost[i].sku == b.target.sku)}');
    }
    // ignore: avoid_print
    print('╚═══════════════╝\n');
  });
}
