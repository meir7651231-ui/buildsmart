// 🔑 Phase A — familySpecFor ⊇ polyrollSpecFor · Huliot 0→~100% · putIfAbsent keystone.
import 'package:buildsmart/data/family_specs.dart';
import 'package:buildsmart/data/huliot_catalog.dart' show kHuliotProducts;
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/data/polyroll_specs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('step 14 — familySpecFor ⊇ polyrollSpecFor (superset, not replacement)', () {
    test('every polyroll product gets the IDENTICAL proven spec', () {
      var checked = 0;
      for (final p in kPolyrollCatalog) {
        final poly = polyrollSpecFor(p);
        final fam = familySpecFor(p);
        if (poly == null) continue;
        checked++;
        expect(fam, isNotNull, reason: '${p.sku}: familySpecFor dropped a polyroll spec');
        expect(fam!.sku, poly.sku);
        expect(fam.material, poly.material);
        expect(fam.ends.length, poly.ends.length, reason: '${p.sku}: end count');
        for (var i = 0; i < poly.ends.length; i++) {
          expect(fam.ends[i].type, poly.ends[i].type, reason: '${p.sku}: end $i type');
          expect(fam.ends[i].size, poly.ends[i].size, reason: '${p.sku}: end $i size');
        }
      }
      expect(checked, greaterThan(100), reason: 'sanity — many polyroll specs checked');
    });
  });

  group('🔑 step 18 — Huliot 789 SKU: 0 → ~100% of connecting fittings', () {
    // Non-connecting categories (gasket/clamp) are legitimately fallback (M1).
    const nonFitting = {'אטם', 'חבק'};
    test('connecting Huliot products resolve to a drainage HDPE spec', () {
      final connecting =
          kHuliotProducts.where((p) => !nonFitting.contains(p.categoryHe)).toList();
      final miss = <String>[];
      for (final p in connecting) {
        final s = familySpecFor(p);
        if (s == null) {
          miss.add('${p.categoryHe} · ${p.nameHe}');
          continue;
        }
        expect(s.ends, isNotEmpty, reason: '${p.sku}: empty ends');
        expect(s.material, 'HDPE·ניקוז'); // distinct — avoids M2 vs HDPE-supply
        expect(s.endSystems, contains(WaterSystem.drainage),
            reason: '${p.sku}: not classified drainage',);
      }
      final total = connecting.length;
      final covered = total - miss.length;
      final pct = 100.0 * covered / total;
      // ignore: avoid_print — the Huliot coverage headline (step 25 gap telemetry).
      print('[huliot-coverage] $covered/$total = ${pct.toStringAsFixed(1)}%'
          '${miss.isEmpty ? '' : ' · gaps (no size):\n  ${miss.take(20).join('\n  ')}'}');
      expect(pct, greaterThanOrEqualTo(90.0),
          reason: '${miss.length} connecting Huliot products unresolved',);
    });

    test('non-fitting Huliot (gasket/clamp) → null fallback, never a wrong spec (M1)', () {
      for (final p in kHuliotProducts.where((p) => nonFitting.contains(p.categoryHe))) {
        expect(familySpecFor(p), isNull, reason: '${p.sku}: ${p.categoryHe} should fallback');
      }
    });
  });

  group('step 16 — registerFamilySpecs via putIfAbsent (keystone R2)', () {
    test('adds Huliot specs without overwriting any existing spec', () {
      // snapshot a few existing (polyroll/lipskey) specs
      final before = <String, VerifiedSpec>{
        for (final e in kVerifiedSpecs.entries.take(50)) e.key: e.value,
      };
      final sizeBefore = kVerifiedSpecs.length;

      registerFamilySpecs();

      // existing untouched (byte-identical — same object identity via putIfAbsent)
      for (final e in before.entries) {
        expect(identical(kVerifiedSpecs[e.key], e.value), isTrue,
            reason: '${e.key}: an existing spec was overwritten',);
      }
      // grew by the resolvable Huliot set
      expect(kVerifiedSpecs.length, greaterThan(sizeBefore),
          reason: 'registerFamilySpecs added nothing',);
      // idempotent — a second run changes nothing
      final after = kVerifiedSpecs.length;
      registerFamilySpecs();
      expect(kVerifiedSpecs.length, after, reason: 'not idempotent');
    });
  });
}
