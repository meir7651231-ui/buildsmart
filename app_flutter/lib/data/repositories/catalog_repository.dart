// ─────────────────────────────────────────────────────────────────────────────
// CatalogRepository — the read surface for the unified product catalog + the
// SmartProduct fixtures (the ▦ קטלוג / 🌳 עץ-חכם source the card flow reads).
//
// SERVER-READY FOUNDATION (Track T6.1). This is the ABSTRACT interface only;
// the local implementation (T6.2) and the provider refactor (T6.3) come later.
// When the catalog moves to a real backend (a product/price API) the only thing
// that swaps is the implementation behind this contract — the providers + UI
// stay unchanged.
//
// CURRENT BACKING (what T6.2's local impl will wrap): the const catalog data —
//   • `kCatalogProducts` (`data/polyroll_catalog.dart`) — the 1,877-row UNIFIED
//     catalog (Lipskey + Polyroll + Huliot) of `LipskeyCatalogProduct`.
//   • `kSmartProducts` (`data/smart_tree.dart`) — the 82 curated SmartProduct
//     cards, with the bridge helpers `smartProductForSku` / `smartProductByKey`
//     / `smartProductsForCat` / `kSmartTreeCats`.
//   • the catalog↔smart bridge in `data/related_info.dart`
//     (`catalogProductForSku` / `catalogProductForBrand` / `catalogProductForSmart`).
//   • `kCatalogCats` (`data/catalog.dart`) — the 11 ▦ search top-categories.
//   • `kCatalogTree` (`data/catalog_tree.dart`) — the ▦ drill-down taxonomy.
// A future product API drops in behind this contract (swap-implementation-only).
//
// Method surface mirrors the catalog reads the card flow / catalog screen use
// today: list-all, lookup-by-sku, the SmartProduct fixtures + the two-way
// catalog↔smart bridge, and the category axes.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/catalog_tree.dart'
    show CatalogNode, kCatalogTree;
import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/sections.dart' show Section;
import 'package:buildsmart/data/smart_tree.dart'
    show SmartBrand, SmartProduct;

/// Server-ready contract over the unified product catalog + SmartProduct
/// fixtures. The current backing is the const catalog data (`kCatalogProducts`,
/// `kSmartProducts`) + the bridge helpers (`data/related_info.dart` /
/// `data/smart_tree.dart`); a future product/price API swaps in behind it.
abstract class CatalogRepository {
  // ── unified catalog (LipskeyCatalogProduct) ───────────────────────────────

  /// Every product in the unified catalog (Lipskey + Polyroll + Huliot).
  /// Mirrors `kCatalogProducts` (`data/polyroll_catalog.dart`).
  /// [tradeId] — per-trade seam; default `'plumbing'` keeps today byte-identical.
  List<LipskeyCatalogProduct> allProducts({String tradeId = 'plumbing'});

  /// The unified catalog product with this [sku], or null when unknown / null.
  /// Mirrors `catalogProductForSku` (`data/related_info.dart`).
  LipskeyCatalogProduct? productForSku(String? sku);

  /// The catalog product a SmartProduct [brand] points at, or null when it has
  /// no SKU / the SKU isn't in the catalog. Mirrors `catalogProductForBrand`.
  LipskeyCatalogProduct? productForBrand(SmartBrand brand);

  /// The catalog product behind [sp]'s recommended brand, or null if none.
  /// Mirrors `catalogProductForSmart` (`data/related_info.dart`).
  LipskeyCatalogProduct? productForSmart(SmartProduct sp);

  // ── SmartProduct fixtures (the curated cards) ──────────────────────────────

  /// Every curated SmartProduct card (82 fixtures). Mirrors `kSmartProducts`
  /// (`data/smart_tree.dart`).
  List<SmartProduct> allSmartProducts();

  /// The SmartProduct with this [key], or null when unknown. Mirrors
  /// `smartProductByKey` (used to link catalog-tree leaves to a card).
  SmartProduct? smartProductByKey(String key);

  /// The SmartProduct that lists [sku] as one of its brand options, or null
  /// (the reverse bridge). Mirrors `smartProductForSku`.
  SmartProduct? smartProductForSku(String sku);

  /// The curated SmartProducts in category [cat]. Mirrors `smartProductsForCat`.
  List<SmartProduct> smartProductsForCat(String cat);

  // ── category axes ──────────────────────────────────────────────────────────

  /// The distinct categories that have curated SmartProducts, in fixture order.
  /// Mirrors `kSmartTreeCats` (`data/smart_tree.dart`).
  /// [tradeId] — per-trade seam; default `'plumbing'` keeps today byte-identical.
  List<String> smartTreeCats({String tradeId = 'plumbing'});

  /// The ▦ קטלוג top categories (11 leaves) shown under the Search FAB.
  /// Mirrors `kCatalogCats` (`data/catalog.dart`).
  /// [tradeId] — per-trade seam; default `'plumbing'` keeps today byte-identical.
  List<Section> catalogCategories({String tradeId = 'plumbing'});

  /// The catalog drill-down tree (the ▦ L1→L3 [CatalogNode] taxonomy).
  /// Mirrors `kCatalogTree` (`data/catalog_tree.dart`).
  /// [tradeId] — per-trade seam; default `'plumbing'` keeps today byte-identical;
  /// other trades read `const []` until the trades-store wiring lands (s43+).
  /// Default body (not abstract) so existing implementations compile unchanged.
  List<CatalogNode> categoryTree({String tradeId = 'plumbing'}) =>
      tradeId == 'plumbing' ? kCatalogTree : const <CatalogNode>[];
}
