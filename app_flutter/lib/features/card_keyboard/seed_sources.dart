// seed_sources.dart — the click mouths' CardSeed sources (P6.52-55). Each function
// turns one mouth's data into CardSeeds over the union pool; the screen renders them
// identically and a tap seeds the dive (P6.58). PURE; nothing wired here.

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/smart_tree.dart' show kSmartProducts;
import 'package:buildsmart/features/card_keyboard/card_seed.dart';
import 'package:buildsmart/features/word_finder/category_groups.dart'
    show groupOf;
import 'package:buildsmart/features/word_finder/material_lexicon.dart'
    show materialOfEnriched, materialsInPoolEnriched;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show kFirstWordCount, wordsByFrequency;
import 'package:buildsmart/features/word_finder/word_lexicon.dart'
    show WordLexicon;

/// Word-grid mouth (P6.52): one CardSeed per lexicon word, admitting the products
/// that word names. Collapsed shows the top-[kFirstWordCount] (the SAME prefix the
/// opening AskWords uses); [expanded] shows the full long tail (the 'עוד…' toggle,
/// P6.59).
List<CardSeed> wordSeeds(WordLexicon lexicon, {bool expanded = false}) {
  final entries = wordsByFrequency(lexicon);
  final visible =
      expanded ? entries : entries.take(kFirstWordCount).toList();
  return [
    for (final e in visible)
      CardSeed(
        mouthId: kWordMouth,
        displayLabel: e.word,
        seedAxisLabel: kWordSeedAxis,
        seedPredicate: _admitsSkus(e.skus),
      ),
  ];
}

/// A predicate admitting exactly the products in [skus] (a Set for O(1) lookup).
bool Function(LipskeyCatalogProduct) _admitsSkus(List<String> skus) {
  final set = skus.toSet();
  return (p) => set.contains(p.sku);
}

/// Material mouth (P6.53): one CardSeed per material present in [pool] (the ENRICHED
/// census — dims-typed materials count too). Each admits the products of that
/// material; נחושת FOLDS brass (materialOfEnriched maps פליז → נחושת). GATE-EXEMPT:
/// a seed source, NOT the coverage-gated material AXIS (MaterialSignal) — this seeds,
/// it does not ask.
List<CardSeed> materialSeeds(List<LipskeyCatalogProduct> pool) {
  return [
    for (final m in materialsInPoolEnriched(pool))
      CardSeed(
        mouthId: kMaterialMouth,
        displayLabel: m,
        seedAxisLabel: kMaterialSeedAxis,
        seedPredicate: _admitsMaterial(m),
      ),
  ];
}

/// A predicate admitting exactly the products whose enriched material is [material].
bool Function(LipskeyCatalogProduct) _admitsMaterial(String material) =>
    (p) => materialOfEnriched(p) == material;

/// Job mouth (P6.54): one CardSeed per recipe in [kSmartProducts] (the "by the job"
/// on-ramp). Each admits the recipe's REAL catalog SKUs — the brand + accessory skus
/// it references, never invented — and carries the recipe emoji. mouthId=kJobMouth.
List<CardSeed> jobSeeds() {
  return [
    for (final recipe in kSmartProducts)
      CardSeed(
        mouthId: kJobMouth,
        displayLabel: recipe.name,
        emoji: recipe.emoji,
        seedAxisLabel: kJobSeedAxis,
        seedPredicate: _admitsSkus([
          for (final b in recipe.brands)
            if (b.sku != null) b.sku!,
          for (final a in recipe.acc)
            if (a.sku != null) a.sku!,
        ]),
      ),
  ];
}

/// Category/emoji mouth (P6.55): one CardSeed per category group present in [pool].
/// [groupOf] is TOTAL — every product maps to a group, falling back to 'אחר' — so the
/// buckets COVER 100% of the universe with ZERO orphan, and are disjoint (groupOf is
/// a function). emoji is null until a group→emoji map lands. mouthId=kCategoryMouth.
List<CardSeed> categorySeeds(List<LipskeyCatalogProduct> pool) {
  final groups = pool.map(groupOf).toSet().toList()..sort();
  return [
    for (final g in groups)
      CardSeed(
        mouthId: kCategoryMouth,
        displayLabel: g,
        seedAxisLabel: kCategorySeedAxis,
        seedPredicate: _admitsGroup(g),
      ),
  ];
}

/// A predicate admitting exactly the products in category group [group].
bool Function(LipskeyCatalogProduct) _admitsGroup(String group) =>
    (p) => groupOf(p) == group;
