/// Build-time WORD LEXICON for the product finder (בית/מאתר).
///
/// STEP 2 of the word-finder swarm — the upper layer over `word_extraction.dart`.
/// A PURE library (no Flutter widgets, no Riverpod providers), snapshot-testable
/// from `kDivePool`. Mirrors the purity and first-seen determinism of
/// `catalog_lens._bucketBy`.
///
/// WHAT IT PRODUCES:
///   A map from a single plain Hebrew WORD (what a non-technical user types —
///   "ברז", "ברך", "צינור") to the skus that word names, plus a flat list of
///   [WordEntry] records carrying provenance (`sourceKind`) and frequency
///   (sku count). The word per product is:
///     canonicalizeWord(firstMeaningfulToken(nameHe, kBrandPrefixBlocklist),
///                      kWordSynonyms)
///   and, when no meaningful token survives, the category fallback
///   (`kCategoryFallbackWord[categoryHe]`). Products that yield neither are
///   dropped from the lexicon (they have no searchable word).
///
/// DETERMINISM: words appear in first-seen order across the input pool, exactly
/// like `_bucketBy` — so the built lexicon is stable and snapshot-comparable.
library;

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/features/word_finder/word_extraction.dart';

/// One word in the lexicon: the [word] itself, the [skus] it names (in
/// first-seen pool order), where the word came from ([sourceKind] — one of
/// 'token', 'category', 'curated'), and its [freq] (== `skus.length`).
class WordEntry {
  const WordEntry({
    required this.word,
    required this.skus,
    required this.sourceKind,
    required this.freq,
  });

  final String word;
  final List<String> skus;

  /// Provenance of the word:
  ///   'token'    — the product's first meaningful name token.
  ///   'category' — a `kCategoryFallbackWord` value (first token was a brand).
  ///   'curated'  — reserved for owner-curated additions (none built here yet).
  final String sourceKind;

  /// Number of skus this word names. Always equals `skus.length`.
  final int freq;
}

/// The built lexicon: ordered [entries] plus a fast [wordToSkus] lookup. Both
/// share the same first-seen word order and the same sku lists.
class WordLexicon {
  const WordLexicon({required this.entries, required this.wordToSkus});

  final List<WordEntry> entries;
  final Map<String, List<String>> wordToSkus;
}

/// Builds the [WordLexicon] from a product [pool] (typically `kDivePool`).
///
/// For each product: word = canonicalize(firstMeaningfulToken(nameHe)); if that
/// is null/empty, fall back to `kCategoryFallbackWord[categoryHe]` (sourceKind
/// 'category'). Products yielding neither are skipped. SKUs accumulate under
/// their word in first-seen order; the first word also fixes the word's
/// position in [WordLexicon.entries] (the `_bucketBy` idiom). PURE and
/// deterministic — same pool in ⇒ identical lexicon out.
WordLexicon buildWordLexicon(List<LipskeyCatalogProduct> pool) {
  final skusByWord = <String, List<String>>{};
  final sourceByWord = <String, String>{};
  final order = <String>[];

  for (final p in pool) {
    final token = firstMeaningfulToken(p.nameHe, kBrandPrefixBlocklist);
    String? word;
    String source;
    if (token != null && token.isNotEmpty) {
      word = canonicalizeWord(token, kWordSynonyms);
      source = 'token';
    } else {
      // First token was a brand (or all numbers): use the category's layman
      // word. May still be null for categories without a seeded fallback.
      final fallback = kCategoryFallbackWord[p.categoryHe];
      if (fallback == null || fallback.isEmpty) continue; // no searchable word
      word = canonicalizeWord(fallback, kWordSynonyms);
      source = 'category';
    }

    if (!skusByWord.containsKey(word)) {
      order.add(word);
      // First-seen source wins the label; a later 'category' hit on a word
      // already established by a 'token' won't downgrade it.
      sourceByWord[word] = source;
    }
    skusByWord.putIfAbsent(word, () => <String>[]).add(p.sku);
  }

  final entries = [
    for (final w in order)
      WordEntry(
        word: w,
        skus: skusByWord[w]!,
        sourceKind: sourceByWord[w]!,
        freq: skusByWord[w]!.length,
      ),
  ];

  return WordLexicon(entries: entries, wordToSkus: skusByWord);
}
