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
//
// On the 'clean' profile ([kProfileEmptyCatalog]) the resolved universe is
// EMPTY (empty shell) — the getter is the ONE point every consumer inherits,
// so CATALOG_SOURCE=v2 can never leak a catalog past it.
//
// Company-catalog overlay (import feature): ONE code, each company pours its
// OWN catalog into this ONE point at runtime — [setCompanyCatalog] installs an
// imported list (hydrated from prefs BEFORE runApp by
// `state/company_catalog_store.dart`) and the getter serves it overlay-first.
// Phase B swaps the LOADER for the server chain (catalog_sync); the sink stays
// this same seam, unchanged.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/huliot_catalog.dart' show kHuliotProducts;
import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/state/app_profile.dart' show kProfileEmptyCatalog;

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

/// The runtime company-catalog overlay (import feature). `null` until a
/// company catalog is imported/hydrated; a non-empty list here REPLACES the
/// compile-time universe in [resolvedCatalogProducts].
List<LipskeyCatalogProduct>? _companyCatalog;

/// Install — or, with `null`/empty, turn OFF — the company-catalog overlay.
/// The ONE write point for the ONE read point ([resolvedCatalogProducts]):
/// the import store (`state/company_catalog_store.dart`) calls this on
/// hydrate / import / clear. Phase B pours the server chain into this same
/// sink.
void setCompanyCatalog(List<LipskeyCatalogProduct>? items) {
  _companyCatalog = items;
}

/// TRUE when a company catalog is the live universe (the import overlay is
/// installed and non-empty). UI derivations (category rows, drill fallbacks)
/// key off THIS — not the profile const — so the define-less demo suite can
/// prove them with [setCompanyCatalog] alone, and the closed-set profile
/// sweep stays untouched.
bool get companyCatalogActive {
  final c = _companyCatalog;
  return c != null && c.isNotEmpty;
}

/// The resolved product universe for the active source. Opt-in consumers read
/// THIS instead of `kCatalogProducts` directly. Under the default (v1) this
/// returns the existing image-upgraded list; v2 appends the 789 new products.
/// On 'clean' ([kProfileEmptyCatalog]) it is EMPTY — that branch is checked
/// FIRST, so CATALOG_SOURCE=v2 can never leak past the empty shell.
///
/// Company-catalog overlay (import feature): when [setCompanyCatalog] has
/// installed a non-empty imported list, THAT list is the universe — checked
/// before the compile-time branches, so ONE code serves each company's own
/// catalog. With no overlay (demo/buildsmart, or clean before an import) the
/// branches below return the SAME objects as before — identity included.
List<LipskeyCatalogProduct> get resolvedCatalogProducts {
  final company = _companyCatalog;
  if (company != null && company.isNotEmpty) return company;
  return kProfileEmptyCatalog
      ? const <LipskeyCatalogProduct>[]
      : catalogSource == CatalogSource.v2 ? kCatalogProductsV2 : kCatalogProducts;
}
