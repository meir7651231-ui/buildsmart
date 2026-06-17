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
    show divePoolIndex, kDivePool, offerAxis;
import 'package:buildsmart/features/word_finder/narrow_axis.dart'
    show angleTokensIn, colorOptions, productHasChip, sizeTokensIn, wordOptions;
import 'package:buildsmart/features/word_finder/word_lexicon.dart';
// The 7th engine ("מה מתחבר לזה" / connection-planner) reuses the REAL,
// verified compatibility engine rather than re-deriving a parallel one — see
// [connectionsFor]. This is the SAME function `install_engine`'s own
// pathfinder calls, so the finder can never drift from the install logic.
//
// COUPLING NOTE (documented, same spirit as the `_size_norm` re-export this
// file already depends on): `install_engine.dart` transitively imports
// `package:flutter_riverpod` (it also declares the compat-screen's
// StateProviders). That import is NOT used here — `connectionsFor` touches only
// the pure `compatibleWith` transform over the const `kCompatCatalog`. The
// engine was already non-runnable under a plain `dart test` (it pulls
// `package:flutter/widgets` via `_size_norm`), so this adds no new test-harness
// requirement: the finder's tests already run under `flutter_test`.
import 'package:buildsmart/logic/install_engine.dart' show compatibleWith;
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

/// 7th engine: the plain-text key that, on a reached anchor, opens the
/// "parts that connect to this" view. Icon-free (rendered via the same BsKey
/// letter idiom as every other word/chip key).
///
/// OWNER-REVIEW: default copy — the polished anchor affordance is owner-design.
const String kConnectionsKey = 'מה מתחבר לזה?';

/// 7th engine: the header shown above the compatible-parts list in the
/// connections view.
///
/// OWNER-REVIEW: default copy.
const String kConnectionsHeader = 'מה מתחבר לזה?';

/// 7th engine: empty-state copy when a reached anchor has no compatible parts
/// (rare — a valid anchor almost always mates something; shown defensively so
/// the view is never a blank keyboard).
///
/// OWNER-REVIEW: default copy.
const String kNoConnections = 'אין חלקים מתאימים';

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

/// The subtype-free narrow axes, in `narrowAxis` priority order, built from the
/// SAME PUBLIC lifted helpers `narrowAxis`/`offerAxis` use. PURE.
///
/// AXIS VOCABULARY — must stay byte-identical to what `narrowAxis` emits so a
/// resulting [AskAxis] label feeds [applyNarrow]/`productHasChip` and lands in
/// the answered-set consistently. Curated facets ('אפשרות') are NOT here: they
/// need a subtype and are handled by `offerAxis` in [offerQuestion]; this list
/// covers only the subtype-free axes the scorer ranks by information gain:
///   • `sizeTokensIn(pool)`  → label 'גודל', chips = token labels,
///   • `angleTokensIn(pool)` → label 'זווית', chips = token labels,
///   • `colorOptions(pool)`  → label 'צבע',  chips = colours,
///   • `wordOptions(pool)`   → label 'דגם',  chips = characterizing words.
///
/// The ORDER of this list is the canonical tie-break: when two axes score
/// identically under [axisExpectedRemaining], the earlier one (size before
/// angle before colour before word — the same precedence `narrowAxis` applies)
/// wins, keeping selection deterministic.
List<({String label, List<String> chips})> _candidateAxes(
  List<LipskeyCatalogProduct> pool,
) =>
    <({String label, List<String> chips})>[
      (label: 'גודל', chips: sizeTokensIn(pool).map((t) => t.label).toList()),
      (label: 'זווית', chips: angleTokensIn(pool).map((t) => t.label).toList()),
      (label: 'צבע', chips: colorOptions(pool)),
      (label: 'דגם', chips: wordOptions(pool)),
    ];

/// INFORMATION-GAIN score for one axis: the EXPECTED number of distinct cards
/// still remaining after the user picks one of its [chips]. PURE; LOWER is
/// better (a more even / more decisive split leaves fewer cards on average).
///
/// FORMULA — for each chip `c`, let `n_c = distinctCardCount(applyNarrow(pool,
/// c))` be the distinct CARDS that survive picking `c`. The chance a uniformly-
/// random user lands in bucket `c` is `n_c / N` (`N = distinctCardCount(pool)`),
/// and the cards left if they do is `n_c`, so the expected remainder is
///   Σ_c (n_c / N) · n_c  =  Σ_c n_c²  /  N .
/// Equivalently `sum(n_c^2) / distinctCardCount(pool)` — exactly the value the
/// spec prescribes. It rewards an EVEN split (many small buckets → small Σn_c²)
/// and punishes a lopsided one (one bucket ≈ N → Σn_c² ≈ N² → score ≈ N, i.e.
/// "you learned almost nothing"). It scores CARDS via [distinctCardCount], NOT
/// raw `pool.length`, so variant-collapsed duplicates are not double-counted.
///
/// NOTE — buckets can OVERLAP (a product carrying ½" AND ¾" lands in both size
/// chips), so Σn_c is not bounded by N; that is intentional. The measure is a
/// monotone "how lopsided" proxy, not a partition entropy: an axis where every
/// chip keeps the whole pool (the ½"×¾" loop) scores ≈ N·(#chips) — strictly
/// WORSE than any axis that actually carves the pool, so the scorer naturally
/// defers non-narrowing axes. Determinism: integer arithmetic, no randomness.
///
/// PERF: computes `distinctCardCount(applyNarrow(pool, c))` EXACTLY ONCE per
/// chip (no repeated work), and the caller invokes it once per candidate axis.
double axisExpectedRemaining(
  List<LipskeyCatalogProduct> pool,
  List<String> chips,
) {
  final n = distinctCardCount(pool);
  if (n == 0) return 0;
  var sumSq = 0;
  for (final c in chips) {
    final nc = distinctCardCount(applyNarrow(pool, c));
    sumSq += nc * nc;
  }
  return sumSq / n;
}

/// The next axis to narrow by — the UNANSWERED axis that, scored by
/// [axisExpectedRemaining], splits the [pool] MOST decisively (lowest expected
/// remaining cards). This is the "easiest path" core: ask the question that
/// removes the most uncertainty first, so the dive reaches a product in the
/// FEWEST taps. PURE. Replaces the old fixed size→angle→colour→word priority.
///
/// WHY THIS EXISTS: `offerAxis`/`narrowAxis` return only the SINGLE best
/// splitting axis by a FIXED order — once the user answers it, `offerAxis`
/// re-offers the SAME axis for as long as it still splits (e.g. a faucet whose
/// name carries `½"×¾"` keeps surfacing a size axis). This helper instead
/// considers EVERY still-unanswered subtype-free axis, scores each by how
/// evenly it carves the pool, and returns the most decisive one — walking the
/// dive through the axes in best-first order, each at most once, before
/// falling back to a product pick.
///
/// CANDIDATES — built via [_candidateAxes] (the SAME public lifted helpers
/// `narrowAxis` uses). An axis is a candidate only when its label is NOT in
/// [answeredLabels] AND it has >1 DISTINCT chip (a lone chip can't narrow
/// anything — the same `>1` gate `narrowAxis` applies). Among the candidates
/// the LOWEST [axisExpectedRemaining] wins; TIES break by [_candidateAxes]
/// order (size → angle → colour → word) for determinism. Returns the winner as
/// `(label, chips)`, or null when no unanswered splitting axis remains (the
/// caller then shows products), which also guarantees termination: every
/// returned axis is unanswered, so the answered-set strictly grows each turn.
({String label, List<String> chips})? bestUnansweredAxis(
  List<LipskeyCatalogProduct> pool,
  Set<String> answeredLabels,
) {
  ({String label, List<String> chips})? best;
  double? bestScore;
  // Iterate in priority order; a STRICT `<` keeps the FIRST (higher-priority)
  // axis on a tie, so the tie-break is the canonical narrowAxis order.
  for (final c in _candidateAxes(pool)) {
    if (answeredLabels.contains(c.label)) continue;
    if (c.chips.toSet().length <= 1) continue; // can't narrow → not a candidate
    final score = axisExpectedRemaining(pool, c.chips);
    if (bestScore == null || score < bestScore) {
      bestScore = score;
      best = c;
    }
  }
  return best;
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
///  4. The MOST-DECISIVE unanswered subtype-free axis ([bestUnansweredAxis] —
///     information-gain scored, lowest [axisExpectedRemaining]) → [AskAxis] for
///     it. THIS is the "easiest path": ask the question that narrows the pool
///     most first, so the dive reaches a product in the fewest taps. Replaces
///     the old fixed size→angle→colour→word order. Each axis is unanswered, so
///     it is asked at most once.
///  5. No subtype-free axis scores (all answered / unsplittable), but the
///     curated-facet axis (`offerAxis`/`narrowAxis` with [subtype]) is
///     UNANSWERED and has chips → [AskAxis] for it. This PRESERVES the curated
///     'אפשרות' path (covers/grates, round/square…), which [bestUnansweredAxis]
///     does not score because it needs a subtype.
///  6. No unanswered splitting axis remains → [ShowProducts] with the distinct
///     remaining products. The convergence floor: every axis the pool can split
///     on has been answered (or is unsplittable), so the dive advances to a
///     product pick instead of spinning on an axis it already asked.
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
  // finder_screen and we must not touch it, so the "ask the most-decisive axis,
  // each at most once" logic lives HERE.
  final answeredAxes = {for (final s in stack) s.axisLabel};

  // (4) The MOST-DECISIVE unanswered subtype-free axis (information-gain scored
  // — lowest expected-remaining cards). This is the easiest path: ask the
  // question that narrows the pool most first, so the dive reaches a product in
  // the fewest taps. Every returned axis is UNANSWERED → asked at most once.
  final best = bestUnansweredAxis(pool, answeredAxes);
  if (best != null) {
    return AskAxis(
      kAxisQuestion[best.label] ?? kAxisFallbackQuestion,
      best.chips,
      best.label,
    );
  }

  // (5) No subtype-free axis scores, but the curated-facet axis (offerAxis/
  // narrowAxis honours the subtype 'אפשרות' override) may still be UNANSWERED
  // with chips. Ask it — this PRESERVES the curated facet path that the scorer
  // does not cover (it needs a subtype). An empty axis label can't be answered,
  // so `ax.label.isEmpty` also routes here only when it carries no chips.
  final ax = offerAxis(pool, subtype);
  final axIsUnanswered = ax.label.isEmpty || !answeredAxes.contains(ax.label);
  if (axIsUnanswered && ax.chips.isNotEmpty) {
    return AskAxis(
      kAxisQuestion[ax.label] ?? kAxisFallbackQuestion,
      ax.chips,
      ax.label,
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

// ── 7th engine: CONNECTION-PLANNER ("מה מתחבר לזה") ─────────────────────────
//
// After the dive reaches a product, let the user see the parts that physically
// CONNECT to it. This is a THIN, pure wrapper over the install engine's verified
// `compatibleWith` — the finder adds no new compatibility logic of its own, so a
// connection it offers is exactly a connection the install/path engine would
// make. The only finder-side rule is the ANCHOR gate below.

/// True when [anchor] is a VALID connection anchor: the finder will only offer
/// "מה מתחבר לזה" for a product that the compatibility engine can reason about
/// with TRUSTWORTHY geometry. PURE — reads only the const [divePoolIndex].
///
/// GATE (both required, mirroring `dive_pool.Membership`):
///  • `inCompat` — the sku is in `kCompatCatalog`, the universe `compatibleWith`
///    scans. A product outside it (a polyroll/huliot sku) can never appear as an
///    anchor on either side of `canConnect`, so connections would be vacuous.
///  • `hasSpec`  — the sku has a `kVerifiedSpec` (the SAME predicate
///    `install_engine._usableConnector` uses). Without verified ends,
///    `canConnect` would fall back to loose name-inference; we refuse to surface
///    those as confident "this connects" claims to a non-technical user.
///
/// A sku the index doesn't know (not in the union pool) is NOT an anchor.
bool isConnectionAnchor(LipskeyCatalogProduct anchor) {
  final m = divePoolIndex[anchor.sku];
  return m != null && m.inCompat && m.hasSpec;
}

/// The parts that CONNECT to [anchor] — the catalog products the install
/// engine's verified `compatibleWith` says can physically join it, at [tempC]
/// (default 20 °C = a cold line, where no temperature filtering applies). PURE
/// (delegates to the memoized, const-data `compatibleWith`).
///
/// Returns EMPTY when [anchor] is not a valid anchor ([isConnectionAnchor] is
/// false) — so a fixture/accessory/uncovered product yields no list rather than
/// a misleading name-inference guess. When it IS an anchor, the result is
/// exactly `compatibleWith(anchor)`: every product `p` in `kCompatCatalog` with
/// `canConnect(anchor, p)` (the anchor itself is excluded — `canConnect` rejects
/// `a.sku == b.sku`), ordered with same-category parts first (the order
/// `compatibleWith` already applies).
///
/// This is the engine half of the 7th engine. The UI half (a flag-gated,
/// icon-free 'מה מתחבר לזה?' affordance) lives in `word_finder_screen.dart`;
/// the polished anchor UX is an OWNER-design decision and is deliberately left
/// minimal here.
List<LipskeyCatalogProduct> connectionsFor(
  LipskeyCatalogProduct anchor, {
  int tempC = 20,
}) {
  if (!isConnectionAnchor(anchor)) return const <LipskeyCatalogProduct>[];
  return compatibleWith(anchor, tempC: tempC);
}
