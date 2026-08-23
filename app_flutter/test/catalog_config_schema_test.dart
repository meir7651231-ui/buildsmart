// CATALOG-CONFIG · Phase F fold test — pins that `configSchemaFor` now aggregates
// REAL per-family values over a passed `universe` (the fold of the old `derive`
// aggregation into the engine schema builder), and falls back to the template
// ladder when a family has no siblings (M1 guard). Deterministic: a HAND-BUILT
// universe of fake products (no live catalog). The category strings come from the
// real `familyOf` map (kPpr* constants) so the test tracks the engine mapping.
// Pure data — exercised define-less (kCatalogConfig OFF).
// SSOT: knowledge/CATALOG-CONFIG-PLAN.md (§F, §0.2).

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart'
    show kPprCouplers, kPprElbows;
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/features/catalog_config/product_config_schema.dart';
import 'package:buildsmart/features/fittings/engine/fitting_dims.dart' show kDepth;
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(String nameHe, String categoryHe) =>
    LipskeyCatalogProduct(
      sku: 'T-$nameHe',
      nameHe: nameHe,
      nameEn: '',
      categoryHe: categoryHe,
      categoryEn: '',
      categoryEmoji: '🔧',
      page: 1,
    );

List<String> _canon(AttributeDef a) =>
    a.values.map((v) => v.canonical ?? v.labelHe).toList();

// ── a hand-built universe (deterministic) ────────────────────────────────────
// elbows: 90° at DN 20/25, 45° at DN 32 — the elbow GROUP shares one angle axis.
final LipskeyCatalogProduct _e9020 = _p('ברך PPR 90° פ.פ 20', kPprElbows);
final LipskeyCatalogProduct _e9025 = _p('ברך PPR 90° פ.פ 25', kPprElbows);
final LipskeyCatalogProduct _e4532 = _p('ברך PPR 45° פ.פ 32', kPprElbows);
// couplings: single-diameter at DN 40/50.
final LipskeyCatalogProduct _c40 = _p('מצמד PPR פ.פ 40', kPprCouplers);
final LipskeyCatalogProduct _c50 = _p('מצמד PPR פ.פ 50', kPprCouplers);
// reducers (מצרה): big end 63, two small ends 40/32.
final LipskeyCatalogProduct _r6340 = _p('מצרה PPR 63x40', kPprCouplers);
final LipskeyCatalogProduct _r6332 = _p('מצרה PPR 63x32', kPprCouplers);

final List<LipskeyCatalogProduct> _universe = <LipskeyCatalogProduct>[
  _e9020,
  _e9025,
  _e4532,
  _c40,
  _c50,
  _r6340,
  _r6332,
];

void main() {
  group('#catalog-config fold — REAL aggregated values over a passed universe', () {
    test('elbow diameter = the exact-family DN ladder (NOT all kDepth)', () {
      final s = configSchemaFor(_e9020, universe: _universe);
      expect(s.familyId, 'ברך 90°');
      // dive-bs2b order: attr[0]=angle (↕) · attr[1]=length (↔) · attr[2]=diameter.
      expect(s.attributes.map((a) => a.id), ['angle', 'length', 'diameter']);
      // diameter aggregates the 90° siblings' odOf only → [20, 25], not kDepth.
      final diameter = s.attributes.last;
      expect(_canon(diameter), ['20', '25']);
      expect(diameter.kind, AttributeKind.dimension);
      expect(diameter.values.length, isNot(kDepth.length)); // real, not template
    });

    test('elbow angle = the whole elbow GROUP (45° + 90°), NOT hardcoded 45/90 only',
        () {
      // 45° elbow shares the SAME aggregated angle axis (group, not exact family).
      final s = configSchemaFor(_e4532, universe: _universe);
      expect(s.familyId, 'ברך 45°');
      final angle = s.attributes[0];
      expect(angle.id, 'angle');
      expect(angle.kind, AttributeKind.choice);
      // labels carry ° (canonical stays °-less) — stuck_log RULE: never a bare 45/90.
      expect(angle.values.map((v) => v.labelHe).toList(), ['45°', '90°']);
    });

    test('coupling diameter = both real DNs (single wheel)', () {
      final s = configSchemaFor(_c40, universe: _universe);
      expect(s.familyId, 'מצמד');
      expect(s.attributes.map((a) => a.id), ['diameter']);
      expect(_canon(s.attributes.single), ['40', '50']);
    });

    test('reducer → large end + aggregated small ends (od2Of)', () {
      final s = configSchemaFor(_r6340, universe: _universe);
      expect(s.familyId, 'מצרה');
      expect(s.attributes.map((a) => a.id), ['diameter-large', 'diameter-small']);
      expect(_canon(s.attributes[0]), ['63']); // shared big end
      expect(_canon(s.attributes[1]), ['32', '40']); // both small ends, sorted
    });
  });

  group('#catalog-config fold — template fallback when a family has no siblings', () {
    test('an empty universe → the template kDepth ladder (M1: never empty)', () {
      final s = configSchemaFor(_e9020, universe: const []);
      final diameter = s.attributes.last;
      // no siblings ⇒ diameter falls back to the sorted kDepth ODs (template).
      expect(diameter.values.length, kDepth.length);
      expect(_canon(diameter), diameterValues().map((v) => v.canonical).toList());
      // angle falls back to the template {45°, 90°} — asserted via the ° labels.
      expect(s.attributes[0].values.map((v) => v.labelHe).toList(), ['45°', '90°']);
    });

    test('every aggregated attribute is non-empty (M1 guard holds)', () {
      for (final p in _universe) {
        final s = configSchemaFor(p, universe: _universe);
        for (final a in s.attributes) {
          expect(a.values, isNotEmpty, reason: '${p.nameHe} · ${a.id} value-less');
        }
      }
    });
  });
}
