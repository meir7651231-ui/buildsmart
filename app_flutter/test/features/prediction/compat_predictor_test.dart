// CONTEXT-SEEDED prediction measurement (swarm finding #1: Compatibility-Graph-as-
// Predictor). The word-by-word baseline harness STRUCTURALLY cannot show this gain
// — it strips the context the idea exploits. So this seeds an ANCHOR product (as if
// it were in the cart / on the line) and measures whether a broad query surfaces
// the product that PHYSICALLY MATES the anchor into the TOP-4 — with vs without the
// matesBoost. This is the metric that proves the "orthogonal signal" breaks the
// zero-sum wall.
//
//   flutter test test/features/prediction/compat_predictor_test.dart

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/data/related_info.dart' show compatibleProductsFor;
import 'package:buildsmart/features/global_search/prediction_ranking.dart'
    show contextCompatibleSkus, matesBoost, nameAffinity, productProminence;
import 'package:buildsmart/screens/catalog_screen.dart'
    show catalogProductMatchesQuery, searchRelevance;
import 'package:flutter_test/flutter_test.dart';

List<String> _words(String s) =>
    s.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

void main() {
  test('CONTEXT-SEEDED — the compat-graph predictor lifts the FITTING product',
      () {
    // Build (anchor, target) pairs: target physically mates the anchor and has a
    // searchable first word. A user with `anchor` on the line who types the
    // target's head-noun should be shown the target — because it fits.
    final pairs = <(LipskeyCatalogProduct, LipskeyCatalogProduct)>[];
    outer:
    for (final anchor in kCatalogProducts) {
      for (final target in compatibleProductsFor(anchor).take(2)) {
        final w = _words(target.nameHe);
        if (w.isEmpty || w.first.length < 2) continue;
        pairs.add((anchor, target));
        if (pairs.length >= 600) break outer;
      }
    }

    // Rank distinct names for [query] with a given per-product bonus, keeping
    // searchRelevance primary (exactly like the live diveResultsProvider sort).
    List<String> ranked(String query, int Function(LipskeyCatalogProduct) bonusOf) {
      final rel = <String, int>{};
      final bon = <String, int>{};
      for (final p in kCatalogProducts) {
        if (!catalogProductMatchesQuery(p, query)) continue;
        final n = p.nameHe.trim();
        final r = searchRelevance(p, query);
        if (r > (rel[n] ?? -1)) rel[n] = r;
        final b = bonusOf(p);
        if (b > (bon[n] ?? -1)) bon[n] = b;
      }
      return rel.keys.toList()
        ..sort((a, b) {
          final byRel = rel[b]!.compareTo(rel[a]!);
          if (byRel != 0) return byRel;
          final byBon = bon[b]!.compareTo(bon[a]!);
          return byBon != 0 ? byBon : a.compareTo(b);
        });
    }

    var baseTop4 = 0;
    var boostTop4 = 0;
    var n = 0;
    for (final (anchor, target) in pairs) {
      final query = _words(target.nameHe).first;
      final compatibleSkus = contextCompatibleSkus([anchor]);
      final tName = target.nameHe.trim();
      final base = ranked(
          query, (p) => nameAffinity(p, query) + productProminence(p));
      final boost = ranked(
          query,
          (p) =>
              nameAffinity(p, query) +
              productProminence(p) +
              matesBoost(p, compatibleSkus));
      final rb = base.indexOf(tName);
      final rx = boost.indexOf(tName);
      if (rb >= 0 && rb < 4) baseTop4++;
      if (rx >= 0 && rx < 4) boostTop4++;
      n++;
    }

    String pct(int x) => '${(100 * x / n).round()}%';
    // ignore: avoid_print
    print('\n══ CONTEXT-SEEDED compat-predictor ($n anchor→fitting pairs) ══');
    // ignore: avoid_print
    print('  fitting product in TOP-4, NO context   : $baseTop4 (${pct(baseTop4)})');
    // ignore: avoid_print
    print('  fitting product in TOP-4, CART-seeded  : $boostTop4 (${pct(boostTop4)})');
    // ignore: avoid_print
    print('  Δ = +${boostTop4 - baseTop4} pairs (+${pct(boostTop4 - baseTop4)})\n');

    expect(boostTop4, greaterThanOrEqualTo(baseTop4),
        reason: 'seeding the cart with a mating anchor must not hurt');
  });
}
