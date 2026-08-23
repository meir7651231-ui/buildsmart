// 🔑 Phase A (steps 20+22) — Huliot connectivity: no-leak · R5(v2) coverage ·
// answer-equivalent · M2 safety. All at the DEFAULT v1 catalog (flag conceptually
// OFF ⇒ this whole seam is dormant in production); these prove it is CORRECT and
// INERT so arming (v2 + kFittingEngine) is safe.
import 'package:buildsmart/data/catalog_source.dart'
    show kCatalogProductsV2, resolvedCatalogProducts;
import 'package:buildsmart/data/family_specs.dart';
import 'package:buildsmart/data/huliot_catalog.dart' show kHuliotProducts;
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/related_info.dart' show compatibleProductsFor;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('step 22 — no-leak: seeding Huliot specs is INERT at the default v1 catalog', () {
    test('after registerFamilySpecs, every compat result stays inside the resolved catalog', () {
      // At v1 (test default) the 789 Huliot products are NOT in resolvedCatalogProducts,
      // so even with their specs registered they can never surface as a compat match.
      registerFamilySpecs();
      final resolved = {for (final p in resolvedCatalogProducts) p.sku};
      for (final p in resolvedCatalogProducts) {
        for (final q in compatibleProductsFor(p)) {
          expect(resolved.contains(q.sku), isTrue,
              reason: '${p.sku} → leaked ${q.sku} outside the resolved catalog',);
        }
      }
    });
  });

  group('step 20 — R5: registerFamilySpecs covers the v2 universal Huliot list (gate 114)', () {
    test('the Huliot portion of kCatalogProductsV2 resolves ≥90%', () {
      const nonFitting = {'אטם', 'חבק'};
      final v2Huliot = kCatalogProductsV2
          .where((p) => p.brand == 'Huliot' && !nonFitting.contains(p.categoryHe))
          .toList();
      expect(v2Huliot.length, greaterThan(500), reason: 'v2 must carry the 789 Huliot');
      final covered = v2Huliot.where((p) => familySpecFor(p) != null).length;
      expect(100.0 * covered / v2Huliot.length, greaterThanOrEqualTo(90.0));
    });
  });

  group('step 22 — M2 safety: Huliot drainage mates only Huliot, never supply', () {
    // Build the Huliot spec set once.
    final specs = <VerifiedSpec>[
      for (final p in kHuliotProducts)
        if (familySpecFor(p) != null) familySpecFor(p)!,
    ];
    List<VerifiedSpec> ofDn(String dn) =>
        specs.where((s) => s.ends.first.size == dn).toList();

    test('two same-DN Huliot fittings mate (they connect)', () {
      final dn = ofDn('110');
      expect(dn.length, greaterThanOrEqualTo(2), reason: 'expect several DN110 Huliot');
      expect(dn[0].compatibleWith(dn[1]), isTrue,
          reason: 'same-DN Huliot drainage must connect',);
    });

    test('a Huliot drainage spec does NOT mate an HDPE-supply spec of the same DN', () {
      final h = ofDn('63').first; // Huliot drainage @ DN63
      const supply = VerifiedSpec(
        sku: 'X-SUPPLY-63', material: 'HDPE', // a pressure-supply HDPE fitting
        ends: [ConnectorEnd(EndType.hdpeCompression, '63')],
      );
      expect(h.compatibleWith(supply), isFalse,
          reason: 'M2: drainage HDPE·ניקוז must not join supply HDPE',);
      expect(h.material, isNot('HDPE')); // the load-bearing distinction
    });

    test('a Huliot drainage spec does NOT mate a PPR (polyroll-supply) spec of the same DN', () {
      final h = ofDn('32').first;
      // any polyroll product resolves to a PPR supply spec via polyrollSpecFor.
      const ppr = VerifiedSpec(
        sku: 'X-PPR-32', material: 'PPR',
        ends: [ConnectorEnd(EndType.hdpeCompression, '32')],
      );
      expect(h.compatibleWith(ppr), isFalse, reason: 'drainage must not join PPR supply');
    });
  });
}
