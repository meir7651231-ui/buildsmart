// Tests for the PURE material axis (material_lexicon.dart, the "ציר-חומר" entry).
//
// HARNESS: runs under `flutter_test`, NOT a bare `dart test` — material_lexicon
// imports `package:buildsmart/data/lipskey_catalog.dart`, which transitively
// pulls `package:flutter/...` into the chain (the same pre-existing coupling
// every other word-finder library carries). The logic under test is pure; the
// harness choice is only about that import chain.
//
// The fixtures are DATA-DRIVEN over the real kDivePool (no hard-coded sku that
// could drift): a copper product is FOUND by scanning for 'נחושת' in its nameHe,
// a PPR product by 'PPR', and the count bounds are loose sanity bounds anchored
// to the brief's verified SCOUT DATA (copper > 50, PPR > 300), never exact.

import 'package:buildsmart/features/word_finder/dive_pool.dart';
import 'package:buildsmart/features/word_finder/material_lexicon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('materialOf', () {
    test('a copper product (nameHe contains נחושת) → נחושת', () {
      // Find a real copper product by its name text (data-driven, no fixed sku).
      final copper = kDivePool.firstWhere((p) => p.nameHe.contains('נחושת'));
      expect(materialOf(copper), 'נחושת',
          reason: 'a product whose name carries נחושת must bucket as נחושת');
    });

    test('a PPR product (nameHe/categoryHe contains PPR) → PPR', () {
      final ppr = kDivePool.firstWhere(
          (p) => '${p.nameHe} ${p.categoryHe}'.contains('PPR'));
      expect(materialOf(ppr), 'PPR',
          reason: 'a product whose text carries PPR must bucket as PPR');
    });

    test('a product matching NO material term → null', () {
      // Find a real product none of whose terms appear in its text.
      final none = kDivePool.firstWhere((p) {
        final haystack = '${p.nameHe} ${p.categoryHe}';
        return kMaterials.values
            .every((terms) => terms.every((t) => !haystack.contains(t)));
      });
      expect(materialOf(none), isNull,
          reason: 'a product with no material term carries no material');
    });

    test('precedence: the FIRST matching kMaterials key wins', () {
      // Every assigned material must equal the FIRST key whose any term hits —
      // i.e. materialOf never returns a later key when an earlier one matched.
      for (final p in kDivePool) {
        final assigned = materialOf(p);
        if (assigned == null) continue;
        final haystack = '${p.nameHe} ${p.categoryHe}';
        String? firstHit;
        for (final entry in kMaterials.entries) {
          if (entry.value.any(haystack.contains)) {
            firstHit = entry.key;
            break;
          }
        }
        expect(assigned, firstHit,
            reason: 'materialOf must return the first matching key (precedence '
                '= kMaterials order)');
      }
    });
  });

  group('materialsInPool', () {
    test('returns the present kMaterials keys IN kMaterials order, each non-empty',
        () {
      final present = materialsInPool(kDivePool);

      // Every returned key is a real kMaterials key, and the list is a
      // subsequence of kMaterials.keys (order preserved, no extras).
      final allKeys = kMaterials.keys.toList();
      var lastIndex = -1;
      for (final m in present) {
        final idx = allKeys.indexOf(m);
        expect(idx, greaterThan(lastIndex),
            reason: 'materialsInPool must keep kMaterials order (subsequence)');
        lastIndex = idx;
        expect(productsOfMaterial(kDivePool, m), isNotEmpty,
            reason: 'a material in the pool list must have >=1 product');
      }

      // And every key that DOES have products is present (none dropped).
      for (final m in allKeys) {
        if (productsOfMaterial(kDivePool, m).isNotEmpty) {
          expect(present, contains(m),
              reason: 'a material with products must appear in materialsInPool');
        }
      }
    });

    test('SANITY bounds (data-driven, not exact): copper > 50, PPR > 300', () {
      // Anchored to the brief's verified SCOUT DATA (נחושת/פליז 111, PPR 774).
      // Loose lower bounds — they pin "the buckets are populated", not a count
      // that would drift as the catalog grows.
      expect(productsOfMaterial(kDivePool, 'נחושת').length, greaterThan(50),
          reason: 'copper/brass is a large bucket (SCOUT DATA ~111)');
      expect(productsOfMaterial(kDivePool, 'PPR').length, greaterThan(300),
          reason: 'PPR is the largest bucket (SCOUT DATA ~774)');
    });
  });

  group('productsOfMaterial', () {
    test('every returned product has materialOf == that material', () {
      for (final m in materialsInPool(kDivePool)) {
        for (final p in productsOfMaterial(kDivePool, m)) {
          expect(materialOf(p), m,
              reason: 'productsOfMaterial($m) must contain only $m products');
        }
      }
    });
  });

  group('purity / determinism', () {
    test('two calls produce identical results', () {
      expect(materialsInPool(kDivePool), materialsInPool(kDivePool),
          reason: 'materialsInPool is pure — same pool ⇒ same list');
      final copper1 = productsOfMaterial(kDivePool, 'נחושת');
      final copper2 = productsOfMaterial(kDivePool, 'נחושת');
      expect(copper1.map((p) => p.sku).toList(),
          copper2.map((p) => p.sku).toList(),
          reason: 'productsOfMaterial is pure — same pool ⇒ same products');
    });
  });
}
