/// PURE soft-signal layer for the unified card-keyboard (#38), Phase 3.
///
/// Soft signals (connections + recipe) only matter once the dive has an ANCHOR —
/// a single resolved product to ask "what connects to THIS / what kit needs
/// THIS". The anchor rule (build-plan §1.5): [anchorOf] is the resolved product
/// when the pool has collapsed to ONE distinct card, else null.
///
/// CONSEQUENCE (an honest finding from building it): during a merged-keys turn
/// the pool has > kShowProductsThreshold distinct cards (the verdict ladder only
/// REACHES the merge then), so [anchorOf] is ALWAYS null there → the soft signals
/// are INERT in the merge (softTilt ≡ 1.0, zero connectionsFor calls — exactly
/// §1.5's "anchor == null → skip, no connectionsFor"). Their visible effect is at
/// RESOLUTION: the product card surfaces [softSuggestionsFor] (Phase 5). So
/// Phase 3 is the anchor rule + the suggestion accessor; it deliberately does NOT
/// re-weight the merge — that would be a guaranteed no-op (and the §1.5 invariant
/// "every MergedKeys chip is a hard axis with soft == false" already holds by
/// construction in Phase 2, with no soft key ever emitted).
///
/// PURE: no Flutter widgets / Riverpod / clock / IO; [pool]/[anchor] are
/// parameters only. Delegates to the SAME verified `connectionsFor` the live
/// finder + install engine use, so a suggestion here is exactly a connection the
/// install engine would make (no parallel compatibility logic).
library;

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show connectionsFor, distinctCardCount, distinctProducts;

/// The dive ANCHOR (build-plan §1.5): the single resolved product when [pool] has
/// collapsed to exactly ONE distinct card, else null. PURE & deterministic.
///
/// Null during any merged-keys turn (the pool is large there, > threshold
/// distinct cards), which is what keeps the merge soft-inert.
LipskeyCatalogProduct? anchorOf(List<LipskeyCatalogProduct> pool) {
  if (pool.isEmpty || distinctCardCount(pool) != 1) return null;
  return distinctProducts(pool).first;
}

/// The soft "what goes with this" suggestions for a resolved [anchor] — the
/// verified compatible parts via [connectionsFor] (the same pathfinder the
/// install engine uses; empty when [anchor] is not a valid connection anchor).
/// The product card (Phase 5) surfaces these beside the resolved product. PURE.
List<LipskeyCatalogProduct> softSuggestionsFor(
  LipskeyCatalogProduct anchor, {
  int tempC = 20,
}) =>
    connectionsFor(anchor, tempC: tempC);
