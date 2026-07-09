// ─────────────────────────────────────────────────────────────────────────────
// PREDICTION RANKING — a PROMINENCE prior for product prediction (pure).
//
// The baseline harness showed WHY early prediction is weak: a broad first word
// ("ברז") makes ~100 products tie on query-relevance (all score the same), so the
// intended one lands at a near-random position and rarely reaches the top 4. This
// breaks that tie toward the product a user most likely MEANS: the ones the
// catalog SHOWCASES (a real photo), products with VERIFIED connection specs
// (central / known-good), the CURATED dive pool, shorter/generic names, and
// earlier catalog pages.
//
// SUBORDINATE TO RELEVANCE: callers sort by (searchRelevance DESC, prominence
// DESC, …), so a specific multi-word query still wins by name match — prominence
// only decides among products the query scores EQUALLY. Pure + deterministic →
// directly unit-testable and measurable in the prediction baseline harness.
// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/lipskey_verified_connections.dart'
    show kVerifiedSpecs;
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;

/// SKUs of the curated dive pool — a Set for O(1) membership (built once).
final Set<String> _diveSkus = {for (final p in kDivePool) p.sku};

final RegExp _wsSplit = RegExp(r'\s+');

/// PURE. How CENTRAL [query] is to [p]'s name — the non-zero-sum half of the
/// prediction tie-break. The baseline's biggest single leak: a product whose name
/// IS the query (e.g. the generic "ברז") tied with ~100 products that merely
/// CONTAIN "ברז", so it was buried instead of leading. This rewards the literal
/// interpretation — an exact name, then a prefix, then how much of the name the
/// query covers (a short/generic name where the query is most of it). Each product
/// wins for ITS OWN name, so unlike a popularity prior this lifts the uniform
/// metric. Subordinate to [searchRelevance] (callers keep that primary).
int nameAffinity(LipskeyCatalogProduct p, String query) {
  final name = p.nameHe.trim().toLowerCase();
  final q = query.trim().toLowerCase();
  // Affinity is a NAME signal only — a product matched via its category/colour
  // (query absent from the name) gets none, so it never outranks a real name hit.
  if (q.isEmpty || name.isEmpty || !name.contains(q)) return 0;
  var s = 0;
  if (name == q) {
    s += 300; // the name IS the query — the strongest literal signal
  } else if (name.startsWith(q)) {
    s += 120; // the name STARTS with the query
  }
  // Coverage: the query as a fraction of the name — a short/generic name where
  // the query is most of it beats a long variant that merely embeds it.
  s += (q.length * 60 / name.length).round().clamp(0, 60);
  return s;
}

/// PURE. How PROMINENT [p] is, independent of the query — the tie-breaker that
/// pushes the product a user most likely means above equally-relevant matches.
/// Higher = more likely the intended early pick. Deterministic.
int productProminence(LipskeyCatalogProduct p) {
  var s = 0;
  // Showcased: the catalog cropped a real photo for it (the common, displayed
  // products — obscure variants have none).
  if (p.imageFile != null) s += 60;
  // Central / known-good: it has verified connection specs (the products the
  // engine trusts for compatibility — the backbone of the catalogue).
  if (kVerifiedSpecs.containsKey(p.sku)) s += 40;
  // Curated: part of the finder's hand-picked dive pool.
  if (_diveSkus.contains(p.sku)) s += 25;
  // Brevity: fewer name tokens ⇒ more GENERIC ⇒ more likely the first thing a
  // broad query means ("ברז" over "מחבר עם ברז ניל ואטם כפול").
  final toks = p.nameHe.trim().split(_wsSplit).where((t) => t.isNotEmpty).length;
  s += (12 - toks).clamp(0, 12);
  // Earlier catalog page ⇒ more prominent placement (small, capped contribution).
  s += ((300 - p.page) ~/ 30).clamp(0, 10);
  return s;
}
