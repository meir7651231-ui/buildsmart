import 'package:flutter/services.dart';
import 'package:buildsmart/data/product_images.dart';
import 'package:buildsmart/logic/money_format.dart' show groupThousands;

import 'package:buildsmart/data/catalog.dart';
import 'package:buildsmart/data/catalog_tree.dart';
import 'package:buildsmart/data/fuzzy_search.dart';
import 'package:buildsmart/data/repositories/catalog_local.dart'
    show catalogRepositoryProvider;
import 'package:buildsmart/data/repositories/claude_functions.dart'
    show claudeGatewayProvider;
import 'package:buildsmart/data/line_score.dart';
import 'package:buildsmart/data/score_band.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/data/search_index.dart';
import 'package:buildsmart/data/sections.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/data/task_skus_local.dart' show productBySku;
import 'package:buildsmart/data/variant_families.dart';
// OWNER-REVIEW · kWordFinder seam — flag-gated in-app entry to WordFinderHome.
// Additive only: when kWordFinderFlag is OFF the section pill never renders and
// the _CatalogBody routing branch is unreachable, so catalog behaviour is
// byte-identical for normal users.
import 'package:buildsmart/features/card_keyboard/card_keyboard_screen.dart';
import 'package:buildsmart/features/ring_dive/ring_dive_flag.dart';
import 'package:buildsmart/features/ring_dive/ring_dive_screen.dart';
import 'package:buildsmart/features/word_finder/word_finder_home.dart';
// GLOBAL SEARCH seam — the dive window ([_DiveResultsView]) becomes the ONE
// unified search surface: with kGlobalSearch ON it also lists the live entity
// domains (orders/tasks/customers/chats/notifications) via the global index.
// Flag OFF (const) ⇒ the whole branch tree-shakes ⇒ the window is byte-identical.
import 'package:buildsmart/features/global_search/global_search.dart'
    show SearchResult, SearchResultKind, kGlobalSearch;
import 'package:buildsmart/features/global_search/global_search_sources.dart'
    show buildGlobalSearchIndex;
import 'package:buildsmart/features/global_search/prediction_ranking.dart'
    show
        nameAffinity,
        productProminence,
        matesBoost,
        contextCompatibleSkus,
        jobBoost;
import 'package:buildsmart/logic/install_engine.dart' show buildInstallation;
import 'package:buildsmart/logic/pressure_drop.dart' show estimatePressureDrop;
import 'package:buildsmart/logic/system_division.dart';
import 'package:buildsmart/screens/adapter_explain_screen.dart'
    show AdapterExplainScreen;
import 'package:buildsmart/screens/quote_polish_screen.dart'
    show QuotePolishScreen;
import 'package:buildsmart/screens/smart_home_screen.dart';
import 'package:buildsmart/screens/lipskey_product_sheet.dart';
import 'package:buildsmart/screens/lipskey_products_screen.dart' hide AttrKind;
import 'package:buildsmart/screens/finder_screen.dart';
import 'package:buildsmart/screens/install_studio_screen.dart';
import 'package:buildsmart/screens/legal_screen.dart';
import 'package:buildsmart/state/card_detail_mode.dart';
import 'package:buildsmart/state/card_projects.dart';
import 'package:buildsmart/state/brand_history.dart';
import 'package:buildsmart/state/card_acc_state.dart';
import 'package:buildsmart/state/card_filter_state.dart';
import 'package:buildsmart/state/card_selection.dart';
import 'package:buildsmart/state/card_versions.dart';
import 'package:buildsmart/state/profession_mode.dart';
import 'package:buildsmart/state/project_mode.dart';
import 'package:buildsmart/state/default_brand_resolver.dart';
import 'package:buildsmart/state/display_temp.dart';
import 'package:buildsmart/state/cart_safety.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/state/feature_flags.dart';
import 'package:buildsmart/state/hidden_catalog_sections.dart';
import 'package:buildsmart/state/intel/intel_bus.dart';
import 'package:buildsmart/state/intel/intel_events.dart';
import 'package:buildsmart/state/keyboard_job_context.dart';
import 'package:buildsmart/state/product_favorites.dart';
import 'package:buildsmart/state/recent_searches.dart';
import 'package:buildsmart/state/recently_viewed.dart';
import 'package:buildsmart/state/saved_configs.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/state/stage_progress.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart' show CfgText;
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Active section label — 'בית' is always first and fixed (the smart home).
/// Default landing is 'בית' — the new smart-home tiles (#32). The legacy 'הכל'
/// overview was deleted; the finder is reachable via the 'מאתר' chip.
final catalogSectionProvider = StateProvider<String>((_) => 'בית');

/// Ordered list of user section labels ('בית' is the fixed first pill, NOT here).
final catalogSectionsListProvider = StateProvider<List<String>>(
  (_) => ['מאתר', 'תכנון חיבור', 'חיפושים אחרונים', 'מועדפים', 'קטגוריות', 'עץ חכם', 'וריאנטים'],
);

/// Per-list catalog items: map of section-label → set of catalog category
/// titles included in that list. Lists not present default to empty.
final catalogListItemsProvider =
    StateProvider<Map<String, Set<String>>>((_) => {});

// hiddenCatalogSectionsProvider (persisted) lives in
// state/hidden_catalog_sections.dart — sections the user hid stay in the list
// but are filtered out of the chip row, restorable from "ניהול רשימות".

/// Current search query text.
final searchQueryProvider = StateProvider<String>((_) => '');

/// Everyday → catalogue-term aliases so a layperson finds a product without
/// knowing the plumber's word for it. Values are tokens also tried against the
/// product haystack — all real catalogue vocabulary (search aliasing, not new
/// data: R8 untouched).
const Map<String, List<String>> kSearchSynonyms = {
  // precise toilet-fixture tokens — NOT bare "אסלה", which also lives in
  // connector categories (מסעפים וחיבורי אסלה / זקיף אסלה) and over-matched.
  'שירותים': ['מושב', 'אסלות וכיורים', 'אביזרי אסלה'],
  'אסלה': ['אסלה', 'מושב'],
  'ניקוז': ['ניקוז', 'מחסום', 'סיפון', 'מאסף', 'תעלת'],
  'מקלחת': ['מקלחת', 'דוש', 'מזלף'],
  'אמבטיה': ['אמבט', 'רחצה'],
  'גינה': ['גן', 'גינון', 'השקיה'],
  'צנרת': ['צינור'],
  'חיבור': ['מחבר', 'מצמד'],
};

/// Normalises a search string: lowercases and folds Hebrew gershayim/geresh
/// (״ ׳) to the ASCII marks (" ') that product names actually use, so a
/// Hebrew-keyboard query like `1/2״` still matches a `1/2"` product.
String _normForSearch(String s) =>
    s.toLowerCase().replaceAll('״', '"').replaceAll('׳', "'");

/// Whitespace splitter — hoisted to a top-level `final` so it is compiled ONCE,
/// not re-compiled per product per keystroke (it ran inside the O(catalog) match
/// + relevance loops). Pure perf; identical behaviour.
final RegExp _wsSplit = RegExp(r'\s+');

/// The seven one-letter Hebrew clitic prefixes (the מש״ה־וכל״ב set) that attach
/// to the front of a word — הברז, באמבטיה, לדוד. A query token may sit one of
/// these past a word start, so "דוד" still finds "הדוד".
const String _kHebrewPrefixes = 'משהוכלב';

/// Word-boundary-aware token match — the replacement for a raw `hay.contains`.
/// [token] hits [hay] when it is the prefix of some whitespace-delimited word in
/// [hay], or of that word past a single Hebrew clitic prefix. This keeps the
/// prefix/plural hits a forgiving search needs ("ברז"→"ברזים", "דוד"→"הדוד")
/// while dropping the mid-word substring false-positives a plain `contains`
/// produced — so "דוד" no longer drags in "בידוד". Numeric/size tokens (1/2")
/// keep working: they are whole space-delimited words, matched by the prefix arm.
bool _tokenHitHe(String hay, String token) {
  if (token.isEmpty) return false;
  for (final w in hay.split(_wsSplit)) {
    if (w.startsWith(token)) return true;
    if (w.length > token.length &&
        _kHebrewPrefixes.contains(w[0]) &&
        w.substring(1).startsWith(token)) {
      return true;
    }
  }
  return false;
}

/// Forgiving product match for the search bar: a non-technical user types plain
/// words ("ברז מטבח", "ניקוז", "שירותים") and the app does the finding — without
/// them knowing the catalogue's term. Matches across name + category + SKU +
/// colour, word-by-word (order-independent, each word may land in any field),
/// expanding everyday words via [kSearchSynonyms]. With [requireAll] = false the
/// caller can fall back to matching ANY word, so a query never dead-ends.
bool catalogProductMatchesQuery(LipskeyCatalogProduct p, String rawQuery,
    {bool requireAll = true}) {
  final q = _normForSearch(rawQuery.trim());
  if (q.isEmpty) return false;
  // SKU is matched separately and ONLY for queries long enough to be a real
  // SKU fragment (≥5 chars — catalogue SKUs are 5–10 digits). Short numeric
  // size queries like "20" / "200" / "3000" must never substring-match an
  // unrelated SKU (e.g. "200" inside SKU 120011) — that buried real size hits
  // under SKU-coincidence noise. Word queries don't touch the SKU at all.
  if (q.length >= 5 && _normForSearch(p.sku).contains(q)) return true;
  final hay = _normForSearch('${p.nameHe} ${p.categoryHe} ${p.color ?? ''}');
  final tokens = q.split(_wsSplit).where((t) => t.isNotEmpty).toList();
  if (tokens.isEmpty) return false;
  bool hit(String t) {
    if (_tokenHitHe(hay, t)) return true;
    final alts = kSearchSynonyms[t];
    return alts != null &&
        alts.any((a) => _tokenHitHe(hay, _normForSearch(a)));
  }

  return requireAll ? tokens.every(hit) : tokens.any(hit);
}

/// Relevance score for ranking search results (higher = better): a name match
/// beats a category-only match beats a synonym/colour match, so the product the
/// user actually meant surfaces first (e.g. a toilet seat above a toilet-branch
/// connector for "שירותים"). Used as the default sort when a query is present.
int searchRelevance(LipskeyCatalogProduct p, String rawQuery) {
  final q = _normForSearch(rawQuery.trim());
  if (q.isEmpty) return 0;
  final name = _normForSearch(p.nameHe);
  final cat = _normForSearch(p.categoryHe);
  final color = _normForSearch(p.color ?? '');
  var score = 0;
  if (name.contains(q)) score += 100; // whole query in the name
  for (final t in q.split(_wsSplit).where((t) => t.isNotEmpty)) {
    if (name.contains(t)) {
      score += 20;
    } else if (cat.contains(t)) {
      score += 8;
    } else if (color.contains(t)) {
      score += 6;
    } else {
      final alts = kSearchSynonyms[t];
      if (alts != null) {
        if (alts.any((a) => name.contains(_normForSearch(a)))) {
          score += 12;
        } else if (alts.any((a) => cat.contains(_normForSearch(a)))) {
          score += 4;
        }
      }
    }
  }
  return score;
}

/// As-you-type word completion (Benzi #6): completes the word currently being
/// typed from the vocabulary of words that appear in catalog **product names**
/// (system-scoped), most-frequent first, capped at [limit]. Returns the whole
/// query with its last word completed (the already-typed words are kept), so
/// tapping a chip fills the search box with a real product term. Pure → tested.
List<String> searchSuggestions(String query,
    {WaterSystem? system, int limit = 6}) {
  // The word being typed = the last whitespace-delimited token; keep the rest.
  final lastSpace = query.lastIndexOf(RegExp(r'\s'));
  final committed = lastSpace < 0 ? '' : query.substring(0, lastSpace + 1);
  final frag = query.substring(lastSpace + 1);
  final fragN = _normForSearch(frag);
  if (fragN.length < 2) return const [];
  // Frequency of product-name words the fragment is a prefix of.
  final freq = <String, int>{}; // original word → count
  for (final p in filterBySystem(kLipskeyCatalog, system)) {
    for (final w in p.nameHe.split(RegExp(r'\s+'))) {
      final wN = _normForSearch(w);
      if (wN.length < 2 || wN == fragN || !wN.startsWith(fragN)) continue;
      freq[w] = (freq[w] ?? 0) + 1;
    }
  }
  // Most-frequent first, then א-ת; de-dupe by normalized form.
  final words = freq.keys.toList()
    ..sort((a, b) {
      final c = freq[b]!.compareTo(freq[a]!);
      return c != 0 ? c : a.compareTo(b);
    });
  final seen = <String>{};
  final out = <String>[];
  for (final w in words) {
    if (!seen.add(_normForSearch(w))) continue;
    out.add('$committed$w');
    if (out.length >= limit) break;
  }
  return out;
}

// catalogSystemFilterProvider lives in logic/system_division.dart (shared with
// the finder so neither screen back-imports the other).

// recentSearchesProvider lives in state/recent_searches.dart (persisted).

/// Currently selected category in the smart tree section. Null = show categories.
final smartTreeCatProvider = StateProvider<String?>((_) => null);

/// Search query within the active smart-tree category's product list.
final smartTreeQueryProvider = StateProvider<String>((_) => '');

/// Re-opens the product detail sheet for a cart line so it can be edited
/// (brand / quantity / accessories — everything but the name). Resolves the
/// line back to its source product: 'lip:<sku>' → Lipskey catalog product,
/// otherwise a smart-tree [SmartProduct] by key.
void openCartLineProductSheet(BuildContext context, SmartCartLine line) {
  final key = line.productKey;
  if (key.startsWith('lip:')) {
    final sku = key.substring(4);
    // Unified catalog: a cart line keyed 'lip:<sku>' may be a Huliot/PPR product
    // (they share the lip: prefix), so resolve + sibling-list over kCatalogProducts.
    final i = kCatalogProducts.indexWhere((p) => p.sku == sku);
    if (i >= 0) {
      final product = kCatalogProducts[i];
      final siblings = kCatalogProducts
          .where((p) => p.categoryHe == product.categoryHe)
          .toList();
      showLipskeyProductSheet(context, product, siblings);
      return;
    }
  }
  final s = kSmartProducts.indexWhere((p) => p.key == key);
  if (s >= 0) {
    _SmartTreeProductList._openProductSheet(context, kSmartProducts[s]);
  }
}

/// Compact display for a cart line in the recent-add bubble: a short product
/// name (the type noun + qualifier, e.g. "ברז כפול") with its distinguishing
/// attributes below (brand model · colour · supplier). Falls back to the full
/// product name when it can't be decomposed.
({String name, String attrs}) cartLineDisplay(SmartCartLine line) {
  if (line.productKey.startsWith('lip:')) {
    final sku = line.productKey.substring(4);
    // Unified: cart-line display must resolve Huliot/PPR 'lip:'-keyed lines too.
    final i = kCatalogProducts.indexWhere((p) => p.sku == sku);
    if (i >= 0) {
      final p = kCatalogProducts[i];
      final type = p.productType;
      String name;
      if (type != null) {
        name = [type, if (p.productSubtype != null) p.productSubtype!].join(' ');
      } else {
        // No recognised type — fall back to the full name, minus the brand /
        // colour tokens (they live in the attrs line) to keep it shorter.
        name = p.nameHe;
        if (p.brandModel != null) name = name.replaceFirst(p.brandModel!, '');
        final cv = p.colorVariant;
        if (cv != null) name = name.replaceAll(cv, '');
        name = name.replaceAll(RegExp(r'\s+'), ' ').trim();
        if (name.isEmpty) name = p.nameHe;
      }
      final attrs = <String>{
        if (p.brandModel != null) p.brandModel!,
        if (p.colorVariant != null) p.colorVariant!,
        if (line.brandName.isNotEmpty) line.brandName,
      }.join(' · ');
      return (name: name, attrs: attrs);
    }
  }
  return (name: line.productName, attrs: line.brandName);
}


/// Currently selected category in the "קטגוריות" drill. Null = show all 11 cats.
final catalogDrillCatProvider = StateProvider<String?>((_) => null);

/// In-tab catalog-tree drill stack (kCatalogTree). Empty = not drilling.
/// Kept inside the catalog tab so the app bar and bottom nav stay fixed.
final catalogTreePathProvider =
    StateProvider<List<CatalogNode>>((_) => const []);

/// Search query within the current drill level (scoped to its subtree).
final catalogTreeQueryProvider = StateProvider<String>((_) => '');

/// Selected facet labels (in order) while drilling inside a faceted leaf.
final catalogFacetProvider = StateProvider<List<String>>((_) => const []);

// [ProductSort], [catalogProductSortLabel] and [catalogProductSortProvider]
// now live in state/catalog_settings.dart (the live sort is seeded from the
// persisted מיון ברירת מחדל user default).

/// The keyboard's live DIVE query — set by the floating card-keyboard on every
/// keystroke (catalog tab). Drives [diveResultsProvider]; the catalog body then
/// shows those products NATIVELY — the app DIVES, with NO search panel/chrome.
final keyboardDiveQueryProvider = StateProvider<String>((_) => '');

/// The products the live DIVE shows: the matcher proven most reliable in the
/// engine probe ([catalogProductMatchesQuery] — the SAME one the search uses),
/// driven by the keyboard's query. AND-tokens → OR → fuzzy; system-filtered +
/// sorted; capped at 40. Empty until the query reaches 2 chars.
final diveResultsProvider = Provider<List<LipskeyCatalogProduct>>((ref) {
  final query = ref.watch(keyboardDiveQueryProvider).trim();
  if (query.length < 2) return const [];
  final sort = ref.watch(catalogProductSortProvider);
  final systemFilter = ref.watch(catalogSystemFilterProvider);
  var matched = kCatalogProducts
      .where((p) => catalogProductMatchesQuery(p, query))
      .toList();
  if (matched.isEmpty) {
    matched = kCatalogProducts
        .where((p) => catalogProductMatchesQuery(p, query, requireAll: false))
        .toList();
  }
  if (matched.isEmpty) matched = fuzzySearchProducts(query, limit: 40);
  final filtered = filterBySystem(matched, systemFilter);
  final ordered = sort == ProductSort.byOrder
      ? (kGlobalSearch
          // PREDICTION ([kGlobalSearch], const ⇒ folds out when off): keep
          // [searchRelevance] PRIMARY, but break its ties by prediction signal —
          // [nameAffinity] (a product whose name IS/starts-with the query beats a
          // variant that merely embeds it — the baseline's biggest leak),
          // [productProminence] (showcased / verified / curated), and — the signal
          // ORTHOGONAL to the letters — [matesBoost]: a candidate that physically
          // CONNECTS to what's already staged on the line (the smart cart + the
          // freshest recently-viewed). Context-seeded harness lift: 39%→66% of the
          // FITTING product reaching top-4. Off ⇒ the plain relevance sort below is
          // byte-identical (this whole branch, [matesBoost] + the context read
          // included, tree-shakes out).
          ? (() {
              final ctx = <LipskeyCatalogProduct>[];
              for (final line in ref.watch(smartCartProvider)) {
                final k = line.productKey;
                final p =
                    productBySku(k.startsWith('lip:') ? k.substring(4) : k);
                if (p != null) ctx.add(p);
              }
              for (final sku in ref.watch(recentlyViewedProvider).take(5)) {
                final p = productBySku(sku);
                if (p != null) ctx.add(p);
              }
              // JOB (keystroke-zero): the OPEN job's own kit steers even the first
              // pick on an empty cart — its SKUs win a [jobBoost], and they also
              // enter the mate-context so what CONNECTS to them is boosted too.
              final jobSkus = <String>{};
              for (final sku in ref.watch(keyboardJobSkusProvider)) {
                final p = productBySku(sku);
                if (p != null) {
                  ctx.add(p);
                  jobSkus.add(p.sku);
                }
              }
              final mates = contextCompatibleSkus(ctx);
              return [...filtered]..sort((a, b) {
                final byRel = searchRelevance(b, query)
                    .compareTo(searchRelevance(a, query));
                if (byRel != 0) return byRel;
                return (nameAffinity(b, query) +
                        productProminence(b) +
                        matesBoost(b, mates) +
                        jobBoost(b, jobSkus))
                    .compareTo(nameAffinity(a, query) +
                        productProminence(a) +
                        matesBoost(a, mates) +
                        jobBoost(a, jobSkus));
              });
            })()
          : ([...filtered]..sort((a, b) =>
              searchRelevance(b, query).compareTo(searchRelevance(a, query)))))
      : sortCatalogProducts(filtered, sort);
  return ordered.take(40).toList();
});

/// Pure: keep only products that have an image when [imageOnly] is set.
List<LipskeyCatalogProduct> filterByImage(
    List<LipskeyCatalogProduct> list, bool imageOnly) {
  if (!imageOnly) return list;
  return list.where((p) => p.imageAsset != null).toList();
}

// productDivisionSystems · filterBySystem · nodeHasSystem moved to
// logic/system_division.dart (shared with the finder; see the import above).

/// Synthetic root whose children are the top catalog categories — a live
/// department opens this so its system-filtered category tree shows.
const CatalogNode kDepartmentTreeRoot = CatalogNode(
    id: 'dept-root', title: 'מחלקות', emoji: '🏬', children: kCatalogTree);

/// Apply a [ProductSort] to a product list (pure — returns a new list, leaves
/// the source order for [ProductSort.byOrder]). This is the single ordering the
/// catalog list + the persisted מיון ברירת מחדל default both flow through.
List<LipskeyCatalogProduct> sortCatalogProducts(
    List<LipskeyCatalogProduct> list, ProductSort s) {
  if (s == ProductSort.byOrder) return list;
  final out = [...list];
  switch (s) {
    case ProductSort.nameAZ:
      out.sort((a, b) => a.nameHe.compareTo(b.nameHe));
    case ProductSort.nameZA:
      out.sort((a, b) => b.nameHe.compareTo(a.nameHe));
    case ProductSort.sku:
      out.sort((a, b) => a.sku.compareTo(b.sku));
    case ProductSort.byOrder:
      break;
  }
  return out;
}

/// One facet option: a [label] chip and the [keyword] that must appear in the
/// product name. A null [keyword] means "none of the other keywords in the
/// group" (e.g. כללי = not-למקלחת).
typedef ProductFacet = ({String label, String? keyword});

/// Ordered facet groups per lipskey leaf category. Drilling a faceted leaf
/// splits its products by these groups before showing the product list.
const Map<String, List<List<ProductFacet>>> kProductFacets = {
  'מחסומי רצפה': [
    [(label: 'תיקני', keyword: 'תיקני'), (label: 'קומקום', keyword: 'קומקום')],
    [(label: 'למקלחת', keyword: 'למקלחת'), (label: 'כללי', keyword: null)],
    [(label: 'פתוח', keyword: 'פתוח'), (label: 'סגור', keyword: 'סגור')],
  ],
};

bool _matchesFacet(
    LipskeyCatalogProduct p, List<ProductFacet> group, ProductFacet chosen) {
  if (chosen.keyword != null) return p.nameHe.contains(chosen.keyword!);
  // null keyword = matches none of the other keywords in the group.
  return !group
      .where((f) => f.keyword != null)
      .any((f) => p.nameHe.contains(f.keyword!));
}

/// All lipskey products under [node]'s subtree (the set shrinks as you drill).
List<LipskeyCatalogProduct> _subtreeProducts(CatalogNode node) {
  final cats = <String>{};
  void walk(CatalogNode n) {
    if (n.lipskeyCategory != null) cats.add(n.lipskeyCategory!);
    for (final c in n.children) {
      walk(c);
    }
  }

  walk(node);
  if (cats.isEmpty) return const [];
  return kCatalogProducts.where((p) => cats.contains(p.categoryHe)).toList();
}

/// Apply the first [sel].length facet groups to [base].
List<LipskeyCatalogProduct> _applyFacets(
  List<LipskeyCatalogProduct> base,
  List<List<ProductFacet>> groups,
  List<String> sel,
) {
  var out = base;
  for (var i = 0; i < sel.length && i < groups.length; i++) {
    final group = groups[i];
    final chosen = group.firstWhere((f) => f.label == sel[i],
        orElse: () => group.first);
    out = out.where((p) => _matchesFacet(p, group, chosen)).toList();
  }
  return out;
}

/// Meaningful words of a product name — drops sizes/numbers, punctuation and
/// very short tokens, so facets split by real characterizing words.
List<String> _facetTokens(String name) {
  final cleaned = name.replaceAll(RegExp('[()"׳\'*.,/+\\-־–—]'), ' ');
  return cleaned
      .split(RegExp(r'\s+'))
      .map((w) => w.trim())
      .where((w) =>
          w.length >= 2 &&
          !w.contains('"') &&
          !w.contains('″') &&
          !RegExp(r'[0-9]').hasMatch(w))
      .toList();
}

/// Auto-derived facet options for a leaf without curated facets. Splits by the
/// most *primary* characterizing word — the first word in each product's name
/// that isn't shared by the whole set (and isn't already chosen) — rather than
/// by whichever word is most frequent.
List<({String label, int count})> _autoFacetOptions(
    List<LipskeyCatalogProduct> products, List<String> chosen) {
  if (products.length <= 1) return const [];
  final tokens = products.map((p) => _facetTokens(p.nameHe)).toList();
  final shared = tokens.first.toSet();
  for (final t in tokens.skip(1)) {
    shared.retainAll(t.toSet());
  }
  final counts = <String, int>{};
  for (final toks in tokens) {
    for (final w in toks) {
      if (shared.contains(w) || chosen.contains(w)) continue;
      counts[w] = (counts[w] ?? 0) + 1; // first distinguishing word wins
      break;
    }
  }
  if (counts.length < 2) return const [];
  final entries = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return [for (final e in entries) (label: e.key, count: e.value)];
}

/// Description for a facet row — a preview of the next characterizing words in
/// the group, falling back to sample product names.
String _facetDesc(List<LipskeyCatalogProduct> matching) {
  if (matching.isEmpty) return '';
  final next = _autoFacetOptions(matching, const []);
  if (next.isNotEmpty) {
    return next.map((e) => e.label).take(6).join(' · ');
  }
  return matching.map((p) => p.nameHe).take(2).join(' · ');
}

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _scrollCtrl = ScrollController();
  bool _headerVisible = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _setHeaderVisible(bool v) {
    if (_headerVisible == v) return;
    setState(() => _headerVisible = v);
    ref.read(tabHeaderHiddenProvider.notifier).state = !v;
  }

  bool _handleScrollNotification(ScrollNotification n) {
    if (n is ScrollUpdateNotification && n.depth == 0) {
      final delta = n.scrollDelta ?? 0;
      final pixels = n.metrics.pixels;
      if (delta > 6 && _headerVisible && pixels > 50) {
        _setHeaderVisible(false);
      } else if (delta < -6 && !_headerVisible) {
        _setHeaderVisible(true);
      } else if (pixels <= 2 && !_headerVisible) {
        _setHeaderVisible(true);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // In-tab catalog-tree drill — replaces the search bar with a drill bar and
    // the list with bordered rows, while the app bar and bottom nav stay fixed.
    final treePath = ref.watch(catalogTreePathProvider);
    if (treePath.isNotEmpty) {
      return _TreeDrill(path: treePath);
    }

    // Smart-tree product list — the green drill bar (with its own search)
    // takes over, hiding the search bar and section chips.
    if (ref.watch(catalogSectionProvider) == 'עץ חכם') {
      final smartCat = ref.watch(smartTreeCatProvider);
      if (smartCat != null) {
        return _SmartTreeProductList(cat: smartCat);
      }
    }

    // AppBar search icon tapped → restore header + scroll to top.
    ref.listen<bool>(tabHeaderHiddenProvider, (_, hidden) {
      if (!hidden && !_headerVisible) {
        _setHeaderVisible(true);
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(0,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut);
        }
      }
    });

    // Studio Pillar-3 · step 93 — catalog SEARCH intel (additive · read-only ·
    // demo byte-identical). A single CHANGE-listener on the live-dive query is
    // the faithful "search committed" seam — the app has NO discrete submit (the
    // floating keyboard writes this provider per commit). `ref.listen` fires ONLY
    // on a query change, never per rebuild, so each event lands once per query
    // (§4). It NEVER carries the raw text — only q_len + a stable, non-reversible
    // q_hash (§4/§7). search_no_result rides the SAME committed-query path (not a
    // build(), which would re-fire): it emits when the query yields no products
    // AND no index entries — the _DiveResultsView empty state.
    ref.listen<String>(keyboardDiveQueryProvider, (_, next) {
      final q = next.trim();
      if (q.length < 2) return;
      final bus = ref.read(intelBusProvider);
      final props = <String, String>{
        'q_len': '${q.length}',
        'q_hash': '${q.hashCode}',
      };
      bus.track(IntelEvents.searchSubmit, props: props);
      final noResults = ref.read(diveResultsProvider).isEmpty &&
          kVisibleSearchIndex.where((e) => e.matches(q)).isEmpty;
      if (noResults) bus.track(IntelEvents.searchNoResult, props: props);
    });

    // Live DIVE (owner): when the floating keyboard has a query, the catalog
    // body shows the NATIVE narrowed product list — the app dives in place.
    final diveActive = ref.watch(keyboardDiveQueryProvider).trim().length >= 2;

    return Column(
      children: [
        // OWNER: the app's search BAR + panel are deleted — the floating keyboard
        // IS the search now (its 🔍 חיפוש tool starts a fresh typed search, and the
        // live dive narrows the catalog underneath). No separate search chrome.
        if (diveActive)
          const Expanded(child: _DiveResultsView())
        else
          // OWNER: the section-pill row is deleted — its lists + all their options
          // now live in the keyboard (tab-0 chips + the 'רשימות' manager chip). The
          // catalog body fills the space directly.
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: _handleScrollNotification,
              child: _CatalogBody(scrollCtrl: _scrollCtrl),
            ),
          ),
      ],
    );
  }
}

/// OWNER: public entry so the KEYBOARD's 'רשימות' chip opens the full list manager
/// (create / edit-contents / rename / hide / delete / reorder) — the same sheet the
/// deleted section-pill row's ➕ opened. All list options now live behind a keyboard
/// chip, not a persistent screen row.
void openManageLists(BuildContext context, WidgetRef ref) =>
    _openManageSheet(context, ref);

void _openManageSheet(BuildContext context, WidgetRef ref) {
  final container = ProviderScope.containerOf(context);
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFFFFFFFF),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => UncontrolledProviderScope(
      container: container,
      child: const _ManageListsSheet(),
    ),
  );
}

class _ManageListsSheet extends ConsumerStatefulWidget {
  const _ManageListsSheet();

  @override
  ConsumerState<_ManageListsSheet> createState() => _ManageListsSheetState();
}

class _ManageListsSheetState extends ConsumerState<_ManageListsSheet> {
  void _toggleHidden(String s) {
    ref.read(hiddenCatalogSectionsProvider.notifier).toggle(s);
    if (ref.read(hiddenCatalogSectionsProvider).contains(s) &&
        ref.read(catalogSectionProvider) == s) {
      ref.read(catalogSectionProvider.notifier).state = 'בית';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sections = ref.watch(catalogSectionsListProvider);
    final hidden = ref.watch(hiddenCatalogSectionsProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, scrollCtrl) => Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCCCCCC),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: 'אישור',
                  icon: const Icon(Icons.check, color: Color(0xFF888888)),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'ניהול רשימות',
                  style: TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  tooltip: 'סגירה',
                  icon: const Icon(Icons.close, color: Color(0xFF888888)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFF5F5F5), height: 1),
          // Reorderable list
          Expanded(
            child: ReorderableListView.builder(
              scrollController: scrollCtrl,
              padding: EdgeInsets.zero,
              onReorder: (oldIdx, newIdx) {
                final list = List<String>.from(sections);
                if (newIdx > oldIdx) newIdx--;
                final item = list.removeAt(oldIdx);
                list.insert(newIdx, item);
                ref.read(catalogSectionsListProvider.notifier).state = list;
              },
              itemCount: sections.length,
              itemBuilder: (_, i) {
                final s = sections[i];
                final isHidden = hidden.contains(s);
                return ListTile(
                  key: ValueKey(s),
                  tileColor: const Color(0xFFFFFFFF),
                  // Leading: icon matching section (dimmed when hidden)
                  leading: Icon(
                    _sectionIcon(s),
                    color: isHidden ? const Color(0xFFCCCCCC) : Colors.black54,
                    size: 22,
                  ),
                  title: Text(
                    s,
                    style: TextStyle(
                      color: isHidden
                          ? const Color(0xFFAAAAAA)
                          : BsTokens.inkLight,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    isHidden ? 'מוסתר — מוסתר מהקטלוג' : 'הגדרה מראש',
                    style: TextStyle(
                        color: isHidden
                            ? const Color(0xFFBBBBBB)
                            : const Color(0xFF888888),
                        fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Hide / show (eye) — non-destructive visibility toggle.
                      IconButton(
                        tooltip: isHidden ? 'הצג' : 'הסתר',
                        icon: Icon(
                          isHidden
                              ? Icons.visibility_off
                              : Icons.visibility_outlined,
                          color: isHidden
                              ? const Color(0xFFEA8A00)
                              : const Color(0xFF888888),
                          size: 20,
                        ),
                        onPressed: () => _toggleHidden(s),
                      ),
                      // OWNER: rename now lives in the manager too (all options
                      // reachable via the keyboard's 'רשימות' chip) — it was
                      // previously ONLY on the deleted row's long-press menu.
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'שנה שם',
                        icon: const Icon(
                          Icons.drive_file_rename_outline,
                          color: Color(0xFF888888),
                          size: 20,
                        ),
                        onPressed: () => _showRenameDialog(context, ref, i, s),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'ערוך',
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFF888888),
                          size: 20,
                        ),
                        onPressed: () => _showItemPickerSheet(context, ref, s),
                      ),
                      IconButton(
                        tooltip: 'מחק',
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFF888888),
                          size: 20,
                        ),
                        onPressed: () async {
                          final ok = await confirmDestructive(
                            context,
                            title: 'מחיקת רשימה?',
                            message: 'הרשימה "$s" תימחק לצמיתות.',
                            confirmLabel: 'מחק',
                          );
                          if (!ok || !context.mounted) return;
                          final list =
                              List<String>.from(
                                ref.read(catalogSectionsListProvider),
                              )..removeAt(i);
                          ref.read(catalogSectionsListProvider.notifier).state =
                              list;
                          if (ref.read(catalogSectionProvider) == s) {
                            ref.read(catalogSectionProvider.notifier).state =
                                'בית';
                          }
                        },
                      ),
                      ReorderableDragStartListener(
                        index: i,
                        child: const Icon(
                          Icons.drag_handle,
                          color: Color(0xFF888888),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(color: Color(0xFFF5F5F5), height: 1),
          InkWell(
            onTap: () => _showAddDialog(context),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: BsTokens.brand, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'יצירת רשימה מותאמת אישית',
                    style: TextStyle(
                      color: BsTokens.brand,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext ctx) {
    final controller = TextEditingController();
    showDialog<void>(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'רשימה חדשה',
          style: TextStyle(color: BsTokens.inkLight, fontSize: 16),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: BsTokens.inkLight),
          decoration: const InputDecoration(
            hintText: 'שם הרשימה',
            hintStyle: TextStyle(color: Color(0xFF888888)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFCCCCCC)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: BsTokens.brand),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text(
              'ביטול',
              style: TextStyle(color: Color(0xFF888888)),
            ),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final list =
                    List<String>.from(ref.read(catalogSectionsListProvider))
                      ..add(name);
                ref.read(catalogSectionsListProvider.notifier).state = list;
              }
              Navigator.pop(dCtx);
            },
            child: const Text(
              'הוספה',
              style: TextStyle(color: BsTokens.brand),
            ),
          ),
        ],
      ),
    ).whenComplete(() => controller.dispose());
  }

}

void _showRenameDialog(
  BuildContext ctx,
  WidgetRef ref,
  int index,
  String current,
) {
  final controller = TextEditingController(text: current);
  showDialog<void>(
    context: ctx,
    builder: (dCtx) => AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        'שינוי שם הרשימה',
        style: TextStyle(color: BsTokens.inkLight, fontSize: 16),
      ),
      content: TextField(
        controller: controller,
        autofocus: true,
        style: const TextStyle(color: BsTokens.inkLight),
        decoration: const InputDecoration(
          hintText: 'שם הרשימה',
          hintStyle: TextStyle(color: Color(0xFF888888)),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFCCCCCC)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: BsTokens.brand),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dCtx),
          child: const Text(
            'ביטול',
            style: TextStyle(color: Color(0xFF888888)),
          ),
        ),
        TextButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isNotEmpty && name != current) {
              // Update sections list
              final list =
                  List<String>.from(ref.read(catalogSectionsListProvider))
                    ..[index] = name;
              ref.read(catalogSectionsListProvider.notifier).state = list;
              // Transfer items map entry to new name
              final items = Map<String, Set<String>>.from(
                ref.read(catalogListItemsProvider),
              );
              if (items.containsKey(current)) {
                items[name] = items.remove(current)!;
                ref.read(catalogListItemsProvider.notifier).state = items;
              }
              // Update active selection if needed
              if (ref.read(catalogSectionProvider) == current) {
                ref.read(catalogSectionProvider.notifier).state = name;
              }
            }
            Navigator.pop(dCtx);
          },
          child: const Text(
            'שמירה',
            style: TextStyle(color: BsTokens.brand),
          ),
        ),
      ],
    ),
  ).whenComplete(() => controller.dispose());
}

void _showItemPickerSheet(
  BuildContext context,
  WidgetRef ref,
  String listLabel,
) {
  final container = ProviderScope.containerOf(context);
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFFFFFFFF),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => UncontrolledProviderScope(
      container: container,
      child: _ItemPickerSheet(listLabel: listLabel),
    ),
  );
}

class _ItemPickerSheet extends ConsumerStatefulWidget {
  const _ItemPickerSheet({required this.listLabel});

  final String listLabel;

  @override
  ConsumerState<_ItemPickerSheet> createState() => _ItemPickerSheetState();
}

class _ItemPickerSheetState extends ConsumerState<_ItemPickerSheet> {
  late String _label;
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _label = widget.listLabel;
    _selected = Set<String>.from(
      ref.read(catalogListItemsProvider)[_label] ?? <String>{},
    );
  }

  void _save() {
    final items = Map<String, Set<String>>.from(
      ref.read(catalogListItemsProvider),
    );
    items[_label] = _selected;
    ref.read(catalogListItemsProvider.notifier).state = items;
    Navigator.pop(context);
  }

  Future<void> _rename() async {
    final controller = TextEditingController(text: _label);
    final newName = await showDialog<String>(
      context: context,
      builder: (dCtx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'שינוי שם הרשימה',
          style: TextStyle(color: BsTokens.inkLight, fontSize: 16),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: BsTokens.inkLight),
          decoration: const InputDecoration(
            hintText: 'שם הרשימה',
            hintStyle: TextStyle(color: Color(0xFF888888)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFCCCCCC)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: BsTokens.brand),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text(
              'ביטול',
              style: TextStyle(color: Color(0xFF888888)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dCtx, controller.text.trim()),
            child: const Text(
              'שמירה',
              style: TextStyle(color: BsTokens.brand),
            ),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newName == null || newName.isEmpty || newName == _label) return;

    final list = List<String>.from(ref.read(catalogSectionsListProvider));
    final idx = list.indexOf(_label);
    if (idx != -1) {
      list[idx] = newName;
      ref.read(catalogSectionsListProvider.notifier).state = list;
    }
    final items =
        Map<String, Set<String>>.from(ref.read(catalogListItemsProvider));
    if (items.containsKey(_label)) {
      items[newName] = items.remove(_label)!;
      ref.read(catalogListItemsProvider.notifier).state = items;
    }
    if (ref.read(catalogSectionProvider) == _label) {
      ref.read(catalogSectionProvider.notifier).state = newName;
    }
    setState(() => _label = newName);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCCCCCC),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _save,
                  child: const Text(
                    'שמירה',
                    style: TextStyle(
                      color: BsTokens.brand,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                InkWell(
                  onTap: _rename,
                  borderRadius: BorderRadius.circular(6),
                  // ≥48dp tap target (a11y) — the header row is already
                  // 48dp tall (IconButton), so no visual change.
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _label,
                              style: const TextStyle(
                                color: BsTokens.inkLight,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.drive_file_rename_outline,
                              color: Color(0xFF888888),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF888888)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'בחר אילו פריטים יופיעו ברשימה',
                style: TextStyle(color: Color(0xFF888888), fontSize: 13),
              ),
            ),
          ),
          const Divider(color: Color(0xFFF5F5F5), height: 1),
          Expanded(
            child: Builder(builder: (_) {
              // T6.3: the ▦ קטלוג categories via the catalog repository
              // (returns the same const `kCatalogCats`). `ref.watch` — this is
              // inside the sheet's build tree.
              // B4: only offer categories that lead to content, so a curated
              // list can never route into the `_TreeComingSoon` "בקרוב"
              // placeholder (owner policy: no content-less surface in release).
              final cats = ref
                  .watch(catalogRepositoryProvider)
                  .catalogCategories()
                  .where((c) => _categoryHasContent(c.title))
                  .toList();
              return ListView.builder(
                controller: scrollCtrl,
                itemCount: cats.length,
                itemBuilder: (_, i) {
                  final cat = cats[i];
                final checked = _selected.contains(cat.title);
                return CheckboxListTile(
                  value: checked,
                  onChanged: (v) => setState(() {
                    if (v ?? false) {
                      _selected.add(cat.title);
                    } else {
                      _selected.remove(cat.title);
                    }
                  }),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: BsTokens.brand,
                  checkColor: Colors.white,
                  tileColor: const Color(0xFFFFFFFF),
                  title: Row(
                    children: [
                      Text(
                        cat.emoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cat.title,
                          style: const TextStyle(
                            color: BsTokens.inkLight,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                },
              );
            }),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

IconData _sectionIcon(String label) => switch (label) {
      'בית'             => Icons.home_outlined,
      'חיפושים אחרונים' => Icons.history,
      'מועדפים'         => Icons.favorite_border,
      'קטגוריות'        => Icons.grid_view_outlined,
      'עץ חכם'          => Icons.account_tree_outlined,
      'תכנון חיבור'     => Icons.handyman,
      _                 => Icons.list_alt_outlined,
    };

/// The live DIVE view (owner): the catalog body when the floating keyboard has
/// a query — the engine-narrowed products in the NATIVE product list. The app
/// dives in place; no search panel, no search chrome.
class _DiveResultsView extends ConsumerWidget {
  const _DiveResultsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // GLOBAL SEARCH ([kGlobalSearch], const ⇒ folds out when off): the catalog's
    // OWN inline dive stands down under the flag — [HomeShell] overlays the ONE
    // unified panel ([GlobalSearchResultsView]) over EVERY tab instead (owner:
    // option A — the list replaces the screen content in place, everywhere), so
    // the results render exactly once. Off ⇒ the legacy body below is byte-identical.
    if (kGlobalSearch) return const SizedBox.shrink();

    final products = ref.watch(diveResultsProvider);
    // OWNER (A slice 3 — unify "so it searches those too"): the ONE keyboard search
    // finds CATEGORIES + SCREENS as well, not just products — exactly what the old
    // search bar did via [kVisibleSearchIndex]. The non-product index matches lead
    // (capped, compact), then the engine-narrowed products fill the rest.
    final query = ref.watch(keyboardDiveQueryProvider).trim();
    final entries = query.isEmpty
        ? const <SearchEntry>[]
        : kVisibleSearchIndex.where((e) => e.matches(query)).take(4).toList();

    if (products.isEmpty && entries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(BsTokens.space4),
          child: Text(
            'אין תוצאות תואמות',
            style: TextStyle(color: BsTokens.mutedLight),
          ),
        ),
      );
    }
    return Column(
      children: <Widget>[
        for (final e in entries) _DiveEntryTile(entry: e),
        if (entries.isNotEmpty)
          const Divider(height: 1, color: Color(0xFFF5F5F5)),
        Expanded(
          child: products.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(BsTokens.space4),
                    child: Text(
                      'אין מוצרים תואמים',
                      style: TextStyle(color: BsTokens.mutedLight),
                    ),
                  ),
                )
              : LipskeyProductsList(products: products),
        ),
      ],
    );
  }

}

/// GLOBAL SEARCH ([kGlobalSearch]) — the ONE unified results panel. Owner: option
/// A — when you type, this list REPLACES the screen content IN PLACE, on EVERY
/// tab (not just the catalog). `HomeShell` overlays it over whatever tab is active
/// whenever the keyboard has a query; the catalog's own inline dive stands down
/// under the flag so the results render exactly once. Beyond the [kVisibleSearchIndex]
/// entries (screens / categories / settings) + the rich [LipskeyProductsList], it
/// lists the live ENTITY domains the search could never show before — orders ·
/// tasks · customers · chats · notifications — via [buildGlobalSearchIndex], each
/// tile running its OWN open/navigate closure. Products stay the rich list (not
/// flattened to tiles), so this ONLY ADDS the five entity domains. Public because
/// `HomeShell` mounts it.
class GlobalSearchResultsView extends ConsumerWidget {
  const GlobalSearchResultsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(diveResultsProvider);
    final query = ref.watch(keyboardDiveQueryProvider).trim();
    final entries = query.isEmpty
        ? const <SearchEntry>[]
        : kVisibleSearchIndex.where((e) => e.matches(query)).take(4).toList();
    // The five ENTITY domains the search can't already show (products → the rich
    // list below; screens / categories / settings → the index entries above).
    final extras = query.length >= 2
        ? buildGlobalSearchIndex(ref)
            .search(query)
            .where((r) =>
                r.kind != SearchResultKind.product &&
                r.kind != SearchResultKind.screen &&
                r.kind != SearchResultKind.setting)
            .take(6)
            .toList()
        : const <SearchResult>[];

    if (products.isEmpty && entries.isEmpty && extras.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(BsTokens.space4),
          child: Text(
            'אין תוצאות תואמות',
            style: TextStyle(color: BsTokens.mutedLight),
          ),
        ),
      );
    }
    return Column(
      children: <Widget>[
        for (final e in entries) _DiveEntryTile(entry: e),
        for (final r in extras) _GlobalDiveTile(result: r),
        if (entries.isNotEmpty || extras.isNotEmpty)
          const Divider(height: 1, color: Color(0xFFF5F5F5)),
        Expanded(
          child: products.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(BsTokens.space4),
                    child: Text(
                      'אין מוצרים תואמים',
                      style: TextStyle(color: BsTokens.mutedLight),
                    ),
                  ),
                )
              : LipskeyProductsList(products: products),
        ),
      ],
    );
  }
}

/// A single ENTITY search hit (order / task / customer / chat / notification)
/// inside the unified dive window ([kGlobalSearch]). Mirrors [_DiveEntryTile]'s
/// look — emoji + title + optional subtitle + a Hebrew type badge — and on tap
/// runs the result's OWN open/navigate closure (open the order/task/customer
/// sheet · jump to the chat/notification section), keeping the overlay floating.
class _GlobalDiveTile extends ConsumerWidget {
  const _GlobalDiveTile({required this.result});

  final SearchResult result;

  static const Map<SearchResultKind, String> _emoji =
      <SearchResultKind, String>{
    SearchResultKind.order: '🧾',
    SearchResultKind.task: '✅',
    SearchResultKind.customer: '👤',
    SearchResultKind.chat: '💬',
    SearchResultKind.notification: '🔔',
  };
  static const Map<SearchResultKind, String> _label =
      <SearchResultKind, String>{
    SearchResultKind.order: 'הזמנה',
    SearchResultKind.task: 'משימה',
    SearchResultKind.customer: 'לקוח',
    SearchResultKind.chat: 'שיחה',
    SearchResultKind.notification: 'התראה',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      dense: true,
      leading: Text(
        _emoji[result.kind] ?? '🔎',
        style: const TextStyle(fontSize: 20),
      ),
      title: Text(
        result.title,
        style: const TextStyle(color: BsTokens.inkLight, fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: result.subtitle.isNotEmpty
          ? Text(
              result.subtitle,
              style: const TextStyle(color: Color(0xFF666666), fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _label[result.kind] ?? '',
          style: const TextStyle(
            color: Color(0xFF888888),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      onTap: () {
        // END the in-place search before running: an entity result may navigate to
        // a tab/section this panel would otherwise keep COVERING. Clearing the dive
        // query drops the panel (see [GlobalSearchResultsView]); the result then
        // opens its sheet over / navigates to the now-revealed destination.
        ref.read(keyboardDiveQueryProvider.notifier).state = '';
        result.run(ref, context);
      },
    );
  }
}

/// A single non-product search hit (category / screen / setting) inside the live
/// DIVE (owner A slice 3). Mirrors the old search list's entry tile: a legal leaf
/// navigates to its screen; every other entry NARROWS the dive to its title (the
/// dive's [keyboardDiveQueryProvider], the analogue of the old search bar setting
/// [searchQueryProvider]).
class _DiveEntryTile extends ConsumerWidget {
  const _DiveEntryTile({required this.entry});

  final SearchEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      dense: true,
      leading: Text(entry.emoji, style: const TextStyle(fontSize: 20)),
      title: Text(
        entry.title,
        style: const TextStyle(color: BsTokens.inkLight, fontSize: 14),
      ),
      subtitle: entry.breadcrumb.isNotEmpty
          ? Text(
              entry.breadcrumb,
              style: const TextStyle(color: Color(0xFF666666), fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          entry.typeLabel,
          style: const TextStyle(
            color: Color(0xFF888888),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      onTap: () {
        if (entry.title == 'תנאי שימוש' || entry.title == 'מדיניות פרטיות') {
          Navigator.of(context).push(
            LegalScreen.route(
              initialTab: entry.title == 'תנאי שימוש'
                  ? LegalTab.terms
                  : LegalTab.privacy,
            ),
          );
          return;
        }
        // Narrow the LIVE dive to this hit (the dive-query analogue of the old
        // search bar's searchQueryProvider = entry.title).
        ref.read(keyboardDiveQueryProvider.notifier).state = entry.title;
      },
    );
  }
}

// Body — switches between the full catalog list (הכל) and a per-section view.
// Non-הכל sections render a header (label + edit button) above either the
// filtered list or an empty state, so the edit affordance is always visible.
class _CatalogBody extends ConsumerWidget {
  const _CatalogBody({this.scrollCtrl});
  final ScrollController? scrollCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(catalogSectionProvider);
    if (active == 'בית') return SmartHomeBody(scrollCtrl: scrollCtrl);
    if (active == 'מאתר') return const FinderScreen();
    // OWNER-REVIEW · kWordFinder seam — routes the flag-gated 'מאתר חכם' pill to
    // the two-mode word-finder host. Unreachable when kWordFinderFlag is off
    // (the pill that sets this active section never renders), so this branch is
    // inert by default. WordFinderHome also self-gates on the same flag.
    // kRingDive demo: when the RingDive flag is on (the demo deploy adds
    // --dart-define=ENABLE_RING_DIVE=true), the smart-finder pill opens the
    // rotary RingDive surface instead; a normal build (flag off) is
    // byte-identical (this section is only reachable via the kWordFinder pill
    // and falls back to WordFinderHome). RingDiveScreen self-gates too.
    if (active == 'מאתר חכם') {
      if (ref.watch(featureFlagsProvider).contains(kRingDiveFlag)) {
        return const Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(child: RingDiveScreen()),
        );
      }
      return const WordFinderHome();
    }
    // OWNER-REVIEW · kCardKeyboard seam (#38 A/B) — routes the flag-gated
    // 'מקלדת חכמה' pill to the unified card-keyboard. Unreachable when the flag is
    // off (the pill that sets this active never renders); CardKeyboardScreen also
    // self-gates. It has no Scaffold/Directionality of its own, so wrap it RTL +
    // scrollable (swarm R10).
    if (active == 'מקלדת חכמה') {
      return const Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
            child: CardKeyboardScreen(),
          ),
        ),
      );
    }
    if (active == 'עץ חכם') return const _SmartTreeSection();
    if (active == 'קטגוריות') return const _CatalogList();
    if (active == 'מועדפים') return const _FavoritesSection();
    if (active == 'חיפושים אחרונים') return const _RecentSearchesSection();
    if (active == 'תכנון חיבור') return const InstallStudioScreen();
    if (active == 'וריאנטים') return const _VariantsSection();

    final selected = ref.watch(catalogListItemsProvider)[active];
    final hasItems = selected != null && selected.isNotEmpty;

    return Column(
      children: [
        _SectionHeader(label: active),
        Expanded(
          child: hasItems
              ? _FilteredCatalogList(selected: selected)
              : _EmptySection(emoji: '📋', label: active),
        ),
      ],
    );
  }
}

class _SectionHeader extends ConsumerWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: BsTokens.brand,
              size: 20,
            ),
            tooltip: 'עריכה',
            onPressed: () => _showItemPickerSheet(context, ref, label),
          ),
        ],
      ),
    );
  }
}


class _FilteredCatalogList extends StatelessWidget {
  const _FilteredCatalogList({required this.selected});

  final Set<String> selected;

  @override
  Widget build(BuildContext context) {
    // Preserve original ordering by collecting original indices that match.
    // B4: also skip any (possibly previously-saved) content-less title so a
    // curated list never renders a tile that drills into the `_TreeComingSoon`
    // "בקרוב" placeholder. Display-only filter — the saved selection is kept.
    final indices = <int>[
      for (var i = 0; i < kCatalogCats.length; i++)
        if (selected.contains(kCatalogCats[i].title) &&
            _categoryHasContent(kCatalogCats[i].title))
          i,
    ];
    return ListView.separated(
      key: const Key('catalog-list'),
      itemCount: indices.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        indent: 76,
        color: Color(0xFFF5F5F5),
      ),
      itemBuilder: (_, i) {
        final idx = indices[i];
        return _CatalogRow(cat: kCatalogCats[idx]);
      },
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.emoji, required this.label});

  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'אין פריטים להצגה.\nפתחו את ניהול הרשימות והקישו ✏️ כדי לבחור פריטים.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF888888), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

/// OWNER POLICY (B4): a top category is shown only when it actually leads to
/// content. A `kCatalogCats` title with no matching `kCatalogTree` node (or a
/// node with an empty subtree) would drill straight into the `_TreeComingSoon`
/// "בקרוב — הקטגוריה הזו בבנייה" placeholder; the App Store rejects visible
/// content-less / "coming soon" surfaces, so those tiles are filtered out of
/// the browse list. Reversible data filter (mirrors wave-1's `where(...)`) —
/// no `kCatalogCats`/`kCatalogTree` data is deleted; re-add a tree node and the
/// category reappears automatically.
bool _categoryHasContent(String title) {
  final node = _findCatalogTreeNodeByTitle(title);
  return node != null && node.children.isNotEmpty;
}

/// Top categories that belong to [system] — matched to their catalog-tree
/// node's dominant system (fixtures show in both), consistent with the tree
/// drill. null → all. Content-less categories (B4) are always filtered out.
List<Section> _catsForSystem(WaterSystem? system) {
  final out = <Section>[];
  for (final c in kCatalogCats) {
    if (!_categoryHasContent(c.title)) continue;
    if (system == null) {
      out.add(c);
      continue;
    }
    final node = _findCatalogTreeNodeByTitle(c.title);
    if (node != null && nodeHasSystem(node, system)) out.add(c);
  }
  return out;
}

/// Real, department-aware summary for a top category — its in-system product
/// count + a description built from its in-system sub-categories. Replaces the
/// old static `_kMeta` copy so each row reflects the *active* system, not fixed
/// marketing text identical across departments.
({int count, String desc}) _categorySummary(String title, WaterSystem? system) {
  final node = _findCatalogTreeNodeByTitle(title);
  if (node == null) return (count: 0, desc: 'בקרוב');
  final leafCats = <String>{};
  void collect(CatalogNode n) {
    if (n.isLeaf) {
      final c = n.lipskeyCategory;
      if (c != null) leafCats.add(c);
    } else {
      for (final ch in n.children) {
        collect(ch);
      }
    }
  }

  collect(node);
  final count = filterBySystem(
          kCatalogProducts.where((p) => leafCats.contains(p.categoryHe)).toList(),
          system)
      .length;
  final subs = [
    for (final ch in node.children)
      if (system == null || nodeHasSystem(ch, system)) ch.title,
  ];
  final desc = subs.isEmpty ? '$count מוצרים' : subs.take(3).join(' · ');
  return (count: count, desc: desc);
}

/// PERF-H3: derived provider — precomputes every category's summary once per
/// active system, keyed by category title. `_CatalogRow` does a map lookup
/// instead of calling `_categorySummary` (which scans the full catalog) on
/// each build. Identical values to the previous per-row calls.
final categorySummaryProvider =
    Provider<Map<String, ({int count, String desc})>>((ref) {
  final system = ref.watch(catalogSystemFilterProvider);
  return {
    for (final c in kCatalogCats) c.title: _categorySummary(c.title, system),
  };
});

class _CatalogList extends ConsumerWidget {
  const _CatalogList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cats = _catsForSystem(ref.watch(catalogSystemFilterProvider));
    return ListView.separated(
      key: const Key('catalog-list'),
      itemCount: cats.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        indent: 76,
        color: Color(0xFFF5F5F5),
      ),
      itemBuilder: (context, i) => _CatalogRow(cat: cats[i]),
    );
  }
}

// ── Lipskey supplier card — pinned at top of catalog list ────────────────────
// ── Featured product card — shown at top of main catalog list ────────────────
CatalogNode? _findCatalogTreeNodeByTitle(String title) {
  for (final n in kCatalogTree) {
    if (n.title == title) return n;
  }
  return null;
}

/// Smart-nav: switch to the catalog tab and drill into [categoryTitle], so a
/// tapped category suggestion takes the user straight to those products.
void openCatalogCategory(WidgetRef ref, String categoryTitle) {
  ref.read(mainTabProvider.notifier).state = 0; // catalog tab
  final node = _findCatalogTreeNodeByTitle(categoryTitle) ??
      CatalogNode(
        id: 'placeholder.$categoryTitle',
        title: categoryTitle,
        emoji: kCatalogCats
            .firstWhere(
              (c) => c.title == categoryTitle,
              orElse: () => const Section(id: '', emoji: '', title: ''),
            )
            .emoji,
      );
  ref.read(catalogTreePathProvider.notifier).state = [node];
}

class _CatalogRow extends ConsumerWidget {
  const _CatalogRow({required this.cat});

  final Section cat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // PERF-H3: map lookup — summaries precomputed once by categorySummaryProvider.
    final summary = ref.watch(categorySummaryProvider)[cat.title] ??
        (count: 0, desc: 'בקרוב');
    final hasBadge = summary.count > 0;
    return InkWell(
      onTap: () {
        // Categories without tree data drill into a designed "coming soon"
        // screen via a childless placeholder node, so the experience stays
        // consistent across every main category.
        final node = _findCatalogTreeNodeByTitle(cat.title) ??
            CatalogNode(
              id: 'placeholder.${cat.title}',
              title: cat.title,
              emoji: cat.emoji,
            );
        ref.read(catalogTreePathProvider.notifier).state = [node];
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Avatar circle with emoji — appears on right in RTL.
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(cat.emoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat.title,
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          summary.desc,
                          style: const TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasBadge)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: BsTokens.brand,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${summary.count}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── In-tab catalog tree drill ─────────────────────────────────────────────
// Renders inside the catalog tab so the app bar (top) and the bottom nav
// (bottom) stay fixed; only the rows scroll. A fixed drill bar replaces the
// search bar: back-one-level + the current category as a pressed orange chip
// with an X that cancels the whole drill.
int _treeNodeCount(CatalogNode node, [WaterSystem? system]) {
  if (!node.isLeaf) {
    return (system == null
            ? node.children
            : node.children.where((c) => nodeHasSystem(c, system)))
        .length;
  }
  if (node.lipskeyCategory != null) {
    return filterBySystem(
            kCatalogProducts
                .where((p) => p.categoryHe == node.lipskeyCategory)
                .toList(),
            system)
        .length;
  }
  if (node.smartKey != null) {
    return smartProductByKey(node.smartKey!)?.brands.length ?? 0;
  }
  return node.brandIds.length;
}

/// Secondary-line description — child names for a branch, or the
/// product/model/brand summary for a leaf.
String _treeNodeDesc(CatalogNode node, [WaterSystem? system]) {
  if (!node.isLeaf) {
    final kids = system == null
        ? node.children
        : node.children.where((c) => nodeHasSystem(c, system)).toList();
    return kids.map((c) => c.title).join(' · ');
  }
  if (node.lipskeyCategory != null) {
    // Preview of what's inside (characterizing words / sample names) rather
    // than a bare product count.
    final prods = filterBySystem(
        kCatalogProducts
            .where((p) => p.categoryHe == node.lipskeyCategory)
            .toList(),
        system);
    final preview = _facetDesc(prods);
    return preview.isNotEmpty
        ? preview
        : '${_treeNodeCount(node, system)} מוצרים · ליפסקי ברקן';
  }
  if (node.smartKey != null) {
    final p = smartProductByKey(node.smartKey!);
    return p != null ? '${p.brands.length} דגמים זמינים' : 'דגמים';
  }
  return '${node.brandIds.length} מותגים';
}

/// PERF: a tree row needs BOTH the count and the description for the SAME
/// (node, system); computing them separately ran the (now-memoised)
/// `nodeHasSystem` child filter twice. This bundles them and caches the pair
/// per `node.id|system` so `_TreeCatRow` builds it ONCE — not twice per row,
/// not again every frame. Identical values to calling the two helpers directly.
final Map<String, ({int count, String desc})> _treeNodeSummaryCache = {};
({int count, String desc}) _treeNodeSummary(CatalogNode node,
    [WaterSystem? system]) {
  final key = '${node.id}|${system?.name ?? ''}';
  return _treeNodeSummaryCache[key] ??= (
    count: _treeNodeCount(node, system),
    desc: _treeNodeDesc(node, system),
  );
}

/// The engine-derived "נתוני קטלוג" facts a card shows for a product: each of
/// these is an O(catalog)-scale sweep (`compatibleProductsFor` ≈ O(855);
/// `installKitFor` + `variantSiblingsCountFor` touch the whole catalog), so the
/// card's Builder recomputed all six on every setState (filter chip, depth
/// toggle, …). They depend ONLY on the product, so we bundle and cache them
/// keyed on sku — byte-identical to calling the helpers inline (same pure
/// inputs → same outputs), just computed once per SKU.
class _CardCatalogData {
  _CardCatalogData(LipskeyCatalogProduct prod)
      : spec = engineeringSpecFor(prod),
        price = priceFor(prod),
        compat = compatibleProductsFor(prod),
        finder = finderGroupFor(prod),
        kit = installKitFor(prod),
        variants = variantSiblingsCountFor(prod),
        readiness = cardReadinessScore(prod);

  final ({
    String material,
    String? pressureRating,
    double maxTempC,
    String waterSystem,
    String endsSummary,
    double? minBoreMm,
  })? spec;
  final int? price;
  final List<LipskeyCatalogProduct> compat;
  final ({String emoji, String label})? finder;
  final ({int must, int optional, int tools})? kit;
  final int variants;
  final ({int score, String label, int breadth, int depth}) readiness;
}

final Map<String, _CardCatalogData> _cardCatalogDataCache = {};
_CardCatalogData _cardCatalogDataFor(LipskeyCatalogProduct prod) =>
    _cardCatalogDataCache[prod.sku] ??= _CardCatalogData(prod);

class _TreeDrill extends ConsumerWidget {
  const _TreeDrill({required this.path});
  final List<CatalogNode> path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = path.last;
    final query =
        ref.watch(catalogTreeQueryProvider.select((q) => q.trim()));
    final facetSel = ref.watch(catalogFacetProvider);
    final systemFilter = ref.watch(catalogSystemFilterProvider);
    // T6.3: catalog reads via the repository (same const data).
    final repo = ref.watch(catalogRepositoryProvider);

    // A leaf that maps to a lipskey category with products drills by facets
    // (curated where defined, else auto-derived) before the product list.
    final leafCat = current.isLeaf ? current.lipskeyCategory : null;
    final isProductLeaf = leafCat != null &&
        repo.allProducts().any((p) => p.categoryHe == leafCat);

    void resetQuery() =>
        ref.read(catalogTreeQueryProvider.notifier).state = '';
    void resetFacets() =>
        ref.read(catalogFacetProvider.notifier).state = const [];

    void cancel() {
      resetQuery();
      resetFacets();
      ref.read(catalogTreePathProvider.notifier).state = const [];
    }

    // Jump back to an ancestor tree level via its breadcrumb chip.
    void jumpToTree(int index) {
      resetQuery();
      resetFacets();
      ref.read(catalogTreePathProvider.notifier).state =
          path.sublist(0, index + 1);
    }

    // Jump back to an earlier facet level via its breadcrumb chip.
    void jumpToFacet(int index) =>
        ref.read(catalogFacetProvider.notifier).state =
            facetSel.sublist(0, index);

    void openNode(CatalogNode n) {
      if (n.isLeaf) {
        // Leaf with products → drill in-tab (facets + product list below).
        if (n.lipskeyCategory != null &&
            repo.allProducts().any((p) => p.categoryHe == n.lipskeyCategory)) {
          resetQuery();
          resetFacets();
          ref.read(catalogTreePathProvider.notifier).state = [...path, n];
          return;
        }
        if (n.smartKey != null) {
          final product = repo.smartProductByKey(n.smartKey!);
          if (product != null) openSmartProductSheet(context, product);
        }
        return;
      }
      resetQuery();
      resetFacets();
      ref.read(catalogTreePathProvider.notifier).state = [...path, n];
    }

    // Unified breadcrumb: tree chips followed by facet chips. The last entry
    // is the active (pressed) chip; the rest jump back to their level on tap.
    final crumbs = <({String label, VoidCallback? onTap})>[];
    for (var i = 0; i < path.length; i++) {
      final last = i == path.length - 1 && facetSel.isEmpty;
      crumbs.add((label: path[i].title, onTap: last ? null : () => jumpToTree(i)));
    }
    for (var j = 0; j < facetSel.length; j++) {
      final last = j == facetSel.length - 1;
      crumbs.add((label: facetSel[j], onTap: last ? null : () => jumpToFacet(j)));
    }

    // Drill rows shown on top; the relevant products are listed below them and
    // shrink as the drill narrows.
    var rowWidgets = <Widget>[];
    var products = <LipskeyCatalogProduct>[];
    Widget? special;

    if (isProductLeaf) {
      final base = filterBySystem(
          repo.allProducts().where((p) => p.categoryHe == leafCat).toList(),
          systemFilter);
      final curated = kProductFacets[leafCat];
      final options = <({String label, String desc, int count})>[];
      if (curated != null) {
        products = _applyFacets(base, curated, facetSel);
        if (facetSel.length < curated.length) {
          final group = curated[facetSel.length];
          for (final f in group) {
            final matching =
                products.where((p) => _matchesFacet(p, group, f)).toList();
            if (matching.isNotEmpty) {
              options.add((
                label: f.label,
                desc: _facetDesc(matching),
                count: matching.length,
              ));
            }
          }
        }
      } else {
        // Auto facets: filter by chosen words, split by next primary word.
        products = base
            .where((p) => facetSel.every((w) => p.nameHe.contains(w)))
            .toList();
        for (final o in _autoFacetOptions(products, facetSel)) {
          final matching =
              products.where((p) => p.nameHe.contains(o.label)).toList();
          options.add((
            label: o.label,
            desc: _facetDesc(matching),
            count: o.count,
          ));
        }
      }
      rowWidgets = [
        for (final o in options)
          _FacetRow(
            label: o.label,
            desc: o.desc,
            count: o.count,
            onTap: () => ref.read(catalogFacetProvider.notifier).state =
                [...facetSel, o.label],
          ),
      ];
    } else if (current.children.isEmpty) {
      special = _TreeComingSoon(node: current);
    } else {
      var rows = query.isEmpty
          ? current.children
          : _searchSubtree(current, query);
      if (systemFilter != null) {
        rows = rows.where((c) => nodeHasSystem(c, systemFilter)).toList();
      }
      rowWidgets = [
        for (final n in rows)
          _TreeCatRow(node: n, system: systemFilter, onTap: () => openNode(n)),
      ];
      products = filterBySystem(_subtreeProducts(current), systemFilter);
      if (query.isNotEmpty) {
        products =
            products.where((p) => p.nameHe.contains(query)).toList();
      }
      if (rows.isEmpty && products.isEmpty) {
        special = Center(
          child: Text(
            'לא נמצאו תוצאות עבור "$query"',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF888888), fontSize: 14),
          ),
        );
      }
    }

    products = sortCatalogProducts(products, ref.watch(catalogProductSortProvider));

    final body = special ??
        CustomScrollView(
          slivers: [
            if (rowWidgets.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(rowWidgets),
                ),
              ),
            if (products.isNotEmpty) ...[
              SliverToBoxAdapter(child: _ProductsHeader(count: products.length)),
              SliverFillRemaining(
                hasScrollBody: true,
                child: LipskeyProductsList(products: products),
              ),
            ],
          ],
        );

    return Column(
      children: [
        _TreeDrillBar(
          key: ValueKey('${current.id}.${facetSel.length}'),
          crumbs: crumbs,
          onBack: cancel,
          onCancel: cancel,
        ),
        Expanded(child: body),
      ],
    );
  }
}

// Bordered row for a product facet option (label + description + count badge).
class _FacetRow extends StatelessWidget {
  const _FacetRow({
    required this.label,
    required this.desc,
    required this.count,
    required this.onTap,
  });
  final String label;
  final String desc;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BsTokens.brand, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        desc.isEmpty ? '$count מוצרים' : desc,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0xFF888888), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: BsTokens.brand,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// Small colored pill: a label with its count at the end (e.g. "חובה 3").
class _CountBadge extends StatelessWidget {
  const _CountBadge({
    required this.label,
    required this.count,
    required this.color,
  });
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$label $count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// Header above the products listed beneath the drill rows.
class _ProductsHeader extends ConsumerWidget {
  const _ProductsHeader({required this.count});
  final int count;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(catalogProductSortProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Text(
            'מוצרים',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: BsTokens.brand.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: BsTokens.brand,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          // Sort-by button on the opposite side of the header.
          if (ref.watch(catalogSettingsProvider.select((s) => s.quickFilterBar)))
          PopupMenuButton<ProductSort>(
            tooltip: 'מיון לפי',
            color: Colors.white,
            position: PopupMenuPosition.under,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onSelected: (s) =>
                ref.read(catalogProductSortProvider.notifier).state = s,
            itemBuilder: (_) => [
              for (final s in ProductSort.values)
                PopupMenuItem<ProductSort>(
                  value: s,
                  child: Row(
                    children: [
                      Icon(
                        s == sort ? Icons.check : Icons.swap_vert,
                        size: 18,
                        color: s == sort
                            ? BsTokens.brand
                            : const Color(0xFF888888),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        catalogProductSortLabel(s),
                        style: TextStyle(
                          color: BsTokens.inkLight,
                          fontSize: 14,
                          fontWeight:
                              s == sort ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: BsTokens.brand, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.swap_vert, size: 16, color: BsTokens.brand),
                  const SizedBox(width: 4),
                  Text(
                    'מיון לפי',
                    style: const TextStyle(
                      color: BsTokens.brand,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Designed "coming soon" body for main categories that have no tree data yet.
class _TreeComingSoon extends StatelessWidget {
  const _TreeComingSoon({required this.node});
  final CatalogNode node;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: BsTokens.brand.withAlpha(20),
                shape: BoxShape.circle,
                border: Border.all(color: BsTokens.brand, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(node.emoji, style: const TextStyle(fontSize: 44)),
            ),
            const SizedBox(height: 20),
            Text(
              node.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: BsTokens.brand,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'בקרוב',
                style: TextStyle(
                  color: bsOnAccent(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'הקטגוריה הזו בבנייה — תת-קטגוריות ומוצרים יתווספו בקרוב.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF888888), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

/// All descendants of [node] whose title contains [query] (case-insensitive).
List<CatalogNode> _searchSubtree(CatalogNode node, String query) {
  final q = query.toLowerCase();
  final out = <CatalogNode>[];
  void walk(CatalogNode n) {
    for (final c in n.children) {
      if (c.title.toLowerCase().contains(q)) out.add(c);
      walk(c);
    }
  }

  walk(node);
  return out;
}

// Fixed drill bar that doubles as a scoped search field: back-one-level + a
// breadcrumb of the drill path (ancestors are outline chips that jump back to
// their level, the current level is a pressed orange chip whose X cancels the
// drill) + a text field that searches inside the current category's subtree.
class _TreeDrillBar extends ConsumerStatefulWidget {
  const _TreeDrillBar({
    super.key,
    required this.crumbs,
    required this.onBack,
    required this.onCancel,
  });

  /// Breadcrumb chips. The last entry is the active (pressed) chip; entries
  /// with a non-null [onTap] jump back to that level.
  final List<({String label, VoidCallback? onTap})> crumbs;
  final VoidCallback onBack;
  final VoidCallback onCancel;

  @override
  ConsumerState<_TreeDrillBar> createState() => _TreeDrillBarState();
}

class _TreeDrillBarState extends ConsumerState<_TreeDrillBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: ref.read(catalogTreeQueryProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Active chip (onTap == null): pressed orange with X. Others: outline chip
  // that jumps back to its level. Each title is capped + ellipsized so a long
  // name never dominates; the row scrolls horizontally for deep paths.
  Widget _crumb(({String label, VoidCallback? onTap}) crumb) {
    final active = crumb.onTap == null;
    if (active) {
      return Semantics(
        button: true,
        label: 'בטל',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onCancel,
          // ≥48dp tap target: the whole active crumb cancels; the visible
          // pill stays small (a11y) inside the fixed-48dp bar.
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: Center(
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
                decoration: BoxDecoration(
                  color: BsTokens.brand,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 130),
                      child: Text(
                        crumb.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.close, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: crumb.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: const Border.fromBorderSide(
            BorderSide(color: Color(0xFFC8C8CE), width: 1),
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 130),
          child: Text(
            crumb.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6E6E73),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Keep the field in sync when the query is cleared externally (navigation).
    ref.listen<String>(catalogTreeQueryProvider, (_, next) {
      if (next != _controller.text) {
        _controller.text = next;
        _controller.selection =
            TextSelection.collapsed(offset: next.length);
      }
    });
    final hasText =
        ref.watch(catalogTreeQueryProvider.select((q) => q.isNotEmpty));

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFE7E7EA),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_forward,
                color: Color(0xFF555555), size: 20),
            tooltip: 'חזרה',
            onPressed: widget.onBack,
          ),
          // Breadcrumb of the drill path — root first on the right, deeper
          // levels to the left (natural RTL order); scrolls if it overflows.
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: false,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < widget.crumbs.length; i++) ...[
                    if (i > 0)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(Icons.chevron_left,
                            color: Color(0xFF999999), size: 16),
                      ),
                    _crumb(widget.crumbs[i]),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Scoped search field (compact).
          SizedBox(
            width: 92,
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onChanged: (v) =>
                  ref.read(catalogTreeQueryProvider.notifier).state = v,
              style: const TextStyle(color: BsTokens.inkLight, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'חיפוש',
                hintStyle: TextStyle(color: Color(0xFF888888), fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (hasText)
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF888888), size: 18),
              tooltip: 'נקה',
              onPressed: () =>
                  ref.read(catalogTreeQueryProvider.notifier).state = '',
            ),
        ],
      ),
    );
  }
}

class _TreeCatRow extends StatelessWidget {
  const _TreeCatRow({required this.node, required this.onTap, this.system});
  final CatalogNode node;
  final VoidCallback onTap;
  final WaterSystem? system;

  @override
  Widget build(BuildContext context) {
    // PERF: count + desc for this (node, system) computed once and cached,
    // instead of two passes over the children per row, every frame.
    final summary = _treeNodeSummary(node, system);
    final count = summary.count;
    final desc = summary.desc;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BsTokens.brand, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(node.emoji, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        node.title,
                        style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              desc,
                              style: const TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (count > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: BsTokens.brand,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Smart Tree Section ────────────────────────────────────────────────────
// Two levels: category list → product list within a category.
// Tapping a product opens a bottom sheet (brands + accessories).

class _SmartTreeSection extends ConsumerWidget {
  const _SmartTreeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCat = ref.watch(smartTreeCatProvider);

    if (selectedCat == null) {
      return const _SmartTreeCatList();
    }
    return _SmartTreeProductList(cat: selectedCat);
  }
}

class _SmartTreeCatList extends ConsumerWidget {
  const _SmartTreeCatList();

  static const _catEmojis = <String, String>{
    'ברזים וכיורים':         '🚰',
    'אסלות':                 '🚽',
    'מקלחות ואמבטיות':       '🚿',
    'חימום מים':             '♨️',
    'מטבח':                  '🍽️',
    'ניקוז וצנרת':           '🕳️',
    'גופי תברואה':           '🚾',
    'בנייה ומחיצות':         '🧱',
    'גמר':                   '🎨',
    'אביזרי קצה וחיבורים':   '🔗',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Scope the smart tree to the active water system (Benzi #1, Phase 2b):
    // keep only categories that still have an in-system product.
    final system = ref.watch(catalogSystemFilterProvider);
    // T6.3: catalog reads via the repository (same const data).
    final repo = ref.watch(catalogRepositoryProvider);
    final cats = system == null
        ? repo.smartTreeCats()
        : repo
            .smartTreeCats()
            .where((c) =>
                filterSmartBySystem(repo.smartProductsForCat(c), system)
                    .isNotEmpty)
            .toList();
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: cats.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 76, color: Color(0xFFF5F5F5)),
            itemBuilder: (_, i) {
              final cat = cats[i];
              final prods =
                  filterSmartBySystem(repo.smartProductsForCat(cat), system);
              final count = prods.length;
              final desc = prods.map((p) => p.name).join(' · ');
              final emoji = _catEmojis[cat] ?? '📦';
              return InkWell(
                onTap: () =>
                    ref.read(smartTreeCatProvider.notifier).state = cat,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF5F5F5),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(emoji,
                            style: const TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat,
                              style: const TextStyle(
                                color: BsTokens.inkLight,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              desc.isEmpty ? '$count מוצרים בעץ' : desc,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: BsTokens.brand,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SmartTreeProductList extends ConsumerStatefulWidget {
  const _SmartTreeProductList({required this.cat});

  final String cat;

  static void _openProductSheet(BuildContext context, SmartProduct p) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SmartProductSheet(product: p),
    );
  }

  @override
  ConsumerState<_SmartTreeProductList> createState() =>
      _SmartTreeProductListState();
}

class _SmartTreeProductListState extends ConsumerState<_SmartTreeProductList> {
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: ref.read(smartTreeQueryProvider));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _back() {
    ref.read(smartTreeQueryProvider.notifier).state = '';
    ref.read(smartTreeCatProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF22C55E);
    final query =
        ref.watch(smartTreeQueryProvider.select((q) => q.trim()));
    // T6.3: smart-tree products via the repository (same const data).
    final all = filterSmartBySystem(
        ref.watch(catalogRepositoryProvider).smartProductsForCat(widget.cat),
        ref.watch(catalogSystemFilterProvider));
    final products = query.isEmpty
        ? all
        : all.where((p) => p.name.contains(query)).toList();
    return Column(
      children: [
        // Drill bar — back + green active category chip with X.
        Container(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE7E7EA),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_forward,
                    color: Color(0xFF555555), size: 20),
                tooltip: 'חזרה',
                onPressed: _back,
              ),
              Flexible(
                child: Semantics(
                  button: true,
                  label: 'בטל',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _back,
                    // ≥48dp tap target: the whole category chip cancels; the
                    // visible pill stays small (a11y) inside the 48dp bar.
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(minWidth: 48, minHeight: 48),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
                          decoration: BoxDecoration(
                            color: green,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🌳 ',
                                  style: TextStyle(fontSize: 13)),
                              Flexible(
                                child: Text(
                                  widget.cat,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: bsOnAccent(context),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.close,
                                  color: bsOnAccent(context), size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  textInputAction: TextInputAction.search,
                  onChanged: (v) =>
                      ref.read(smartTreeQueryProvider.notifier).state = v,
                  style: const TextStyle(color: BsTokens.inkLight, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'חיפוש',
                    hintStyle: TextStyle(color: Color(0xFF888888), fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: products.isEmpty
              ? Center(
                  child: Text(
                    'לא נמצאו תוצאות עבור "$query"',
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(color: Color(0xFF888888), fontSize: 14),
                  ),
                )
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            itemCount: products.length,
            itemBuilder: (_, i) {
              final p = products[i];
              final desc = p.acc.map((a) => a.name).join(' · ');
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: green, width: 1),
                ),
                clipBehavior: Clip.antiAlias,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        _SmartTreeProductList._openProductSheet(context, p),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF5F5F5),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(p.emoji,
                                style: const TextStyle(fontSize: 24)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: const TextStyle(
                                    color: BsTokens.inkLight,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  desc.isEmpty ? p.cat : desc,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF888888),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _CountBadge(
                                label: 'חובה',
                                count: p.mustCount,
                                color: const Color(0xFFE53935),
                              ),
                              const SizedBox(height: 4),
                              _CountBadge(
                                label: 'סה"כ',
                                count: p.acc.length,
                                color: green,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


/// Public entry point — opens the unified "ברז לכיור" sheet (brand picker +
/// accessories + cart sync) for [product]. Used by the catalog drill-down so
/// reaching a leaf opens the same rich sheet as the smart-tree.
void openSmartProductSheet(BuildContext context, SmartProduct product) {
  // Studio Pillar-3 · step 93 — product_view intel (additive · one place catches
  // every caller · fired from a tap handler, never build → demo byte-identical).
  // Reads the bus via the container — the established idiom (catalog_screen:622).
  ProviderScope.containerOf(context, listen: false)
      .read(intelBusProvider)
      .track(IntelEvents.productView,
          props: <String, String>{'sku': product.key});
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFFFFFFFF),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _SmartProductSheet(product: product),
  );
}

/// Distinct size tokens (e.g. 1¼" / 2") parsed from brand names.
List<String> _deriveBrandSizes(List<SmartBrand> brands) {
  final re = RegExp(r'[0-9][0-9.¼½¾/]*\s*["״]');
  final out = <String>{};
  for (final b in brands) {
    final m = re.firstMatch(b.name);
    if (m != null) out.add(m.group(0)!.replaceAll(' ', ''));
  }
  return out.toList();
}

/// Distinct "type" words — the first distinguishing word in each brand name
/// (shared words and sizes excluded).
List<String> _deriveBrandTypes(List<SmartBrand> brands) {
  if (brands.length < 2) return const [];
  final toks = brands.map((b) => _facetTokens(b.name)).toList();
  final shared = toks.first.toSet();
  for (final t in toks.skip(1)) {
    shared.retainAll(t.toSet());
  }
  final out = <String>{};
  for (final t in toks) {
    for (final w in t) {
      if (!shared.contains(w)) {
        out.add(w);
        break;
      }
    }
  }
  return out.toList();
}

/// Collapsible section with a header (title + selected value + chevron).
class _SheetSection extends StatelessWidget {
  const _SheetSection({
    required this.title,
    required this.value,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });
  final String title;
  final String value;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (value.isNotEmpty)
                  Flexible(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: BsTokens.brand,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                Icon(expanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF888888), size: 20),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: child,
          ),
          secondChild: const SizedBox(width: double.infinity),
          crossFadeState:
              expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 180),
        ),
      ],
    );
  }
}

/// Single-select chip row used by the סוג / מידה selectors.
class _ChipWrap extends StatelessWidget {
  const _ChipWrap({
    required this.options,
    required this.selected,
    required this.onSelect,
  });
  final List<String> options;
  final String? selected;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final o in options)
          GestureDetector(
            onTap: () => onSelect(o),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected == o ? BsTokens.brand : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected == o
                      ? BsTokens.brand
                      : const Color(0xFFC8C8CE),
                ),
              ),
              child: Text(
                o,
                style: TextStyle(
                  color: selected == o ? bsOnAccent(context) : const Color(0xFF6E6E73),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Polish G — visual UI for a saved card-version (Roadmap step 76).
/// Two tap targets: the label loads the saved brand into the card; the small
/// "×" deletes the version. Matches the existing violet palette of the
/// "💾 שמור גרסה" button so the relationship is obvious.
class _SavedVersionChip extends StatelessWidget {
  const _SavedVersionChip({
    required this.label,
    required this.onLoad,
    required this.onDelete,
  });

  final String label;
  final VoidCallback onLoad;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: 'טעינת גרסה — החלף למותג השמור',
            child: Semantics(
              button: true,
              label: 'טען גרסה $label',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onLoad,
                // ≥48dp tap target (a11y) — label text stays 10.5sp; only
                // the hit area (and the violet pill) grows.
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(minWidth: 48, minHeight: 48),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 3, 6, 3),
                      child: Text(label,
                          style: const TextStyle(
                              color: Color(0xFF5B21B6),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Tooltip(
            message: 'מחק גרסה',
            child: Semantics(
              button: true,
              label: 'מחק גרסה $label',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onDelete,
                // ≥48dp tap target around the small ✕ (a11y).
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: Icon(Icons.close,
                        size: 12, color: Color(0xFF7C3AED)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmartProductSheet extends ConsumerStatefulWidget {
  const _SmartProductSheet({required this.product});

  final SmartProduct product;

  @override
  ConsumerState<_SmartProductSheet> createState() =>
      _SmartProductSheetState();
}

class _SmartProductSheetState extends ConsumerState<_SmartProductSheet> {
  late int _selectedBrand;
  int? _activeStage;
  late Map<int, bool> _accSelected;
  late Map<int, int> _accQty;

  bool _brandOpen = false;
  bool _typeOpen = false;
  bool _sizeOpen = false;
  String? _selType;
  String? _selSize;
  bool _hotOnly = false; // Roadmap step 65 — quick "hot-water only" filter.
  bool _metallicOnly = false; // Roadmap step 65 — quick "metal-only" filter.

  // Brands matching the chosen סוג / מידה filters (derived from names).
  List<int> get _filteredBrandIdx {
    final brands = widget.product.brands;
    return [
      for (var i = 0; i < brands.length; i++)
        if ((_selType == null || brands[i].name.contains(_selType!)) &&
            (_selSize == null || brands[i].name.contains(_selSize!)) &&
            (!_hotOnly || brandSuitableForHot(brands[i])) &&
            (!_metallicOnly || brandIsMetallic(brands[i])))
          i,
    ];
  }

  void _applyFilterSelection() {
    final idx = _filteredBrandIdx;
    if (idx.isNotEmpty && !idx.contains(_selectedBrand)) {
      _selectedBrand = idx.first;
    }
  }

  Widget _brandCard(int i) {
    final b = widget.product.brands[i];
    final selected = i == _selectedBrand;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedBrand = i);
        // Roadmap step 7 — remember this brand choice for the product.
        ref
            .read(cardSelectionProvider.notifier)
            .setBrand(widget.product.key, b.name);
        // Roadmap step 51 — also tally cross-session brand-pick frequency.
        ref
            .read(brandHistoryProvider.notifier)
            .record(widget.product.key, b.name);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? BsTokens.brand.withAlpha(30) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? BsTokens.brand : const Color(0xFFE0E0E0),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          b.name,
                          style: const TextStyle(
                            color: BsTokens.inkLight,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (b.rec) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: BsTokens.brand,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'מומלץ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    b.tag,
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              b.price != null ? '₪${groupThousands(b.price!)}' : 'לפי ספק',
              style: TextStyle(
                color: selected ? BsTokens.brand : const Color(0xFF888888),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Roadmap step 7 + step 51 — resolve default brand: last selection wins,
    // then most-used (brand history), then recommended.
    final savedBrand = ref.read(cardSelectionProvider)[widget.product.key];
    final histFav = ref
        .read(brandHistoryProvider.notifier)
        .favouriteFor(widget.product.key);
    _selectedBrand = resolveDefaultBrandIndex(
      sp: widget.product,
      cardSelection: savedBrand,
      brandHistoryFav: histFav,
    );
    final acc = widget.product.acc;
    // Roadmap step 7 — restore per-accessory selected+qty from persistence.
    final accStore = ref.read(cardAccStateProvider.notifier);
    _accSelected = {
      for (var i = 0; i < acc.length; i++)
        i: accStore.get(widget.product.key, acc[i].name)?.selected ?? false
    };
    _accQty = {
      for (var i = 0; i < acc.length; i++)
        i: accStore.get(widget.product.key, acc[i].name)?.qty ?? 1
    };
    // Roadmap step 7 (filter dimension) — restore סוג / מידה picks per-product.
    final f = ref.read(cardFilterStateProvider)[widget.product.key];
    _selType = f?.type;
    _selSize = f?.size;
    // Roadmap step 66 — record this product as recently-viewed (post-frame so
    // we don't mutate a provider during the initial build).
    final sku = widget.product.recBrand.sku;
    if (sku != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(recentlyViewedProvider.notifier).touch(sku);
      });
    }
  }

  void _tapStage(int i) =>
      setState(() => _activeStage = _activeStage == i ? null : i);

  // Roadmap step 28/22 — resolve the smart cart's lines to catalog products.
  List<LipskeyCatalogProduct> _resolveCartProducts() {
    final cart = ref.read(smartCartProvider);
    // T6.3: catalog↔smart bridge via the repository (same const data).
    final repo = ref.read(catalogRepositoryProvider);
    final out = <LipskeyCatalogProduct>[];
    for (final line in cart) {
      final csp = repo.smartProductByKey(line.productKey);
      if (csp == null) continue;
      SmartBrand? cb;
      for (final b in csp.brands) {
        if (b.name == line.brandName) {
          cb = b;
          break;
        }
      }
      final cprod = cb == null ? null : repo.productForBrand(cb);
      if (cprod != null) out.add(cprod);
    }
    return out;
  }

  // Roadmap step 22 — "build my line": run the install engine over the line so
  // far (cart) + this product, and show the materialized BOM.
  // Roadmap step 74 — full project BOM: run buildInstallation over all
  // products assigned to a project (resolved via their stored SKU), show the
  // materialized list in a dialog (reuses _showLineBom's presentation).
  void _showProjectBom(String project) {
    final notifier = ref.read(cardProjectsProvider.notifier);
    final items = notifier.forProject(project);
    // T6.3: SKU→catalog lookup via the repository (same const data).
    final repo = ref.read(catalogRepositoryProvider);
    final anchors = <LipskeyCatalogProduct>[];
    for (final it in items) {
      final cp = repo.productForSku(it.sku);
      if (cp != null) anchors.add(cp);
    }
    if (anchors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('אין פריטים שניתן לפתור לקו ב"$project"'),
            duration: const Duration(seconds: 2)),
      );
      return;
    }
    final plan = buildInstallation(anchors, autoCompliance: true, tempC: 60);
    showDialog<void>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('BOM פרויקט "$project" — ${plan.items.length} פריטים'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final it in plan.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                        '${plan.quantities[it.sku] ?? 1}× ${it.nameHe}',
                        style: const TextStyle(fontSize: 12.5)),
                  ),
                if (plan.gaps.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                        '⚠ ${plan.gaps.length} פערים ללא חיבור ישיר',
                        style: const TextStyle(
                            color: Color(0xFFB45309),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('סגור')),
          ],
        ),
      ),
    );
  }

  void _showLineBom(LipskeyCatalogProduct prod) {
    final anchors = <LipskeyCatalogProduct>[..._resolveCartProducts(), prod];
    final plan = buildInstallation(anchors, autoCompliance: true, tempC: 60);
    final items = plan.items.isEmpty ? [prod] : plan.items;
    showDialog<void>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('קו מוצע — ${items.length} פריטים'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final it in items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                        '${plan.quantities[it.sku] ?? 1}× ${it.nameHe}',
                        style: const TextStyle(fontSize: 12.5)),
                  ),
                if (plan.gaps.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('⚠ ${plan.gaps.length} פערים ללא חיבור ישיר',
                        style: const TextStyle(
                            color: Color(0xFFB45309),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('סגור')),
          ],
        ),
      ),
    );
  }

  int get _total {
    final brand = widget.product.brands[_selectedBrand];
    var t = brand.price ?? 0;
    final acc = widget.product.acc;
    for (var i = 0; i < acc.length; i++) {
      if (_accSelected[i] ?? false) {
        t += (acc[i].price ?? 0) * (_accQty[i] ?? 1);
      }
    }
    return t;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final brand = p.brands[_selectedBrand];
    final mustItems = p.acc.where((a) => a.must).toList();
    final optItems = p.acc.where((a) => !a.must).toList();
    final types = _deriveBrandTypes(p.brands);
    final sizes = _deriveBrandSizes(p.brands);

    // Roadmap steps 6/11/21 — pull the catalog's engineering data into the smart
    // card for the selected brand's real SKU, via the SmartProduct↔catalog bridge.
    Widget catRow(String k, String v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(children: [
            Text('$k: ',
                style: const TextStyle(color: Color(0xFF888888), fontSize: 12)),
            Expanded(
              child: Text(v,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
        );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Column(
        children: [
          // Header with handle + prominent close (X)
          SizedBox(
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Positioned(
                  // 48dp tap box centred on the same spot as the old 36dp
                  // circle (top 6→0, left 12→6 compensates the +12dp box).
                  top: 0,
                  left: 6,
                  child: Tooltip(
                    message: 'סגור',
                    child: Semantics(
                      button: true,
                      label: 'סגור',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.pop(context),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Center(
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: BsTokens.brand,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 22),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Product header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(p.emoji, style: const TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        p.cat,
                        style: const TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF5F5F5)),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Installation flow diagram
                if (p.stages.isNotEmpty)
                  _DiagramFlow(
                    product: p,
                    activeStage: _activeStage,
                    onStageTap: _tapStage,
                  ),
                // Tapping a stage pops its matching accessories as chips.
                if (_activeStage != null)
                  _ExplodeChips(
                    key: ValueKey(_activeStage),
                    items: [
                      for (final a in p.acc)
                        if (p.stages[_activeStage!].match
                            .any((m) => a.name.contains(m)))
                          a,
                    ],
                  ),
                // Roadmap step 31 — install progress: tap a stage to mark done.
                if (p.stages.isNotEmpty)
                  Builder(builder: (_) {
                    ref.watch(stageProgressProvider);
                    final prog = ref.read(stageProgressProvider.notifier);
                    final done = prog.doneCount(p.key, p.stages.length);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('מעקב התקנה — $done/${p.stages.length} שלבים בוצעו',
                              style: const TextStyle(
                                  color: Color(0xFF666666),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          // Polish D — visual progress bar that fills as
                          // stages are marked done (Roadmap step 31).
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: p.stages.isEmpty
                                  ? 0
                                  : done / p.stages.length,
                              minHeight: 5,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFF7A2D)), // brand-orange fill
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (var i = 0; i < p.stages.length; i++)
                                GestureDetector(
                                  onTap: () => prog.toggle(p.key, i),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 9, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: prog.isDone(p.key, i)
                                          ? const Color(0xFFD1FAE5)
                                          : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: prog.isDone(p.key, i)
                                              ? const Color(0xFF34D399)
                                              : const Color(0xFFE2E8F0)),
                                    ),
                                    child: Text(
                                        '${prog.isDone(p.key, i) ? "✓ " : ""}${p.stages[i].label}',
                                        style: TextStyle(
                                            color: prog.isDone(p.key, i)
                                                ? const Color(0xFF047857)
                                                : const Color(0xFF475569),
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                // ── Selectors: מותג / סוג / מידה (collapsible) ──
                _SheetSection(
                  title: 'בחר מותג',
                  value: p.brands[_selectedBrand].name,
                  expanded: _brandOpen,
                  onToggle: () => setState(() => _brandOpen = !_brandOpen),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Roadmap step 65 — quick "hot-water only" + "metal only"
                      // brand filters.
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() {
                                _hotOnly = !_hotOnly;
                                _applyFilterSelection();
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: _hotOnly
                                      ? const Color(0xFFFFEDD5)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: _hotOnly
                                          ? const Color(0xFFFB923C)
                                          : const Color(0xFFE2E8F0)),
                                ),
                                child: Text(
                                    '${_hotOnly ? "✓ " : ""}🌡 מים חמים בלבד',
                                    style: TextStyle(
                                        color: _hotOnly
                                            ? const Color(0xFFC2410C)
                                            : const Color(0xFF64748B),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() {
                                _metallicOnly = !_metallicOnly;
                                _applyFilterSelection();
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: _metallicOnly
                                      ? const Color(0xFFF1F5F9)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: _metallicOnly
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFFE2E8F0)),
                                ),
                                child: Text(
                                    '${_metallicOnly ? "✓ " : ""}💎 מתכת בלבד',
                                    style: TextStyle(
                                        color: _metallicOnly
                                            ? const Color(0xFF334155)
                                            : const Color(0xFF64748B),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_filteredBrandIdx.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: Text(
                              'אין מותג תואם לסינון שנבחר',
                              style: TextStyle(
                                  color: Color(0xFF64748B), fontSize: 13),
                            ),
                          ),
                        )
                      else
                        for (final i in _filteredBrandIdx) _brandCard(i),
                    ],
                  ),
                ),
                if (types.isNotEmpty)
                  _SheetSection(
                    title: 'בחר סוג',
                    value: _selType ?? '',
                    expanded: _typeOpen,
                    onToggle: () => setState(() => _typeOpen = !_typeOpen),
                    child: _ChipWrap(
                      options: types,
                      selected: _selType,
                      onSelect: (v) => setState(() {
                        _selType = _selType == v ? null : v;
                        // Roadmap step 7 — persist filter selection per product.
                        ref
                            .read(cardFilterStateProvider.notifier)
                            .setType(widget.product.key, _selType);
                        _applyFilterSelection();
                      }),
                    ),
                  ),
                if (sizes.isNotEmpty)
                  _SheetSection(
                    title: 'בחר מידה',
                    value: _selSize ?? '',
                    expanded: _sizeOpen,
                    onToggle: () => setState(() => _sizeOpen = !_sizeOpen),
                    child: _ChipWrap(
                      options: sizes,
                      selected: _selSize,
                      onSelect: (v) => setState(() {
                        _selSize = _selSize == v ? null : v;
                        // Roadmap step 7 — persist filter selection per product.
                        ref
                            .read(cardFilterStateProvider.notifier)
                            .setSize(widget.product.key, _selSize);
                        _applyFilterSelection();
                      }),
                    ),
                  ),

                // 📦 נתוני קטלוג — spec / compat / price of the selected
                // brand's real SKU (Roadmap 6/11/21), via the bridge.
                Builder(builder: (_) {
                  // T6.3: brand→catalog lookup via the repository (same const).
                  final prod =
                      ref.read(catalogRepositoryProvider).productForBrand(brand);
                  if (prod == null) return const SizedBox.shrink();
                  // PERF: the six engine sweeps below are pure in `prod`, so the
                  // bundle is computed once per SKU and reused across setState
                  // rebuilds instead of recomputed every time.
                  final data = _cardCatalogDataFor(prod);
                  final spec = data.spec;
                  final price = data.price;
                  final compat = data.compat;
                  final finder = data.finder;
                  final kit = data.kit;
                  final variants = data.variants;
                  // Roadmap step 95 — expert/simple depth toggle (persisted).
                  final expert =
                      ref.watch(cardDetailModeProvider) == CardDetailMode.expert;
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CfgText(
                              'catalog.detail.dataHeader',
                              '📦 נתוני קטלוג',
                              style: TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Roadmap step 30 — card data readiness score
                            // (polish E — colorised by band 🟢/🟡/🔴).
                            Builder(builder: (_) {
                              final s = data.readiness;
                              final c = scoreBandColors(s.score);
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: c.bg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: c.border),
                                ),
                                child: Text('ציון ${s.score} · ${s.label}',
                                    style: TextStyle(
                                        color: c.fg,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700)),
                              );
                            }),
                            const Spacer(),
                            // Roadmap step 52 — project mode chip (tap cycles).
                            Builder(builder: (_) {
                              final m = ref.watch(projectModeProvider);
                              final l = labelForProjectMode(m);
                              return Tooltip(
                                message:
                                    'סוג פרויקט · טאפ למחזר: כל פרויקט / מערכת קרה / מערכת חמה / מסחרי',
                                child: Semantics(
                                button: true,
                                label: 'החלף סוג פרויקט (קר/חם/מסחרי)',
                                child: GestureDetector(
                                onTap: () => ref
                                    .read(projectModeProvider.notifier)
                                    .set(nextProjectMode(m)),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.only(end: 6),
                                  child: Text('${l.emoji}${l.label}',
                                      style: const TextStyle(
                                          color: Color(0xFF6B7280),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700)),
                                ),
                              ),
                              ),
                              );
                            }),
                            // Roadmap step 57 — profession mode chip (tap cycles).
                            Builder(builder: (_) {
                              final prof = ref.watch(professionModeProvider);
                              final l = labelForProfession(prof);
                              return Tooltip(
                                message:
                                    'רמת משתמש · טאפ למחזר: DIY (חובב) / קבלן / מקצועי. רמת ההסבר מתאימה עצמה.',
                                child: Semantics(
                                button: true,
                                label: 'החלף סוג משתמש (DIY/קבלן/מקצועי)',
                                child: GestureDetector(
                                onTap: () => ref
                                    .read(professionModeProvider.notifier)
                                    .set(nextProfessionMode(prof)),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.only(end: 6),
                                  child: Text('${l.emoji}${l.label}',
                                      style: const TextStyle(
                                          color: Color(0xFF6B7280),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700)),
                                ),
                              ),
                              ),
                              );
                            }),
                            // Roadmap step 47 — save this config (favourite).
                            Builder(builder: (_) {
                              ref.watch(savedConfigsProvider);
                              final saved = ref
                                  .read(savedConfigsProvider.notifier)
                                  .isSaved(p.key, brand.name);
                              return Tooltip(
                                message: saved
                                    ? 'תצורה שמורה — טאפ להסיר ממועדפים'
                                    : 'שמור את התצורה הזו (מותג נוכחי) כמועדפת',
                                child: Semantics(
                                button: true,
                                label: 'שמור תצורה כמועדף',
                                child: GestureDetector(
                                  onTap: () => ref
                                      .read(savedConfigsProvider.notifier)
                                      .toggle(p.key, brand.name),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.only(end: 8),
                                    child: Text(saved ? '★ נשמר' : '☆ שמור',
                                        style: TextStyle(
                                            color: saved
                                                ? const Color(0xFFD97706)
                                                : const Color(0xFF999999),
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                ),
                                ),
                              );
                            }),
                            // Roadmap step 48 — copy a shareable price quote.
                            Tooltip(
                              message:
                                  'העתק הצעת מחיר לזיכרון — מחיר + מק"ט + מותג, מוכן ל-WhatsApp',
                              child: GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(
                                      text:
                                          quoteTextFor(p, _selectedBrand)));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('הצעת המחיר הועתקה'),
                                        duration: Duration(seconds: 2)),
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsetsDirectional.only(end: 8),
                                  child: const CfgText(
                                    'catalog.action.proposal',
                                    '📋 הצעה',
                                    style: TextStyle(
                                      color: Color(0xFF0F766E),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // #ai-quote-polish — when AI is live, turn the raw
                            // quote into a professional customer message (every
                            // number preserved). gateway null → not in the tree
                            // → demo byte-identical.
                            Builder(builder: (context) {
                              if (ref.watch(claudeGatewayProvider) == null) {
                                return const SizedBox.shrink();
                              }
                              return Tooltip(
                                message:
                                    'נסח הצעה מקצועית עם AI — מוכן לשליחה ללקוח',
                                // a11y (swarm): expose a button role to a11y.
                                child: Semantics(
                                  button: true,
                                  label: 'נסח הצעה מקצועית',
                                  child: GestureDetector(
                                    onTap: () => Navigator.of(context).push(
                                        QuotePolishScreen.route(
                                            rawQuote: quoteTextFor(
                                                p, _selectedBrand),
                                            productName: p.name)),
                                    child: const Padding(
                                      padding:
                                          EdgeInsetsDirectional.only(end: 8),
                                      child: const CfgText(
                                        'catalog.action.draft',
                                        '✨ נסח',
                                        style: TextStyle(
                                          color: Color(0xFF6D28D9),
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                            Tooltip(
                              message: expert
                                  ? 'מצב מורחב — מציג את כל המפרט. טאפ לפישוט.'
                                  : 'מצב פשוט — מסתיר פרטים הנדסיים. טאפ להרחבה.',
                              child: Semantics(
                                button: true,
                                label: 'החלף מצב הצגה (מורחב או פשוט)',
                                child: GestureDetector(
                                  onTap: () => ref
                                      .read(cardDetailModeProvider.notifier)
                                      .toggle(),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: expert
                                          ? BsTokens.brand.withAlpha(28)
                                          : const Color(0xFFEEEEEE),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                        expert ? 'מצב מורחב ▾' : 'מצב פשוט ▸',
                                        style: TextStyle(
                                            color: expert
                                                ? BsTokens.brand
                                                : const Color(0xFF777777),
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Roadmap step 59 — one-line card summary.
                        Text(smartCardSummaryHe(p, brand),
                            style: const TextStyle(
                                color: Color(0xFF444444),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600)),
                        // Roadmap step 67 — discovery tags.
                        Builder(builder: (_) {
                          final tags = discoveryTagsFor(p, brand);
                          if (tags.isEmpty) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                for (final t in tags)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Text(t,
                                        style: const TextStyle(
                                            color: Color(0xFF475569),
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700)),
                                  ),
                              ],
                            ),
                          );
                        }),
                        // Roadmap step 24 — system safety note (always shown).
                        Builder(builder: (_) {
                          final note = systemSafetyNoteHe(prod);
                          if (note == null) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(note,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Color(0xFF1D4ED8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          );
                        }),
                        // Roadmap step 29 — physical-connection warning.
                        Builder(builder: (context) {
                          final warn = connectionWarningHe(prod);
                          if (warn == null) return const SizedBox.shrink();
                          final aiOn =
                              ref.watch(claudeGatewayProvider) != null;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(warn,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Color(0xFFB91C1C),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700)),
                                // #ai-adapter-explain — when AI is live, explain
                                // which adapter bridges the gap (grounded on the
                                // part's REAL verified ends). gateway null → not
                                // in the tree → byte-identical demo.
                                if (aiOn)
                                  // a11y (swarm): expose a button role to a11y.
                                  Semantics(
                                    button: true,
                                    label: 'הסבר איזה מתאם מגשר',
                                    child: GestureDetector(
                                      onTap: () => Navigator.of(context).push(
                                          AdapterExplainScreen.route(
                                              productName: prod.nameHe,
                                              sku: prod.sku)),
                                      child: const Padding(
                                        padding: EdgeInsets.only(top: 4),
                                        child: const CfgText(
                                          'catalog.action.howToBridge',
                                          '🔌 איך לגשר?',
                                          style: TextStyle(
                                            color: Color(0xFF1D4ED8),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                        // Roadmap step 28 — "your line so far": how this product
                        // fits what's already in the cart.
                        Builder(builder: (_) {
                          final cart = ref.watch(smartCartProvider);
                          if (cart.isEmpty) return const SizedBox.shrink();
                          // T6.3: catalog↔smart bridge via the repository.
                          final repo = ref.read(catalogRepositoryProvider);
                          final lineProducts = <LipskeyCatalogProduct>[];
                          for (final line in cart) {
                            final csp = repo.smartProductByKey(line.productKey);
                            if (csp == null) continue;
                            SmartBrand? cb;
                            for (final b in csp.brands) {
                              if (b.name == line.brandName) {
                                cb = b;
                                break;
                              }
                            }
                            final cprod = cb == null
                                ? null
                                : repo.productForBrand(cb);
                            if (cprod != null) lineProducts.add(cprod);
                          }
                          final fit = lineFitFor(prod, lineProducts);
                          // Roadmap step 27 — suggest a bridging adapter when
                          // this product doesn't directly mate the line.
                          final adapter = fit.connects > 0
                              ? null
                              : adapterSuggestionFor(prod, lineProducts);
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '🧩 בקו שלך: ${cart.length} פריטים · '
                                    '${fit.connects > 0 ? "מתחבר ל-${fit.connects} מהם" : "אין חיבור ישיר לפריטי הקו"}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: fit.connects > 0
                                            ? const Color(0xFF0F766E)
                                            : const Color(0xFF9A3412),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700)),
                                if (adapter != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                        '🔌 מתאם מומלץ: ${adapter.nameHe}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Color(0xFF1D4ED8),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600)),
                                  ),
                              ],
                            ),
                          );
                        }),
                        // Roadmap step 26 — hot-water suitability across brands;
                        // tap-cycles the preview temperature (60 → 80 → 95 → 60).
                        if (expert)
                          Builder(builder: (_) {
                            final tempC = ref.watch(displayTempProvider);
                            final hw = hotWaterSuitabilityFor(p, tempC: tempC);
                            if (hw.total < 2) return const SizedBox.shrink();
                            final allOk = hw.suitable == hw.total;
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Tooltip(
                                message:
                                    'בורר טמפ׳ תצוגה · טאפ למחזר: 60°C → 80°C → 95°C → 60°C. משפיע על "מותגים מתאימים".',
                                child: Semantics(
                                button: true,
                                label: 'החלף טמפ׳ תצוגה (60/80/95)',
                                child: GestureDetector(
                                onTap: () => ref
                                    .read(displayTempProvider.notifier)
                                    .state = cycleDisplayTemp(tempC),
                                child: Text(
                                    '🌡 מים חמים (${hw.tempC}°C): '
                                    '${hw.suitable}/${hw.total} מותגים מתאימים  ↻',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: allOk
                                            ? const Color(0xFF0F766E)
                                            : const Color(0xFFB45309),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                              ),
                              ),
                              ),
                            );
                          }),
                        const SizedBox(height: 6),
                        if (spec != null) ...[
                          catRow('חומר', spec.material),
                          if (spec.pressureRating != null)
                            catRow('לחץ', spec.pressureRating!),
                          catRow('טמפ׳ מרבית',
                              '${spec.maxTempC.toStringAsFixed(0)}°C'),
                          catRow('מערכת', spec.waterSystem),
                          if (expert && spec.endsSummary.isNotEmpty)
                            catRow('קצוות', spec.endsSummary),
                          if (expert && spec.minBoreMm != null)
                            catRow('קוטר מינ׳',
                                '${spec.minBoreMm!.toStringAsFixed(0)}mm'),
                        ],
                        // Roadmap step 15 — durability rating (heuristic stars).
                        if (expert)
                          Builder(builder: (_) {
                            final d = durabilityRatingFor(prod);
                            if (d == null) return const SizedBox.shrink();
                            final stars = '★' * d.stars + '☆' * (5 - d.stars);
                            return catRow('עמידות', '$stars · ${d.reason}');
                          }),
                        if (expert && finder != null)
                          // finder.emoji is a plumbing glyph canvaskit can't
                          // draw (empty box) — show just the label (I1-fu).
                          catRow('מאתר', finder.label),
                        if (expert && kit != null)
                          catRow('ערכת התקנה',
                              '${kit.must} חובה · ${kit.optional} אופ׳ · ${kit.tools} כלים'),
                        // Roadmap step 34 — install time + difficulty.
                        if (expert)
                          Builder(builder: (_) {
                            final eff = installEffortFor(prod);
                            if (eff == null) return const SizedBox.shrink();
                            return catRow('התקנה',
                                '~${eff.minutes} דק׳ · ${eff.difficulty}');
                          }),
                        if (expert && variants > 1)
                          catRow('וריאנטים', '$variants גרסאות'),
                        // Roadmap step 20 — manufacturer + part number.
                        if (expert)
                          Builder(builder: (_) {
                            final mi = manufacturerInfoFor(prod);
                            if (mi == null) return const SizedBox.shrink();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                catRow('יצרן', mi.manufacturer),
                                catRow('מק"ט יצרן', mi.partNumber),
                              ],
                            );
                          }),
                        if (price != null)
                          catRow('מחיר משוער', '~₪${groupThousands(price)}'),
                        // Roadmap step 45 — cheaper standard-comparable brand.
                        Builder(builder: (_) {
                          final alt = cheaperAlternativeBrand(p, _selectedBrand);
                          if (alt == null) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                                '💰 חלופה זולה יותר: ${alt.name} (~₪${groupThousands(alt.price)})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Color(0xFF15803D),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          );
                        }),
                        // Roadmap step 42 — estimated line cost breakdown.
                        if (expert)
                          Builder(builder: (_) {
                            final c =
                                lineCostEstimateFor(p, _selectedBrand);
                            if (c == null) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                  '🧮 עלות קו משוערת: ~₪${groupThousands(c.total)}  '
                                  '(מוצר ₪${groupThousands(c.product)} · אביזרים ₪${groupThousands(c.accessories)} · עבודה ₪${groupThousands(c.labour)})',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Color(0xFF334155),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600)),
                            );
                          }),
                        if (compat.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text('🔗 מתחבר ל-${compat.length} מוצרים',
                              style: const TextStyle(
                                  color: Color(0xFF0F766E),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                          for (final h in compat.take(3))
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                '· ${h.nameHe} — ${connectionExplainHe(prod, h)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Color(0xFF888888), fontSize: 11),
                              ),
                            ),
                          // Roadmap step 56 — data-driven "frequently paired".
                          if (expert)
                            Builder(builder: (_) {
                              final types = frequentlyPairedTypesFor(prod);
                              if (types.isEmpty) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                    'מוצרים משלימים נפוצים: ${types.join(" · ")}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Color(0xFF6D28D9),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                              );
                            }),
                          // Roadmap step 23 — inline materialized chain when a
                          // line is in progress (cart not empty).
                          Builder(builder: (_) {
                            final line = _resolveCartProducts();
                            if (line.isEmpty) return const SizedBox.shrink();
                            final plan = buildInstallation([...line, prod],
                                tempC: 60);
                            final text = chainArrowText(plan.items);
                            if (text.isEmpty) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text('🔗 שרשרת: $text',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Color(0xFF475569),
                                      fontSize: 10.5,
                                      height: 1.3)),
                            );
                          }),
                          // Roadmap step 22 — "build my line" → materialized BOM.
                          const SizedBox(height: 8),
                          Semantics(
                            button: true,
                            label: 'פתח קו פריטים מומחש',
                            child: GestureDetector(
                              onTap: () => _showLineBom(prod),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: BsTokens.brand.withAlpha(24),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: BsTokens.brand.withAlpha(90)),
                                ),
                                child: const CfgText(
                                  'catalog.action.buildBom',
                                  '🔧 בנה לי קו (BOM)',
                                  style: TextStyle(
                                    color: BsTokens.brand,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Roadmap step 25 — engine-derived auto safety kit.
                          if (expert)
                            Builder(builder: (_) {
                              final line = _resolveCartProducts();
                              // Pick anchors: cart+prod, else prod + top compat
                              // partner (so a single product still has a
                              // meaningful line for the engine).
                              final anchors = line.isNotEmpty
                                  ? <LipskeyCatalogProduct>[...line, prod]
                                  : (compat.isEmpty
                                      ? <LipskeyCatalogProduct>[prod]
                                      : <LipskeyCatalogProduct>[
                                          prod,
                                          compat.first,
                                        ]);
                              if (anchors.length < 2) return const SizedBox.shrink();
                              final withT = buildInstallation(anchors,
                                  autoCompliance: true, tempC: 60);
                              final withF = buildInstallation(anchors,
                                  autoCompliance: false, tempC: 60);
                              final kit = safetyKitItems(withT.items, withF.items);
                              if (kit.isEmpty) return const SizedBox.shrink();
                              // Roadmap step 30 (line-level) — readiness score
                              // computed from the same plans we just built.
                              final lineScore = lineReadinessFromCounts(
                                  gapCount: withT.gaps.length,
                                  safetyKitSize: kit.length);
                              // Roadmap step 24 — ΔP inline estimate for this line.
                              final pd = estimatePressureDrop(withT.items);
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '🎯 ציון קו ${lineScore.score} · ${lineScore.label}  ·  💧 ΔP ~${pd.dropBar.toStringAsFixed(2)} bar',
                                        style: TextStyle(
                                            // Polish E — unified band palette
                                            // (≥75 emerald · 50–74 amber · <50 rose).
                                            color: scoreBandColors(
                                                    lineScore.score)
                                                .fg,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700)),
                                    Text(
                                        '🛡 ערכת בטיחות (auto): ${kit.map((p) => p.nameHe).take(4).join(" · ")}',
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Color(0xFFB45309),
                                            fontSize: 10.5,
                                            height: 1.3,
                                            fontWeight: FontWeight.w600)),
                                    // Roadmap step 46 — add line + safety to cart.
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Semantics(
                                        button: true,
                                        label:
                                            'הוסף את הקו לסל כולל פריטי בטיחות',
                                        child: GestureDetector(
                                        onTap: () {
                                          final selectedAcc = <SmartCartAcc>[
                                            for (var i = 0;
                                                i < p.acc.length;
                                                i++)
                                              if (_accSelected[i] ?? false)
                                                SmartCartAcc(
                                                    name: p.acc[i].name,
                                                    emoji: p.acc[i].emoji,
                                                    price: p.acc[i].price ?? 0,
                                                    qty: _accQty[i] ?? 1),
                                          ];
                                          final safetyAcc =
                                              buildSafetyAccessories(
                                                  kit,
                                                  (cp) =>
                                                      priceFor(cp) ?? 0);
                                          ref
                                              .read(smartCartProvider.notifier)
                                              .add(SmartCartLine(
                                                productKey: p.key,
                                                productName: p.name,
                                                productEmoji: p.emoji,
                                                brandName: brand.name,
                                                brandPrice: brand.price ??
                                                    (priceFor(prod) ?? 0),
                                                productQty: 1,
                                                accessories: [
                                                  ...selectedAcc,
                                                  ...safetyAcc,
                                                ],
                                              ));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      'הקו נוסף לסל (+${kit.length} פריטי בטיחות)'),
                                                  duration: const Duration(
                                                      seconds: 2)));
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 7),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF3C7),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color:
                                                    const Color(0xFFFCD34D)),
                                          ),
                                          child: const Text(
                                              '🛒 + בטיחות לסל',
                                              style: TextStyle(
                                                  color: Color(0xFFB45309),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700)),
                                        ),
                                      ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                        // Roadmap steps 71/72/74 — assign to a project.
                        Builder(builder: (_) {
                          const proj = 'הפרויקט שלי';
                          final loc = data.finder?.label ?? 'כללי';
                          ProjectItem mk(String l) => ProjectItem(
                              project: proj,
                              location: l,
                              productKey: p.key,
                              brandName: brand.name,
                              sku: prod.sku);
                          ref.watch(cardProjectsProvider);
                          final notifier =
                              ref.read(cardProjectsProvider.notifier);
                          final inProj = notifier.forProject(proj);
                          final units =
                              inProj.fold<int>(0, (s, e) => s + e.qty);
                          final locs = {for (final e in inProj) e.location}.length;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Semantics(
                                    button: true,
                                    label: 'הוסף את המוצר לפרויקט',
                                    child: GestureDetector(
                                    onTap: () {
                                      notifier.add(mk(loc));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  'נוסף ל"$proj" · $loc'),
                                              duration:
                                                  const Duration(seconds: 2)));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEF2FF),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: const Color(0xFFC7D2FE)),
                                      ),
                                      child: const CfgText(
                                        'catalog.action.addToProject',
                                        '➕ הוסף לפרויקט',
                                        style: TextStyle(
                                          color: Color(0xFF4338CA),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      notifier.addToLocations(
                                          mk(loc), ['חדר 1', 'חדר 2', 'חדר 3']);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content:
                                                  Text('נוסף ל-3 חדרים'),
                                              duration: Duration(seconds: 2)));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: const Text('×3 חדרים',
                                          style: TextStyle(
                                              color: Color(0xFF475569),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                  ),
                                ],
                              ),
                              // Roadmap step 80 — ready project templates.
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    const CfgText(
                                      'catalog.templates.label',
                                      'תבניות:',
                                      style: TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    for (final t in projectTemplates())
                                      GestureDetector(
                                        onTap: () {
                                          notifier.applyTemplate(
                                              proj, t.name, t.products);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      'הוחלה תבנית "${t.name}" (${t.products.length} פריטים)'),
                                                  duration: const Duration(
                                                      seconds: 2)));
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 9, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFDF4FF),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: const Color(0xFFF0ABFC)),
                                          ),
                                          child: Text('🧩 ${t.name}',
                                              style: const TextStyle(
                                                  color: Color(0xFF86198F),
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w700)),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (units > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                      '📋 בפרויקט "$proj": $units יחידות · $locs מיקומים',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Color(0xFF4338CA),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600)),
                                ),
                              // Roadmap step 74 — full project BOM dialog.
                              if (units > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: GestureDetector(
                                    onTap: () => _showProjectBom(proj),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0E7FF),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                            color: const Color(0xFFA5B4FC)),
                                      ),
                                      child: const Text(
                                          '📋 BOM פרויקט מלא',
                                          style: TextStyle(
                                              color: Color(0xFF3730A3),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                  ),
                                ),
                              // Roadmap step 75 — customer quote for the project.
                              if (units > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(
                                          text: projectQuoteText(
                                              proj, inProj)));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'הצעת מחיר לפרויקט הועתקה'),
                                              duration: Duration(seconds: 2)));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECFDF5),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                            color: const Color(0xFFA7F3D0)),
                                      ),
                                      child: const Text(
                                          '📋 הצעת מחיר לפרויקט',
                                          style: TextStyle(
                                              color: Color(0xFF047857),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }),
                        // Roadmap step 19 — auto compliance/safety triggers.
                        Builder(builder: (_) {
                          final triggers = complianceTriggersFor(prod);
                          if (triggers.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              const CfgText(
                                'catalog.detail.requiredStandards',
                                'תקינות נדרשת',
                                style: TextStyle(
                                  color: Color(0xFF888888),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              for (final t in triggers) ...[
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text('${t.label} — ${t.reason}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Color(0xFFB45309),
                                          fontSize: 11)),
                                ),
                                if (expert && complianceWhyHe(t.label) != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 1, right: 14),
                                    child: Text('↳ ${complianceWhyHe(t.label)}',
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Color(0xFF595959),
                                            fontSize: 10,
                                            height: 1.25)),
                                  ),
                              ],
                            ],
                          );
                        }),
                        // Roadmap step 73 — what the line needs to mate each end.
                        if (expert)
                          Builder(builder: (_) {
                            final needs = connectionNeedsHe(prod);
                            if (needs.isEmpty) return const SizedBox.shrink();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                const CfgText(
                                  'catalog.detail.connectionNeeds',
                                  'מה הקו צריך לחיבור',
                                  style: TextStyle(
                                    color: Color(0xFF888888),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                for (final n in needs)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text('🔩 $n',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Color(0xFF555555),
                                            fontSize: 11)),
                                  ),
                              ],
                            );
                          }),
                        // Roadmap step 38 — end-of-install acceptance checklist.
                        if (expert)
                          Builder(builder: (_) {
                            final checks = acceptanceChecklistFor(prod);
                            if (checks.isEmpty) return const SizedBox.shrink();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                const CfgText(
                                  'catalog.detail.acceptanceCheck',
                                  'בדיקת קבלה (סיום התקנה)',
                                  style: TextStyle(
                                    color: Color(0xFF888888),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                for (final c in checks)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(c,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Color(0xFF0F766E),
                                            fontSize: 11)),
                                  ),
                              ],
                            );
                          }),
                        // Roadmap step 12 — relevant Israeli standards (ת"י).
                        if (expert)
                          Builder(builder: (_) {
                          final stds = israeliStandardsFor(prod);
                          if (stds.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              const CfgText(
                                'catalog.detail.israeliStandard',
                                'תקן ישראלי רלוונטי',
                                style: TextStyle(
                                  color: Color(0xFF888888),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              for (final s in stds)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text('📋 ${s.code} — ${s.scope}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Color(0xFF0F766E),
                                          fontSize: 11)),
                                ),
                            ],
                          );
                        }),
                        // Roadmap step 33 — required tools (derived from ends).
                        if (expert)
                          Builder(builder: (_) {
                          final tools = installToolsFor(prod);
                          if (tools.isEmpty) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: catRow('כלי עבודה', tools.join(' · ')),
                          );
                        }),
                        // Roadmap step 35 — common mistakes + tips.
                        if (expert)
                          Builder(builder: (_) {
                            final tips = installTipsFor(prod);
                            if (tips.isEmpty) return const SizedBox.shrink();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                const CfgText(
                                  'catalog.detail.commonMistakes',
                                  'טעויות נפוצות וטיפים',
                                  style: TextStyle(
                                    color: Color(0xFF888888),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                for (final t in tips)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(t,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Color(0xFF7C2D12),
                                            fontSize: 10.5,
                                            height: 1.25)),
                                  ),
                              ],
                            );
                          }),
                        // Roadmap step 63 — variant family ("גרסאות נוספות").
                        if (expert)
                          Builder(builder: (_) {
                          final fam = variantSiblingsOf(prod)
                              .where((q) => q.sku != prod.sku)
                              .toList();
                          if (fam.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text('גרסאות נוספות במשפחה (${fam.length})',
                                  style: const TextStyle(
                                      color: Color(0xFF888888),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                              for (final q in fam.take(4))
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text('· ${q.nameHe}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Color(0xFF888888),
                                          fontSize: 11)),
                                ),
                            ],
                          );
                        }),
                        // Roadmap step 76 — config versioning (save+compare).
                        if (expert)
                          Builder(builder: (_) {
                            ref.watch(cardVersionsProvider);
                            final notif =
                                ref.read(cardVersionsProvider.notifier);
                            final versions = notif.forProduct(p.key);
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Semantics(
                                        button: true,
                                        label: 'שמור גרסת תצורה',
                                        child: GestureDetector(
                                        onTap: () {
                                          notif.save(
                                              label: brand.name,
                                              productKey: p.key,
                                              brandName: brand.name);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      'נשמר: "${brand.name}"'),
                                                  duration: const Duration(
                                                      seconds: 2)));
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF5F3FF),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color:
                                                    const Color(0xFFC4B5FD)),
                                          ),
                                          child: const CfgText(
                                            'catalog.action.saveVersion',
                                            '💾 שמור גרסה',
                                            style: TextStyle(
                                              color: Color(0xFF5B21B6),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (versions.isNotEmpty)
                                        Text('${versions.length} גרסאות',
                                            style: const TextStyle(
                                                color: Color(0xFF6D28D9),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  if (versions.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          // Polish G — each saved version is
                                          // now a [load][×] pair: tap the
                                          // label to switch to that brand,
                                          // tap × to delete it. Closes the
                                          // missing UI for step 76.
                                          for (final v in versions)
                                            _SavedVersionChip(
                                              label: v.label,
                                              onLoad: () {
                                                final idx = widget
                                                    .product.brands
                                                    .indexWhere((b) =>
                                                        b.name == v.brandName);
                                                if (idx >= 0) {
                                                  setState(() =>
                                                      _selectedBrand = idx);
                                                  ref
                                                      .read(
                                                          cardSelectionProvider
                                                              .notifier)
                                                      .setBrand(p.key,
                                                          v.brandName);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                              'נטען: "${v.label}"'),
                                                          duration:
                                                              const Duration(
                                                                  seconds: 2)));
                                                }
                                              },
                                              onDelete: () => notif.remove(v.id),
                                            ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                        // Roadmap step 16 — "when to pick which" brand guide.
                        if (expert)
                          Builder(builder: (_) {
                          final guide = brandDecisionGuide(p);
                          if (guide.length < 2) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              const CfgText(
                                'catalog.detail.brandGuide',
                                'מתי לבחור איזה מותג',
                                style: TextStyle(
                                  color: Color(0xFF888888),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              for (final g in guide)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text('• ${g.brand}: ${g.advice}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Color(0xFF666666),
                                          fontSize: 11)),
                                ),
                            ],
                          );
                        }),
                        // Roadmap step 66 — recently-viewed history.
                        if (expert)
                          Builder(builder: (_) {
                          final recent = ref
                              .watch(recentlyViewedProvider)
                              .where((s) => s != prod.sku)
                              .take(5)
                              .toList();
                          if (recent.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              const CfgText(
                                'catalog.detail.recentlyViewed',
                                'נצפו לאחרונה',
                                style: TextStyle(
                                  color: Color(0xFF888888),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              for (final sku in recent)
                                Builder(builder: (_) {
                                  // T6.3: SKU→catalog lookup via the repository.
                                  final rp = ref
                                      .read(catalogRepositoryProvider)
                                      .productForSku(sku);
                                  if (rp == null) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text('🕘 ${rp.nameHe}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Color(0xFF888888),
                                            fontSize: 11)),
                                  );
                                }),
                            ],
                          );
                        }),
                      ],
                    ),
                  );
                }),

                // Must accessories
                if (mustItems.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 8),
                    child: Text(
                      '⚡ פריטי חובה',
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ...List.generate(mustItems.length, (i) {
                    final a = mustItems[i];
                    final gi = p.acc.indexOf(a);
                    return _AccRow(
                      acc: a,
                      selected: _accSelected[gi] ?? false,
                      qty: _accQty[gi] ?? 1,
                      onToggle: (v) {
                        setState(() => _accSelected[gi] = v);
                        // Roadmap step 7 — persist acc selection.
                        ref
                            .read(cardAccStateProvider.notifier)
                            .setSelected(p.key, a.name, v);
                      },
                      onQtyChanged: (q) {
                        setState(() => _accQty[gi] = q);
                        // Roadmap step 7 — persist acc qty.
                        ref
                            .read(cardAccStateProvider.notifier)
                            .setQty(p.key, a.name, q);
                      },
                      activeMatch: _activeStage != null
                          ? p.stages[_activeStage!].match
                          : null,
                    );
                  }),
                ],

                // Optional accessories
                if (optItems.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 8),
                    child: Text(
                      '💡 פריטים אופציונליים',
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ...List.generate(optItems.length, (i) {
                    final a = optItems[i];
                    final gi = p.acc.indexOf(a);
                    return _AccRow(
                      acc: a,
                      selected: _accSelected[gi] ?? false,
                      qty: _accQty[gi] ?? 1,
                      onToggle: (v) {
                        setState(() => _accSelected[gi] = v);
                        // Roadmap step 7 — persist acc selection.
                        ref
                            .read(cardAccStateProvider.notifier)
                            .setSelected(p.key, a.name, v);
                      },
                      onQtyChanged: (q) {
                        setState(() => _accQty[gi] = q);
                        // Roadmap step 7 — persist acc qty.
                        ref
                            .read(cardAccStateProvider.notifier)
                            .setQty(p.key, a.name, q);
                      },
                      activeMatch: _activeStage != null
                          ? p.stages[_activeStage!].match
                          : null,
                    );
                  }),
                ],

                // CTA
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: BsTokens.brand,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final selectedAcc = <SmartCartAcc>[
                        for (var i = 0; i < p.acc.length; i++)
                          if (_accSelected[i] ?? false)
                            SmartCartAcc(
                              name: p.acc[i].name,
                              emoji: p.acc[i].emoji,
                              price: p.acc[i].price ?? 0,
                              qty: _accQty[i] ?? 1,
                            ),
                      ];
                      ref.read(smartCartProvider.notifier).add(
                            SmartCartLine(
                              productKey: p.key,
                              productName: p.name,
                              productEmoji: p.emoji,
                              brandName: brand.name,
                              brandPrice: brand.price ?? 0,
                              productQty: 1,
                              accessories: selectedAcc,
                            ),
                          );
                      // Studio Pillar-3 · step 93 — add_to_cart intel (additive ·
                      // single statement · tap handler, not build → byte-identical).
                      ref.read(intelBusProvider).track(IntelEvents.addToCart,
                          props: <String, String>{'sku': p.key});
                      Navigator.pop(context);
                      showToast(context,
                          '${p.name} · ${brand.name} (+${selectedAcc.length} אביזרים) נוסף לסל 🛒');
                    },
                    child: Text(
                      'הוסף לסל · ₪${groupThousands(_total)}',
                      style: TextStyle(
                        color: bsOnAccent(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Matching accessories that "explode" in as chips when a stage is tapped.
class _ExplodeChips extends ConsumerStatefulWidget {
  const _ExplodeChips({super.key, required this.items});
  final List<SmartAcc> items;

  @override
  ConsumerState<_ExplodeChips> createState() => _ExplodeChipsState();
}

class _ExplodeChipsState extends ConsumerState<_ExplodeChips>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    final n = widget.items.length;
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250 + n * 70),
    );
    _anims = List.generate(n, (i) {
      final start = (i * 0.12).clamp(0.0, 0.7);
      return CurvedAnimation(
        parent: _ctrl,
        curve: Interval(start, (start + 0.5).clamp(0.0, 1.0),
            curve: Curves.elasticOut),
      );
    });
    if (ref.read(catalogSettingsProvider).reducedMotion) {
      _ctrl.value = 1;
    } else {
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var i = 0; i < widget.items.length; i++)
            ScaleTransition(
              scale: _anims[i],
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: BsTokens.brand.withAlpha(28),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: BsTokens.brand, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.items[i].emoji,
                        style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 5),
                    Text(
                      widget.items[i].name,
                      style: const TextStyle(
                        color: BsTokens.brand,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Installation diagram with staggered pop-in animation ─────────────────
// Mirrors the prototype's tdiagram — gradient card, 4 stages, amber title dot.
// Each stage pops in 180 ms after the previous (elasticOut spring).

class _DiagramFlow extends ConsumerStatefulWidget {
  const _DiagramFlow({
    required this.product,
    this.activeStage,
    this.onStageTap,
  });
  final SmartProduct product;
  final int? activeStage;
  final void Function(int)? onStageTap;

  @override
  ConsumerState<_DiagramFlow> createState() => _DiagramFlowState();
}

class _DiagramFlowState extends ConsumerState<_DiagramFlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    final n = widget.product.stages.length;
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + n * 180),
    );
    _anims = List.generate(n, (i) {
      final start = i * 0.18;
      final end = (start + 0.55).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _ctrl,
        curve: Interval(start, end, curve: Curves.elasticOut),
      );
    });
    if (ref.read(catalogSettingsProvider).reducedMotion) {
      _ctrl.value = 1;
    } else {
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    if (p.stages.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 4),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE6E6EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFF2A516),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  p.diagramTitle,
                  style: const TextStyle(
                    color: Color(0xFF9B9DA0),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < p.stages.length; i++) ...[
                if (i > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Icon(
                      Icons.chevron_left,
                      color: BsTokens.brand,
                      size: 14,
                    ),
                  ),
                Expanded(
                  child: ScaleTransition(
                    scale: _anims[i],
                    child: GestureDetector(
                      onTap: () => widget.onStageTap?.call(i),
                      child: _StageCard(
                        stage: p.stages[i],
                        active: widget.activeStage == i,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          // Hint line — mirrors prototype td-stage-hint
          const SizedBox(height: 8),
          if (widget.activeStage != null)
            Text(
              '⤵ האביזרים לשלב "${p.stages[widget.activeStage!].label}" — הקש שוב לביטול',
              style: const TextStyle(
                color: Color(0xFFF2A516),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            )
          else
            const Text(
              '💡 הקש על שלב כדי להדגיש את האביזרים שלו',
              style: TextStyle(
                color: Color(0xFF888888),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({required this.stage, this.active = false});
  final SmartStage stage;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final isActive = active;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFF2A516).withAlpha(50)
                  : stage.isFinal
                      ? const Color(0xFF1F6F6B).withAlpha(40)
                      : Colors.black.withAlpha(8),
              border: Border.all(
                color: isActive
                    ? const Color(0xFFF2A516)
                    : stage.isFinal
                        ? BsTokens.brand
                        : Colors.black.withAlpha(28),
                width: isActive ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isActive
                  ? [BoxShadow(color: const Color(0xFFF2A516).withAlpha(77), blurRadius: 8, spreadRadius: 1)]
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(stage.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(height: 7),
          Text(
            stage.label,
            style: TextStyle(
              color: isActive ? const Color(0xFFF2A516) : BsTokens.inkLight,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          const SizedBox(height: 2),
          Text(
            stage.sub,
            style: const TextStyle(color: Color(0xFF8B8D8F), fontSize: 8),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _AccRow extends StatelessWidget {
  const _AccRow({
    required this.acc,
    required this.selected,
    required this.qty,
    required this.onQtyChanged,
    this.onToggle,
    this.activeMatch,
  });

  final SmartAcc acc;
  final bool selected;
  final int qty;
  final ValueChanged<bool>? onToggle; // null = must item (always on)
  final ValueChanged<int> onQtyChanged;
  final List<String>? activeMatch;

  bool get _isHit =>
      activeMatch == null || activeMatch!.any((m) => acc.name.contains(m));

  @override
  Widget build(BuildContext context) {
    final hit = _isHit;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: activeMatch == null ? 1.0 : (hit ? 1.0 : 0.3),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: hit && activeMatch != null
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFF2A516).withAlpha(115),
                  width: 1.5,
                ),
              )
            : null,
        padding: hit && activeMatch != null
            ? const EdgeInsets.all(6)
            : EdgeInsets.zero,
        child: Row(
          children: [
            // Checkbox / lock — ≥48dp tap target around the 24dp box (a11y);
            // the visible square stays 24dp.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onToggle?.call(!selected),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: selected
                          ? BsTokens.brand
                          : const Color(0xFFEDEDED),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: selected
                            ? BsTokens.brand
                            : const Color(0xFFC8C8CE),
                      ),
                    ),
                    child: selected
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 13)
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 2),
            // Emoji + selected badge
            SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child:
                        Text(acc.emoji, style: const TextStyle(fontSize: 16)),
                  ),
                  if (selected)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFFFFFF),
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Name + why
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          acc.name,
                          style: const TextStyle(
                            color: BsTokens.inkLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: 'מידע על האביזר',
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _showAccInfo(context, acc),
                          // ≥48dp tap target around the small ⓘ (a11y),
                          // without enlarging the visible glyph.
                          child: const SizedBox(
                            width: 48,
                            height: 48,
                            child: Center(
                              child: Icon(
                                Icons.info_outline,
                                color: BsTokens.brand,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    acc.why,
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Price + mini stepper
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  acc.price != null
                      ? '₪${groupThousands(acc.price! * qty)}'
                      : 'לפי ספק',
                  style: TextStyle(
                    color: selected
                        ? BsTokens.brand
                        : const Color(0xFF666666),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _MiniQtyBtn(
                        icon: Icons.remove,
                        onTap: qty > 1
                            ? () => onQtyChanged(qty - 1)
                            : null,
                      ),
                      SizedBox(
                        width: 22,
                        child: Text(
                          '$qty',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: BsTokens.inkLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _MiniQtyBtn(
                        icon: Icons.add,
                        onTap: () => onQtyChanged(qty + 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniQtyBtn extends StatelessWidget {
  const _MiniQtyBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: icon == Icons.add ? 'הוסף כמות' : 'הפחת כמות',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        // ≥48dp tap target (a11y) — the visible +/- glyph stays 12dp; only
        // the hit area (and the grey pill) grows.
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Icon(
              icon,
              size: 12,
              color: onTap != null
                  ? Colors.black54
                  : const Color(0xFFCCCCCC),
            ),
          ),
        ),
      ),
    );
  }
}

void _showAccInfo(BuildContext context, SmartAcc acc) {
  showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: const Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(acc.emoji,
                        style: const TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          acc.name,
                          style: const TextStyle(
                            color: BsTokens.inkLight,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: acc.must
                                ? const Color(0xFFF2A516).withAlpha(50)
                                : const Color(0xFFEDEDED),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            acc.must ? '⚡ פריט חובה' : '💡 אופציונלי',
                            style: TextStyle(
                              color: acc.must
                                  ? const Color(0xFFB57B00)
                                  : const Color(0xFF666666),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'למה צריך:',
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                acc.why,
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: BsTokens.brand.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Text(
                      'מחיר ליחידה:',
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '₪${groupThousands(acc.price!)}',
                      style: const TextStyle(
                        color: BsTokens.brand,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // A11Y-M2: AlignmentDirectional.centerStart is RTL-correct
              // (maps to right edge in RTL layouts, left in LTR).
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'סגור',
                    style: TextStyle(color: BsTokens.brand, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ── מועדפים section ──────────────────────────────────────────────────────────

class _FavoritesSection extends ConsumerWidget {
  const _FavoritesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favSkus = ref.watch(productFavoritesProvider);
    if (favSkus.isEmpty) {
      return const _EmptySection(emoji: '⭐', label: 'מועדפים');
    }
    // Scope favorites to the active water system (Benzi #1, option 2).
    // T6.3: catalog read via the repository (same const data).
    final products = filterBySystem(
        ref
            .watch(catalogRepositoryProvider)
            .allProducts()
            .where((p) => favSkus.contains(p.sku))
            .toList(),
        ref.watch(catalogSystemFilterProvider));
    return Column(
      children: [
        Container(
          color: BsTokens.inkLight,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              const Text('⭐',
                  style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Text('${products.length} מועדפים',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: products.length,
            itemBuilder: (_, i) => _FavProductRow(product: products[i]),
          ),
        ),
      ],
    );
  }
}

class _FavProductRow extends ConsumerWidget {
  const _FavProductRow({required this.product});
  final LipskeyCatalogProduct product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: product.imageAsset != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: productImage(product.imageAsset!,
                  width: 48, height: 48, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Text(product.typeEmoji,
                      style: const TextStyle(fontSize: 30))),
            )
          : Text(product.typeEmoji,
              style: const TextStyle(fontSize: 30)),
      title: Text(product.nameHe,
          style: const TextStyle(
              color: BsTokens.inkLight, fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(product.brand,
          style: const TextStyle(color: BsTokens.mutedLight, fontSize: 11)),
      onTap: () => showLipskeyProductSheet(
          context,
          product,
          // T6.3: catalog read via the repository (same const data).
          ref
              .read(catalogRepositoryProvider)
              .allProducts()
              .where((p) => p.categoryHe == product.categoryHe)
              .toList()),
    );
  }
}

// ── חיפושים אחרונים section ───────────────────────────────────────────────────

class _RecentSearchesSection extends ConsumerWidget {
  const _RecentSearchesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(recentSearchesProvider);
    if (items.isEmpty) {
      return const _EmptySection(emoji: '🕐', label: 'חיפושים אחרונים');
    }
    return Column(
      children: [
        Container(
          color: BsTokens.inkLight,
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${items.length} חיפושים אחרונים',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              TextButton(
                onPressed: () async {
                  final ok = await confirmDestructive(
                    context,
                    title: 'ניקוי כל החיפושים?',
                    message: 'כל היסטוריית החיפושים תימחק.',
                    confirmLabel: 'נקה הכל',
                  );
                  if (!ok || !context.mounted) return;
                  ref.read(recentSearchesProvider.notifier).clear();
                },
                child: const CfgText(
                  'catalog.search.clearAll',
                  'נקה הכל',
                  style: TextStyle(color: BsTokens.brand, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(
                height: 1, indent: 56, color: Color(0xFFEEEEEE)),
            itemBuilder: (_, i) {
              final q = items[i];
              return ListTile(
                leading: const Icon(Icons.history,
                    color: Color(0xFF9AA3B2), size: 20),
                title: Text(q,
                    style: const TextStyle(
                        color: BsTokens.inkLight, fontSize: 14)),
                trailing: IconButton(
                  tooltip: 'הסר',
                  icon: const Icon(Icons.close,
                      color: Color(0xFF9AA3B2), size: 18),
                  onPressed: () =>
                      ref.read(recentSearchesProvider.notifier).remove(q),
                ),
                onTap: () =>
                    LipskeyProductsScreen.openWordSearch(context, q),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Variants section ───────────────────────────────────────────────────────
final variantsKindFilterProvider = StateProvider<AttrKind?>((_) => null);
final variantsValueFilterProvider = StateProvider<Set<String>>((_) => <String>{});
final variantsSizePatternProvider = StateProvider<Set<String>>((_) => <String>{});
final variantsSizeDiameterProvider = StateProvider<Set<String>>((_) => <String>{});
final variantsSizeSystemProvider = StateProvider<Set<String>>((_) => <String>{});
final variantsSizeGenderProvider = StateProvider<Set<String>>((_) => <String>{});
final variantsValuesExpandedProvider = StateProvider<bool>((_) => false);
final variantsActiveFamilyProvider = StateProvider<VariantFamily?>((_) => null);

/// 4th-level: which sub-group is open under קוטר / מבנה (null = none).
final variantsActiveSubGroupProvider = StateProvider<String?>((_) => null);

// pattern → structural pattern (A/A×A/A×B×A...) — was מבנה, NOW labelled סוג
// diameter → combined diameter + length atoms — labelled קוטר/אורך
// system → product type (זווית/טי/מאסף/מצמד...) — was סוג, NOW labelled מבנה
// gender → stays מין
enum SizeSortAxis { pattern, diameter, system, gender }
const Map<SizeSortAxis, String> kSizeSortLabel = {
  SizeSortAxis.system: 'מבנה',
  SizeSortAxis.pattern: 'סוג',
  SizeSortAxis.diameter: 'קוטר/אורך',
  SizeSortAxis.gender: 'מין',
};
final variantsSizeSortAxisProvider =
    StateProvider<SizeSortAxis>((_) => SizeSortAxis.pattern);

bool sizePassesFacets(String value, {
  required Set<String> patterns,
  required Set<String> diameters,
  required Set<String> systems,
}) {
  if (patterns.isNotEmpty && !patterns.contains(sizeStructurePattern(value))) return false;
  if (diameters.isNotEmpty && !sizeDiameterAtoms(value).any(diameters.contains)) return false;
  if (systems.isNotEmpty && !systems.contains(sizeSystem(value))) return false;
  return true;
}

class _VariantsSection extends ConsumerWidget {
  const _VariantsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(variantsActiveFamilyProvider);
    if (active != null) return _VariantFamilyView(family: active);
    final kindFilter = ref.watch(variantsKindFilterProvider);
    final valueFilter = ref.watch(variantsValueFilterProvider);
    final sizePatterns = ref.watch(variantsSizePatternProvider);
    final sizeDiameters = ref.watch(variantsSizeDiameterProvider);
    final sizeSystems = ref.watch(variantsSizeSystemProvider);
    final sizeGenders = ref.watch(variantsSizeGenderProvider);
    var families = familiesByKind(kindFilter);
    if (kindFilter != null && valueFilter.isNotEmpty) {
      families = families
          .where((f) => f.products.any((p) => valueFilter.contains(variantValue(p, kindFilter))))
          .toList();
    }
    if (kindFilter == AttrKind.size &&
        (sizePatterns.isNotEmpty || sizeDiameters.isNotEmpty || sizeSystems.isNotEmpty || sizeGenders.isNotEmpty)) {
      // Decompose composite diameter selections "MATERIAL|ATOM"
      final plainDiameters = <String>{};
      final materialDiameters = <String, Set<String>>{};
      for (final v in sizeDiameters) {
        final idx = v.indexOf('|');
        if (idx > 0) {
          final mat = v.substring(0, idx);
          final atom = v.substring(idx + 1);
          materialDiameters.putIfAbsent(mat, () => <String>{}).add(atom);
        } else {
          plainDiameters.add(v);
        }
      }
      families = families.where((f) => f.products.any((p) {
        // pattern + system facets
        final v = variantValue(p, AttrKind.size);
        if (sizePatterns.isNotEmpty && !sizePatterns.contains(sizeStructurePattern(v))) return false;
        if (sizeSystems.isNotEmpty &&
            !sizeSystems.contains(p.productType ?? '(לא מסווג)')) return false;
        if (sizeGenders.isNotEmpty && !sizeGenders.contains(genderPattern(p.nameHe))) return false;
        // Diameter filter — either plain atoms OR material-scoped atoms
        if (plainDiameters.isNotEmpty || materialDiameters.isNotEmpty) {
          final atoms = sizeDiameterAtoms(v);
          final mat = productMaterial(p);
          final plainOk = plainDiameters.isNotEmpty && atoms.any(plainDiameters.contains);
          final matOk = materialDiameters[mat] != null &&
              atoms.any(materialDiameters[mat]!.contains);
          if (!plainOk && !matOk) return false;
        }
        return true;
      })).toList();
    }
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          color: cs.surface,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              children: [
                for (final k in AttrKind.values) ...[
                  _KindChip(kind: k, label: '${kAttrKindEmoji[k]} ${kAttrKindLabel[k]}', count: familiesByKind(k).length),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),
        ),
        // Size sort axis row — always visible when size selected (3rd level)
        if (kindFilter == AttrKind.size)
          Container(
            color: cs.surface,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            width: double.infinity,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: const _SizeSortAxisRow(),
            ),
          ),
        // Values (4th level) — only visible when explicitly expanded
        if (kindFilter != null && ref.watch(variantsValuesExpandedProvider))
          Container(
            color: cs.surface,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            width: double.infinity,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (kindFilter == AttrKind.size) const _ActiveSizeFacetRow(),
                  if (kindFilter != AttrKind.size)
                    for (final group in valueSubGroupsForKind(kindFilter)) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 0,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          for (int i = 0; i < group.length; i++) ...[
                            if (i > 0)
                              const Padding(padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Text('—', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.w700, fontSize: 13))),
                            _ValueChip(value: group[i].$1, label: group[i].$1, count: group[i].$2),
                          ],
                        ],
                      ),
                    ],
                ],
              ),
            ),
          ),
        Container(
          color: cs.onSurface.withOpacity(0.04),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          width: double.infinity,
          child: Text('${families.length} משפחות וריאנטים',
              textAlign: TextAlign.right,
              style: TextStyle(color: cs.onSurface.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: families.isEmpty
              ? const Center(child: Text('אין משפחות וריאנטים'))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: families.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: cs.outline.withOpacity(0.15)),
                  itemBuilder: (_, i) => _FamilyRow(family: families[i]),
                ),
        ),
      ],
    );
  }
}

class _KindChip extends ConsumerWidget {
  const _KindChip({required this.kind, required this.label, required this.count});
  final AttrKind? kind;
  final String label;
  final int count;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(variantsKindFilterProvider) == kind;
    return InkWell(
      onTap: () {
        final wasActive = ref.read(variantsKindFilterProvider.notifier).state == kind;
        if (wasActive) {
          final exp = ref.read(variantsValuesExpandedProvider.notifier);
          exp.state = !exp.state;
          return;
        }
        ref.read(variantsKindFilterProvider.notifier).state = kind;
        ref.read(variantsValueFilterProvider.notifier).state = <String>{};
        ref.read(variantsSizePatternProvider.notifier).state = <String>{};
        ref.read(variantsSizeDiameterProvider.notifier).state = <String>{};
        ref.read(variantsSizeSystemProvider.notifier).state = <String>{};
        ref.read(variantsSizeGenderProvider.notifier).state = <String>{};
        ref.read(variantsValuesExpandedProvider.notifier).state = false;
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF7A18) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? const Color(0xFFFF7A18) : Theme.of(context).colorScheme.outline.withOpacity(0.35), width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(color: selected ? bsOnAccent(context) : Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(color: selected ? Colors.white.withOpacity(0.25) : const Color(0x14FF7A18), borderRadius: BorderRadius.circular(10)),
              child: Text('$count', style: TextStyle(color: selected ? bsOnAccent(context) : const Color(0xFFCC6614), fontWeight: FontWeight.w700, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SizeSortAxisRow extends ConsumerWidget {
  const _SizeSortAxisRow();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(variantsSizeSortAxisProvider);
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 6, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Padding(padding: const EdgeInsets.only(left: 2, right: 2), child: Text('מיון לפי:', style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontWeight: FontWeight.w700, fontSize: 12))),
        for (final axis in SizeSortAxis.values)
          _AxisChip(
            label: kSizeSortLabel[axis]!,
            isSelected: active == axis,
            onTap: () {
              final wasActive = active == axis;
              ref.read(variantsSizeSortAxisProvider.notifier).state = axis;
              ref.read(variantsActiveSubGroupProvider.notifier).state = null;
              final exp = ref.read(variantsValuesExpandedProvider.notifier);
              exp.state = wasActive ? !exp.state : true;
            },
          ),
      ],
    );
  }
}

class _AxisChip extends StatelessWidget {
  const _AxisChip({required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF7A18) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? const Color(0xFFFF7A18) : cs.outline.withOpacity(0.35), width: 1.2),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? bsOnAccent(context) : cs.onSurface, fontWeight: FontWeight.w700, fontSize: 12)),
      ),
    );
  }
}

class _ActiveSizeFacetRow extends ConsumerWidget {
  const _ActiveSizeFacetRow();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final axis = ref.watch(variantsSizeSortAxisProvider);
    switch (axis) {
      case SizeSortAxis.pattern:
        return _SubGroupBrowser(
          subGroups: _patternSubGroups(),
          subGroupLabel: _patternOutletLabel,
          provider: variantsSizePatternProvider,
        );
      case SizeSortAxis.diameter:
        return _MaterialDiameterBrowser();
      case SizeSortAxis.system:
        return _SizeFacetRow(label: '', items: _systemCounts(), provider: variantsSizeSystemProvider);
      case SizeSortAxis.gender:
        return _SizeFacetRow(label: '', items: _genderCounts(), provider: variantsSizeGenderProvider);
    }
  }
}

/// Two-level browser for קוטר: top row shows materials (HDPE/נחושת/PVC/...),
/// click a material to see only the diameter atoms used by products of that
/// material.
class _MaterialDiameterBrowser extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(variantsActiveSubGroupProvider);
    final selected = ref.watch(variantsSizeDiameterProvider);

    // Build material → (atom → count) for products in size families.
    final perMat = <String, Map<String, int>>{};
    for (final fam in familiesByKind(AttrKind.size)) {
      for (final p in fam.products) {
        final mat = productMaterial(p);
        final byAtom = perMat.putIfAbsent(mat, () => <String, int>{});
        for (final a in sizeDiameterAtoms(variantValue(p, AttrKind.size))) {
          byAtom[a] = (byAtom[a] ?? 0) + 1;
        }
      }
    }
    final materials = perMat.entries.toList()
      ..sort((a, b) {
        final ta = a.value.values.fold<int>(0, (s, v) => s + v);
        final tb = b.value.values.fold<int>(0, (s, v) => s + v);
        return tb.compareTo(ta);
      });

    void toggleAtom(String material, String a) {
      final key = '$material|$a';
      final next = {...selected};
      if (next.contains(key)) {
        next.remove(key);
      } else {
        next.add(key);
      }
      ref.read(variantsSizeDiameterProvider.notifier).state = next;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top row: material buttons
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            for (final m in materials)
              _AxisChip(
                label: '${m.key}  ${m.value.values.fold<int>(0, (s, v) => s + v)}',
                isSelected: active == m.key,
                onTap: () => ref
                    .read(variantsActiveSubGroupProvider.notifier)
                    .state = active == m.key ? null : m.key,
              ),
          ],
        ),
        // Below: diameter atoms for the active material
        if (active != null && perMat[active] != null) ...[
          const SizedBox(height: 6),
          () {
            // L13-A: hoist sort once — used for both .length and item access.
            final sorted = perMat[active]!.entries.toList()
              ..sort((a, b) =>
                  _diameterSortKey(a.key).compareTo(_diameterSortKey(b.key)));
            return Wrap(
              spacing: 0,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (int i = 0; i < sorted.length; i++) ...[
                  if (i > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3),
                      child: Text('—',
                          style: TextStyle(
                              color: Color(0xFF8A8A8A),
                              fontWeight: FontWeight.w700,
                              fontSize: 12)),
                    ),
                  () {
                    final e = sorted[i];
                    final key = '$active|${e.key}';
                    return Padding(
                      padding: const EdgeInsetsDirectional.only(start: 4),
                      child: _FacetChip(
                        label: e.key,
                        count: e.value,
                        isSelected: selected.contains(key),
                        onTap: () => toggleAtom(active, e.key),
                      ),
                    );
                  }(),
                ],
              ],
            );
          }(),
        ],
      ],
    );
  }
}

/// Maps a pattern value to its outlet-group label for the 4th level.
String _patternOutletLabel(String pattern) {
  switch (_patternOutlets(pattern)) {
    case 1: return '1 יציאה';
    case 2: return '2 יציאות';
    case 3: return '3 יציאות';
    default: return 'אחר';
  }
}

/// Two-level browser: sub-group buttons first; click a sub-group to see its
/// values inline. Used for קוטר (תבריג/HDPE/DN) and מבנה (1/2/3 outlets).
class _SubGroupBrowser extends ConsumerWidget {
  const _SubGroupBrowser({
    required this.subGroups,
    required this.subGroupLabel,
    required this.provider,
  });
  final List<List<(String value, int count)>> subGroups;
  /// Called with one of the values in the group to derive the group's label.
  final String Function(String) subGroupLabel;
  final StateProvider<Set<String>> provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(variantsActiveSubGroupProvider);
    final selected = ref.watch(provider);
    void toggleValue(String v) {
      final next = {...selected};
      if (next.contains(v)) {
        next.remove(v);
      } else {
        next.add(v);
      }
      ref.read(provider.notifier).state = next;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Row of sub-group buttons (4th level chips)
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            for (final group in subGroups)
              () {
                if (group.isEmpty) return const SizedBox.shrink();
                final label = subGroupLabel(group.first.$1);
                final total = group.fold<int>(0, (s, e) => s + e.$2);
                final isActive = active == label;
                return _AxisChip(
                  label: '$label  $total',
                  isSelected: isActive,
                  onTap: () => ref.read(variantsActiveSubGroupProvider.notifier).state =
                      isActive ? null : label,
                );
              }(),
          ],
        ),
        // Values of the active sub-group (5th level, hidden until sub-group chosen)
        if (active != null)
          ...subGroups.where((g) => g.isNotEmpty && subGroupLabel(g.first.$1) == active).map(
            (group) => Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Wrap(
                spacing: 0,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (int i = 0; i < group.length; i++) ...[
                    if (i > 0)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: Text('—', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 4),
                      child: _FacetChip(
                        label: group[i].$1,
                        count: group[i].$2,
                        isSelected: selected.contains(group[i].$1),
                        onTap: () => toggleValue(group[i].$1),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

List<(String value, int count)> _patternCounts() {
  final freq = <String, int>{};
  for (final fam in familiesByKind(AttrKind.size)) {
    for (final p in fam.products) {
      final v = variantValue(p, AttrKind.size);
      if (v.isEmpty) continue;
      final k = sizeStructurePattern(v);
      freq[k] = (freq[k] ?? 0) + 1;
    }
  }
  final out = freq.entries.map((e) => (e.key, e.value)).toList()..sort((a, b) => b.$2.compareTo(a.$2));
  return out;
}

/// Counts of distinct PRODUCT TYPES in size families. Used under axis "מבנה"
/// (renamed) so the user sees זווית/טי/מאסף/... instead of the old system.
List<(String value, int count)> _systemCounts() {
  final freq = <String, int>{};
  for (final fam in familiesByKind(AttrKind.size)) {
    final t = fam.products.first.productType ?? '(לא מסווג)';
    freq[t] = (freq[t] ?? 0) + fam.products.length;
  }
  final out = freq.entries.map((e) => (e.key, e.value)).toList()..sort((a, b) => b.$2.compareTo(a.$2));
  return out;
}

List<(String value, int count)> _genderCounts() {
  final freq = <String, int>{};
  for (final fam in familiesByKind(AttrKind.size)) {
    for (final p in fam.products) {
      final k = genderPattern(p.nameHe);
      freq[k] = (freq[k] ?? 0) + 1;
    }
  }
  const order = ['ז.ז', 'נ.נ', 'ז.נ', 'ז', 'נ', '—'];
  final out = <(String, int)>[];
  for (final k in order) { if (freq[k] != null) out.add((k, freq[k]!)); }
  return out;
}

int _patternOutlets(String p) {
  if (p == '1') return 1;
  if (p == 'A×A' || p == 'A×B') return 2;
  if (p.startsWith('A×A×') || p.startsWith('A×B×')) return 3;
  return 9;
}

List<List<(String value, int count)>> _patternSubGroups() {
  final all = _patternCounts();
  final by = <int, List<(String, int)>>{};
  for (final e in all) { by.putIfAbsent(_patternOutlets(e.$1), () => []).add(e); }
  final keys = by.keys.toList()..sort();
  return [for (final k in keys) by[k]!];
}

double _diameterSortKey(String atom) {
  final m = RegExp(r'\d+(?:\.\d+)?').firstMatch(atom);
  if (m == null) return 9999;
  return double.tryParse(m.group(0)!) ?? 9999;
}

class _SizeFacetRow extends ConsumerWidget {
  const _SizeFacetRow({required this.label, required this.items, required this.provider});
  final String label;
  final List<(String value, int count)> items;
  final StateProvider<Set<String>> provider;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(provider);
    final cs = Theme.of(context).colorScheme;
    void toggle(String v) {
      final next = {...selected};
      if (next.contains(v)) { next.remove(v); } else { next.add(v); }
      ref.read(provider.notifier).state = next;
    }
    final groups = [items];
    return Wrap(
      spacing: 0, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (label.isNotEmpty)
          Padding(padding: const EdgeInsets.only(left: 2, right: 2), child: Text('$label:', style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontWeight: FontWeight.w700, fontSize: 12))),
        for (int gi = 0; gi < groups.length; gi++) ...[
          if (gi > 0)
            const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('|', style: TextStyle(color: Color(0xFFBBBBBB), fontWeight: FontWeight.w700, fontSize: 12))),
          for (int i = 0; i < groups[gi].length; i++) ...[
            if (i > 0)
              const Padding(padding: EdgeInsets.symmetric(horizontal: 3), child: Text('—', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.w700, fontSize: 12))),
            Padding(padding: const EdgeInsetsDirectional.only(start: 4), child: _FacetChip(label: groups[gi][i].$1, count: groups[gi][i].$2, isSelected: selected.contains(groups[gi][i].$1), onTap: () => toggle(groups[gi][i].$1))),
          ],
        ],
      ],
    );
  }
}

class _FacetChip extends StatelessWidget {
  const _FacetChip({required this.label, required this.count, required this.isSelected, required this.onTap});
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x22FF7A18) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFFFF7A18) : cs.outline.withOpacity(0.25), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(color: isSelected ? const Color(0xFFCC6614) : cs.onSurface.withOpacity(0.8), fontWeight: FontWeight.w600, fontSize: 11)),
            const SizedBox(width: 3),
            Text('$count', style: TextStyle(color: cs.onSurface.withOpacity(0.45), fontWeight: FontWeight.w600, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

class _ValueChip extends ConsumerWidget {
  const _ValueChip({required this.value, required this.label, required this.count});
  final String? value;
  final String label;
  final int count;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(variantsValueFilterProvider);
    final selected = value == null ? filter.isEmpty : filter.contains(value);
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        final n = ref.read(variantsValueFilterProvider.notifier);
        if (value == null) { n.state = <String>{}; return; }
        final next = {...filter};
        if (next.contains(value)) { next.remove(value); } else { next.add(value!); }
        n.state = next;
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? const Color(0x22FF7A18) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? const Color(0xFFFF7A18) : cs.outline.withOpacity(0.25), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(color: selected ? const Color(0xFFCC6614) : cs.onSurface.withOpacity(0.8), fontWeight: FontWeight.w600, fontSize: 12)),
            const SizedBox(width: 4),
            Text('$count', style: TextStyle(color: cs.onSurface.withOpacity(0.45), fontWeight: FontWeight.w600, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _FamilyRow extends ConsumerWidget {
  const _FamilyRow({required this.family});
  final VariantFamily family;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => ref.read(variantsActiveFamilyProvider.notifier).state = family,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: const Color(0x22FF7A18), borderRadius: BorderRadius.circular(10)),
              child: Text('${family.count}', style: const TextStyle(color: Color(0xFFCC6614), fontWeight: FontWeight.w800, fontSize: 12)),
            ),
            const Spacer(),
            // A11Y-H2: Flexible prevents RenderFlex overflow on long frame names.
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${family.emoji}  ${family.frame}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text('${family.categoryHe} · ${family.brand}', style: TextStyle(color: cs.onSurface.withOpacity(0.55), fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_left, size: 18, color: cs.onSurface.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }
}

class _VariantFamilyView extends ConsumerWidget {
  const _VariantFamilyView({required this.family});
  final VariantFamily family;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          color: cs.surface,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              Tooltip(
                message: 'חזרה',
                child: Semantics(
                  button: true,
                  label: 'חזרה',
                  child: InkWell(
                    onTap: () => ref.read(variantsActiveFamilyProvider.notifier).state = null,
                    // RTL arrow: arrow_back is semantically "go back" and mirrors
                    // correctly in RTL (points right → back in Hebrew layout).
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Center(child: Icon(Icons.arrow_forward, size: 20)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text('${family.emoji}  ${family.frame}', textAlign: TextAlign.right, style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w800, fontSize: 15))),
            ],
          ),
        ),
        Container(
          color: cs.onSurface.withOpacity(0.04),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          width: double.infinity,
          child: Text('${family.count} וריאנטים · ${kAttrKindLabel[family.kind]} שונה · [${family.categoryHe} / ${family.brand}]',
              textAlign: TextAlign.right,
              style: TextStyle(color: cs.onSurface.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        Expanded(child: LipskeyProductsList(products: family.products)),
      ],
    );
  }
}
