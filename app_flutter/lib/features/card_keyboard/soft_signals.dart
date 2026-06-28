// soft_signals.dart — the soft re-ranking layer (P9.82-83). Soft signals (a chip relating
// to a connected product, a recipe/kit, or recently-viewed history) NEVER add or drop a
// chip — they only nudge its order WITHIN its axis via a multiplier in [1.0, kMaxSoftTilt].
// The multiplier is 1.0 (inert) when a chip matches no anchor, and there IS no anchor until
// the pool narrows toward convergence — so a wide-open card is byte-identical to the
// hard-signal ordering. Pure — unit-tested in isolation.

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/smart_tree.dart' show SmartProduct;
import 'package:buildsmart/features/word_finder/recipe_kit.dart'
    show KitMatch, assembleKit;

/// The strongest a soft tilt can get (every anchor matched).
const double kMaxSoftTilt = 1.6;

/// Per-anchor bumps, ordered by signal strength: a verified connection counts most, then
/// recipe co-membership, then recently-viewed history. They sum to exactly the cap.
const double kSoftConnectionBump = 0.25;
const double kSoftRecipeBump = 0.20;
const double kSoftHistoryBump = 0.15;

/// The widest a pool can be and still have a dominant soft anchor. Above this the pool is
/// too broad for soft signals to mean anything: [softAnchor] returns null and softTilt
/// stays inert, so the wide-open card keeps its hard-signal order byte-for-byte.
const int kNearConvergence = 8;

/// A soft re-ranking multiplier for a chip from the soft anchors it matches. 1.0 (inert)
/// when it matches none; never exceeds [kMaxSoftTilt]. Soft signals only reorder WITHIN an
/// axis — never add, drop, or cross axes.
double softTilt({
  bool connection = false,
  bool recipe = false,
  bool history = false,
}) {
  var tilt = 1.0;
  if (connection) tilt += kSoftConnectionBump;
  if (recipe) tilt += kSoftRecipeBump;
  if (history) tilt += kSoftHistoryBump;
  return tilt > kMaxSoftTilt ? kMaxSoftTilt : tilt;
}

/// The soft anchor of [pool] near convergence: the pool's own skus when it is small enough
/// that a dominant theme exists (2..[kNearConvergence]), else null. softTilt checks a
/// chip's connection/recipe relations AGAINST this set; a wide pool → null → inert. The
/// full universe is the widest pool, so `softAnchor(kDivePool) == null`.
Set<String>? softAnchor(List<LipskeyCatalogProduct> pool) {
  if (pool.length < 2 || pool.length > kNearConvergence) return null;
  return {for (final p in pool) p.sku};
}

/// The resolved member skus of [recipe]'s kit — the co-members a chip can softly relate to.
/// Only resolved lines (curated/auto/swarm, a real bound product) count; ambiguous and none
/// lines carry no product.
Set<String> kitSkusFor(SmartProduct recipe) => {
      for (final line in assembleKit(recipe))
        if (line.product != null &&
            (line.match == KitMatch.curated ||
                line.match == KitMatch.auto ||
                line.match == KitMatch.swarm))
          line.product!.sku,
    };
