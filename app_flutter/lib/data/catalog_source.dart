// ─────────────────────────────────────────────────────────────────────────────
// Catalog source flag — additive staging for the Huliot catalog (directive:
// knowledge/DIRECTIVE-huliot-images.md).
//
//   • v1 = `kCatalogProducts` (the existing unified catalog) — UNCHANGED, live,
//          kept intact for instant rollback.
//   • v2 = v1 + `kHuliotProducts` (adds the 1,346 additive Huliot products).
//
// The DEFAULT is v1: nothing changes live until the flag flips. The flip is
// owner-gated (gradual 5%→100%) and set at launch via
// `--dart-define=CATALOG_SOURCE=v2`. Because the default resolves to the SAME
// const list the app reads today, wiring a consumer to [resolvedCatalogProducts]
// is byte-identical until CATALOG_SOURCE=v2.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/huliot_catalog.dart' show kHuliotProducts;
import 'package:buildsmart/data/huliot_image_overrides.dart'
    show kHuliotImageOverrides;
import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;

/// The two catalog sources. [v1] is the live/rollback baseline; [v2] is the
/// staging catalog that includes the additive Huliot products.
enum CatalogSource { v1, v2 }

/// The staging catalog (v2): the live unified catalog PLUS the additive Huliot
/// products. A SEPARATE list — v1 (`kCatalogProducts`) is never mutated, so a
/// rollback is simply "read v1". (`final`, not `const`: `kCatalogProducts` is
/// itself assembled at load time, so the union can't be a compile-time const.)
final List<LipskeyCatalogProduct> kCatalogProductsV2 = <LipskeyCatalogProduct>[
  for (final p in kCatalogProducts) _withOwnerImage(p),
  ...kHuliotProducts,
];

/// s-huliot: for a product the owner upgraded (via the image picker →
/// [kHuliotImageOverrides]), return a copy that points at the chosen higher-res
/// Huliot image through [LipskeyCatalogProduct.imageAssetOverride]; brand, dims
/// and every other field stay identical. Untouched products pass through as-is.
LipskeyCatalogProduct _withOwnerImage(LipskeyCatalogProduct p) {
  final override = kHuliotImageOverrides[p.sku];
  if (override == null) return p;
  return LipskeyCatalogProduct(
    sku: p.sku,
    nameHe: p.nameHe,
    nameEn: p.nameEn,
    color: p.color,
    qtyPack: p.qtyPack,
    qtyPallet: p.qtyPallet,
    categoryHe: p.categoryHe,
    categoryEn: p.categoryEn,
    categoryEmoji: p.categoryEmoji,
    page: p.page,
    dims: p.dims,
    imageFile: p.imageFile,
    imageFiles: p.imageFiles,
    specImageFile: p.specImageFile,
    specImageFiles: p.specImageFiles,
    brand: p.brand,
    imageAssetOverride: override,
  );
}

const String _kCatalogSourceDefine =
    String.fromEnvironment('CATALOG_SOURCE', defaultValue: 'v1');

/// The active source. Stays [CatalogSource.v1] until launched with
/// `--dart-define=CATALOG_SOURCE=v2`.
CatalogSource get catalogSource =>
    _kCatalogSourceDefine == 'v2' ? CatalogSource.v2 : CatalogSource.v1;

/// The resolved product universe for the active source. Opt-in consumers read
/// THIS instead of `kCatalogProducts` directly. Under the default (v1) this
/// returns the byte-identical existing const list — zero live change.
List<LipskeyCatalogProduct> get resolvedCatalogProducts =>
    catalogSource == CatalogSource.v2 ? kCatalogProductsV2 : kCatalogProducts;
