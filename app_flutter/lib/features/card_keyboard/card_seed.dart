// card_seed.dart — the ONE seam every CLICK mouth shares (word-grid, material, job,
// category/emoji). Each mouth emits CardSeeds; tapping one seeds the dive the SAME
// way — a NewbieStep with the seed's predicate + a per-mouth axis-label sentinel
// that keeps the real signal axes offer-able (mirrors the opening word seed). So a
// new mouth is "a CardSeed source", never a new tap path. PURE data; the screen
// wires it (P6.58). TOUCHES NO PRODUCTION BEHAVIOUR until then.

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;

/// A single tappable seed from a click mouth.
class CardSeed {
  const CardSeed({
    required this.mouthId,
    required this.displayLabel,
    required this.seedPredicate,
    required this.seedAxisLabel,
    this.emoji,
  });

  /// Which mouth produced this seed (one of the `k*Mouth` ids).
  final String mouthId;

  /// The chip label shown to the user.
  final String displayLabel;

  /// Optional leading emoji (the category mouth uses it; null elsewhere).
  final String? emoji;

  /// Pure pool narrower — the products this seed admits.
  final bool Function(LipskeyCatalogProduct) seedPredicate;

  /// The NewbieStep axis label: a per-mouth SENTINEL, distinct from every signal
  /// axisName, so seeding never pre-answers a real axis (the axis stays offer-able).
  final String seedAxisLabel;
}

/// The click mouths' ids.
const String kWordMouth = 'word';
const String kMaterialMouth = 'material';
const String kJobMouth = 'job';
const String kCategoryMouth = 'category';

/// Per-mouth axis-label sentinels — pairwise distinct, and (by the `_seed.` prefix)
/// distinct from any signal axisName ('גודל'/'חומר'/'צבע'/'דגם'/'אפשרות'/'זווית'),
/// so a seed keeps every real axis offer-able.
const String kWordSeedAxis = '_seed.word';
const String kMaterialSeedAxis = '_seed.material';
const String kJobSeedAxis = '_seed.job';
const String kCategorySeedAxis = '_seed.category';

/// All seed-axis sentinels — for the distinctness invariant and the screen's
/// "is this a seed axis (keep axes open)?" check.
const Set<String> kSeedAxisSentinels = {
  kWordSeedAxis,
  kMaterialSeedAxis,
  kJobSeedAxis,
  kCategorySeedAxis,
};
