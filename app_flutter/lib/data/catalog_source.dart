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
/// returns the byte-identical existing const list — zero live change.
List<LipskeyCatalogProduct> get resolvedCatalogProducts =>
    catalogSource == CatalogSource.v2 ? kCatalogProductsV2 : kCatalogProducts;
