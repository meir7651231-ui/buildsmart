// ─────────────────────────────────────────────────────────────────────────────
// CATALOG-CONFIG · dive-bs2b — the VARIANT resolver (plan D · image-per-selection).
// PURE + widget-free: given a [ProductConfigSchema], the live [selection] map and
// a product [universe], it finds the catalog SKU whose engine-derivable values
// MATCH the current selection, so the center image can SWAP on every axis/wheel
// change instead of staying fixed to the tapped tile (the abandoned dive-bs4).
//
// MATCHING (owner directive · "the image is the current selection"): a candidate
// is a family member (`familyOf(p) == schema.familyId`, or a manifold when the
// schema is the derived 'מחלק') whose DERIVED values equal the selection tokens —
// `odOf`==diameter · the elbow family's angle==angle · `color`==color ·
// `dims['יציאות']`==ports. LENGTH/THREAD carry no catalog data → ignored. The best
// (highest-scoring) member wins; ties keep the first in universe order.
//
// FALLBACK (plan D.2 · never an empty box): no scoring member → [variantImageFor]
// is null and the card drops to the tapped image, then [familyFallbackImage] (the
// family's first pictured member), then the schema emoji. So the center is NEVER
// blank.
//
// GATING (plan G · byte-identical-off): pure functions, NO `kCatalogConfig` branch;
// reachable only through the gated card. Nothing outside features/catalog_config/
// imports it ⇒ it tree-shakes out of a default (OFF) build. The unit test drives
// it directly over a HAND-BUILT universe (exercised OFF · deterministic).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/features/catalog_config/product_config_schema.dart';
import 'package:buildsmart/features/fittings/engine/catalog_map.dart';

/// The derived-family id used for manifolds ([configSchemaFor] tags them 'מחלק',
/// since `familyOf` returns null for a manifold).
const String _kManifoldFamily = 'מחלק';

/// Manifold predicate — a LOCAL mirror of the schema builder's private one, so
/// this resolver stays self-contained and `product_config_schema.dart`'s API is
/// left untouched (byte-identical-off). Same rule: the name carries 'מחלק'/'סעפת'.
bool _isManifold(LipskeyCatalogProduct p) =>
    p.nameHe.contains('מחלק') || p.nameHe.contains('סעפת');

/// Is [p] a member of the family [schema] was derived from? An engine family
/// matches by `familyOf`; the derived 'מחלק' family matches by [_isManifold]
/// (a manifold has no `familyOf`).
bool _inFamily(ProductConfigSchema schema, LipskeyCatalogProduct p) =>
    familyOf(p) == schema.familyId ||
    (schema.familyId == _kManifoldFamily && _isManifold(p));

/// The angle degrees an elbow family label carries ('ברך 90°' → '90'), or null
/// when [family] is not an elbow. °-less — matching the engine canonical token
/// the angle wheel stores (stuck_log RULE: the canonical never carries °).
String? _familyAngle(String? family) {
  if (family == null || !family.startsWith('ברך')) {
    return null;
  }
  final match = RegExp(r'\d+').firstMatch(family);
  return match?.group(0);
}

/// The catalog value [p] derives for attribute [attrId] — the SAME derivation the
/// schema builder aggregates, so a selection token (canonical) compares 1:1. null
/// ⇒ [p] carries no value for it, or the attribute is not catalog-derivable
/// (length/thread/freeText → ignored in matching, never a mismatch penalty).
String? _derivedValue(LipskeyCatalogProduct p, String attrId) {
  switch (attrId) {
    case 'diameter':
    case 'diameter-large':
      return odOf(p)?.toString();
    case 'diameter-small':
      return od2Of(p)?.toString();
    case 'angle':
      return _familyAngle(familyOf(p));
    case 'color':
      return p.color;
    case 'ports':
      final raw = p.dims?['יציאות'];
      return raw == null ? null : '$raw';
    default:
      return null;
  }
}

/// The family members of [schema] within [universe] — the BOUNDED candidate set
/// the card resolves against (memoized once per product so a rebuild never scans
/// the whole catalog). Empty when the family has no members here.
List<LipskeyCatalogProduct> familyProducts(
  ProductConfigSchema schema,
  List<LipskeyCatalogProduct> universe,
) =>
    [
      for (final p in universe)
        if (_inFamily(schema, p)) p,
    ];

/// The catalog product whose derivable values BEST match [selection] within
/// [schema]'s family in [universe] — the SKU whose image the card shows for the
/// current picks. Scores each family member by how many selection tokens its
/// derived values equal (length/thread ignored); the highest-scoring member wins,
/// ties keep the first in universe order. null ⇒ no member matched a single token
/// (empty family / a selection no member carries → the caller falls back · M1).
LipskeyCatalogProduct? variantForSelection(
  ProductConfigSchema schema,
  Map<String, String> selection,
  List<LipskeyCatalogProduct> universe,
) {
  LipskeyCatalogProduct? best;
  var bestScore = 0;
  for (final p in universe) {
    if (!_inFamily(schema, p)) {
      continue;
    }
    var score = 0;
    selection.forEach((id, want) {
      if (_derivedValue(p, id) == want) {
        score++;
      }
    });
    if (score > bestScore) {
      bestScore = score;
      best = p;
    }
  }
  return best;
}

/// The image asset of the SKU matching [selection] (plan D · swaps per pick), or
/// null when nothing matches → the caller drops to the tapped image / the family
/// fallback / the emoji.
String? variantImageFor(
  ProductConfigSchema schema,
  Map<String, String> selection,
  List<LipskeyCatalogProduct> universe,
) =>
    variantForSelection(schema, selection, universe)?.imageAsset;

/// The FAMILY fallback image (plan D.2) — the first family member that carries an
/// image, so a selection matching no exact SKU still shows a family photo rather
/// than a blank box. null ⇒ the family has no pictured member (→ the emoji).
String? familyFallbackImage(
  ProductConfigSchema schema,
  List<LipskeyCatalogProduct> universe,
) {
  for (final p in universe) {
    if (_inFamily(schema, p) && p.imageAsset != null) {
      return p.imageAsset;
    }
  }
  return null;
}
