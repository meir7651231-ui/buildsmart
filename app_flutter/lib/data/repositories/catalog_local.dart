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
// this repository holds no [Ref]: the PLUMBING reads are PURE (top-level consts /
// const-derived helpers only), and the s50 authored-trade read-path arrives as an
// INJECTED doc source (`authoredDoc`) — null (every direct construction) keeps
// the s42 behavior: non-plumbing reads stay empty. The backing:
//   • `kCatalogProducts`            (data/polyroll_catalog.dart)
//   • `catalogProductForSku/Brand/Smart` (data/related_info.dart) — the bridge
//   • `kSmartProducts` + `smartProductByKey` / `smartProductForSku` /
//     `smartProductsForCat` / `kSmartTreeCats` (data/smart_tree.dart)
//   • `kCatalogCats`                (data/catalog.dart)
//   • `kCatalogTree`                (data/catalog_tree.dart)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/catalog.dart' show kCatalogCats;
import 'package:buildsmart/data/catalog_source.dart'
    show resolvedCatalogProducts;
import 'package:buildsmart/data/catalog_tree.dart'
    show CatalogNode, kCatalogTree;
import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
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
import 'package:buildsmart/domain/trade_product_adapter.dart'
    show TradeProductLegacy;
import 'package:buildsmart/state/trades_store.dart'
    show TradesDoc, tradesStoreProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The local (const-backed) implementation of [CatalogRepository]. The plumbing
/// reads are pure: every method forwards to a top-level const / const-derived
/// helper, returning the SAME object the screens read directly today — no value
/// is recomputed and no [Ref] is needed. s50: non-plumbing (authored) trades are
/// served from the injected [authoredDoc] source (the trades store); a null
/// source keeps the s42 behavior — authored reads stay empty. A future remote
/// impl swaps in behind the same provider.
class LocalCatalogRepository implements CatalogRepository {
  /// [authoredDoc] — s50: the authored-trades doc source. The provider wires it
  /// to the trades store; null (every direct construction, incl. the const
  /// global [catalogRepo]) keeps non-plumbing reads empty (the s42 contract).
  const LocalCatalogRepository({TradesDoc Function()? authoredDoc})
      : _authoredDoc = authoredDoc;

  /// Returns the CURRENT authored [TradesDoc] (read fresh per call — no cached
  /// snapshot), or null when no source was injected.
  final TradesDoc Function()? _authoredDoc;

  // ── unified catalog (LipskeyCatalogProduct) ───────────────────────────────

  /// [tradeId] — per-trade seam; default `'plumbing'` keeps today byte-identical.
  @override
  List<LipskeyCatalogProduct> allProducts({String tradeId = 'plumbing'}) {
    if (tradeId != 'plumbing') {
      // s50: authored trades read the trades store through the injected doc
      // source — each TradeProduct rendered via the s35 legacy adapter, sorted
      // by sku (stable, id-keyed order). No source → the s42 empty read.
      final doc = _authoredDoc?.call();
      if (doc == null) return const <LipskeyCatalogProduct>[];
      return [
        for (final p in doc.products)
          if (p.tradeId == tradeId) p.toLegacy(),
      ]..sort((a, b) => a.sku.compareTo(b.sku));
    }
    // s-huliot: the catalog-source seam. Default (CATALOG_SOURCE unset / 'v1')
    // returns `kCatalogProducts` byte-identically; `--dart-define=CATALOG_SOURCE=v2`
    // serves the additive Huliot catalog. v1 stays intact for rollback.
    return resolvedCatalogProducts;
  }

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

  /// [tradeId] — per-trade seam; default `'plumbing'` keeps today byte-identical.
  @override
  List<String> smartTreeCats({String tradeId = 'plumbing'}) {
    // Authored trades stay empty in v1 — the SmartProduct cat strings are
    // plumbing-specific; the authored category axis is [categoryTree].
    if (tradeId != 'plumbing') return const <String>[];
    return kSmartTreeCats;
  }

  /// [tradeId] — per-trade seam; default `'plumbing'` keeps today byte-identical.
  @override
  List<Section> catalogCategories({String tradeId = 'plumbing'}) {
    // Authored trades stay empty in v1 — the [Section] shape is plumbing-
    // specific (the ▦ search axis); the authored category axis is [categoryTree].
    if (tradeId != 'plumbing') return const <Section>[];
    return kCatalogCats;
  }

  /// [tradeId] — per-trade seam; default `'plumbing'` keeps today byte-identical.
  /// (Explicit override: this class `implements` the interface, so the default
  /// body on [CatalogRepository.categoryTree] isn't inherited — mirrored here.)
  @override
  List<CatalogNode> categoryTree({String tradeId = 'plumbing'}) {
    if (tradeId != 'plumbing') {
      // s50: one flat leaf [CatalogNode] per authored category of the trade,
      // sorted by sortIndex (children default to const [] — a leaf; the
      // deeper parentId drill arrives with the cutover step). No source →
      // the s42 empty read.
      final doc = _authoredDoc?.call();
      if (doc == null) return const <CatalogNode>[];
      final cats = [
        for (final c in doc.categories)
          if (c.tradeId == tradeId) c,
      ]..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
      return [
        for (final c in cats)
          CatalogNode(id: c.id, title: c.titleHe, emoji: c.emoji),
      ];
    }
    return kCatalogTree;
  }
}

/// The BARE (no authored-doc source) [LocalCatalogRepository] behind the global
/// accessor [catalogRepo]. For the PLUMBING reads it is behavior-identical to
/// the provider's instance (both forward to the same consts), so the catalog
/// keeps ONE source for everything live today; only the s50 authored-trade
/// reads differ (empty here — the global has no [Ref] to reach the store).
const _kCatalogRepo = LocalCatalogRepository();

/// Global const accessor to the catalog repository — for top-level functions
/// and StatelessWidgets that have no [Ref] to read the provider. Serves the
/// plumbing reads identically to the provider's instance (same consts), so a
/// future remote impl that swaps the provider must swap this too (one source).
/// No authored-doc source ⇒ non-plumbing reads stay empty here (s42 behavior);
/// every live call-site passes no tradeId, so nothing observable changes.
CatalogRepository catalogRepo() => _kCatalogRepo;

/// The catalog repository provider — the server-ready seam the catalog screens
/// read through (T6.3) and a future remote product/price API swaps in behind.
/// s50: constructs the repository WITH the authored-doc source wired to the
/// trades store — `ref.read` (not watch) on purpose: the provider stays
/// non-rebuilding and each repository call reads the CURRENT doc lazily; live
/// reactivity for authored trades arrives with the cutover step (nothing live
/// switches the active trade yet). Plumbing reads never touch the source.
final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => LocalCatalogRepository(
    authoredDoc: () => ref.read(tradesStoreProvider),
  ),
);
