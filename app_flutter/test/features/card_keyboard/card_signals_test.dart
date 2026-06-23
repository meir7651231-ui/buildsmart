// Unified card-keyboard (#38) Phase 1 — hard signal sources.
//
// PARITY (#29): the four subtype-free axes produce chip values byte-identical to
// the live finder helpers they wrap. MATERIAL: the new 5th axis — the coverage
// gate (#28) and the null-tolerant carry-along predicate (§2).

import 'package:buildsmart/features/card_keyboard/card_engine.dart'
    show SignalChip;
import 'package:buildsmart/features/card_keyboard/card_signals.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/material_lexicon.dart'
    show materialOf, materialsInPool;
import 'package:buildsmart/features/word_finder/narrow_axis.dart'
    show angleTokensIn, colorOptions, sizeTokensIn, wordOptions;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('hard signals — chip parity with the live finder helpers', () {
    test('size chips: same SET as sizeTokensIn, re-sorted ASCENDING mm (R4)', () {
      final chips = const SizeSignal().chipsFor(kDivePool);
      final tokens = sizeTokensIn(kDivePool);
      // SET parity preserved (same labels as the live helper)...
      expect(chips.map((c) => c.value).toSet(),
          tokens.map((t) => t.label).toSet());
      // ...but ordered by GLOBAL mm so the merge's representativeTake endpoints
      // are the real physical min/max, not per-family (swarm R4).
      final mmOf = {for (final t in tokens) t.label: t.mm};
      final mms = [for (final c in chips) mmOf[c.value]!];
      for (var i = 1; i < mms.length; i++) {
        expect(mms[i] >= mms[i - 1], isTrue,
            reason: 'size chips must be globally mm-ascending');
      }
      expect(chips.every((c) => c.value == c.displayLabel), isTrue,
          reason: 'no cross-fold yet → value == displayLabel');
      expect(chips.every((c) => c.axisId == 'size'), isTrue);
    });

    test('angle chips == angleTokensIn labels', () {
      final chips = const AngleSignal().chipsFor(kDivePool);
      expect(
        chips.map((c) => c.value).toList(),
        angleTokensIn(kDivePool).map((t) => t.label).toList(),
      );
    });

    test('colour chips == colorOptions', () {
      final chips = const ColorSignal().chipsFor(kDivePool);
      expect(chips.map((c) => c.value).toList(), colorOptions(kDivePool));
    });

    test('word chips == wordOptions', () {
      final chips = const WordSignal().chipsFor(kDivePool);
      expect(chips.map((c) => c.value).toList(), wordOptions(kDivePool));
    });
  });

  group('material axis — coverage gate + null-tolerant predicate', () {
    test('coverage gate: all-unseeded pool → no chips; all-seeded → chips', () {
      final seeded =
          kDivePool.where((p) => materialOf(p) != null).take(20).toList();
      final unseeded =
          kDivePool.where((p) => materialOf(p) == null).take(20).toList();
      expect(seeded, isNotEmpty, reason: 'sanity: some products carry material');
      expect(unseeded, isNotEmpty, reason: 'sanity: some carry none');
      expect(const MaterialSignal().chipsFor(seeded), isNotEmpty,
          reason: 'seededFraction 1.0 ≥ gate → material chips');
      expect(const MaterialSignal().chipsFor(unseeded), isEmpty,
          reason: 'seededFraction 0 < gate → axis hidden (#28)');
    });

    test('coverage gate BOUNDARY: exactly 0.5 shows, just-below hides (per-pool)',
        () {
      // The gate is `seededFraction < kMaterialCoverageGate` (STRICT <), so a pool
      // at EXACTLY 0.5 shows and one just below hides — and chipsFor recomputes it
      // per pool (so material appears/disappears as a dive narrows). Swarm R3: the
      // suite previously pinned only the 0.0 / 1.0 extremes, leaving the operator
      // that IS the gate's whole contract unguarded.
      final seeded = kDivePool.firstWhere((p) => materialOf(p) != null);
      final unseeded =
          kDivePool.where((p) => materialOf(p) == null).take(2).toList();
      expect(unseeded.length, 2, reason: 'sanity: two unseeded products exist');
      expect(const MaterialSignal().chipsFor([seeded, unseeded[0]]), isNotEmpty,
          reason: 'seededFraction == 0.5 is NOT below the gate → axis SHOWS');
      expect(const MaterialSignal().chipsFor([seeded, ...unseeded]), isEmpty,
          reason: 'seededFraction 1/3 < gate → axis HIDES (recomputed per pool)');
    });

    test('chips == materialsInPool when the gate passes', () {
      final seeded =
          kDivePool.where((p) => materialOf(p) != null).take(40).toList();
      expect(
        const MaterialSignal().chipsFor(seeded).map((c) => c.value).toList(),
        materialsInPool(seeded),
      );
    });

    test('predicate is null-tolerant: unknown-material product rides along', () {
      final unknown = kDivePool.firstWhere((p) => materialOf(p) == null);
      const copperChip =
          SignalChip(axisId: 'material', value: 'נחושת', displayLabel: 'נחושת');
      expect(const MaterialSignal().matches(unknown, copperChip), isTrue,
          reason: 'a null material carries along (§2 — the unseeded majority '
              'is not lost; swarm R3 corrected the stale "~42%" figure)');

      final copper = kDivePool
          .firstWhere((p) => materialOf(p) == 'נחושת', orElse: () => unknown);
      if (materialOf(copper) == 'נחושת') {
        const steelChip =
            SignalChip(axisId: 'material', value: 'פלדה', displayLabel: 'פלדה');
        expect(const MaterialSignal().matches(copper, steelChip), isFalse,
            reason: 'a KNOWN material only matches its own value (or null)');
      }
    });
  });

  test('kHardSignals = the 5 axes in canonical order', () {
    expect(
      kHardSignals.map((s) => s.axisId).toList(),
      <String>['size', 'angle', 'color', 'word', 'material'],
    );
  });

  group('curated facet axis (swarm R7 gap-close)', () {
    test('sourcesFor: 5 hard axes for null/unknown subtype, +facet for curated',
        () {
      expect(sourcesFor(null).map((s) => s.axisId).toList(),
          <String>['size', 'angle', 'color', 'word', 'material']);
      expect(sourcesFor('not-a-subtype').map((s) => s.axisId).toList(),
          <String>['size', 'angle', 'color', 'word', 'material']);
      expect(sourcesFor('מכסים ורשתות').map((s) => s.axisId).toList(),
          <String>['size', 'angle', 'color', 'word', 'material', 'facet']);
    });

    test('CuratedFacetSignal: chips are curated keywords present in the pool', () {
      const facet = CuratedFacetSignal('מכסים ורשתות');
      final pool = kDivePool
          .where((p) => p.nameHe.contains('מכסה') || p.nameHe.contains('רשת'))
          .toList();
      final chips = facet.chipsFor(pool);
      expect(chips, isNotEmpty, reason: 'cover/grate keywords are present');
      expect(chips.every((c) => c.axisId == 'facet'), isTrue);
      expect(chips.every((c) => c.axisName == 'אפשרות'), isTrue);
      for (final c in chips) {
        final hit = pool.firstWhere((p) => p.nameHe.contains(c.value));
        expect(facet.matches(hit, c), isTrue,
            reason: 'matches keeps a product whose name contains the keyword');
      }
    });

    test('CuratedFacetSignal: null / unknown subtype → no chips', () {
      expect(const CuratedFacetSignal(null).chipsFor(kDivePool), isEmpty);
      expect(const CuratedFacetSignal('xyz').chipsFor(kDivePool), isEmpty);
    });
  });
}
