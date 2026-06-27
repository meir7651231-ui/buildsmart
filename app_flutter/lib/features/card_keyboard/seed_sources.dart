// seed_sources.dart — the click mouths' CardSeed sources (P6.52-55). Each function
// turns one mouth's data into CardSeeds over the union pool; the screen renders them
// identically and a tap seeds the dive (P6.58). PURE; nothing wired here.

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/features/card_keyboard/card_seed.dart';
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
