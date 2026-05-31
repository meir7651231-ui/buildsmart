import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';

/// Forgiving search over the catalog: returns products whose [nameHe] contains
/// every word of the query (case-insensitive, whitespace-tolerant), ranked by
/// how *tightly* the match sits. The query "ברז AQUATEC" matches a product
/// named "ברז לכיור — AQUATEC" but also "AQUATEC ברז מטבח". Empty query →
/// empty result. Roadmap step 62 (helper only — UI search box TBD).
///
/// Ranking: products where the WHOLE query appears as one substring rank
/// highest, otherwise products with words closer together rank higher. Within
/// the same rank, catalog order is preserved (stable sort).
///
/// Default source is the UNIFIED catalog (`kCatalogProducts` = Lipskey +
/// Polyroll) — searching `kLipskeyCatalog` alone would silently miss PPR.
List<LipskeyCatalogProduct> fuzzySearchProducts(String query,
    {Iterable<LipskeyCatalogProduct>? products, int limit = 20}) {
  final q = query.trim();
  if (q.isEmpty) return const [];
  final words =
      q.toLowerCase().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return const [];
  final phrase = q.toLowerCase();

  final source = (products ?? kCatalogProducts).toList();
  final ranked = <({LipskeyCatalogProduct p, int score, int order})>[];

  for (var i = 0; i < source.length; i++) {
    final p = source[i];
    final hay = p.nameHe.toLowerCase();
    var ok = true;
    for (final w in words) {
      if (!hay.contains(w)) {
        ok = false;
        break;
      }
    }
    if (!ok) continue;

    // 0 = best (whole phrase as substring). +1 per missing-adjacency.
    var score = 1000;
    if (hay.contains(phrase)) {
      score = 0;
    } else if (words.length > 1) {
      // crude proximity: sum of distances between first occurrences.
      var prev = -1;
      for (final w in words) {
        final idx = hay.indexOf(w, prev + 1);
        if (prev >= 0 && idx > prev) score += (idx - prev);
        prev = idx;
      }
    }
    ranked.add((p: p, score: score, order: i));
  }

  ranked.sort((a, b) {
    final c = a.score.compareTo(b.score);
    return c != 0 ? c : a.order.compareTo(b.order);
  });

  return [for (final e in ranked.take(limit)) e.p];
}
