/// PURE unified "card-keyboard" engine (#38) — the parallel merged-prediction
/// engine behind [kCardKeyboardFlag].
///
/// Where [offerQuestion] asks ONE most-splitting axis per turn, this returns a
/// MERGED key-set from ALL signals at once (size · angle · colour · word ·
/// material, with recipe/connection soft tilts woven in), folding the
/// word/material/job entrances into one flow — WITHOUT touching the live
/// word_finder (zero edits there; a byte-identity test guards it).
///
/// PHASE 0 (this skeleton): the [CardVerdict] type + the [SignalChip] model +
/// the verdict LADDER ([mergedKeys], §1.2). The merge itself (§1.3) is stubbed
/// to empty, so until Phase 2 the engine behaves exactly like [offerQuestion]'s
/// resolve/show rungs and falls to [CardShowProducts] for the merge rung (the
/// convergence floor). Phases 1-3 fill the signals + the scored merge.
///
/// PURITY/DETERMINISM: same contract as `word_finder_engine` — pure transforms
/// of the inputs, no Flutter widgets / Riverpod / clock / IO. [pool] is a
/// PARAMETER only (never a global / provider), so the engine is
/// employer-isolation-safe (build plan §3).
library;

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/features/card_keyboard/card_signals.dart'
    show SignalSource, sourcesFor;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show
        NewbieStep,
        collapseKeyOf,
        distinctCardCount,
        distinctProducts,
        kFirstQuestion,
        kFirstWordCount,
        kShowProductsThreshold,
        wordsByFrequency;
import 'package:buildsmart/features/word_finder/word_lexicon.dart'
    show WordEntry, WordLexicon;
import 'package:flutter/foundation.dart' show immutable, visibleForTesting;

/// One MERGED key the keyboard shows — a single tappable chip that narrows the
/// pool by one `(axis, value)`, plus how it renders. (Model v4, build plan
/// §1.3.) The KEY split — [value] (predicate) vs [displayLabel] (render) — is
/// what lets the size axis match on a canonical key while showing the raw label.
@immutable
class SignalChip {
  const SignalChip({
    required this.axisId,
    required this.value,
    required this.displayLabel,
    this.axisName,
    this.infoGain = 0,
    this.soft = false,
  });

  /// The predicate FAMILY: `'size' | 'angle' | 'color' | 'word' | 'material'`.
  /// Picks WHICH predicate the chip applies; [value] picks the value within it
  /// (`axisId == 'word'` is shared — without [value] you can't tell which word).
  final String axisId;

  /// The predicate KEY: the `materialOf` value / a lexicon word / the
  /// `canonicalSize` key for size. Drives the membership test — NOT necessarily
  /// what is shown.
  final String value;

  /// The VISIBLE text, word-for-word. Equals [value] for word/material/colour/
  /// angle; for SIZE [value] is the canonical key (e.g. `'DN15'`) while this is
  /// the raw label (e.g. `'1/2"'`). Parity (#29) + Semantics assert on THIS.
  final String displayLabel;

  /// The axis DISPLAY name (e.g. `'גודל'`) — for the Semantics axis prefix /
  /// chip-row hint only. Never affects routing or the predicate (#6).
  final String? axisName;

  /// Ranking magnitude — a DISPLAY / coarse tier ONLY, never the sort key (the
  /// comparator uses an exact integer rational; §1.3). EXCLUDED from ==/hashCode
  /// (P2.46): a double's NaN/ULP makes a value type fragile in sets + goldens.
  final double infoGain;

  /// Always false for an EMITTED key: soft signals (recipe/connections) only
  /// re-weight an existing hard-axis chip — they never produce a standalone key
  /// (§1.5 invariant, asserted in Phase 3's tests).
  final bool soft;

  @override
  bool operator ==(Object other) =>
      other is SignalChip &&
      other.axisId == axisId &&
      other.value == value &&
      other.displayLabel == displayLabel &&
      other.axisName == axisName &&
      other.soft == soft;

  @override
  int get hashCode =>
      Object.hash(axisId, value, displayLabel, axisName, soft);

  /// A copy with [infoGain] populated (P7.64). infoGain is a DISPLAY tier only and
  /// is excluded from ==/hashCode, so re-stamping never changes a chip's identity,
  /// the row's order, or any golden/set keyed on chips.
  SignalChip withInfoGain(double gain) => SignalChip(
        axisId: axisId,
        value: value,
        displayLabel: displayLabel,
        axisName: axisName,
        infoGain: gain,
        soft: soft,
      );
}

/// What the unified engine returns at one turn of the dive. Sealed with exactly
/// FOUR cases; the screen (Phase 4) switches on all four. The first three
/// re-wrap the values [offerQuestion] already produces (so the screen can reuse
/// the existing rendering); [MergedKeys] is the new merged row.
sealed class CardVerdict {
  const CardVerdict();
}

/// "Pick a plain word" — the opening turn (stack empty). Mirrors `AskWords`.
class CardAskWords extends CardVerdict {
  const CardAskWords(this.questionHe, this.words);
  final String questionHe;
  final List<WordEntry> words;
}

/// "Here is the product" — the pool collapsed to one distinct card. Mirrors
/// `Resolve`: [product] is the representative, [siblings] the whole collapsed
/// set (colour/size/material variants the UI can offer).
class CardResolve extends CardVerdict {
  const CardResolve(this.product, this.siblings);
  final LipskeyCatalogProduct product;
  final List<LipskeyCatalogProduct> siblings;
}

/// "Pick a product" — the pool is small enough to scan by eye, OR nothing
/// splits it further (the convergence floor). Mirrors `ShowProducts`.
class CardShowProducts extends CardVerdict {
  const CardShowProducts(this.products);
  final List<LipskeyCatalogProduct> products;
}

/// "Tap a merged key" — the NEW case. One row of [chips] merged from every hard
/// axis at once (size/angle/colour/word/material), ranked and soft-tilted. Every
/// chip is a hard-axis key (`soft == false`); soft signals only re-weighted the
/// order (§1.5). Empty is impossible here — an empty merge falls to
/// [CardShowProducts] in [mergedKeys].
class MergedKeys extends CardVerdict {
  const MergedKeys(this.chips);
  final List<SignalChip> chips;
}

/// The unified engine's single entry. Same inputs as [offerQuestion]; returns a
/// [CardVerdict]. The verdict LADDER (build plan §1.2):
///   1. stack empty                    → [CardAskWords] (opening).
///   2. `distinctCardCount(pool) <= 1`  → [CardResolve].
///   3. `<= kShowProductsThreshold`     → [CardShowProducts] (scan-by-eye).
///   4. else build the merged key-set; if EMPTY (every axis answered or
///      non-splitting, but the pool is still > threshold) → [CardShowProducts]
///      (the convergence floor, so the dive ALWAYS advances).
///
/// PHASE 0: step 4's [_mergedChips] is stubbed to empty, so the merge rung
/// always falls to the floor until Phase 2 fills it. Rungs 1-3 are live and
/// mirror [offerQuestion] exactly. PURE & deterministic.
CardVerdict mergedKeys(
  List<LipskeyCatalogProduct> pool,
  List<NewbieStep> stack,
  WordLexicon lexicon,
  String? subtype,
) {
  if (stack.isEmpty) {
    return CardAskWords(
      kFirstQuestion,
      wordsByFrequency(lexicon).take(kFirstWordCount).toList(),
    );
  }
  if (pool.isNotEmpty && distinctCardCount(pool) <= 1) {
    return CardResolve(pool.first, pool);
  }
  if (distinctCardCount(pool) <= kShowProductsThreshold) {
    return CardShowProducts(distinctProducts(pool));
  }
  final chips = _mergedChips(pool, stack, subtype);
  if (chips.isEmpty) return CardShowProducts(distinctProducts(pool));
  return MergedKeys(chips);
}

/// Census-only memo toggle (P0.5). OFF in production so the live [mergedKeys]
/// call sites are byte-identical; the <=6/<=4 census flips it on to share one
/// merge computation across raw pools that collapse to the same card-set.
const bool kCensusMemoEnabled = false;

final Map<String, CardVerdict> _mergedKeysMemo = <String, CardVerdict>{};

/// @visibleForTesting — clears the census memo between runs / tests.
@visibleForTesting
void clearMergedKeysMemo() => _mergedKeysMemo.clear();

/// @visibleForTesting — [mergedKeys] with a CENSUS-ONLY memo keyed on the
/// collapsed card-set + the answered-axis set + subtype (the full determinant of
/// the merge). Two raw pools that collapse to the same cards under the same
/// answered axes share one computation. Behind [enabled] (default
/// [kCensusMemoEnabled] = false) → a transparent pass-through in production.
@visibleForTesting
CardVerdict mergedKeysMemoized(
  List<LipskeyCatalogProduct> pool,
  List<NewbieStep> stack,
  WordLexicon lexicon,
  String? subtype, {
  bool enabled = kCensusMemoEnabled,
}) {
  if (!enabled) return mergedKeys(pool, stack, lexicon, subtype);
  final poolSig = (pool.map(collapseKeyOf).toSet().toList()..sort()).join('|');
  final axesSig =
      (stack.map((s) => s.axisLabel).toSet().toList()..sort()).join(',');
  final key = '$poolSig##$axesSig##$subtype';
  return _mergedKeysMemo.putIfAbsent(
      key, () => mergedKeys(pool, stack, lexicon, subtype));
}

/// Merge tuning (build plan §1.4 #11). OWNER-REVIEW defaults.
const int kMergedKeyCap = 10; // total chips in the merged row
const int kMergedAxisFloor = 2; // ≥ this many per represented axis
const int kMergedAxisMaxPerAxis = 4; // ≤ this many per axis (so several show)

/// One scored candidate axis for the merge — its [chips] plus the INTEGER
/// histogram `(sumSq, n)` that ranks it: the axis's expected-remaining cards
/// `expRem = sumSq / n`, compared between axes by integer CROSS-MULTIPLY so no
/// float is ever a sort key (build plan §1.3, the determinism guarantee).
class _AxisScore {
  _AxisScore(this.rank, this.chips, this.sumSq, this.n);

  /// Canonical axis order (the [sourcesFor] index) — the deterministic
  /// tie-break when two axes have an equal expRem.
  final int rank;
  final List<SignalChip> chips;

  /// `Σ_chip distinctCardCount(narrowed)²` over the axis's chips.
  final int sumSq;

  /// `distinctCardCount(scoringPool)` — the denominator of expRem (> 0 here).
  final int n;
}

/// The merged key-set for the current turn (build plan §1.3-1.4).
///
/// PURE · SYNCHRONOUS · INTEGER-DETERMINISTIC. For each UNANSWERED hard axis
/// with ≥ 2 chips it builds the integer histogram `(sumSq, n)` (material scores
/// on the SEEDED subset with the exact predicate, §2; every other axis on the
/// full pool), ranks the axes by `expRem = sumSq/n` ASCENDING via cross-multiply
/// (lower = a more decisive split; zero float as a sort key → byte-stable under
/// input shuffle, no NaN), then lays out the row best-axis-first with a per-axis
/// floor (≥ [kMergedAxisFloor]) and caps (≤ [kMergedAxisMaxPerAxis] per axis,
/// ≤ [kMergedKeyCap] total). The size axis is sampled by [representativeTake]
/// (not front-truncated). Soft tilts are NOT applied here (softTilt is inert):
/// realising Phase 3 will mean giving each [SignalChip] a computed per-chip
/// weight and replacing the per-axis positional take with a per-axis scored
/// top-K — a restructure of this loop, not just populating [SignalChip.infoGain]
/// (today always 0). Chip order within an axis is the live helper's; the word
/// axis (the one helper with a pool-order-sensitive tie-break) is made
/// order-independent by [WordSignal.chipsFor]'s canonical sku-sort (swarm R2),
/// so the byte-stable-under-shuffle guarantee above is TOTAL, not just the rank.
///
/// Returns empty when no unanswered axis can split the pool — [mergedKeys] then
/// falls to the convergence floor ([CardShowProducts]).
List<SignalChip> _mergedChips(
  List<LipskeyCatalogProduct> pool,
  List<NewbieStep> stack,
  String? subtype,
) {
  final answered = <String>{for (final s in stack) s.axisLabel};
  final scored = <_AxisScore>[];
  // The five hard axes PLUS, for a curated subtype, the 'אפשרות' facet axis
  // (swarm R7 gap-close). The facet ranks among the others by decisiveness.
  final sources = sourcesFor(subtype);
  for (var rank = 0; rank < sources.length; rank++) {
    final src = sources[rank];
    if (answered.contains(src.axisName)) continue; // each axis at most once
    final score = _scoreAxis(rank, src, pool);
    if (score != null) scored.add(score);
  }

  // Rank axes by expRem = sumSq/n ASCENDING via INTEGER cross-multiply
  // (a.sumSq·b.n vs b.sumSq·a.n) — no float sort key, so byte-stable under input
  // shuffle (no ULP near-ties, no NaN). Tie-break: canonical axis order.
  scored.sort((a, b) {
    final lhs = a.sumSq * b.n;
    final rhs = b.sumSq * a.n;
    if (lhs != rhs) return lhs.compareTo(rhs);
    return a.rank.compareTo(b.rank);
  });

  // Lay out the row best-axis-first: ≥ floor and ≤ maxPerAxis per represented
  // axis, total ≤ cap. The floor guard stops once fewer than `floor` slots
  // remain, so no lonely single-chip axis is appended.
  final out = <SignalChip>[];
  for (final a in scored) {
    if (out.length >= kMergedKeyCap) break;
    final room = kMergedKeyCap - out.length;
    if (out.isNotEmpty && room < kMergedAxisFloor) break;
    final take = room < kMergedAxisMaxPerAxis ? room : kMergedAxisMaxPerAxis;
    // SIZE and ANGLE are magnitude-ordered (size ascending mm; angle ascending
    // degrees — its SizeToken.mm field IS the degree value), so a positional
    // take(take) would front-truncate and HIDE the largest values — the tail-cut
    // build-plan §1.4 #11 forbids (swarm R5: the size-only branch silently
    // exposed angle to the very truncation it documents against). Sample
    // REPRESENTATIVE buckets across the sorted range — always incl. smallest AND
    // largest. WORD (frequency-ordered) and COLOUR (lexical) keep the natural
    // first-N, where top-N IS the right pick.
    final taken = const {'size', 'angle'}.contains(a.chips.first.axisId)
        ? representativeTake(a.chips, take)
        : a.chips.take(take).toList();
    // P7.64: stamp infoGain = n − distinctCardCount(narrowed) on each emitted chip.
    // infoGain is excluded from ==/hashCode, so this leaves the row ORDER untouched
    // (a display tier the rank reads; the sort key is still the integer expRem).
    final src = sources[a.rank];
    for (final c in taken) {
      final nc =
          distinctCardCount(pool.where((p) => src.matches(p, c)).toList());
      out.add(c.withInfoGain((a.n - nc).toDouble()));
    }
  }
  return out;
}

/// Scores one axis [src] over [pool] for the merged row (P7.65 — extracted from
/// [_mergedChips], behavior-identical). Returns null when the axis can't be laid
/// out: fewer than [kMergedAxisFloor] chips, an empty pool, or NO chip narrows it.
///
/// EVERY axis — material INCLUDED (swarm R3 fix) — is scored on the FULL pool with
/// its OWN tap predicate (src.matches), so an axis's measured decisiveness is EXACTLY
/// what tapping a chip delivers, and all axes share one denominator
/// n = distinctCardCount(pool) (expRem commensurable across axes). For material this
/// COUNTS the null carry-along the tap keeps (a copper tap holds copper +
/// unknown-material) — the honest post-tap pool; material is NOT a special branch.
_AxisScore? _scoreAxis(
  int rank,
  SignalSource src,
  List<LipskeyCatalogProduct> pool,
) {
  final chips = src.chipsFor(pool);
  if (chips.length < kMergedAxisFloor) return null;
  final n = distinctCardCount(pool);
  if (n == 0) return null; // div-0 guard; an empty pool can't split
  var sumSq = 0;
  var anySplit = false;
  for (final chip in chips) {
    final nc =
        distinctCardCount(pool.where((p) => src.matches(p, chip)).toList());
    if (nc < n) anySplit = true; // this chip actually narrows the pool
    sumSq += nc * nc;
  }
  // No chip narrows AT ALL → laying it out would be a visible NO-OP tap; skip.
  if (!anySplit) return null;
  return _AxisScore(rank, chips, sumSq, n);
}

/// Pick [count] chips spread EVENLY across [chips] — representative buckets, NOT
/// the first [count]. For a dense, magnitude-ordered axis (size, ascending mm)
/// this surfaces the smallest AND the largest (and a spread between), never
/// front-truncating away the big sizes (build-plan §1.4 #11). Both endpoints are
/// always included. In the regime the loop runs (count ≥ 2 AND chips.length >
/// count) the rounded indices are strictly increasing, so the result is EXACTLY
/// [count] and the dedup Set is a defensive no-op (swarm R2 — never longer, and
/// never fewer than 2 when [chips] has ≥ 2, the endpoints differ). Returns
/// [chips] unchanged when it already fits in [count]. PURE & deterministic.
List<SignalChip> representativeTake(List<SignalChip> chips, int count) {
  if (count <= 1 || chips.length <= count) return chips.take(count).toList();
  final picked = <int>{};
  final out = <SignalChip>[];
  for (var i = 0; i < count; i++) {
    final idx = (i * (chips.length - 1) / (count - 1)).round();
    if (picked.add(idx)) out.add(chips[idx]);
  }
  return out;
}
