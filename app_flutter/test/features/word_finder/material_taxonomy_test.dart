import 'package:buildsmart/data/lipskey_verified_connections.dart'
    show kVerifiedSpecs;
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/material_lexicon.dart'
    show kMaterials, materialOf;
import 'package:buildsmart/features/word_finder/material_taxonomy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('brass folds into the copper bucket', () {
    expect(canonicalMaterial('פליז'), 'נחושת');
    expect(canonicalMaterial('brass'), 'נחושת');
  });

  test('stainless and steel each collapse to one bucket', () {
    expect(canonicalMaterial('stainless'), canonicalMaterial('נירוסטה'));
    expect(canonicalMaterial('stainless'), 'נירוסטה');
    expect(canonicalMaterial('steel'), 'פלדה');
  });

  test('every kMaterials key is a fixed point (idempotent, no reclassify)', () {
    for (final k in kMaterials.keys) {
      expect(canonicalMaterial(k), k, reason: 'a canonical bucket maps to itself');
      expect(canonicalMaterial(canonicalMaterial(k)), canonicalMaterial(k),
          reason: 'idempotent');
    }
  });

  test('canonicalMaterial never reclassifies an existing materialOf hit', () {
    for (final p in kDivePool) {
      final m = materialOf(p);
      if (m != null) expect(canonicalMaterial(m), m);
    }
  });

  test('every VerifiedSpec.material value resolves (no throw, non-empty)', () {
    for (final spec in kVerifiedSpecs.values) {
      expect(canonicalMaterial(spec.material), isNotEmpty,
          reason: 'spec ${spec.sku}: ${spec.material}');
    }
  });
}
