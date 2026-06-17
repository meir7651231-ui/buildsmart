// Unit tests for the deduped UNION pool index (STEP 1, dive_pool.dart).
//
// Pure-Dart assertions — no widgets pumped — verifying that kDivePool is
// genuinely deduped, that it FIXES the kCatalogProducts hot-water omission,
// and that divePoolIndex carries plausible membership flags.

import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('kDivePool', () {
    test('(a) is deduped by sku — no duplicate skus', () {
      final skus = kDivePool.map((p) => p.sku).toList();
      expect(skus.toSet().length, kDivePool.length,
          reason: 'every sku in kDivePool must be unique (first-wins dedupe)');
    });

    test('(b) includes a known hot-water sku (omission fixed)', () {
      // kCatalogProducts omits hot-water; kDivePool must NOT.
      final hwSkus = kHotWaterCatalog.map((p) => p.sku).toSet();
      expect(hwSkus, isNotEmpty,
          reason: 'sanity: the hot-water corpus is non-empty');

      final poolSkus = kDivePool.map((p) => p.sku).toSet();
      // A specific, named hot-water sku must be present...
      expect(poolSkus, contains('HW-PUMP-25'),
          reason: 'a known hot-water sku must be in the dive pool');
      // ...and so must EVERY hot-water sku (the whole family carried over).
      expect(poolSkus.containsAll(hwSkus), isTrue,
          reason: 'kDivePool must carry the entire hot-water family');
    });
  });

  group('divePoolIndex', () {
    test('(c) has a plausible entry for a known catalog+smart+spec sku', () {
      // 217861 — American bottle trap (kLipskeyCatalog): in the catalog union,
      // in the compat union, has a verified spec, and is a SmartProduct brand.
      final m = divePoolIndex['217861'];
      expect(m, isNotNull, reason: 'known catalog sku must be indexed');
      expect(m!.inCatalog, isTrue);
      expect(m.inCompat, isTrue);
      expect(m.hasSpec, isTrue);
      expect(m.hasSmart, isTrue);
    });

    test('hot-water sku is indexed: in compat, NOT in catalog union', () {
      final m = divePoolIndex['HW-PUMP-25'];
      expect(m, isNotNull, reason: 'hot-water sku must be indexed');
      expect(m!.inCompat, isTrue,
          reason: 'hot-water lives in the compatibility union');
      expect(m.inCatalog, isFalse,
          reason: 'hot-water is exactly what the catalog union omits');
    });

    test('index covers every sku in the pool', () {
      expect(divePoolIndex.length, kDivePool.length);
      for (final p in kDivePool) {
        expect(divePoolIndex.containsKey(p.sku), isTrue,
            reason: 'every pooled sku must have a Membership entry');
      }
    });
  });
}
