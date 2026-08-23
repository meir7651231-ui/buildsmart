import 'package:buildsmart/features/word_finder/dive_pool.dart';
import 'package:buildsmart/features/word_finder/material_lexicon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final pool = kDivePool;

  test('enriched is a strict superset — every existing hit is unchanged', () {
    for (final p in pool) {
      final base = materialOf(p);
      if (base != null) {
        expect(materialOfEnriched(p), base,
            reason: 'enriched must never reclassify an existing materialOf hit');
      }
    }
  });

  test('dims recovers name-omitted materials, each genuinely dims-backed', () {
    final base = pool.where((p) => materialOf(p) != null).length;
    final rich = pool.where((p) => materialOfEnriched(p) != null).length;
    expect(rich, greaterThan(base),
        reason: 'dims[חומר] must recover materials the name text omits');

    final recovered = pool
        .where((p) => materialOf(p) == null && materialOfEnriched(p) != null)
        .toList();
    expect(recovered, isNotEmpty);
    for (final p in recovered) {
      // Never invented — every recovery is declared in the product's dims.
      expect(p.dims?['חומר'], isNotNull);
    }
  });

  test('copper is ALREADY complete via name text (dims adds no new copper)', () {
    // Data reality (vs the plan's "~64 dims copper"): every catalog copper
    // product names 'נחושת', so materialOf already tags all of it; dims[חומר]
    // adds zero NEW copper. If this ever flips, a copper name tag regressed.
    final copperViaDims = pool.where(
        (p) => materialOf(p) == null && materialOfEnriched(p) == 'נחושת');
    expect(copperViaDims, isEmpty);
  });
}
