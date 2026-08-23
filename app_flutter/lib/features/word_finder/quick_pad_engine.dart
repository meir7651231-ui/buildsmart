/// PURE quick-pad ranking engine for the DIVERSE-LIST mode (the "ערב-רב"
/// quick re-order pad — the user's most-used products surfaced as fast
/// quick-add keys).
///
/// STEP of the word-finder swarm, kept PURE in the spirit of `dive_pool.dart`
/// (STEP 1), `word_lexicon.dart` / `word_extraction.dart` (STEP 2) and
/// `narrow_axis.dart` (STEP 0): no Flutter widgets, no Riverpod providers.
/// Importing it pulls in zero UI (only `@immutable` from flutter/foundation).
///
/// WHAT IT PRODUCES:
///   A capped, deduped, deterministic list of [QuickPick]s — one per product —
///   resolved from plain SKU collections the SCREEN hands in. The screen reads
///   the Riverpod providers (favorites / recents / usage-frequency) and passes
///   their raw sku lists here, so this engine stays pure and unit-testable.
///
/// PRIORITY / DEDUPE (first-wins keeps the highest-priority source):
///   favorites → frequent → recent.
/// A sku that appears in several inputs is emitted ONCE under its highest
/// source. SKUs absent from `kDivePool` are dropped (the pad only shows real,
/// addable products). The label is a SHORT human word derived from `nameHe`
/// via the SAME `firstMeaningfulToken` + `canonicalizeWord` idiom the word
/// lexicon uses — NOT the full technical name.
///
/// DETERMINISM: same inputs in ⇒ identical list out. The sku→product map over
/// `kDivePool` is precomputed once (first-wins on a sku collision, mirroring
/// the dive-pool's own dedupe order).
library;

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart';
import 'package:buildsmart/features/word_finder/word_extraction.dart';
import 'package:flutter/foundation.dart';

/// One key on the quick-pad: the resolved [product], a SHORT display [label]
/// for the key face, and the [source] that surfaced it.
@immutable
class QuickPick {
  const QuickPick({
    required this.product,
    required this.label,
    required this.source,
  });

  final LipskeyCatalogProduct product;

  /// SHORT human display string for the key — see [quickLabel]. Never the full
  /// technical `nameHe`.
  final String label;

  /// Which signal surfaced this product. One of:
  ///   'favorite' — user-pinned (productFavoritesProvider).
  ///   'frequent' — high per-item usage tally (smartInputUsageProvider).
  ///   'recent'   — recently viewed (recentlyViewedProvider).
  /// ('search' is reserved for a future recent-search-derived source; included
  /// in the documented vocabulary so callers can pass it without a code change.)
  final String source;
}

/// sku → product over the deduped `kDivePool`, built fresh once. FIRST-WINS on
/// a sku collision, matching the dive-pool's own source-priority dedupe.
final Map<String, LipskeyCatalogProduct> _bySku = _buildBySku();

Map<String, LipskeyCatalogProduct> _buildBySku() {
  final out = <String, LipskeyCatalogProduct>{};
  for (final p in kDivePool) {
    out.putIfAbsent(p.sku, () => p); // first-wins; kDivePool is already deduped
  }
  return out;
}

/// The SHORT display label for a product's quick-pad key.
///
/// Reuses the lexicon's proven derivation so the pad shows the SAME plain word
/// the rest of the finder buckets by:
///   1. the first meaningful token of `nameHe` (brand-prefix skipped,
///      sizes/codes dropped), canonicalized via `kWordSynonyms`;
///   2. else the category's layman fallback word (`kCategoryFallbackWord`);
///   3. else the trimmed `nameHe` (never empty for a real catalog product).
/// Guaranteed non-empty for any product carrying a `nameHe`.
String quickLabel(LipskeyCatalogProduct p) {
  final token = firstMeaningfulToken(p.nameHe, kBrandPrefixBlocklist);
  if (token != null && token.isNotEmpty) {
    return canonicalizeWord(token, kWordSynonyms);
  }
  final fallback = kCategoryFallbackWord[p.categoryHe];
  if (fallback != null && fallback.isNotEmpty) {
    return canonicalizeWord(fallback, kWordSynonyms);
  }
  return p.nameHe.trim();
}

/// Builds the ordered, deduped, capped list of [QuickPick]s for the quick-pad.
///
/// ORDER: favorites first, then frequent, then recent. DEDUPE by sku across all
/// three (first-wins keeps the highest-priority source). SKUs not in `kDivePool`
/// are dropped. The result is capped to [cap]. PURE and deterministic.
///
/// The SCREEN supplies the raw sku collections (it reads the Riverpod providers
/// — see the stage-B wiring note); this engine never touches providers.
///
///  - [favSkus]      : the favorite sku SET (`productFavoritesProvider`).
///  - [frequentSkus] : most-used skus, most-frequent first (derived from
///    `smartInputUsageProvider`).
///  - [recentSkus]   : recently-viewed skus, newest first
///    (`recentlyViewedProvider`).
List<QuickPick> quickPicks({
  required Set<String> favSkus,
  List<String> recentSkus = const [],
  List<String> frequentSkus = const [],
  int cap = 30,
}) {
  final out = <QuickPick>[];
  final taken = <String>{};

  void add(Iterable<String> skus, String source) {
    for (final sku in skus) {
      if (out.length >= cap) return;
      if (!taken.add(sku)) continue; // already emitted under a higher source
      final product = _bySku[sku];
      if (product == null) continue; // not a real, addable product → drop
      out.add(QuickPick(
        product: product,
        label: quickLabel(product),
        source: source,
      ));
    }
  }

  // Favorites is a Set (unordered); its members all share the top priority, so
  // intra-group order is not contractually meaningful — only that they precede
  // frequent and recent.
  add(favSkus, 'favorite');
  add(frequentSkus, 'frequent');
  add(recentSkus, 'recent');

  return List.unmodifiable(out);
}
