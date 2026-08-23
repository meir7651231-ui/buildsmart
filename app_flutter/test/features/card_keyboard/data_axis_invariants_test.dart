// data_axis_invariants_test.dart — step 45: cross-axis invariants that must hold
// after all P1 data edits (39 size · 40/41 material · 42 colour · 43 taxonomy ·
// 44 groups). These pin the COHERENCE between axes, not any single value.

import 'package:buildsmart/features/word_finder/category_groups.dart';
import 'package:buildsmart/features/word_finder/color_truth.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart';
import 'package:buildsmart/features/word_finder/material_lexicon.dart'
    show materialOf, materialOfEnriched, materialsInPoolEnriched;
import 'package:buildsmart/features/word_finder/material_taxonomy.dart';
import 'package:buildsmart/features/word_finder/narrow_axis.dart'
    show sizeTokensIn;
import 'package:buildsmart/features/word_finder/size_equiv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final pool = kDivePool;

  test('no card colour value is also a material (axes are disjoint)', () {
    final colours = cardColorOptions(pool).toSet();
    final materials = materialsInPoolEnriched(pool).toSet();
    expect(colours.intersection(materials), isEmpty,
        reason: 'a value cannot be both a true colour and a material');
  });

  test('every product has a category group (groupOf is total)', () {
    for (final p in pool) {
      expect(groupOf(p), isNotEmpty);
    }
  });

  test('enriched coverage >= live coverage (seededFraction recovered)', () {
    final base = pool.where((p) => materialOf(p) != null).length;
    final rich = pool.where((p) => materialOfEnriched(p) != null).length;
    expect(rich, greaterThanOrEqualTo(base));
  });

  test('every canonicalSize fold is itself canonical (reachable fixed point)',
      () {
    for (final t in sizeTokensIn(pool)) {
      final c = canonicalSize(t.label);
      if (c != null) {
        expect(canonicalSize(c), c, reason: 'a DN key must fold to itself');
      }
    }
  });

  test('every material-axis value is canonical under the taxonomy', () {
    for (final m in materialsInPoolEnriched(pool)) {
      expect(canonicalMaterial(m), m,
          reason: 'the material axis must already be in canonical form');
    }
  });
}
