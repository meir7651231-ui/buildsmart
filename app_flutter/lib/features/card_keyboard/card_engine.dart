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
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show
        NewbieStep,
        distinctCardCount,
        distinctProducts,
        kFirstQuestion,
        kFirstWordCount,
        kShowProductsThreshold,
        wordsByFrequency;
import 'package:buildsmart/features/word_finder/word_lexicon.dart'
    show WordEntry, WordLexicon;
import 'package:flutter/foundation.dart' show immutable;

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
  /// comparator uses an exact integer rational; §1.3).
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
      other.infoGain == infoGain &&
      other.soft == soft;

  @override
  int get hashCode =>
      Object.hash(axisId, value, displayLabel, axisName, infoGain, soft);
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
  final chips = _mergedChips(pool, stack, lexicon, subtype);
  if (chips.isEmpty) return CardShowProducts(distinctProducts(pool));
  return MergedKeys(chips);
}

/// The merged key-set for the current turn (build plan §1.3).
///
/// PHASE 0 STUB: returns empty, so the ladder falls to the convergence floor.
/// Phase 1 supplies the 5 hard signals; Phase 2 implements the scored merge
/// (the axes weighted together, integer-deterministic comparator, top-K +
/// per-axis floor); Phase 3 weaves the soft tilts. The signature already takes
/// every input the merge needs so later phases fill the body without touching
/// [mergedKeys] or its callers.
List<SignalChip> _mergedChips(
  List<LipskeyCatalogProduct> pool,
  List<NewbieStep> stack,
  WordLexicon lexicon,
  String? subtype,
) =>
    const <SignalChip>[];
