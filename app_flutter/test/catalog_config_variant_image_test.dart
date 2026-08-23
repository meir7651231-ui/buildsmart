// CATALOG-CONFIG · dive-bs2b variant-image test — pins the PURE resolver that lets
// the centre image SWAP per selection (plan D). Over a HAND-BUILT universe (no live
// catalog): a fake elbow family (2 diameters × 2 angles + images) + a fake manifold
// family (2 ports/colors). variantForSelection picks the SKU whose engine-derived
// values (odOf / the family angle / color / dims['יציאות']) match the selection —
// LENGTH is ignored (no catalog data); familyFallbackImage returns the family's
// first pictured member; an unmatched/empty universe → null (M1 fallback). Pure
// data — exercised define-less (kCatalogConfig OFF).
// SSOT: knowledge/CATALOG-CONFIG-PLAN.md (§D · §dive-bs2b).

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart'
    show kPprCollars, kPprElbows;
import 'package:buildsmart/features/catalog_config/product_config_schema.dart';
import 'package:buildsmart/features/catalog_config/variant_image.dart';
import 'package:flutter_test/flutter_test.dart';

/// A fake catalog product — only the fields the resolver reads matter (name →
/// family/od/angle, category → family, color/dims → manifold, imageFile → image).
LipskeyCatalogProduct _p(
  String sku,
  String nameHe,
  String categoryHe, {
  String? imageFile,
  String? color,
  Map<String, dynamic>? dims,
}) =>
    LipskeyCatalogProduct(
      sku: sku,
      nameHe: nameHe,
      nameEn: '',
      categoryHe: categoryHe,
      categoryEn: '',
      categoryEmoji: '🔧',
      page: 1,
      color: color,
      dims: dims,
      imageFile: imageFile,
    );

// ── a fake ELBOW family: 90°/45° × DN 20/25, each with its own image ──────────
final LipskeyCatalogProduct _e9020 =
    _p('E-9020', 'ברך PPR 90° 20', kPprElbows, imageFile: 'e9020.jpeg');
final LipskeyCatalogProduct _e9025 =
    _p('E-9025', 'ברך PPR 90° 25', kPprElbows, imageFile: 'e9025.jpeg');
final LipskeyCatalogProduct _e4520 =
    _p('E-4520', 'ברך PPR 45° 20', kPprElbows, imageFile: 'e4520.jpeg');
final LipskeyCatalogProduct _e4525 =
    _p('E-4525', 'ברך PPR 45° 25', kPprElbows, imageFile: 'e4525.jpeg');

final List<LipskeyCatalogProduct> _elbows = [_e9020, _e9025, _e4520, _e4525];

// ── a fake MANIFOLD family: 3-way blue / 2-way red, DN 25, each with an image ──
final LipskeyCatalogProduct _m3blue = _p(
  'M-3B',
  'מחלק PPR 3 דרך 25',
  kPprCollars,
  imageFile: 'm3b.jpeg',
  color: 'כחול',
  dims: {'יציאות': '3'},
);
final LipskeyCatalogProduct _m2red = _p(
  'M-2R',
  'מחלק PPR 2 דרך 25',
  kPprCollars,
  imageFile: 'm2r.jpeg',
  color: 'אדום',
  dims: {'יציאות': '2'},
);

final List<LipskeyCatalogProduct> _manifolds = [_m3blue, _m2red];

void main() {
  group('#catalog-config variant — elbow family (odOf + angle match)', () {
    final schema = configSchemaFor(_e9020, universe: _elbows);

    test('familyProducts bounds the candidates to the exact 90° family', () {
      final fam = familyProducts(schema, _elbows);
      expect(fam.map((p) => p.sku), ['E-9020', 'E-9025']); // the 45° pair excluded
    });

    test('picks the SKU whose diameter (+ angle) match the selection', () {
      // The °-less angle token the wheel stores, taken from the ° LABEL (never a
      // bare 45/90 literal — stuck_log RULE). Both candidates carry it (90°), so
      // DIAMETER discriminates; LENGTH is ignored (no catalog data).
      final angle = schema.attributes.first.values
          .firstWhere((v) => v.labelHe == '90°')
          .canonical!;
      final small = variantForSelection(
        schema,
        {'angle': angle, 'length': 'קצר', 'diameter': '20'},
        _elbows,
      );
      final big = variantForSelection(
        schema,
        {'angle': angle, 'length': 'ארוך', 'diameter': '25'},
        _elbows,
      );
      expect(small?.sku, 'E-9020');
      expect(big?.sku, 'E-9025'); // LENGTH differs but is ignored — diameter wins
      expect(variantImageFor(schema, const {'diameter': '25'}, _elbows),
          'assets/lipskey/products/e9025.jpeg',);
    });

    test('no SKU matches → variantImageFor null, familyFallbackImage the 1st image',
        () {
      const selection = {'diameter': '99'}; // no family member has od 99
      expect(variantForSelection(schema, selection, _elbows), isNull);
      expect(variantImageFor(schema, selection, _elbows), isNull);
      // the fallback is the family's first pictured member (never a blank box).
      expect(familyFallbackImage(schema, _elbows),
          'assets/lipskey/products/e9020.jpeg',);
    });

    test('empty universe → null everywhere (M1 · caller drops to the emoji)', () {
      const empty = <LipskeyCatalogProduct>[];
      expect(
        variantForSelection(schema, const {'diameter': '20'}, empty),
        isNull,
      );
      expect(variantImageFor(schema, const {'diameter': '20'}, empty), isNull);
      expect(familyFallbackImage(schema, empty), isNull);
    });
  });

  group('#catalog-config variant — manifold family (color + ports match)', () {
    final schema = configSchemaFor(_m3blue, universe: _manifolds);

    test('derived family is מחלק with the ports/color/diameter axes', () {
      expect(schema.familyId, 'מחלק');
      expect(familyProducts(schema, _manifolds).map((p) => p.sku),
          ['M-3B', 'M-2R'],);
    });

    test('picks the SKU whose ports + color match the selection', () {
      final blue = variantForSelection(
        schema,
        const {'ports': '3', 'color': 'כחול', 'diameter': '25'},
        _manifolds,
      );
      final red = variantForSelection(
        schema,
        const {'ports': '2', 'color': 'אדום', 'diameter': '25'},
        _manifolds,
      );
      expect(blue?.sku, 'M-3B');
      expect(red?.sku, 'M-2R');
      expect(variantImageFor(schema,
          const {'ports': '2', 'color': 'אדום'}, _manifolds),
          'assets/lipskey/products/m2r.jpeg',);
    });
  });
}
