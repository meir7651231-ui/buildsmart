/// PURE hard-axis signal sources for the unified card-keyboard (#38), Phase 1.
///
/// Each [SignalSource] turns a pool into the candidate [SignalChip]s for ONE
/// axis (size · angle · colour · word · material) plus the membership predicate
/// that narrows the pool when the user taps a chip. The merge ([mergedKeys],
/// Phase 2) scores and interleaves all five; Phase 1 just produces each axis's
/// chips + predicate, isolated and unit-testable.
///
/// PARITY (#29): the four subtype-free axes (size/angle/colour/word) reuse the
/// EXACT helpers the live finder uses — `sizeTokensIn` / `angleTokensIn` /
/// `colorOptions` / `wordOptions` + `productHasChip` — so a chip's
/// [SignalChip.displayLabel] is byte-identical to the old `AskAxis` output, and
/// [SizeSignal] does NOT yet cross-fold spellings (DN15↔½"): that is a
/// data-dependent semantic change (a verified nominal table), deferred as an
/// owner-reviewed enhancement. The existing parse already canonicalises SPELLING
/// (1.25"→1¼", 1/2"→½"), so each token label is its own stable key.
///
/// PURE: no Flutter widgets / Riverpod / clock / IO. [pool] is a parameter only.
library;

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/features/card_keyboard/card_engine.dart'
    show SignalChip;
import 'package:buildsmart/features/word_finder/material_lexicon.dart'
    show materialOf, materialsInPool;
import 'package:buildsmart/features/word_finder/narrow_axis.dart'
    show angleTokensIn, colorOptions, productHasChip, sizeTokensIn, wordOptions;

/// Below this fraction of products with a KNOWN material, the material axis is
/// hidden — too sparse to be a useful split (build plan §2, #28). OWNER-REVIEW.
const double kMaterialCoverageGate = 0.5;

/// A hard-axis signal source. PURE: a transform of [pool] → candidate chips, and
/// a membership predicate. Subtype-free (no `subtype` needed — the curated
/// 'אפשרות' facet stays in the live finder, out of the merged engine for now).
abstract class SignalSource {
  const SignalSource();

  /// Stable axis id: `'size' | 'angle' | 'color' | 'word' | 'material'`. Drives
  /// the predicate family + the [SignalChip.axisId]; never changes by copy.
  String get axisId;

  /// Axis display name (the Semantics prefix / chip-row hint). Never affects
  /// routing or the predicate (#6).
  String get axisName;

  /// The candidate chips this axis offers for [pool] — deduped, in axis order.
  /// Empty when the axis can't split the pool (or, for material, when coverage
  /// is below [kMaterialCoverageGate]).
  List<SignalChip> chipsFor(List<LipskeyCatalogProduct> pool);

  /// Whether [p] is KEPT when the user taps [chip] (the narrowing predicate).
  /// Keyed on [SignalChip.value] (the predicate key), never the displayLabel.
  bool matches(LipskeyCatalogProduct p, SignalChip chip);
}

/// SIZE axis — the structural size tokens (`sizeTokensIn`). value==displayLabel
/// (the already-spelling-canonical token label); predicate = `productHasChip`
/// (no loose contains for digit-bearing labels). Byte-parity with the live axis.
class SizeSignal extends SignalSource {
  const SizeSignal();
  @override
  String get axisId => 'size';
  @override
  String get axisName => 'גודל';
  @override
  List<SignalChip> chipsFor(List<LipskeyCatalogProduct> pool) => <SignalChip>[
        for (final t in sizeTokensIn(pool))
          SignalChip(
            axisId: axisId,
            value: t.label,
            displayLabel: t.label,
            axisName: axisName,
          ),
      ];
  @override
  bool matches(LipskeyCatalogProduct p, SignalChip chip) =>
      productHasChip(p, chip.value);
}

/// ANGLE axis — `angleTokensIn`; predicate = `productHasChip` (structural).
class AngleSignal extends SignalSource {
  const AngleSignal();
  @override
  String get axisId => 'angle';
  @override
  String get axisName => 'זווית';
  @override
  List<SignalChip> chipsFor(List<LipskeyCatalogProduct> pool) => <SignalChip>[
        for (final t in angleTokensIn(pool))
          SignalChip(
            axisId: axisId,
            value: t.label,
            displayLabel: t.label,
            axisName: axisName,
          ),
      ];
  @override
  bool matches(LipskeyCatalogProduct p, SignalChip chip) =>
      productHasChip(p, chip.value);
}

/// COLOUR axis — `colorOptions`; predicate is the EXACT `p.color` equality the
/// colour axis is built from (NOT `productHasChip`, whose digit-free name fallback
/// could wrongly match a colour word inside the name).
class ColorSignal extends SignalSource {
  const ColorSignal();
  @override
  String get axisId => 'color';
  @override
  String get axisName => 'צבע';
  @override
  List<SignalChip> chipsFor(List<LipskeyCatalogProduct> pool) => <SignalChip>[
        for (final c in colorOptions(pool))
          SignalChip(
            axisId: axisId,
            value: c,
            displayLabel: c,
            axisName: axisName,
          ),
      ];
  @override
  bool matches(LipskeyCatalogProduct p, SignalChip chip) =>
      p.color == chip.value;
}

/// WORD axis — `wordOptions` (the first distinguishing word per name); predicate
/// = `productHasChip` (its digit-free `name.contains` fallback is exactly how a
/// word chip matches in the live finder).
class WordSignal extends SignalSource {
  const WordSignal();
  @override
  String get axisId => 'word';
  @override
  String get axisName => 'דגם';
  @override
  List<SignalChip> chipsFor(List<LipskeyCatalogProduct> pool) {
    // DETERMINISM (swarm R2): wordOptions' equal-count tie-break + take(12) follow
    // the pool's iteration order (a LinkedHashMap + a non-stable sort over
    // pool-order entries), so a re-ordered pool could yield a DIFFERENT word set.
    // Feed it a CANONICAL (sku-sorted) pool so the word axis is order-independent
    // like the other four — the live wordOptions is untouched and the count-desc
    // ranking is preserved (only the equal-count tie-break is now sku-stable).
    final canonical = [...pool]..sort((a, b) => a.sku.compareTo(b.sku));
    return <SignalChip>[
      for (final w in wordOptions(canonical))
        SignalChip(
          axisId: axisId,
          value: w,
          displayLabel: w,
          axisName: axisName,
        ),
    ];
  }

  @override
  bool matches(LipskeyCatalogProduct p, SignalChip chip) =>
      productHasChip(p, chip.value);
}

/// MATERIAL axis — the NEW 5th axis (build plan §2). `materialsInPool` chips,
/// GATED so it shows only when ≥ [kMaterialCoverageGate] of the pool has a known
/// material (#28). The predicate is NULL-TOLERANT: an unknown-material product
/// rides ALONG (so the unseeded MAJORITY is not dropped — materialOf detects a
/// known material for only a minority of the union pool, and the exact share
/// varies per narrowed pool; swarm R3 corrected an earlier "~42%" overstatement);
/// only the Phase-2 scoring excludes nulls so copper/brass counts are not
/// inflated by the shared null.
class MaterialSignal extends SignalSource {
  const MaterialSignal();
  @override
  String get axisId => 'material';
  @override
  String get axisName => 'חומר';

  /// Fraction of [pool] with a known [materialOf] — drives the coverage gate.
  static double seededFraction(List<LipskeyCatalogProduct> pool) {
    if (pool.isEmpty) return 0;
    final seeded = pool.where((p) => materialOf(p) != null).length;
    return seeded / pool.length;
  }

  @override
  List<SignalChip> chipsFor(List<LipskeyCatalogProduct> pool) {
    if (seededFraction(pool) < kMaterialCoverageGate) return const <SignalChip>[];
    return <SignalChip>[
      for (final m in materialsInPool(pool))
        SignalChip(
          axisId: axisId,
          value: m,
          displayLabel: m,
          axisName: axisName,
        ),
    ];
  }

  @override
  bool matches(LipskeyCatalogProduct p, SignalChip chip) {
    final m = materialOf(p);
    return m == chip.value || m == null; // null carries along (§2)
  }
}

/// The five hard-axis sources in canonical order (size → angle → colour → word →
/// material) — the same precedence the live finder's tie-break uses, with the
/// new material axis last. The merge (Phase 2) iterates these.
const List<SignalSource> kHardSignals = <SignalSource>[
  SizeSignal(),
  AngleSignal(),
  ColorSignal(),
  WordSignal(),
  MaterialSignal(),
];
