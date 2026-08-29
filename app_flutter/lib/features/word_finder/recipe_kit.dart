/// PURE data-bridge for the WORK-RECIPE engine (engine #6 of the word-finder
/// swarm — "מתכון העבודה").
///
/// THE PROBLEM IT SOLVES:
///   `kSmartProducts` (smart_tree.dart) is a hand-authored library of work
///   recipes. Each recipe lists its accessories as [SmartAcc] rows, but most of
///   those rows carry a NAME ONLY — their `sku` is null (≈305 of 363 across the
///   tree). A name like "סרט טפלון" or "אטם דו צדדי" is human-readable but is
///   NOT yet linked to a catalog product, so the recipe cannot (today) drop the
///   accessory straight into a cart. This bridge TRANSLATES each accessory name
///   into a catalog product (`LipskeyCatalogProduct`) using the SAME search
///   relevance the catalog screen already uses, measures HOW MUCH of the tree it
///   can resolve, and assembles a per-recipe kit.
///
/// PURITY (and the documented Flutter coupling):
///   This library imports NO Flutter widgets and builds NO UI. It is a plain
///   transform over const data and is deterministic — same recipe in ⇒ same kit
///   out, no clock, no randomness, no I/O.
///   It DOES import `searchRelevance` from `screens/catalog_screen.dart`, which
///   transitively pulls `package:flutter/...` into the dependency chain (the
///   catalog screen is a widget file). This mirrors what `word_finder_screen`
///   and the rest of the finder already do; the function we use
///   (`searchRelevance`) is itself a pure `int` scorer over a product + query.
///   The consequence is only a TEST-HARNESS one: like every other finder
///   library that touches this chain (see `word_finder_engine.dart`'s coupling
///   note), `recipe_kit`'s tests run under `flutter_test`, not a bare
///   `dart test`. No new Flutter coupling is introduced beyond that single
///   already-present import.
library;

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/recipe_acc_overrides.dart';
import 'package:buildsmart/screens/catalog_screen.dart' show searchRelevance;
import 'package:flutter/foundation.dart';

/// How confidently a [SmartAcc] was bound to a catalog product.
///
///  - [curated] : the accessory already carries an owner-set `sku` AND that sku
///    is a real product in the pool. The strongest binding — a human chose it.
///  - [auto]    : no curated sku, but the name resolves to ONE clearly-best
///    catalog product (top relevance clears the confidence floor AND beats the
///    runner-up by a decisive margin). Safe to auto-fill.
///  - [ambiguous] : the name matched SOMETHING, but not confidently — either the
///    best score is below the auto floor, or several products tie within the
///    margin (e.g. a generic "אטם" matches dozens). Needs OWNER review before it
///    can be trusted; the best candidate is kept so the owner can confirm/reject.
///  - [none]    : nothing in the catalog matched the name at all (score 0 or
///    below the minimum floor). No product is attached.
///  - [swarm]   : no owner sku and the keyword scorer could not resolve it, but
///    the match+verify SWARM picked a product semantically AND a second agent
///    verified it (see [kAccSkuOverrides]). Machine-confident, pending owner
///    spot-check — counted as resolved like [curated] / [auto].
enum KitMatch { curated, auto, ambiguous, none, swarm }

/// The resolution of ONE accessory row: the original [acc], the catalog
/// [product] it bound to (null for [KitMatch.none]), the [match] confidence, and
/// the relevance [score] that produced it (0 for a curated/none row that did not
/// go through the scorer; the curated row's score is left at 0 because it was
/// chosen by sku, not by relevance).
@immutable
class KitLine {
  const KitLine({
    required this.acc,
    required this.product,
    required this.match,
    required this.score,
    this.alternatives = const <LipskeyCatalogProduct>[],
  });

  /// The recipe accessory this line resolves (name / why / must / etc.).
  final SmartAcc acc;

  /// The catalog product the accessory bound to, or null when [match] is
  /// [KitMatch.none]. For a [KitMatch.swarm] line this is the RECOMMENDED
  /// (top-ranked) product; [alternatives] holds the rest.
  final LipskeyCatalogProduct? product;

  /// How confident the binding is.
  final KitMatch match;

  /// The [searchRelevance] score behind an [KitMatch.auto] / [KitMatch.ambiguous]
  /// binding. For [KitMatch.curated] / [KitMatch.swarm] it is 0 (the row was
  /// bound by sku/rank, not by score); for [KitMatch.none] it is the top score
  /// seen (0 or below floor).
  final int score;

  /// For a [KitMatch.swarm] line: the ALTERNATIVE products (ranked AFTER
  /// [product]) the UI can offer beside the recommended default — the "or here
  /// are other options" list. Empty for every other match kind.
  final List<LipskeyCatalogProduct> alternatives;
}

// ── OWNER-REVIEW tuning constants ───────────────────────────────────────────
//
// These thresholds govern when an auto-translation is trusted. They are
// CONSERVATIVE BY DESIGN: they prefer to flag a row [ambiguous] (owner confirms)
// over emitting a confident-but-wrong [auto]. The owner may loosen them once a
// spot-check of the auto rows looks right.
//
// Scoring reminder (from `catalog_screen.searchRelevance`): the WHOLE accessory
// phrase appearing inside a product name scores +100; each accessory word found
// in a name adds +20 (category-only +8, colour +6, synonym +12/+4).
//
// THE DISCRIMINATOR IS THE MARGIN, NOT THE ABSOLUTE SCORE. Measured against the
// real tree+catalog, the generic / wrong matches all TIE at the top (several
// products share the accessory's words, so top == runner-up, margin 0) — e.g.
// "אטם דו צדדי" tops at 160 but a dozen products score 160, and "מיכל הדחה סמוי"
// tops at 40 with many ties. A genuinely UNIQUE accessory instead leaves the
// runner-up far behind: "מד לחץ" → top 140 / runner-up 20 (margin 120),
// "צינור ניקוז" → top 140 / runner-up 32 (margin 108). Coincidental single-token
// overlaps (a shared size like 10 מ"מ) produce only a small margin (≤20). So the
// auto gate requires BOTH a real absolute score AND a decisive margin over the
// runner-up; everything else — ties, weak tops, coincidental overlaps — stays
// [KitMatch.ambiguous] for owner review.

/// Minimum top score for ANY binding. Below this the accessory is [KitMatch.none]
/// (a score of 8 means only a category-level word matched — too weak to attach a
/// specific product; a score of 0 means the catalog simply has no such product,
/// e.g. "סרט טפלון" / "משקוף" / "רובה אפוקסי", which carry no catalog name). The
/// owner can still review near-floor rows because they surface as [KitMatch.none]
/// with their score recorded. OWNER-REVIEW.
const int kKitMinScore = 8;

/// The absolute score the single best product must reach to be eligible for
/// [KitMatch.auto]. 140 = the WHOLE multi-token name appears in the product name
/// (+100) AND both its words land (2 × +20) — a genuine multi-token 1:1 match.
/// This floor sits deliberately ABOVE the single-token ceiling: a one-word name
/// maxes at 120 (+100 whole-phrase, +20 token), so a lone generic word that
/// coincidentally hits exactly ONE product (large margin) can NEVER reach auto —
/// it stays [KitMatch.ambiguous] for owner review. Combined with [kKitAutoMargin]
/// this keeps BOTH single-token coincidences AND strong-but-tied multi-token
/// names (e.g. "אטם דו צדדי", top 160 with many ties) out of auto. OWNER-REVIEW.
const int kKitAutoScore = 140;

/// How far the best score must EXCEED the runner-up to call it [KitMatch.auto].
/// 40 = a clear two-word-class gap, so only an accessory whose top product stands
/// decisively apart (margin ≥ 40, like "מד לחץ" at 120 or "צינור ניקוז" at 108)
/// auto-binds; ties (margin 0) and coincidental single-token overlaps (margin
/// ≤ 20) stay [KitMatch.ambiguous]. OWNER-REVIEW.
const int kKitAutoMargin = 40;

/// sku → product over the deduped [kDivePool], built once. Used to (a) confirm a
/// curated `acc.sku` actually exists in the pool and (b) is the universe the
/// relevance scorer ranks. FIRST-WINS on a collision, matching the pool's own
/// dedupe order (the pool is already deduped, so this is just an index).
final Map<String, LipskeyCatalogProduct> _bySku = {
  for (final p in kDivePool) p.sku: p,
};

/// Resolves a single recipe [acc] to a [KitLine] by the documented rules:
///
///  1. CURATED — `acc.sku` is set AND present in [kDivePool] → bind to that exact
///     product with [KitMatch.curated]. (A curated sku that is NOT in the pool
///     falls through to scoring, so a stale owner sku still gets a best-effort
///     match rather than silently attaching a missing product.)
///  2. Otherwise SCORE every pool product by `searchRelevance(p, acc.name)` and
///     take the highest:
///       • top score 0 OR below [kKitMinScore]          → [KitMatch.none];
///       • top ≥ [kKitAutoScore] AND (top − runnerUp) ≥ [kKitAutoMargin]
///                                                       → [KitMatch.auto];
///       • otherwise (matched, but below floor-of-confidence or inside the
///         margin)                                       → [KitMatch.ambiguous]
///         (the best candidate is kept for owner review).
///
/// PURE & deterministic: ties in score are broken by pool order (the first
/// product reaching the max wins), so the same accessory always resolves to the
/// same line.
KitLine resolveAccessory(SmartAcc acc) {
  // (1) Curated: owner already chose a sku and it is a real pooled product.
  final curatedSku = acc.sku;
  if (curatedSku != null) {
    final curated = _bySku[curatedSku];
    if (curated != null) {
      return KitLine(
        acc: acc,
        product: curated,
        match: KitMatch.curated,
        score: 0,
      );
    }
  }

  // (1b) Swarm-RANKED override: the RANK+verify swarm produced a ranked list of
  // fitting products for a name the scorer could not resolve — best-fit first.
  // The FIRST in-pool product is the RECOMMENDED default ([product]); the rest
  // become [KitLine.alternatives] for the UI to offer ("or here are others").
  // Wins over scoring (adversarially verified) but NEVER over an owner-set sku
  // (checked above). Skus not in the pool are skipped.
  final ranked = kAccRankedSkus[acc.name];
  if (ranked != null && ranked.isNotEmpty) {
    final products = <LipskeyCatalogProduct>[
      for (final s in ranked)
        if (_bySku[s] != null) _bySku[s]!,
    ];
    if (products.isNotEmpty) {
      return KitLine(
        acc: acc,
        product: products.first,
        match: KitMatch.swarm,
        score: 0,
        alternatives: products.length > 1
            ? products.sublist(1)
            : const <LipskeyCatalogProduct>[],
      );
    }
  }

  // (2) Score the pool. Track the single best product, its score, and the
  // runner-up score (the best among products OTHER THAN `best`) so we can
  // measure the margin between the winner and the next product.
  LipskeyCatalogProduct? best;
  var bestScore = 0;
  var runnerUp = 0; // best score among products other than `best`
  for (final p in kDivePool) {
    final s = searchRelevance(p, acc.name);
    if (s > bestScore) {
      runnerUp = bestScore; // the old best becomes the runner-up
      bestScore = s;
      best = p;
    } else if (s > runnerUp) {
      runnerUp = s;
    }
  }

  // No usable match: nothing scored, or the best is below the confidence floor.
  if (best == null || bestScore < kKitMinScore) {
    return KitLine(
      acc: acc,
      product: null,
      match: KitMatch.none,
      score: bestScore,
    );
  }

  // Confident single winner → auto. Requires BOTH a strong absolute score and a
  // decisive margin over the runner-up.
  final decisiveMargin = (bestScore - runnerUp) >= kKitAutoMargin;
  if (bestScore >= kKitAutoScore && decisiveMargin) {
    return KitLine(
      acc: acc,
      product: best,
      match: KitMatch.auto,
      score: bestScore,
    );
  }

  // Matched, but not confidently — keep the best candidate for owner review.
  return KitLine(
    acc: acc,
    product: best,
    match: KitMatch.ambiguous,
    score: bestScore,
  );
}

/// Assembles the kit for a whole [recipe]: ONE [KitLine] per accessory in
/// `recipe.acc`, in the SAME order. PURE — a straight map over
/// [resolveAccessory].
List<KitLine> assembleKit(SmartProduct recipe) =>
    [for (final a in recipe.acc) resolveAccessory(a)];

/// Aggregate coverage counts over a set of resolved [KitLine]s.
///
/// [total] = curated + auto + ambiguous + none (every accessory falls into
/// exactly one bucket). [perRecipe] optionally records the same five counts
/// keyed by `SmartProduct.key`, so a report can show which recipes are
/// well-covered and which are mostly unresolved.
@immutable
class KitCoverage {
  const KitCoverage({
    required this.total,
    required this.curated,
    required this.auto,
    required this.swarm,
    required this.ambiguous,
    required this.none,
    this.perRecipe = const {},
  });

  final int total;
  final int curated;
  final int auto;
  final int swarm;
  final int ambiguous;
  final int none;

  /// Optional per-recipe breakdown: `SmartProduct.key` → its own [KitCoverage]
  /// (whose `perRecipe` is empty). Empty unless explicitly populated by
  /// [measureKitCoverage].
  final Map<String, KitCoverage> perRecipe;

  /// curated + auto + swarm — the accessories that resolve to a product (an
  /// owner sku, a high-confidence scorer match, or a verified swarm override).
  /// The "real, usable" coverage (swarm matches are pending owner spot-check).
  int get resolved => curated + auto + swarm;

  /// Share of [total] that is [resolved] (curated + auto), in 0..1. 0 when the
  /// set is empty. PURE.
  double get resolvedRatio => total == 0 ? 0 : resolved / total;

  double _ratio(int n) => total == 0 ? 0 : n / total;

  double get curatedRatio => _ratio(curated);
  double get autoRatio => _ratio(auto);
  double get swarmRatio => _ratio(swarm);
  double get ambiguousRatio => _ratio(ambiguous);
  double get noneRatio => _ratio(none);
}

/// Tallies one batch of [lines] into a [KitCoverage] (no per-recipe map). PURE.
KitCoverage _tally(List<KitLine> lines) {
  var curated = 0;
  var auto = 0;
  var swarm = 0;
  var ambiguous = 0;
  var none = 0;
  for (final l in lines) {
    switch (l.match) {
      case KitMatch.curated:
        curated++;
      case KitMatch.auto:
        auto++;
      case KitMatch.swarm:
        swarm++;
      case KitMatch.ambiguous:
        ambiguous++;
      case KitMatch.none:
        none++;
    }
  }
  return KitCoverage(
    total: lines.length,
    curated: curated,
    auto: auto,
    swarm: swarm,
    ambiguous: ambiguous,
    none: none,
  );
}

/// Runs the bridge over EVERY recipe in [kSmartProducts] and returns the TRUE
/// total coverage — the real answer to "how much of the tree resolves to a
/// catalog product". Also fills [KitCoverage.perRecipe] with one entry per
/// recipe. PURE & deterministic (a fixed iteration over const data).
KitCoverage measureKitCoverage() {
  var curated = 0;
  var auto = 0;
  var swarm = 0;
  var ambiguous = 0;
  var none = 0;
  var total = 0;
  final perRecipe = <String, KitCoverage>{};
  for (final recipe in kSmartProducts) {
    final lines = assembleKit(recipe);
    final c = _tally(lines);
    perRecipe[recipe.key] = c;
    total += c.total;
    curated += c.curated;
    auto += c.auto;
    swarm += c.swarm;
    ambiguous += c.ambiguous;
    none += c.none;
  }
  return KitCoverage(
    total: total,
    curated: curated,
    auto: auto,
    swarm: swarm,
    ambiguous: ambiguous,
    none: none,
    perRecipe: perRecipe,
  );
}
