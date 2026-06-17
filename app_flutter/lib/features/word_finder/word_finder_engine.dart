/// PURE conversation engine for the product finder's NEWBIE path (בית/מאתר).
///
/// STEP 3 of the word-finder swarm — the layer that turns the pure data
/// primitives (STEP 0 `narrow_axis`, STEP 1 `dive_pool`, STEP 2 `word_lexicon`)
/// into a deterministic question/answer loop a non-technical user walks:
///   1. "מה אתה מחפש?"  →  pick a plain WORD (top words by frequency),
///   2. then repeatedly "narrow by" one axis (size / angle / colour / model /
///      curated option) until the pool collapses to ONE product card,
///   3. at which point the engine RESOLVES to that product (+ its siblings).
///
/// PURITY: this library imports NO Flutter widgets and builds NO UI. It depends
/// only on the pure finder libraries. (Those libraries DO transitively pull in
/// `package:flutter/widgets.dart` via `_size_norm.dart`'s `TextDirection` /
/// `immutable` re-export — a PRE-EXISTING fact of the dependency chain
/// `dive_pool → narrow_axis → _size_norm`, not something introduced here. This
/// file itself adds zero new Flutter coupling and constructs zero widgets, so
/// it stays unit-testable as a plain Dart library.)
///
/// DETERMINISM: every function here is a pure transform of its inputs —
/// `offerQuestion`, `resolveWord` and `applyNarrow` produce identical output
/// for identical input. No clocks, no randomness, no I/O.
library;

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart'
    show kDivePool, offerAxis;
import 'package:buildsmart/features/word_finder/narrow_axis.dart'
    show angleTokensIn, colorOptions, productHasChip, sizeTokensIn, wordOptions;
import 'package:buildsmart/features/word_finder/word_lexicon.dart';
import 'package:buildsmart/screens/_size_norm.dart'
    show parseAngleTokens, parseSizeTokens;

/// One answered step in the newbie conversation — a chosen "narrow by" chip on
/// a given axis. A list of these (the conversation "stack") is the breadcrumb
/// trail the UI renders ("ברז › 1/2" › שחור") and the engine reads (via its
/// emptiness) to know whether the dive has started.
///
/// const-friendly: all fields are final and the constructor is `const`, so a
/// caller may build canonical fixed steps at compile time. [predicate] is the
/// pure membership test used to apply this step to a pool (mirrors
/// [applyNarrow]'s `productHasChip` for the common case, but a curated caller
/// may supply any pure predicate).
class NewbieStep {
  const NewbieStep({
    required this.axisLabel,
    required this.chipLabel,
    required this.predicate,
    required this.crumbWord,
  });

  /// The narrowAxis label this step answered ('גודל' / 'זווית' / 'צבע' /
  /// 'דגם' / 'אפשרות'), kept so the UI can re-show the axis hint in the trail.
  final String axisLabel;

  /// The chip the user tapped (e.g. '1/2"', 'שחור', '45°', 'אמריקאי').
  final String chipLabel;

  /// Pure membership test for this step. For the standard size/angle/colour/
  /// word/curated chips this is `(p) => productHasChip(p, chipLabel)`.
  final bool Function(LipskeyCatalogProduct) predicate;

  /// The plain word shown for this step in the breadcrumb trail (usually the
  /// chip label, but a caller may humanize it).
  final String crumbWord;
}

/// What the engine asks (or resolves) at one turn of the conversation. A sealed
/// hierarchy with exactly four concrete kinds — the caller switches on the
/// runtime type (or `is`-tests) to render the right control.
sealed class NewbieQuestion {
  const NewbieQuestion();
}

/// "Pick a plain word." Shown first (and only first). [words] are the top
/// lexicon entries by frequency; the user taps one to seed the pool via
/// [resolveWord].
class AskWords extends NewbieQuestion {
  const AskWords(this.questionHe, this.words);

  /// The Hebrew prompt (e.g. [kFirstQuestion]).
  final String questionHe;

  /// Candidate words to offer, highest-frequency first.
  final List<WordEntry> words;
}

/// "Narrow by this axis." Shown for every turn after the first while the pool
/// still has >1 distinct card AND an axis splits it.
class AskAxis extends NewbieQuestion {
  const AskAxis(this.questionHe, this.chips, this.axisLabel);

  /// The plain-Hebrew question mapped from [axisLabel] via [kAxisQuestion].
  final String questionHe;

  /// The chip labels to offer for this axis (from `offerAxis(...).chips`).
  final List<String> chips;

  /// The raw narrowAxis label ('גודל' / 'זווית' / 'צבע' / 'דגם' / 'אפשרות').
  final String axisLabel;
}

/// "Here is the product." The pool has collapsed to a single distinct card.
/// [product] is the representative; [siblings] is every product that shares the
/// collapsed card (colour/size/material variants), so the UI can offer them.
class Resolve extends NewbieQuestion {
  const Resolve(this.product, this.siblings);

  final LipskeyCatalogProduct product;
  final List<LipskeyCatalogProduct> siblings;
}

/// "Pick a product." The cascade can't (or shouldn't) narrow further, so the
/// engine stops asking axes and offers the distinct remaining products directly.
///
/// This is the CONVERGENCE guard for the multi-size loop: a faucet name carries
/// SEVERAL size tokens (e.g. `½"×¾"`), so after the user taps one size the pool
/// STILL surfaces a size axis and the engine would ask 'איזה גודל?' AGAIN,
/// growing the breadcrumb ('ברז · ½" · ½"') without ever reaching a product.
/// [offerQuestion] returns this instead of re-asking the same axis (or when the
/// pool is already small / unsplittable), so the dive ALWAYS advances to a pick.
///
/// [products] are the DISTINCT products of the pool — deduped by the same
/// `_collapseKey` the engine uses everywhere else, in pool order, capped at
/// [kShowProductsCap]. The UI renders them as plain word-keys; tapping one opens
/// the existing reach-product sheet.
class ShowProducts extends NewbieQuestion {
  const ShowProducts(this.products);

  final List<LipskeyCatalogProduct> products;
}

/// narrowAxis label → plain-Hebrew question. Keys are the EXACT label strings
/// `narrowAxis` returns (see `narrow_axis.dart`): 'גודל' (sizes), 'זווית'
/// (angles), 'צבע' (colours), 'דגם' (characterizing words), 'אפשרות' (curated
/// facets). Unknown labels fall back to [kAxisFallbackQuestion].
///
/// OWNER-REVIEW: default copy. The owner may reword any of these prompts.
const Map<String, String> kAxisQuestion = <String, String>{
  'גודל': 'איזה גודל?',
  'זווית': 'ישר או עם זווית?', // OWNER-REVIEW (was 'ישר או בזווית?')
  'צבע': 'איזה צבע?',
  'דגם': 'איזה סוג?', // OWNER-REVIEW (was 'איזה דגם?')
  'אפשרות': 'מה מתאים לך?', // OWNER-REVIEW (was 'מה מתאים?')
};

/// Fallback question for an axis label not in [kAxisQuestion] (e.g. a future
/// axis, or the empty-label "nothing splits" case if a caller asks anyway).
///
/// OWNER-REVIEW: default copy.
const String kAxisFallbackQuestion = 'מה מתאים?';

/// The opening prompt of the newbie path.
///
/// OWNER-REVIEW: default copy (was 'מה אתה צריך?'). The user taps concrete part
/// nouns (ברז/מסעף/ברך/צינור) — you SEARCH FOR a part, not "need" it.
const String kFirstQuestion = 'מה אתה מחפש?';

/// The [ShowProducts] prompt — shown when the cascade converged and the user
/// picks a product directly instead of answering another axis.
///
/// OWNER-REVIEW: default copy (was 'בחר מוצר'). At this step the cascade has
/// converged to a short list — 'בחר את המוצר' signals the final pick.
const String kPickProductQuestion = 'בחר את המוצר';

/// How many top words (by frequency) the first question offers.
///
/// OWNER-REVIEW: default count.
const int kFirstWordCount = 24;

/// At or below this many DISTINCT cards, the cascade stops asking axes and just
/// lets the user pick a product directly ([ShowProducts]). Keeps the dive from
/// dragging a non-technical user through extra axis taps when the remaining
/// pool is already small enough to scan by eye.
///
/// OWNER-REVIEW: default threshold.
const int kShowProductsThreshold = 12;

/// Hard cap on how many products [ShowProducts] carries — a sane upper bound so
/// a degenerate "nothing splits" pool can't dump hundreds of keys on the user.
/// Only reached when an axis repeat / empty-axis forces [ShowProducts] above the
/// [kShowProductsThreshold] (the threshold branch is already <= that count).
///
/// OWNER-REVIEW: default cap.
const int kShowProductsCap = 30;

/// sku → product over [kDivePool], built once. Lets [resolveWord] turn the
/// lexicon's sku lists back into products without re-scanning the pool.
final Map<String, LipskeyCatalogProduct> _divePoolBySku = {
  for (final p in kDivePool) p.sku: p,
};

/// Pure variant-collapse key — the engine's stand-in for finder_screen's
/// `productListDedupeKey`.
///
/// SUBSTITUTION (documented): `productListDedupeKey` is a PUBLIC top-level
/// function, but it lives in `screens/lipskey_products_screen.dart`, which
/// imports `package:flutter/material.dart` and Riverpod. Importing it would
/// pull Flutter widgets into this PURE engine, violating the STEP-3 contract.
/// So instead we compute a faithful pure key from primitives this file may
/// import: strip every size token (`parseSizeTokens`), every angle token
/// (`parseAngleTokens`) and the colour out of `nameHe`, then key on
/// `brand || categoryHe || strippedName`. This collapses size/angle/colour
/// variants of the same product onto one card — the same intent as the
/// original (which additionally strips curated attr-words via file-private
/// sets we deliberately do not reach into). For the finder's dive this is
/// equivalent in practice: once the conversation has narrowed by the splitting
/// axes, the remaining variants differ only by those stripped dimensions.
String _collapseKey(LipskeyCatalogProduct p) {
  // Labels to remove from the name: size + angle token labels, plus the raw
  // matched substrings (the structural label may be a pretty-fold of what's in
  // the name, so remove both forms defensively).
  final remove = <String>{};
  for (final t in parseSizeTokens(p.nameHe)) {
    remove.add(t.label);
  }
  for (final t in parseAngleTokens(p.nameHe)) {
    remove.add(t.label);
  }
  final color = p.color?.trim();
  var stripped = p.nameHe;
  for (final r in remove) {
    if (r.isNotEmpty) stripped = stripped.replaceAll(r, ' ');
  }
  if (color != null && color.isNotEmpty) {
    stripped = stripped.replaceAll(color, ' ');
  }
  // Collapse whitespace so removed tokens don't leave key-affecting gaps.
  stripped = stripped.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).join(' ');
  return '${p.brand}||${p.categoryHe}||$stripped';
}

/// Distinct collapsed cards in [pool] — the count of cards the user would
/// actually see (variants fold into one), mirroring finder_screen's
/// `results.map(productListDedupeKey).toSet().length`.
int distinctCardCount(List<LipskeyCatalogProduct> pool) =>
    pool.map(_collapseKey).toSet().length;

/// One representative product per distinct collapsed card in [pool], in pool
/// order (FIRST member of each card wins, matching `pool.first` semantics the
/// rest of the engine relies on), capped at [kShowProductsCap]. This is exactly
/// the set [ShowProducts] offers: the products a user would scan when the
/// cascade stops narrowing. PURE — same collapse key as [distinctCardCount], so
/// `distinctProducts(pool).length == min(distinctCardCount(pool), cap)`.
List<LipskeyCatalogProduct> distinctProducts(
  List<LipskeyCatalogProduct> pool, {
  int cap = kShowProductsCap,
}) {
  final seen = <String>{};
  final out = <LipskeyCatalogProduct>[];
  for (final p in pool) {
    if (seen.add(_collapseKey(p))) {
      out.add(p);
      if (out.length >= cap) break;
    }
  }
  return out;
}

/// The next axis to narrow by that has NOT yet been answered, given the current
/// [pool] and the set of axis labels [answeredLabels] already chosen on this
/// dive. PURE.
///
/// WHY THIS EXISTS: `offerAxis`/`narrowAxis` return only the SINGLE best
/// splitting axis (the first that splits, in priority order) — once the user
/// answers it, `offerAxis` re-offers the SAME best axis for as long as it still
/// splits (e.g. a faucet whose name carries `½"×¾"` keeps surfacing a size
/// axis). The old engine treated that repeat as "stop, show products". This
/// helper instead walks PAST the already-answered axis to the next UNANSWERED
/// one, so the dive narrows through each available axis ONCE
/// (size → angle → colour → word) before falling back to a product pick.
///
/// AXIS VOCABULARY — must stay byte-identical to what `narrowAxis` emits so the
/// resulting [AskAxis] label feeds [applyNarrow]/`productHasChip` and lands in
/// the answered-set consistently. Built from the SAME PUBLIC lifted helpers
/// `narrowAxis` uses, in the SAME priority order (curated facets are handled by
/// `offerAxis` in [offerQuestion] — they need a subtype — so this helper starts
/// at the subtype-free axes):
///   • `sizeTokensIn(pool)`  → label 'גודל', chips = token labels,
///   • `angleTokensIn(pool)` → label 'זווית', chips = token labels,
///   • `colorOptions(pool)`  → label 'צבע',  chips = colours,
///   • `wordOptions(pool)`   → label 'דגם',  chips = characterizing words.
///
/// An axis is a candidate only when its label is NOT in [answeredLabels] AND it
/// has >1 DISTINCT chip (a lone chip can't narrow anything — same `>1` gate
/// `narrowAxis` applies). Returns the first such axis by the priority order
/// above as `(label, chips)`, or null when every splitting axis is already
/// answered (the caller then shows products).
({String label, List<String> chips})? nextUnansweredAxis(
  List<LipskeyCatalogProduct> pool,
  Set<String> answeredLabels,
) {
  // Candidates in narrowAxis priority order. Chip lists are deduped to a
  // DISTINCT set (sizeTokensIn/angleTokensIn already dedupe tokens, but we fold
  // their labels too so the >1 gate counts distinct CHIPS exactly).
  final candidates = <({String label, List<String> chips})>[
    (label: 'גודל', chips: sizeTokensIn(pool).map((t) => t.label).toList()),
    (label: 'זווית', chips: angleTokensIn(pool).map((t) => t.label).toList()),
    (label: 'צבע', chips: colorOptions(pool)),
    (label: 'דגם', chips: wordOptions(pool)),
  ];
  for (final c in candidates) {
    if (answeredLabels.contains(c.label)) continue;
    if (c.chips.toSet().length > 1) return c;
  }
  return null;
}

/// The next thing to ask the user, given the current [pool], the answered
/// [stack], the [lexicon] (for the first word list) and an optional [subtype]
/// (passed through to `offerAxis`/`narrowAxis` for curated facets). PURE.
///
/// Ordering (each step short-circuits):
///  1. Empty [stack] → [AskWords] with the top [kFirstWordCount] words by freq.
///  2. Pool collapses to ONE distinct card → [Resolve] (representative +
///     siblings = the whole pool).
///  3. Pool is already small (`distinctCardCount <= kShowProductsThreshold`) →
///     [ShowProducts] with the distinct remaining products. The small-pool
///     shortcut: don't drag a non-technical user through axis taps when the
///     remaining cards already fit on one scan.
///  4. The best splitting axis (`offerAxis`, which honours the curated-facet
///     override) is NOT yet answered and has chips → [AskAxis] for it.
///  5. Otherwise that best axis is a REPEAT (already answered — the multi-size
///     ½"×¾" loop, where `narrowAxis` keeps surfacing a size axis). Instead of
///     stopping, walk to the next UNANSWERED axis via [nextUnansweredAxis]
///     (size → angle → colour → word, skipping answered ones). If one exists →
///     [AskAxis] for it (mapped question), so the dive narrows through EACH
///     available axis ONCE.
///  6. No unanswered splitting axis remains → [ShowProducts] with the distinct
///     remaining products. This is the real convergence floor: every axis the
///     pool can split on has been answered (or the best axis was empty /
///     unsplittable), so the dive advances to a product pick instead of
///     spinning on an axis it already asked.
NewbieQuestion offerQuestion(
  List<LipskeyCatalogProduct> pool,
  List<NewbieStep> stack,
  WordLexicon lexicon,
  String? subtype,
) {
  if (stack.isEmpty) {
    final top = [...lexicon.entries]
      ..sort((a, b) => b.freq.compareTo(a.freq));
    return AskWords(
      kFirstQuestion,
      top.take(kFirstWordCount).toList(),
    );
  }

  // (2) Resolved to a single distinct card.
  if (pool.isNotEmpty && distinctCardCount(pool) <= 1) {
    return Resolve(pool.first, pool);
  }

  // (3) Small-pool shortcut — already few enough cards to scan by eye.
  if (distinctCardCount(pool) <= kShowProductsThreshold) {
    return ShowProducts(distinctProducts(pool));
  }

  // The axis labels already answered on this dive. `narrowAxis` is shared with
  // finder_screen and we must not touch it, so the "narrow through each axis
  // once" logic lives HERE.
  final answeredAxes = {for (final s in stack) s.axisLabel};

  // (4) The best splitting axis (curated facets → size → angle → colour → word
  // via offerAxis/narrowAxis). Ask it when it is UNANSWERED and has chips.
  final ax = offerAxis(pool, subtype);
  final axIsUnanswered = ax.label.isEmpty || !answeredAxes.contains(ax.label);
  if (axIsUnanswered && ax.chips.isNotEmpty) {
    return AskAxis(
      kAxisQuestion[ax.label] ?? kAxisFallbackQuestion,
      ax.chips,
      ax.label,
    );
  }

  // (5) The best axis is a REPEAT (already answered — the multi-size loop) or
  // empty. Narrow by the next UNANSWERED axis instead of re-asking it, so the
  // dive walks through each available axis once (size → angle → colour → word).
  final next = nextUnansweredAxis(pool, answeredAxes);
  if (next != null) {
    return AskAxis(
      kAxisQuestion[next.label] ?? kAxisFallbackQuestion,
      next.chips,
      next.label,
    );
  }

  // (6) Every splitting axis is answered (or unsplittable) → show the products.
  return ShowProducts(distinctProducts(pool));
}

/// Maps a chosen [word] to the products it names, via the [lexicon]'s
/// `wordToSkus` and the once-built sku→product index over [kDivePool]. Skus the
/// pool index doesn't know (should not happen — the lexicon is built from the
/// same pool) are skipped. PURE; preserves the lexicon's first-seen sku order.
List<LipskeyCatalogProduct> resolveWord(String word, WordLexicon lexicon) {
  final skus = lexicon.wordToSkus[word];
  if (skus == null) return const <LipskeyCatalogProduct>[];
  final out = <LipskeyCatalogProduct>[];
  for (final sku in skus) {
    final p = _divePoolBySku[sku];
    if (p != null) out.add(p);
  }
  return out;
}

/// Narrows [pool] to the products that carry [chipLabel], using the SAME
/// structural test the finder UI uses (`productHasChip` from `narrow_axis.dart`
/// — no loose `String.contains` for digit-bearing size/angle labels). PURE.
List<LipskeyCatalogProduct> applyNarrow(
  List<LipskeyCatalogProduct> pool,
  String chipLabel,
) =>
    pool.where((p) => productHasChip(p, chipLabel)).toList();
