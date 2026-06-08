// ─────────────────────────────────────────────────────────────────────────────
// LocalCatalogRepository — the T6.2 local implementation of [CatalogRepository].
//
// SERVER-READY FOUNDATION (Track T6.2 + T6.3). This wraps the EXISTING const
// catalog data — it adds NO new data and changes NO value. Every read returns
// EXACTLY the same const list / lookup the screens read today, so the catalog
// (▦ קטלוג), the finder, departments and the SmartProduct cards stay
// byte-for-byte identical. When the catalog moves to a real product/price API,
// only THIS class swaps (the provider + UI stay unchanged).
//
// Unlike [LocalOrdersRepository] (which holds a [Ref] to reach the live engine)
// this repository is PURE — it reads only top-level consts / const-derived
// helpers, so it needs no [Ref] and its provider is `const`. The backing:
//   • `kCatalogProducts`            (data/polyroll_catalog.dart)
//   • `catalogProductForSku/Brand/Smart` (data/related_info.dart) — the bridge
//   • `kSmartProducts` + `smartProductByKey` / `smartProductForSku` /
//     `smartProductsForCat` / `kSmartTreeCats` (data/smart_tree.dart)
//   • `kCatalogCats`                (data/catalog.dart)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:buildsmart/data/catalog.dart' show kCatalogCats;
import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/data/related_info.dart'
    show catalogProductForBrand, catalogProductForSku, catalogProductForSmart;
import 'package:buildsmart/data/repositories/catalog_repository.dart';
import 'package:buildsmart/data/sections.dart' show Section;
// The three SmartProduct helpers share their names with this class's methods, so
// they're imported under the `st` prefix — an unprefixed call would resolve to
// the (overriding) instance method and recurse forever. `SmartBrand` /
// `SmartProduct` / `kSmartProducts` / `kSmartTreeCats` don't collide, so they
// come in unprefixed for readability.
import 'package:buildsmart/data/smart_tree.dart'
    show SmartBrand, SmartProduct, kSmartProducts, kSmartTreeCats;
import 'package:buildsmart/data/smart_tree.dart' as st
    show smartProductByKey, smartProductForSku, smartProductsForCat;

/// The local (const-backed) implementation of [CatalogRepository]. Pure: every
/// method forwards to a top-level const / const-derived helper, returning the
/// SAME object the screens read directly today — no value is recomputed and no
/// [Ref] is needed. A future remote impl swaps in behind the same provider.
class LocalCatalogRepository implements CatalogRepository {
  const LocalCatalogRepository();

  // ── unified catalog (LipskeyCatalogProduct) ───────────────────────────────

  @override
  List<LipskeyCatalogProduct> allProducts() => kCatalogProducts;

  @override
  LipskeyCatalogProduct? productForSku(String? sku) => catalogProductForSku(sku);

  @override
  LipskeyCatalogProduct? productForBrand(SmartBrand brand) =>
      catalogProductForBrand(brand);

  @override
  LipskeyCatalogProduct? productForSmart(SmartProduct sp) =>
      catalogProductForSmart(sp);

  // ── SmartProduct fixtures (the curated cards) ──────────────────────────────

  @override
  List<SmartProduct> allSmartProducts() => kSmartProducts;

  @override
  SmartProduct? smartProductByKey(String key) => st.smartProductByKey(key);

  @override
  SmartProduct? smartProductForSku(String sku) => st.smartProductForSku(sku);

  @override
  List<SmartProduct> smartProductsForCat(String cat) =>
      st.smartProductsForCat(cat);

  // ── category axes ──────────────────────────────────────────────────────────

  @override
  List<String> smartTreeCats() => kSmartTreeCats;

  @override
  List<Section> catalogCategories() => kCatalogCats;
}

/// The single shared [LocalCatalogRepository] instance. Both the global
/// accessor [catalogRepo] and the [catalogRepositoryProvider] hand this exact
/// instance out, so the catalog has ONE source whether it's reached from a
/// Consumer (via the provider) or from top-level pure code / a StatelessWidget
/// (via the global). Pure + `const`, so sharing one instance costs nothing.
const _kCatalogRepo = LocalCatalogRepository();

/// Global const accessor to the catalog repository — for top-level functions
/// and StatelessWidgets that have no [Ref] to read the provider. Returns the
/// SAME instance the provider yields, so a future remote impl that swaps the
/// provider must swap this too (one source). Pure reads only (no live state).
CatalogRepository catalogRepo() => _kCatalogRepo;

/// The catalog repository provider — the server-ready seam the catalog screens
/// read through (T6.3) and a future remote product/price API swaps in behind.
/// Pure (no [Ref]); hands out the SAME [_kCatalogRepo] as the global accessor.
final catalogRepositoryProvider =
    Provider<CatalogRepository>((ref) => _kCatalogRepo);
