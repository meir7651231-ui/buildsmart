// ─────────────────────────────────────────────────────────────────────────────
// Catalog source flag — additive staging for the NEW Huliot catalog (directive:
// knowledge/DIRECTIVE-huliot-images.md).
//
//   • v1 = `kCatalogProducts` (the existing unified catalog) — live. It already
//          carries the owner's curated image upgrades on EXISTING products (512
//          Huliot + 248 Lipski), applied at the source in polyroll_catalog.dart.
//   • v2 = v1 + `kHuliotProducts` (adds the 789 genuinely-NEW Huliot products).
//
// The image upgrades are LIVE (part of v1). This flag stages ONLY the catalog
// EXPANSION (the 789 new products): the product universe is unchanged until the
// flag flips. The flip is owner-gated (gradual 5%→100%) and set at launch via
// `--dart-define=CATALOG_SOURCE=v2`.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/huliot_catalog.dart' show kHuliotProducts;
import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;

/// The two catalog sources. [v1] is the live baseline (already image-upgraded);
/// [v2] is the staging catalog that ALSO includes the 789 new Huliot products.
enum CatalogSource { v1, v2 }

/// The staging catalog (v2): the live unified catalog PLUS the additive NEW
/// Huliot products. A SEPARATE list — v1 (`kCatalogProducts`) is never mutated,
/// so a rollback of the EXPANSION is simply "read v1". (`final`, not `const`:
/// `kCatalogProducts` is itself assembled at load time, so the union can't be a
/// compile-time const.)
final List<LipskeyCatalogProduct> kCatalogProductsV2 = <LipskeyCatalogProduct>[
  ...kCatalogProducts,
  ...kHuliotProducts,
];

const String _kCatalogSourceDefine =
    String.fromEnvironment('CATALOG_SOURCE', defaultValue: 'v1');

/// The active source. Stays [CatalogSource.v1] until launched with
/// `--dart-define=CATALOG_SOURCE=v2`.
CatalogSource get catalogSource =>
    _kCatalogSourceDefine == 'v2' ? CatalogSource.v2 : CatalogSource.v1;

/// The resolved product universe for the active source. Opt-in consumers read
/// THIS instead of `kCatalogProducts` directly. Under the default (v1) this
/// returns the existing image-upgraded list; v2 appends the 789 new products.
List<LipskeyCatalogProduct> get resolvedCatalogProducts =>
    catalogSource == CatalogSource.v2 ? kCatalogProductsV2 : kCatalogProducts;
