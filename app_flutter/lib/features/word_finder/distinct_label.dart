/// PURE minimal-distinction labeller for the product finder (בית/מאתר).
///
/// STEP of the word-finder swarm — the fix for the IDENTICAL-KEY bug: when the
/// dive converges to a [ShowProducts] list (or the connections view) EVERY key
/// shows the SAME plain word (`quickLabel`) and the keys look identical. A
/// non-technical user can't tell two 'ברז' keys apart.
///
/// WHAT IT PRODUCES:
///   A map from each product's unique `sku` to a DISPLAY LABEL that is UNIQUE
///   within the supplied list, built by adding the SMALLEST plain-language
///   distinction needed — never an icon, never the full technical `nameHe`. A
///   product that is already the only one with its base word keeps the bare
///   `quickLabel`; only the products that COLLIDE grow a distinguishing suffix.
///
/// HOW IT DISTINGUISHES (two shapes, ONE function):
///   • In [ShowProducts] the pool is already collapsed by brand + category +
///     abstract-name (`_collapseKey` strips size / angle / colour), so the only
///     thing left that differs between cards is a BRAND word or a characterizing
///     NAME word.
///   • In the connections view the list is NOT collapse-deduped, so size, angle
///     and colour ALSO differ between parts.
///   The axis cascade below covers BOTH: it tries a characterizing name word,
///   then size, then angle, then colour, then brand — adding an axis ONLY when
///   it actually tells two still-colliding members apart, so the
///   [ShowProducts] case naturally uses the name/brand axes and the connections
///   case can reach size/angle/colour too.
///
/// PURITY: imports `package:buildsmart` ONLY (never `package:app_flutter`), no
/// Flutter widgets, no Riverpod, no clock, no randomness. It reuses the SAME
/// pure primitives the rest of the finder buckets by — `quickLabel`,
/// `productSizeTokens`, `angleTokensIn` — so a label can never drift from the
/// word the dive grouped on.
///
/// DETERMINISM: same input list ⇒ identical output map. Every step is a pure
/// transform; the only order-dependent rule (the numeric tie-break) keys on the
/// INPUT order, which the caller controls.
library;

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/features/word_finder/narrow_axis.dart'
    show angleTokensIn, productSizeTokens;
import 'package:buildsmart/features/word_finder/quick_pad_engine.dart'
    show quickLabel;

// ── Reversible display-format defaults (OWNER-REVIEW) ───────────────────────
//
// These three constants are the ONLY display-format choices in this file. They
// are reversible defaults the owner may reword/reorder without touching the
// distinction LOGIC.

/// OWNER-REVIEW: the separator between the base word and a distinguishing
/// suffix (e.g. `ברז שחור`). A single space reads as plain language; change it
/// to ' · ' or ' — ' to taste. Reversible — the distinction logic is unchanged.
const String kLabelAxisSeparator = ' ';

/// OWNER-REVIEW: the canonical AXIS ORDER of the distinction cascade. The first
/// axis that actually separates two colliding members wins, so this order is
/// the tie-break preference: a characterizing NAME word first (most meaningful
/// to a layman), then size, angle, colour, and brand last (a brand word is the
/// least informative distinction for a non-technical user). Reorder to taste;
/// the logic re-reads this list, so a reorder is a pure preference change.
const List<String> kDistinctAxisOrder = <String>[
  'word', // first characterizing name token
  'size', // productSizeTokens joined
  'angle', // angle token labels
  'color', // p.color
  'brand', // p.brand
];

/// OWNER-REVIEW: the stable numeric-suffix format for products that remain
/// identical after EVERY axis (a same-spec, different-sku variant). The first
/// keeps the bare label; the rest get ` (2)`, ` (3)`, … in INPUT order. Change
/// the bracket/format here; reversible and logic-independent.
String _numberSuffix(int ordinal) => ' ($ordinal)'; // 2-based; 1 → no suffix

/// The token separators the finder's `wordOptions` splits a name on. Kept
/// BYTE-IDENTICAL to `narrow_axis.wordOptions` / `word_extraction` so the
/// characterizing-word axis tokenises a name EXACTLY the way the dive's word
/// bucketing does — the two can never drift.
final RegExp _kWordSplit = RegExp(r'[\s()"׳/×,.+\-]+');

/// Real-word tokens of [name] — the SAME rule `wordOptions` uses: split on
/// [_kWordSplit], keep tokens of length ≥ 2 that carry NO digit (drops sizes
/// `250`, fractions `1/2"`, codes `DN40`). PURE.
List<String> _wordTokens(String name) => name
    .split(_kWordSplit)
    .where((w) => w.length >= 2 && !RegExp(r'\d').hasMatch(w))
    .toList();

/// The size axis value for a product: every `productSizeTokens` label joined by
/// a space (e.g. `½" ¾"`), or '' when the product carries no size token. PURE.
String _sizeValue(LipskeyCatalogProduct p) =>
    productSizeTokens(p).map((t) => t.label).join(' ');

/// The angle axis value for a product: its angle token labels joined by a space
/// (e.g. `45°`), or '' when none. Uses `angleTokensIn` over the single-product
/// list so it shares the finder's angle vocabulary. PURE.
String _angleValue(LipskeyCatalogProduct p) =>
    angleTokensIn(<LipskeyCatalogProduct>[p]).map((t) => t.label).join(' ');

/// The colour axis value: the trimmed `color`, or '' when absent. PURE.
String _colorValue(LipskeyCatalogProduct p) => p.color?.trim() ?? '';

/// The brand axis value: the trimmed `brand`, or '' when absent. PURE.
String _brandValue(LipskeyCatalogProduct p) => p.brand.trim();

/// The STARTING label for a product — its [quickLabel]. DEFENSIVE hardening:
/// `quickLabel` can in principle return '' (a product whose `nameHe` is
/// blank/whitespace AND whose `categoryHe` has no layman fallback word), which
/// would render an INVISIBLE key face. No product in the current union pool does
/// this (audited: 0 of ~1948), so this is purely a guard against a future
/// catalog row: fall back to the product's `sku` so a key is ALWAYS visible (and
/// still unique). PURE.
// OWNER-REVIEW: the empty-name fallback target (the raw `sku` vs a placeholder
// word) is a reversible choice; it only ever affects an otherwise-blank label.
String _baseLabel(LipskeyCatalogProduct p) {
  final base = quickLabel(p);
  return base.isEmpty ? p.sku : base;
}

/// Mutable per-product working state while the cascade runs: the product, its
/// position in the input (for the stable numeric tie-break and stable grouping
/// order) and the label being grown.
class _Row {
  _Row(this.product, this.index, this.label);
  final LipskeyCatalogProduct product;
  final int index;
  String label;
}

/// The characterizing-word axis value for one [row], relative to its collision
/// group: the FIRST real-word token of `nameHe` that is NEITHER the base word
/// ([baseLabel]) NOR a token SHARED by every member of the group ([sharedTokens]
/// — those can't distinguish anyone). '' when no such token survives. PURE.
String _wordValue(
  _Row row,
  String baseLabel,
  Set<String> sharedTokens,
) {
  for (final t in _wordTokens(row.product.nameHe)) {
    if (t == baseLabel) continue; // same as the base word → no new information
    if (sharedTokens.contains(t)) continue; // every member has it → useless
    return t; // first distinguishing token wins (the wordOptions idiom)
  }
  return '';
}

/// The tokens SHARED by every member of [rows] — present in EVERY product's
/// `nameHe` token set. A shared token can't tell members apart, so the
/// characterizing-word axis skips them (mirrors `wordOptions`'s `shared` set).
/// PURE.
Set<String> _sharedWordTokens(List<_Row> rows) {
  if (rows.isEmpty) return <String>{};
  Set<String>? shared;
  for (final r in rows) {
    final toks = _wordTokens(r.product.nameHe).toSet();
    if (shared == null) {
      shared = toks;
    } else {
      shared = shared.intersection(toks);
    }
    if (shared.isEmpty) break; // nothing left to share
  }
  return shared ?? <String>{};
}

/// Reads the axis value for [row] on the named [axis] (one of
/// [kDistinctAxisOrder]). The 'word' axis needs the group context
/// ([baseLabel] + [sharedTokens]); the rest are per-product. PURE.
String _axisValue(
  String axis,
  _Row row,
  String baseLabel,
  Set<String> sharedTokens,
) {
  switch (axis) {
    case 'word':
      return _wordValue(row, baseLabel, sharedTokens);
    case 'size':
      return _sizeValue(row.product);
    case 'angle':
      return _angleValue(row.product);
    case 'color':
      return _colorValue(row.product);
    case 'brand':
      return _brandValue(row.product);
    default:
      return '';
  }
}

/// Groups [rows] by their CURRENT label, preserving first-seen order. Used to
/// find which rows still collide after each axis. PURE.
Map<String, List<_Row>> _groupByLabel(List<_Row> rows) {
  final out = <String, List<_Row>>{};
  for (final r in rows) {
    out.putIfAbsent(r.label, () => <_Row>[]).add(r);
  }
  return out;
}

/// Applies one [axis] to a single COLLISION BUCKET — rows that ALL currently
/// share the SAME label. Adds the axis value to each member that HAS one, but
/// ONLY when the axis actually distinguishes within the bucket — i.e. the
/// bucket carries at least TWO distinct values on this axis, where a MISSING
/// ('') value counts as its own distinct value (so "has a size" vs "no size" is
/// itself a distinction).
///
/// A no-op when the axis tells nobody in the bucket apart (every member shares
/// one value). Members with a '' value never get a suffix appended (you can't
/// show an empty distinction); they keep the bare current label, which is still
/// distinct from the bucket-mates that DID grow a suffix. PURE (mutates only the
/// supplied rows' `label`).
void _applyAxisToBucket(String axis, List<_Row> bucket, String baseLabel) {
  final sharedTokens =
      axis == 'word' ? _sharedWordTokens(bucket) : const <String>{};
  final values = <_Row, String>{
    for (final r in bucket) r: _axisValue(axis, r, baseLabel, sharedTokens),
  };
  // Distinct values INCLUDING the empty string — "" is a real, distinguishing
  // state (no size / no colour). An axis with <2 distinct values can't split
  // this bucket, so skip it untouched (mirrors the `>1` gate narrowAxis applies).
  if (values.values.toSet().length < 2) return;
  for (final r in bucket) {
    final v = values[r]!;
    if (v.isEmpty) continue; // can't append an empty distinction
    r.label = '${r.label}$kLabelAxisSeparator$v';
  }
}

/// Builds a `sku → display label` map for [products] where every label is
/// UNIQUE within the list, starting from each product's [quickLabel] and adding
/// the SMALLEST plain-language distinction needed. PURE, deterministic, and free
/// of Flutter/Riverpod/clock/randomness.
///
/// ALGORITHM:
///   1. Seed every row with its base `quickLabel`.
///   2. Group by base label. A SINGLETON group is already unique → keep the
///      bare base word.
///   3. For each COLLIDING group, walk [kDistinctAxisOrder]
///      (word → size → angle → colour → brand). For each axis, extract a short
///      text value per member ('' when absent) and apply it ONLY if ≥2 distinct
///      values exist among the members STILL colliding (empty counts as a
///      value). Append the value only to members that have one. After each
///      axis, recompute who still collides and continue with ONLY those.
///   4. FINALLY, any labels STILL shared across the WHOLE list — a same-spec,
///      different-sku variant (or the rare full-`nameHe` cross-group clash) —
///      get a stable numeric suffix by INPUT order: the first keeps the bare
///      label, the second gets ` (2)`, the third ` (3)`, and so on. This makes
///      the returned map collision-free by construction.
///
/// DUPLICATE SKUS: a list should carry distinct skus (the caller's payloads are
/// unique skus), but if the SAME sku appears twice the map simply holds one
/// entry for it (last write wins) — the label is still well-defined.
Map<String, String> distinctSelectionLabels(
  List<LipskeyCatalogProduct> products,
) {
  if (products.isEmpty) return const <String, String>{};

  // Stable working rows in input order (the numeric tie-break and group order
  // both rely on this order).
  final rows = <_Row>[
    for (var i = 0; i < products.length; i++)
      _Row(products[i], i, _baseLabel(products[i])),
  ];

  // Walk each base-label collision group independently. A group's `baseLabel`
  // is the shared starting label (every member began equal to it).
  for (final entry in _groupByLabel(rows).entries) {
    final baseLabel = entry.key;
    final group = entry.value;
    if (group.length < 2) continue; // already unique on the bare base word

    // Axis cascade. At each axis, RE-GROUP the group's members by their CURRENT
    // label and apply the axis INDEPENDENTLY to each still-colliding bucket
    // (members sharing an identical label) — so distinction is always judged
    // among rows that still look the same, never across rows already told
    // apart. A member that became unique on an earlier axis lands in a
    // singleton bucket and is simply skipped. This is the spec's "after each
    // axis recompute who still collides and continue only for them".
    for (final axis in kDistinctAxisOrder) {
      final buckets = _groupByLabel(group).values
          .where((b) => b.length > 1)
          .toList();
      if (buckets.isEmpty) break; // everyone in this group is distinct now
      for (final bucket in buckets) {
        _applyAxisToBucket(axis, bucket, baseLabel);
      }
    }
  }

  // GLOBAL numeric tie-break — the final guarantee that every label is unique
  // ACROSS THE WHOLE LIST, not just within a base-label group. A collision can
  // survive the axis cascade two ways: a same-spec different-sku VARIANT (the
  // common case), or the rare cross-group clash when `quickLabel` fell back to a
  // full `nameHe` that happens to equal another group's suffixed label. Both are
  // resolved identically: per still-shared label, the FIRST row in INPUT order
  // keeps the bare label; the rest get ` (2)`, ` (3)`, … This pass runs over ALL
  // rows so the map it returns is collision-free by construction.
  for (final bucket in _groupByLabel(rows).values) {
    if (bucket.length < 2) continue;
    bucket.sort((a, b) => a.index.compareTo(b.index)); // stable input order
    for (var k = 1; k < bucket.length; k++) {
      bucket[k].label = '${bucket[k].label}${_numberSuffix(k + 1)}'; // 2-based
    }
  }

  return <String, String>{
    for (final r in rows) r.product.sku: r.label,
  };
}
