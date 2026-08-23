// pool_seed.dart — the ONE seed funnel (P7.62). Every mouth (word/material/job/
// category/text/voice/AI) ultimately yields a [CardSeed]; [seedStep] turns it into
// the SINGLE opening step ([kOpeningSeedAxis] — a non-signal sentinel, so no real
// axis is pre-answered), and [seedPool] applies it over the universe. ONE funnel,
// ONE axis: the screen wires every mouth through here (P7.68). PURE.

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/features/card_keyboard/card_seed.dart'
    show CardSeed, kWordMouth;
import 'package:buildsmart/features/card_keyboard/seed_sources.dart'
    show categorySeeds, materialSeeds;
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/synonym_bridge.dart'
    show resolveQuery;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show NewbieStep;
import 'package:buildsmart/features/word_finder/word_lexicon.dart'
    show WordLexicon;

/// The SINGLE opening-seed axis label — public, non-signal, shared by EVERY mouth,
/// so a seed (whatever the mouth) keeps every real axis (size/material/colour/…)
/// offer-able and the dive still terminates. Replaces the per-mouth sentinels'
/// role once the screen migrates (P7.68).
const String kOpeningSeedAxis = '_seed.opening';

/// The seeded pool: the [universe] narrowed by [seed]'s predicate. Never invents —
/// every result is a real universe product.
List<LipskeyCatalogProduct> seedPool(
  CardSeed seed,
  List<LipskeyCatalogProduct> universe,
) =>
    universe.where(seed.seedPredicate).toList();

/// The opening step a [seed] pushes — the SAME shape for every mouth (one funnel).
NewbieStep seedStep(CardSeed seed) => NewbieStep(
      axisLabel: kOpeningSeedAxis,
      chipLabel: seed.displayLabel,
      crumbWord: seed.displayLabel,
      predicate: seed.seedPredicate,
    );

/// A predicate admitting exactly the products in [skus].
bool Function(LipskeyCatalogProduct) _admits(Set<String> skus) =>
    (p) => skus.contains(p.sku);

/// Seed from free text (P7.63): [resolveQuery] folds synonyms + unions multi-word
/// terms over the universe. Returns null when NOTHING resolves (all-unknown), so the
/// caller shows an honest empty state instead of a false dead-end.
CardSeed? seedFromText(String query, WordLexicon lexicon) {
  final skus = resolveQuery(query, lexicon).toSet();
  if (skus.isEmpty) return null;
  return CardSeed(
    mouthId: kWordMouth,
    displayLabel: query,
    seedAxisLabel: kOpeningSeedAxis,
    seedPredicate: _admits(skus),
  );
}

/// Seed from a material name — the matching material bucket, or null if unknown.
CardSeed? seedFromMaterial(String material) {
  for (final s in materialSeeds(kDivePool)) {
    if (s.displayLabel == material) return s;
  }
  return null;
}

/// Seed from a category/facet group — the matching bucket, or null if unknown.
CardSeed? seedFromFacet(String group) {
  for (final s in categorySeeds(kDivePool)) {
    if (s.displayLabel == group) return s;
  }
  return null;
}

/// Seed from an explicit sku set (a deep link / related-products jump), or null when
/// empty. Never invents — only skus already in the pool can match.
CardSeed? seedFromSkus(Set<String> skus, String label) {
  if (skus.isEmpty) return null;
  return CardSeed(
    mouthId: kWordMouth,
    displayLabel: label,
    seedAxisLabel: kOpeningSeedAxis,
    seedPredicate: _admits(skus),
  );
}
