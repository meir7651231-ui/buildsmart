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
    show materialOfEnriched, materialsInPoolEnriched;
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

  group('material axis — gated CO-EQUAL (>1 split + coverage floor)', () {
    final copper = kDivePool
        .where((p) => materialOfEnriched(p) == 'נחושת')
        .take(8)
        .toList();
    final ppr = kDivePool
        .where((p) => materialOfEnriched(p) == 'PPR')
        .take(8)
        .toList();
    final unknown = kDivePool
        .where((p) => materialOfEnriched(p) == null)
        .take(12)
        .toList();

    test('a single-material pool yields no chips (cannot split)', () {
      expect(copper, isNotEmpty, reason: 'sanity: copper products exist');
      expect(materialsInPoolEnriched(copper), ['נחושת'],
          reason: 'sanity: an all-copper pool has exactly one material');
      expect(const MaterialSignal().chipsFor(copper), isEmpty,
          reason: 'one material cannot narrow → the gated co-axis hides it');
    });

    test('a multi-material pool above the floor yields chips', () {
      final pool = [...copper.take(5), ...ppr.take(5)];
      expect(materialsInPoolEnriched(pool).length, greaterThan(1),
          reason: 'sanity: two materials present');
      expect(const MaterialSignal().chipsFor(pool), isNotEmpty,
          reason: '>1 material + full coverage → it splits → chips');
    });

    test('below the coverage floor: no chips even with >1 material', () {
      final pool = [...unknown, ...copper.take(2), ...ppr.take(2)];
      expect(materialsInPoolEnriched(pool).length, greaterThan(1),
          reason: 'sanity: two known materials present');
      expect(MaterialSignal.seededFraction(pool),
          lessThan(kMaterialCoverageGate),
          reason: 'sanity: a mostly-unknown pool is below the floor');
      expect(const MaterialSignal().chipsFor(pool), isEmpty,
          reason: 'coverage below the floor → hidden despite splitting');
    });

    test('chips == materialsInPoolEnriched when the gate passes', () {
      final pool = [...copper.take(5), ...ppr.take(5)];
      expect(
        const MaterialSignal().chipsFor(pool).map((c) => c.value).toList(),
        materialsInPoolEnriched(pool),
      );
    });

    test('predicate is null-tolerant: a truly-unknown product rides along', () {
      final u = kDivePool.firstWhere((p) => materialOfEnriched(p) == null);
      const copperChip =
          SignalChip(axisId: 'material', value: 'נחושת', displayLabel: 'נחושת');
      expect(const MaterialSignal().matches(u, copperChip), isTrue,
          reason: 'a null (unknown) material carries along (§2)');

      final c = kDivePool.firstWhere((p) => materialOfEnriched(p) == 'נחושת');
      const pprChip =
          SignalChip(axisId: 'material', value: 'PPR', displayLabel: 'PPR');
      expect(const MaterialSignal().matches(c, pprChip), isFalse,
          reason: 'a KNOWN material matches only its own value (or null)');
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
