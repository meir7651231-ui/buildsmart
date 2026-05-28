import 'package:buildsmart/data/catalog.dart';
import 'package:buildsmart/data/catalog_tree.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/search_index.dart';
import 'package:buildsmart/data/sections.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/data/variant_families.dart';
import 'package:buildsmart/screens/barcode_scanner.dart';
import 'package:buildsmart/screens/lipskey_brand_screen.dart';
import 'package:buildsmart/screens/lipskey_product_sheet.dart';
import 'package:buildsmart/screens/lipskey_products_screen.dart' hide AttrKind;
import 'package:buildsmart/screens/finder_screen.dart';
import 'package:buildsmart/services/voice.dart';
import 'package:buildsmart/screens/install_studio_screen.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/state/product_favorites.dart';
import 'package:buildsmart/state/recent_searches.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the Install Studio as an immersive full-screen route (above the shell).
void _openStudio(BuildContext context) {
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(builder: (_) => const InstallStudioScreen()),
  );
}

/// Active section label — 'הכל' is always first and fixed.
/// Default landing is the בית (finder home) — the least-technical path to a
/// product (group → sub → add, 2–3 taps), so the app opens straight on it.
final catalogSectionProvider = StateProvider<String>((_) => 'בית');

/// Ordered list of user section labels (הכל is NOT stored here).
final catalogSectionsListProvider = StateProvider<List<String>>(
  (_) => ['בית', 'תכנון חיבור', 'חיפושים אחרונים', 'מועדפים', 'קטגוריות', 'עץ חכם', 'וריאנטים'],
);

/// Per-list catalog items: map of section-label → set of catalog category
/// titles included in that list. Lists not present default to empty.
final catalogListItemsProvider =
    StateProvider<Map<String, Set<String>>>((_) => {});

/// True while the search panel is open (search bar focused / has input).
final searchPanelOpenProvider = StateProvider<bool>((_) => false);

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
  final hay =
      _normForSearch('${p.nameHe} ${p.categoryHe} ${p.sku} ${p.color ?? ''}');
  if (hay.contains(q)) return true; // fast path: exact phrase or SKU
  final tokens = q.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
  if (tokens.isEmpty) return false;
  bool hit(String t) {
    if (hay.contains(t)) return true;
    final alts = kSearchSynonyms[t];
    return alts != null && alts.any((a) => hay.contains(_normForSearch(a)));
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
  for (final t in q.split(RegExp(r'\s+')).where((t) => t.isNotEmpty)) {
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

/// Active search scope chip (הכל / מוצרים / קטגוריות / מסכים).
final searchScopeProvider = StateProvider<String>((_) => 'הכל');

/// When true, the search-panel results show only products that have an image
/// (the ⚙️ פילטרים tool · "עם תמונה").
final searchImageOnlyProvider = StateProvider<bool>((_) => false);

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
    final i = kLipskeyCatalog.indexWhere((p) => p.sku == sku);
    if (i >= 0) {
      final product = kLipskeyCatalog[i];
      final siblings = kLipskeyCatalog
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
    final i = kLipskeyCatalog.indexWhere((p) => p.sku == sku);
    if (i >= 0) {
      final p = kLipskeyCatalog[i];
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

/// Sort order for the products listed beneath the drill rows.
enum ProductSort { byOrder, nameAZ, nameZA, sku }

String _productSortLabel(ProductSort s) => switch (s) {
      ProductSort.byOrder => 'ברירת מחדל',
      ProductSort.nameAZ => 'שם א-ת',
      ProductSort.nameZA => 'שם ת-א',
      ProductSort.sku => 'מק"ט',
    };

final catalogProductSortProvider =
    StateProvider<ProductSort>((_) => ProductSort.byOrder);

/// Pure: keep only products that have an image when [imageOnly] is set.
List<LipskeyCatalogProduct> filterByImage(
    List<LipskeyCatalogProduct> list, bool imageOnly) {
  if (!imageOnly) return list;
  return list.where((p) => p.imageAsset != null).toList();
}

List<LipskeyCatalogProduct> _sortProducts(
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
  return kLipskeyCatalog.where((p) => cats.contains(p.categoryHe)).toList();
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

// Simulated metadata — preview text, timestamp, unread badge count.
// Ordered to match kCatalogCats (same index).
const _kMeta = [
  (preview: 'ברז מיקסר + אמבטיה · 12 פריטים חדשים', time: 'עכשיו', badge: 12),
  (preview: 'אסלה תלויה חדשה · 4 פריטים',            time: 'אתמול', badge: 4),
  (preview: 'ערכת מקלחת חדשה × 3',                    time: 'אתמול', badge: 0),
  (preview: 'דוד שמש 150L – מבצע',                    time: '21.5',  badge: 2),
  (preview: 'כיור גרניט 2 אגנים',                      time: '21.5',  badge: 0),
  (preview: 'צינור PVC 110mm – מלאי מוגבל',           time: '20.5',  badge: 0),
  (preview: '3 ספקים עדכנו מחירים',                   time: '20.5',  badge: 3),
  (preview: 'חיבורים לחץ ½″ · מחיר עודכן',           time: '19.5',  badge: 0),
  (preview: 'לבנה בטון 25×25×15 – מבצע שבוע',        time: '19.5',  badge: 0),
  (preview: 'צבע לבן 15L · 2 מותגים',                 time: '18.5',  badge: 0),
  (preview: 'ערכת כלים מקצועית 120 חלקים',            time: '18.5',  badge: 0),
  (preview: 'מערכת השקיה · טפטפות + מחברים',          time: '17.5',  badge: 0),
];

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

    // Force header visible whenever search panel opens.
    ref.listen<bool>(searchPanelOpenProvider, (_, open) {
      if (open) _setHeaderVisible(true);
    });
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

    final searchOpen = ref.watch(searchPanelOpenProvider);
    final showFull = _headerVisible || searchOpen;

    return Column(
      children: [
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: showFull
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [_SearchBar()],
                  )
                : const SizedBox.shrink(),
          ),
        ),
        if (searchOpen)
          const Expanded(child: _SearchPanel())
        else ...[
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: showFull
                  ? const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [_SectionChipsRow()],
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: _handleScrollNotification,
              child: _CatalogBody(scrollCtrl: _scrollCtrl),
            ),
          ),
        ],
      ],
    );
  }
}

class _MiniSearchPill extends StatelessWidget {
  const _MiniSearchPill({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.search, color: Color(0xFF888888), size: 18),
      ),
    );
  }
}

// Horizontal pill tabs — הכל + dynamic user sections + [+] button.
// Short-tap activates the section.
// Long-press on a non-הכל chip shows ניהול/מחיקה popup.
// Plus button opens the management sheet.
class _SectionChipsRow extends ConsumerWidget {
  const _SectionChipsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active   = ref.watch(catalogSectionProvider);
    final sections = ref.watch(catalogSectionsListProvider);

    void activate(String label) =>
        ref.read(catalogSectionProvider.notifier).state = label;

    void deleteSection(String label) {
      final list = List<String>.from(ref.read(catalogSectionsListProvider))
        ..remove(label);
      ref.read(catalogSectionsListProvider.notifier).state = list;
      if (active == label) activate('הכל');
    }

    Future<void> showLongPressMenu(BuildContext ctx, String label) async {
      final w = MediaQuery.of(ctx).size.width;
      final top = MediaQuery.of(ctx).padding.top;
      final choice = await showMenu<String>(
        context: ctx,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        position: RelativeRect.fromLTRB(w * 0.1, top + 140, w * 0.1, 0),
        items: [
          const PopupMenuItem<String>(
            value: 'manage',
            child: Row(
              children: [
                Icon(Icons.list, color: Colors.black54, size: 20),
                SizedBox(width: 12),
                Text(
                  'ניהול רשימות',
                  style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 15),
                ),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'rename',
            child: Row(
              children: [
                Icon(
                  Icons.drive_file_rename_outline,
                  color: Colors.black54,
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  'שינוי שם',
                  style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 15),
                ),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                SizedBox(width: 12),
                Text(
                  'מחיקת רשומה',
                  style: TextStyle(color: Colors.redAccent, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      );
      if (!ctx.mounted) return;
      if (choice == 'manage') _openManageSheet(ctx, ref);
      if (choice == 'rename') {
        final list = ref.read(catalogSectionsListProvider);
        final idx = list.indexOf(label);
        if (idx != -1) _showRenameDialog(ctx, ref, idx, label);
      }
      if (choice == 'delete') deleteSection(label);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // הכל — fixed, no long-press menu
            _SectionPill(
              label: 'הכל',
              active: active == 'הכל',
              onTap: () => activate('הכל'),
            ),
            for (final s in sections) ...[
              const SizedBox(width: 8),
              _SectionPill(
                label: s,
                active: active == s,
                onTap: () => activate(s),
                onLongPress: () => showLongPressMenu(context, s),
              ),
            ],
            const SizedBox(width: 8),
            _AddPill(onTap: () => _openManageSheet(context, ref)),
          ],
        ),
      ),
    );
  }
}

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
  @override
  Widget build(BuildContext context) {
    final sections = ref.watch(catalogSectionsListProvider);

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
                  icon: const Icon(Icons.check, color: Color(0xFF888888)),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'ניהול רשימות',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
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
                return ListTile(
                  key: ValueKey(s),
                  tileColor: const Color(0xFFFFFFFF),
                  // Leading: icon matching section
                  leading: Icon(
                    _sectionIcon(s),
                    color: Colors.black54,
                    size: 22,
                  ),
                  title: Text(
                    s,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'הגדרה מראש',
                    style: TextStyle(color: Color(0xFF888888), fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFF888888),
                          size: 20,
                        ),
                        onPressed: () => _showItemPickerSheet(context, ref, s),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFF888888),
                          size: 20,
                        ),
                        onPressed: () {
                          final list =
                              List<String>.from(
                                ref.read(catalogSectionsListProvider),
                              )..removeAt(i);
                          ref.read(catalogSectionsListProvider.notifier).state =
                              list;
                          if (ref.read(catalogSectionProvider) == s) {
                            ref.read(catalogSectionProvider.notifier).state =
                                'הכל';
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
          style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 16),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Color(0xFF1A1A1A)),
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
    );
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
        style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 16),
      ),
      content: TextField(
        controller: controller,
        autofocus: true,
        style: const TextStyle(color: Color(0xFF1A1A1A)),
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
  );
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
          style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 16),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Color(0xFF1A1A1A)),
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
                            color: Color(0xFF1A1A1A),
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
            child: ListView.builder(
              controller: scrollCtrl,
              itemCount: kCatalogCats.length,
              itemBuilder: (_, i) {
                final cat = kCatalogCats[i];
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
                            color: Color(0xFF1A1A1A),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
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

class _SectionPill extends StatelessWidget {
  const _SectionPill({
    required this.label,
    required this.active,
    required this.onTap,
    this.onLongPress,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? BsTokens.brand : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: active
            ? BorderSide.none
            : const BorderSide(color: Color(0xFFC8C8CE), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFF6E6E73),
              fontSize: 13,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _AddPill extends StatelessWidget {
  const _AddPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFC8C8CE), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Icon(Icons.add, color: Color(0xFF6E6E73), size: 18),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.onTap});

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends ConsumerStatefulWidget {
  const _SearchBar();

  @override
  ConsumerState<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<_SearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(searchQueryProvider));
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      ref.read(searchPanelOpenProvider.notifier).state = true;
    }
  }

  void _closePanel() {
    _focusNode.unfocus();
    ref.read(searchPanelOpenProvider.notifier).state = false;
  }

  void _submit(String value) {
    final q = value.trim();
    if (q.isEmpty) return;
    // Honour the "שמור היסטוריית חיפוש" setting.
    if (!ref.read(catalogSettingsProvider).searchHistoryEnabled) return;
    ref.read(recentSearchesProvider.notifier).add(q);
  }

  @override
  Widget build(BuildContext context) {
    // Keep external query state in sync (e.g. when a recent-search is tapped).
    ref.listen<String>(searchQueryProvider, (_, next) {
      if (next != _controller.text) {
        _controller.text = next;
        _controller.selection =
            TextSelection.collapsed(offset: next.length);
      }
    });

    final open     = ref.watch(searchPanelOpenProvider);
    final hasText  = ref.watch(searchQueryProvider).isNotEmpty;
    final scope    = ref.watch(searchScopeProvider);
    final hasScope = scope != 'הכל';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE7E7EA),
          borderRadius: BorderRadius.circular(24),
          border: open
              ? Border.all(color: BsTokens.brand, width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            // Leading: back arrow when panel open, search icon otherwise.
            if (open)
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF888888),
                  size: 20,
                ),
                onPressed: _closePanel,
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.search, color: Color(0xFF888888), size: 20),
              ),

            // Scope token chip — shown when a non-הכל scope is active.
            if (hasScope) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: BsTokens.brand,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      scope,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () =>
                          ref.read(searchScopeProvider.notifier).state = 'הכל',
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
            ],

            // Text input — expands to fill remaining width.
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textInputAction: TextInputAction.search,
                onChanged: (v) =>
                    ref.read(searchQueryProvider.notifier).state = v,
                onSubmitted: _submit,
                style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 14),
                decoration: InputDecoration(
                  hintText: hasScope
                      ? 'חפש $scope...'
                      : 'חיפוש מוצרים, קטגוריות, מסכים...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            // Clear button — shown when there is text.
            if (hasText)
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Color(0xFF888888),
                  size: 18,
                ),
                onPressed: () {
                  _controller.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchPanel extends ConsumerWidget {
  const _SearchPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query    = ref.watch(searchQueryProvider);
    final scope    = ref.watch(searchScopeProvider);
    final showResults = query.isNotEmpty || scope != 'הכל';
    return Material(
      color: BsTokens.cardLight,
      child: Column(
        children: [
          const _SearchToolsRow(),
          const _SearchScopeRow(),
          const Divider(height: 1, color: Color(0xFFF5F5F5)),
          Expanded(
            child: showResults
                ? const _SearchResultsList()
                : const _RecentSearchesList(),
          ),
        ],
      ),
    );
  }
}

class _SearchToolsRow extends ConsumerWidget {
  const _SearchToolsRow();

  static const _sheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
  );

  // ↕️ מיון — pick a sort for the live product results.
  void _openSortSheet(BuildContext context, WidgetRef ref) {
    final current = ref.read(catalogProductSortProvider);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: _sheetShape,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SheetTitle('מיון מוצרים'),
            for (final s in ProductSort.values)
              ListTile(
                leading: Icon(
                  s == current ? Icons.check : Icons.swap_vert,
                  color:
                      s == current ? BsTokens.brand : const Color(0xFF888888),
                ),
                title: Text(_productSortLabel(s),
                    style: const TextStyle(color: Color(0xFF1A1A1A))),
                onTap: () {
                  ref.read(catalogProductSortProvider.notifier).state = s;
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  // ⚙️ פילטרים — filter the live product results.
  void _openFilterSheet(BuildContext context, WidgetRef ref) {
    final imageOnly = ref.read(searchImageOnlyProvider);
    Widget opt(String label, bool value) => ListTile(
          leading: Icon(
            value == imageOnly ? Icons.check : Icons.radio_button_unchecked,
            color:
                value == imageOnly ? BsTokens.brand : const Color(0xFF888888),
          ),
          title: Text(label, style: const TextStyle(color: Color(0xFF1A1A1A))),
          onTap: () {
            ref.read(searchImageOnlyProvider.notifier).state = value;
            Navigator.pop(context);
          },
        );
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: _sheetShape,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SheetTitle('סינון תוצאות'),
            opt('הכל', false),
            opt('עם תמונה בלבד', true),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SearchToolButton(
            emoji: '🎤',
            label: 'קולי',
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final ok = await VoiceService.instance.listen(
                onFinal: (t) {
                  if (t.isNotEmpty) {
                    messenger.showSnackBar(SnackBar(content: Text(t)));
                  }
                },
              );
              if (!ok) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('הדפדפן לא תומך בחיפוש קולי')),
                );
              }
            },
          ),
          _SearchToolButton(
            emoji: '📷',
            label: 'ברקוד',
            onTap: () => openBarcodeScanner(context),
          ),
          _SearchToolButton(
            emoji: '⚙️',
            label: 'פילטרים',
            onTap: () => _openFilterSheet(context, ref),
          ),
          _SearchToolButton(
            emoji: '↕️',
            label: 'מיון',
            onTap: () => _openSortSheet(context, ref),
          ),
          _SearchToolButton(
            emoji: '▦',
            label: 'קטלוג',
            onTap: () {
              ref.read(searchPanelOpenProvider.notifier).state = false;
              ref.read(catalogSectionProvider.notifier).state = 'קטגוריות';
            },
          ),
        ],
      ),
    );
  }
}

/// Small right-aligned title row for the search tool bottom-sheets.
class _SheetTitle extends StatelessWidget {
  const _SheetTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(text,
              style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
        ),
      );
}

class _SearchToolButton extends StatelessWidget {
  const _SearchToolButton({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchScopeRow extends ConsumerWidget {
  const _SearchScopeRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = ref.watch(searchScopeProvider);
    const scopes = ['הכל', 'מוצרים', 'קטגוריות', 'מסכים'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final s in scopes) ...[
              _SectionPill(
                label: s,
                active: scope == s,
                onTap: () =>
                    ref.read(searchScopeProvider.notifier).state = s,
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecentSearchesList extends ConsumerWidget {
  const _RecentSearchesList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(recentSearchesProvider);
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'התחל להקליד כדי לחפש מוצרים, קטגוריות ומסכים.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF888888), fontSize: 14),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'חיפושים אחרונים',
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () =>
                    ref.read(recentSearchesProvider.notifier).clear(),
                child: const Text(
                  'נקה',
                  style: TextStyle(color: BsTokens.brand, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final q = items[i];
              return ListTile(
                dense: true,
                leading: const Icon(
                  Icons.history,
                  color: Color(0xFF888888),
                  size: 20,
                ),
                title: Text(
                  q,
                  style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 14),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.north_west,
                    color: Color(0xFF888888),
                    size: 18,
                  ),
                  onPressed: () =>
                      ref.read(searchQueryProvider.notifier).state = q,
                ),
                onTap: () =>
                    ref.read(searchQueryProvider.notifier).state = q,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SearchResultsList extends ConsumerWidget {
  const _SearchResultsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final scope = ref.watch(searchScopeProvider);

    final filtered = kSearchIndex.where((e) {
      // When query is empty, skip text matching — show all items in scope.
      if (query.isNotEmpty && !e.matches(query)) return false;
      return switch (scope) {
        'מוצרים'   => e.type == SearchType.category,
        'קטגוריות' => e.type == SearchType.setting || e.type == SearchType.menu,
        'מסכים'    => e.type == SearchType.screen ||
            e.type == SearchType.persona ||
            e.type == SearchType.action,
        _ => true,
      };
    }).toList();

    // Live product matches from the real catalog (name or SKU), shown in
    // "הכל" / "מוצרים" scopes once the user has typed something.
    final showProducts = query.trim().length >= 2 &&
        (scope == 'הכל' || scope == 'מוצרים');
    // Apply the ⚙️ image filter and ↕️ sort (from the search-panel tools)
    // before capping to 40 results.
    final imageOnly = ref.watch(searchImageOnlyProvider);
    final sort = ref.watch(catalogProductSortProvider);
    // AND-match first; if a reasonable query finds nothing (e.g. a stray word
    // the catalogue doesn't use), fall back to matching ANY word so the user
    // never hits a dead end.
    List<LipskeyCatalogProduct> matchProducts() {
      final and = kLipskeyCatalog
          .where((p) => catalogProductMatchesQuery(p, query))
          .toList();
      if (and.isNotEmpty) return and;
      return kLipskeyCatalog
          .where((p) => catalogProductMatchesQuery(p, query, requireAll: false))
          .toList();
    }

    // Default order ranks by relevance (best match first); an explicit
    // ↕️ sort (name/SKU) overrides it.
    List<LipskeyCatalogProduct> orderProducts(List<LipskeyCatalogProduct> ps) {
      if (sort != ProductSort.byOrder) return _sortProducts(ps, sort);
      return [...ps]..sort(
          (a, b) => searchRelevance(b, query).compareTo(searchRelevance(a, query)));
    }

    final products = showProducts
        ? orderProducts(filterByImage(matchProducts(), imageOnly)).take(40).toList()
        : const <LipskeyCatalogProduct>[];

    if (filtered.isEmpty && products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            query.isNotEmpty
                ? 'לא נמצאו תוצאות עבור "$query"'
                : 'אין תוצאות ב$scope',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF888888), fontSize: 14),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length + products.length,
      itemBuilder: (_, i) {
        // Product results come after the index entries.
        if (i >= filtered.length) {
          final p = products[i - filtered.length];
          return ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.center,
              child: p.imageAsset != null
                  ? Image.asset(p.imageAsset!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Text(p.categoryEmoji,
                          style: const TextStyle(fontSize: 20)))
                  : Text(p.categoryEmoji, style: const TextStyle(fontSize: 20)),
            ),
            title: Text(p.nameHe,
                style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 14),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text('${p.categoryHe} · #${p.sku}',
                style: const TextStyle(color: Color(0xFF666666), fontSize: 11),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF1c1409),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('מוצר',
                  style: TextStyle(
                      color: Color(0xFFFF7A18), fontSize: 10,
                      fontWeight: FontWeight.w600)),
            ),
            onTap: () {
              final cat = kLipskeyCatalog
                  .where((x) => x.categoryHe == p.categoryHe)
                  .toList();
              showLipskeyProductSheet(context, p, cat);
            },
          );
        }
        final entry = filtered[i];
        return ListTile(
          leading: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(entry.emoji, style: const TextStyle(fontSize: 20)),
          ),
          title: Text(
            entry.title,
            style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 14),
          ),
          subtitle: entry.breadcrumb.isNotEmpty
              ? Text(
                  entry.breadcrumb,
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 11,
                  ),
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
            ref.read(searchQueryProvider.notifier).state = entry.title;
            if (!ref.read(catalogSettingsProvider).searchHistoryEnabled) return;
            ref.read(recentSearchesProvider.notifier).add(entry.title);
          },
        );
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
    if (active == 'הכל') return _AllOverview(scrollCtrl: scrollCtrl);
    if (active == 'בית') return const FinderScreen();
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
                color: Color(0xFF1A1A1A),
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
    final indices = <int>[
      for (var i = 0; i < kCatalogCats.length; i++)
        if (selected.contains(kCatalogCats[i].title)) i,
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
        return _CatalogRow(cat: kCatalogCats[idx], meta: _kMeta[idx]);
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
              color: Color(0xFF1A1A1A),
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

class _CatalogList extends StatelessWidget {
  const _CatalogList({this.scrollCtrl});
  final ScrollController? scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: scrollCtrl,
      key: const Key('catalog-list'),
      itemCount: kCatalogCats.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        indent: 76,
        color: Color(0xFFF5F5F5),
      ),
      itemBuilder: (context, i) {
        return _CatalogRow(
          cat: kCatalogCats[i],
          meta: _kMeta[i],
        );
      },
    );
  }
}

// ── "הכל" overview — a preview block per section ─────────────────────────────
class _AllOverview extends ConsumerWidget {
  const _AllOverview({this.scrollCtrl});
  final ScrollController? scrollCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void go(String s) =>
        ref.read(catalogSectionProvider.notifier).state = s;

    final recents = ref.watch(recentSearchesProvider);
    final favSkus = ref.watch(productFavoritesProvider);
    final favProducts =
        kLipskeyCatalog.where((p) => favSkus.contains(p.sku)).take(3).toList();

    return ListView(
      controller: scrollCtrl,
      key: const Key('catalog-list'),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // קטגוריות — full list inline (no preview cap, no "הצג הכל").
        _OverviewBlock(
          title: 'קטגוריות',
          count: kCatalogCats.length,
          children: [
            for (var i = 0; i < kCatalogCats.length; i++)
              _CatalogRow(cat: kCatalogCats[i], meta: _kMeta[i]),
          ],
        ),
        // חיפושים אחרונים
        _OverviewBlock(
          title: 'חיפושים אחרונים',
          count: recents.length,
          onShowAll: () => go('חיפושים אחרונים'),
          children: recents.isEmpty
              ? const [_OverviewEmpty('אין חיפושים אחרונים')]
              : [
                  for (final q in recents.take(3))
                    _OverviewRow(
                      icon: Icons.history,
                      label: q,
                      onTap: () {
                        ref.read(searchQueryProvider.notifier).state = q;
                        ref.read(searchPanelOpenProvider.notifier).state = true;
                      },
                    ),
                ],
        ),
        // תאימות
        _OverviewBlock(
          title: 'תכנון חיבור',
          count: kLipskeyCatalog.length,
          onShowAll: () => _openStudio(context),
          children: [
            _OverviewRow(
              icon: Icons.handyman,
              label: 'תכנון חיבור — בחר מה לחבר ונכין רשימת קנייה',
              onTap: () => _openStudio(context),
            ),
          ],
        ),
        // מועדפים
        _OverviewBlock(
          title: 'מועדפים',
          count: favSkus.length,
          onShowAll: () => go('מועדפים'),
          children: favProducts.isEmpty
              ? const [_OverviewEmpty('אין מועדפים עדיין')]
              : [
                  for (final p in favProducts)
                    _OverviewRow(
                      icon: Icons.favorite,
                      label: p.nameHe,
                      onTap: () => go('מועדפים'),
                    ),
                ],
        ),
        // עץ חכם
        _OverviewBlock(
          title: 'עץ חכם',
          count: kSmartTreeCats.length,
          onShowAll: () => go('עץ חכם'),
          isLast: true,
          children: [
            for (var i = 0; i < kSmartTreeCats.length && i < 3; i++)
              _OverviewRow(
                icon: Icons.account_tree_outlined,
                label:
                    '${kSmartTreeCats[i]} · ${smartProductsForCat(kSmartTreeCats[i]).length} מוצרים',
                onTap: () {
                  ref.read(smartTreeCatProvider.notifier).state =
                      kSmartTreeCats[i];
                  go('עץ חכם');
                },
              ),
          ],
        ),
        // ספק מוביל — כרטיס תצוגה של ליפסקי ברקן (קטלוג חיצוני)
        const _LipskeySupplierCard(),
      ],
    );
  }
}

class _OverviewBlock extends StatelessWidget {
  const _OverviewBlock({
    required this.title,
    required this.children,
    this.onShowAll,
    this.count = 0,
    this.isLast = false,
  });
  final String title;
  final int count;
  final VoidCallback? onShowAll;
  final List<Widget> children;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 14, 16, 4),
          child: Row(
            children: [
              const SizedBox(width: 16),
              // Title + count badge fill the space (so the title can ellipsize
              // without stealing room from / mis-centering the "הצג הכל" link).
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 1),
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
              ),
              if (onShowAll != null)
                TextButton(
                  onPressed: onShowAll,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('הצג הכל',
                          style: TextStyle(
                              color: BsTokens.brand,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      Icon(Icons.chevron_left, color: BsTokens.brand, size: 18),
                    ],
                  ),
                ),
            ],
          ),
        ),
        ...children,
        if (!isLast)
          const Divider(height: 1, thickness: 1, color: BsTokens.brand),
      ],
    );
  }
}

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            Icon(icon, color: BsTokens.brand, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 14),
              ),
            ),
            const Icon(Icons.chevron_left, color: Color(0xFFB0B0B8), size: 18),
          ],
        ),
      ),
    );
  }
}

class _OverviewEmpty extends StatelessWidget {
  const _OverviewEmpty(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
        child: Text(text,
            style: const TextStyle(color: Color(0xFF888888), fontSize: 13)),
      );
}

// ── Lipskey supplier card — pinned at top of catalog list ────────────────────
class _LipskeySupplierCard extends StatelessWidget {
  const _LipskeySupplierCard();

  // SKU 217861 — סיפון אמריקאי 1¼" לבן — our showcase product
  static final LipskeyCatalogProduct _showcase =
      kLipskeyCatalog.firstWhere((p) => p.sku == '217861');

  @override
  Widget build(BuildContext context) {
    final p = _showcase;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF0D1B2A), Color(0xFF1A1A2E)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF3D5A80), width: 0.8),
        ),
        child: Column(
          children: [
            // ── header: supplier badge + "כל המוצרים" ────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D5A80).withOpacity(0.25),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF3D5A80), width: 0.7),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🏭', style: TextStyle(fontSize: 13)),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text('ליפסקי ברקן',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Color(0xFF64FFDA),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        LipskeyBrandScreen.route(),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text('כל הקטגוריות',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.black38, fontSize: 12)),
                          ),
                          SizedBox(width: 3),
                          Icon(Icons.chevron_left, color: Colors.white38, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFF3D5A80), indent: 14, endIndent: 14),

            // ── showcase product row ─────────────────────────
            GestureDetector(
              onTap: () {
                final catProducts = kLipskeyCatalog
                    .where((x) => x.categoryHe == p.categoryHe)
                    .toList();
                showLipskeyProductSheet(context, p, catProducts);
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // תמונה
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFF080815),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: p.imageAsset != null
                          ? Image.asset(p.imageAsset!, fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  Center(child: Text(p.categoryEmoji,
                                      style: const TextStyle(fontSize: 32))))
                          : Center(child: Text(p.categoryEmoji,
                              style: const TextStyle(fontSize: 32))),
                    ),
                    const SizedBox(width: 12),

                    // שם + פרטים
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(p.nameHe,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        height: 1.3),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3D5A80).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: const Color(0xFF3D5A80), width: 0.7),
                                ),
                                child: const Text('פרטים',
                                    style: TextStyle(
                                        color: Color(0xFF64FFDA),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text('#${p.sku}',
                              style: const TextStyle(
                                  color: Color(0xFFFFB300),
                                  fontFamily: 'monospace',
                                  fontSize: 11)),
                          const SizedBox(height: 5),
                          Wrap(
                            spacing: 6,
                            children: [
                              if (p.color != null)
                                _InfoChip('🎨 ${p.color!}'),
                              if (p.qtyPack != null)
                                _InfoChip('📦 ${p.qtyPack}'),
                              if (p.qtyPallet != null)
                                _InfoChip('🏗️ ${p.qtyPallet}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label,
            style: const TextStyle(color: Colors.black38, fontSize: 11)),
      );
}

// ── Featured product card — shown at top of main catalog list ────────────────
class _FeaturedProductCard extends ConsumerStatefulWidget {
  const _FeaturedProductCard({required this.product});
  final SmartProduct product;

  @override
  ConsumerState<_FeaturedProductCard> createState() =>
      _FeaturedProductCardState();
}

class _FeaturedProductCardState extends ConsumerState<_FeaturedProductCard> {
  int _qty = 1;
  bool _added = false;

  @override
  Widget build(BuildContext context) {
    final rec = widget.product.recBrand;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: GestureDetector(
        onTap: () =>
            _SmartTreeProductList._openProductSheet(context, widget.product),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1C2B2A), Color(0xFF1A1A2E)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color.fromARGB(90, 31, 111, 107),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ──
              Row(
                children: [
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: BsTokens.brand.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            widget.product.emoji,
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                        if (_added)
                          Positioned(
                            right: -4,
                            bottom: -4,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFFFFFFF),
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
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
                            const SizedBox(width: 8),
                            const Text(
                              'מוצר היום',
                              style: TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          widget.product.cat,
                          style: const TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        rec.price != null ? '₪${rec.price}' : 'מחיר לפי ספק',
                        style: const TextStyle(
                          color: BsTokens.brand,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        'ממותג מומלץ',
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // ── Qty stepper + Add to cart ──
              Row(
                children: [
                  // Stepper
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF252525),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _QtyBtn(
                          icon: Icons.remove,
                          onTap: _qty > 1
                              ? () => setState(() => _qty--)
                              : null,
                        ),
                        SizedBox(
                          width: 36,
                          child: Text(
                            '$_qty',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _QtyBtn(
                          icon: Icons.add,
                          onTap: () => setState(() => _qty++),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Add to cart button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ref.read(smartCartProvider.notifier).add(
                              SmartCartLine(
                                productKey: widget.product.key,
                                productName: widget.product.name,
                                productEmoji: widget.product.emoji,
                                brandName: rec.name,
                                brandPrice: rec.price ?? 0,
                                productQty: _qty,
                                accessories: const [],
                              ),
                            );
                        setState(() => _added = true);
                        showToast(
                          context,
                          '${widget.product.name} × $_qty נוסף לסל 🛒',
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: BsTokens.brand,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          rec.price != null
                              ? 'הוסף לסל · ₪${rec.price! * _qty}'
                              : 'הוסף לסל · לפי ספק',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null ? Colors.white : const Color(0xFF555555),
        ),
      ),
    );
  }
}

CatalogNode? _findCatalogTreeNodeByTitle(String title) {
  for (final n in kCatalogTree) {
    if (n.title == title) return n;
  }
  return null;
}

class _CatalogRow extends ConsumerWidget {
  const _CatalogRow({required this.cat, required this.meta});

  final Section cat;
  final ({String preview, String time, int badge}) meta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasBadge = meta.badge > 0;
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          cat.title,
                          style: const TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        meta.time,
                        style: TextStyle(
                          color: hasBadge
                              ? BsTokens.brand
                              : const Color(0xFF888888),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          meta.preview,
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
                            '${meta.badge}',
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
int _treeNodeCount(CatalogNode node) {
  if (!node.isLeaf) return node.children.length;
  if (node.lipskeyCategory != null) {
    return kLipskeyCatalog
        .where((p) => p.categoryHe == node.lipskeyCategory)
        .length;
  }
  if (node.smartKey != null) {
    return smartProductByKey(node.smartKey!)?.brands.length ?? 0;
  }
  return node.brandIds.length;
}

/// Secondary-line description — child names for a branch, or the
/// product/model/brand summary for a leaf.
String _treeNodeDesc(CatalogNode node) {
  if (!node.isLeaf) {
    return node.children.map((c) => c.title).join(' · ');
  }
  if (node.lipskeyCategory != null) {
    // Preview of what's inside (characterizing words / sample names) rather
    // than a bare product count.
    final prods = kLipskeyCatalog
        .where((p) => p.categoryHe == node.lipskeyCategory)
        .toList();
    final preview = _facetDesc(prods);
    return preview.isNotEmpty
        ? preview
        : '${_treeNodeCount(node)} מוצרים · ליפסקי ברקן';
  }
  if (node.smartKey != null) {
    final p = smartProductByKey(node.smartKey!);
    return p != null ? '${p.brands.length} דגמים זמינים' : 'דגמים';
  }
  return '${node.brandIds.length} מותגים';
}

class _TreeDrill extends ConsumerWidget {
  const _TreeDrill({required this.path});
  final List<CatalogNode> path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = path.last;
    final query = ref.watch(catalogTreeQueryProvider).trim();
    final facetSel = ref.watch(catalogFacetProvider);

    // A leaf that maps to a lipskey category with products drills by facets
    // (curated where defined, else auto-derived) before the product list.
    final leafCat = current.isLeaf ? current.lipskeyCategory : null;
    final isProductLeaf = leafCat != null &&
        kLipskeyCatalog.any((p) => p.categoryHe == leafCat);

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
            kLipskeyCatalog.any((p) => p.categoryHe == n.lipskeyCategory)) {
          resetQuery();
          resetFacets();
          ref.read(catalogTreePathProvider.notifier).state = [...path, n];
          return;
        }
        if (n.smartKey != null) {
          final product = smartProductByKey(n.smartKey!);
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
      final base =
          kLipskeyCatalog.where((p) => p.categoryHe == leafCat).toList();
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
      final rows = query.isEmpty
          ? current.children
          : _searchSubtree(current, query);
      rowWidgets = [
        for (final n in rows)
          _TreeCatRow(node: n, onTap: () => openNode(n)),
      ];
      products = _subtreeProducts(current);
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

    products = _sortProducts(products, ref.watch(catalogProductSortProvider));

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
                          color: Color(0xFF1A1A1A),
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
          if (ref.watch(catalogSettingsProvider).quickFilterBar)
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
                        _productSortLabel(s),
                        style: TextStyle(
                          color: const Color(0xFF1A1A1A),
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
                color: Color(0xFF1A1A1A),
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
              child: const Text(
                'בקרוב',
                style: TextStyle(
                  color: Colors.white,
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
      return Container(
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
            GestureDetector(
              onTap: widget.onCancel,
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ],
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
    final hasText = ref.watch(catalogTreeQueryProvider).isNotEmpty;

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
            icon: const Icon(Icons.arrow_back,
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
              style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 14),
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
  const _TreeCatRow({required this.node, required this.onTap});
  final CatalogNode node;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final count = _treeNodeCount(node);
    final desc = _treeNodeDesc(node);
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
                          color: Color(0xFF1A1A1A),
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
    final cats = kSmartTreeCats;
    return Column(
      children: [
        // מוצר היום — כרטיס מוצר חכם מומלץ (קטלוג פנימי)
        _FeaturedProductCard(product: kSmartProducts.first),
        Expanded(
          child: ListView.separated(
            itemCount: cats.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 76, color: Color(0xFFF5F5F5)),
            itemBuilder: (_, i) {
              final cat = cats[i];
              final prods = smartProductsForCat(cat);
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
                                color: Color(0xFF1A1A1A),
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
    final query = ref.watch(smartTreeQueryProvider).trim();
    final all = smartProductsForCat(widget.cat);
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
                icon: const Icon(Icons.arrow_back,
                    color: Color(0xFF555555), size: 20),
                tooltip: 'חזרה',
                onPressed: _back,
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
                  decoration: BoxDecoration(
                    color: green,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🌳 ', style: TextStyle(fontSize: 13)),
                      Flexible(
                        child: Text(
                          widget.cat,
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
                      GestureDetector(
                        onTap: _back,
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 16),
                      ),
                    ],
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
                  style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 14),
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
                                    color: Color(0xFF1A1A1A),
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

// ── Catalog Drill Section ─────────────────────────────────────────────────────
// Level 1: 11 kCatalogCats grid → Level 2: smartProductsForCat() list → sheet.

class _CatalogDrillSection extends ConsumerWidget {
  const _CatalogDrillSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCat = ref.watch(catalogDrillCatProvider);
    if (selectedCat == null) return const _CatalogDrillCatGrid();
    return _CatalogDrillProductList(cat: selectedCat);
  }
}

class _CatalogDrillCatGrid extends ConsumerWidget {
  const _CatalogDrillCatGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Container(
          color: const Color(0xFFFFFFFF),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: const Row(
            children: [
              Text('▦', style: TextStyle(fontSize: 20)),
              SizedBox(width: 10),
              Text(
                'קטגוריות — בחר תחום',
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFF5F5F5)),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: kCatalogCats.length,
            itemBuilder: (context, i) {
              final cat = kCatalogCats[i];
              final count = smartProductsForCat(cat.title).length;
              return GestureDetector(
                onTap: () =>
                    ref.read(catalogDrillCatProvider.notifier).state = cat.title,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2E),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: const Color(0xFF3A3A4A), width: 0.8),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(cat.emoji,
                          style: const TextStyle(fontSize: 32)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: count > 0
                                  ? const Color(0xFF3D5A80).withOpacity(0.25)
                                  : Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              count > 0 ? '$count פריטים' : 'בקרוב',
                              style: TextStyle(
                                color: count > 0
                                    ? const Color(0xFF64FFDA)
                                    : Colors.white38,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
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

// ── Catalog → Lipskey category mapping ───────────────────────────────────────
const Map<String, List<String>> _kCatalogToLipskeyCats = {
  'ניקוז וצנרת': [
    'מחסומים (סיפונים) גלויים',
    'מחסומי רצפה',
    'מאספים וקולטים',
    'אביזרי שקע-תקע',
    'ברכיים',
    'מסעפים וחיבורי אסלה',
    'מצמדים וצינורות',
    'צינורות',
    'אביזרי תבריג',
  ],
  'אסלות': [
    'התקנה גבוהה',
    'התקנה נמוכה',
    'התקנה צמודה',
    'מושבי אסלה',
    'זקיף אסלה',
  ],
  'מקלחות ואמבטיות': [
    'אמבט ואגנית',
  ],
  'גופי תברואה': [
    'חלקים סניטריים',
  ],
  'אביזרי קצה וחיבורים': [
    'אטמים אומים ופקקים',
  ],
};

class _CatalogDrillProductList extends ConsumerWidget {
  const _CatalogDrillProductList({required this.cat});

  final String cat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final smartProducts = smartProductsForCat(cat);
    final catData = kCatalogCats.firstWhere(
      (c) => c.title == cat,
      orElse: () => kCatalogCats.first,
    );

    // Lipskey sub-categories for this catalog cat
    final lipskeySubCatNames = _kCatalogToLipskeyCats[cat] ?? [];
    final lipskeyGroups = [
      for (final catName in lipskeySubCatNames)
        (
          name: catName,
          products: kLipskeyCatalog
              .where((p) => p.categoryHe == catName)
              .toList(),
        ),
    ].where((g) => g.products.isNotEmpty).toList();

    final isEmpty = smartProducts.isEmpty && lipskeyGroups.isEmpty;

    return Column(
      children: [
        // Breadcrumb header
        Container(
          color: const Color(0xFFFFFFFF),
          padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    color: BsTokens.brand, size: 18),
                onPressed: () =>
                    ref.read(catalogDrillCatProvider.notifier).state = null,
              ),
              Text('${catData.emoji} ', style: const TextStyle(fontSize: 16)),
              Text(
                cat,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFF5F5F5)),
        if (isEmpty)
          const Expanded(
            child: Center(
              child: Text('בקרוב',
                  style: TextStyle(color: Color(0xFF999999), fontSize: 16)),
            ),
          )
        else
          Expanded(
            child: CustomScrollView(
              slivers: [
                // ── SmartTree section ──────────────────────────────────────
                if (smartProducts.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _SectionBanner(
                        emoji: '🌳', label: 'עץ חכם', color: const Color(0xFF1B2D1B)),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final p = smartProducts[i];
                        return Column(
                          children: [
                            InkWell(
                              onTap: () => _openSmartSheet(context, p),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(p.name,
                                                    style: const TextStyle(
                                                      color: Color(0xFF1A1A1A),
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w600,
                                                    )),
                                              ),
                                              Text(
                                                p.recBrand.price != null
                                                    ? '₪${p.recBrand.price}'
                                                    : '—',
                                                style: const TextStyle(
                                                    color: Color(0xFF888888),
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '⚡ ${p.mustCount} פריטי חובה · ${p.acc.length} סה"כ',
                                            style: const TextStyle(
                                                color: Color(0xFF888888),
                                                fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_left,
                                        color: Color(0xFF555555), size: 20),
                                  ],
                                ),
                              ),
                            ),
                            if (i < smartProducts.length - 1)
                              const Divider(
                                  height: 1,
                                  indent: 76,
                                  color: Color(0xFFF5F5F5)),
                          ],
                        );
                      },
                      childCount: smartProducts.length,
                    ),
                  ),
                ],

                // ── Lipskey section ────────────────────────────────────────
                if (lipskeyGroups.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _SectionBanner(
                        emoji: '🏭',
                        label: 'ליפסקי ברקן',
                        color: const Color(0xFF0D1B2A)),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final g = lipskeyGroups[i];
                        return Column(
                          children: [
                            InkWell(
                              onTap: () => Navigator.push(
                                context,
                                LipskeyProductsScreen.route(
                                  category: g.name,
                                  products: g.products,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0D1B2A),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF3D5A80)
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        g.products.first.categoryEmoji,
                                        style:
                                            const TextStyle(fontSize: 22),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(g.name,
                                              style: const TextStyle(
                                                color: Color(0xFF1A1A1A),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              )),
                                          const SizedBox(height: 3),
                                          Text(
                                            '${g.products.length} פריטים · ליפסקי ברקן',
                                            style: const TextStyle(
                                                color: Color(0xFF64FFDA),
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_left,
                                        color: Color(0xFF555555), size: 20),
                                  ],
                                ),
                              ),
                            ),
                            if (i < lipskeyGroups.length - 1)
                              const Divider(
                                  height: 1,
                                  indent: 76,
                                  color: Color(0xFFF5F5F5)),
                          ],
                        );
                      },
                      childCount: lipskeyGroups.length,
                    ),
                  ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
      ],
    );
  }

  static void _openSmartSheet(BuildContext context, SmartProduct p) {
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
}

class _SectionBanner extends StatelessWidget {
  const _SectionBanner(
      {required this.emoji, required this.label, required this.color});

  final String emoji;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}

/// Public entry point — opens the unified "ברז לכיור" sheet (brand picker +
/// accessories + cart sync) for [product]. Used by the catalog drill-down so
/// reaching a leaf opens the same rich sheet as the smart-tree.
void openSmartProductSheet(BuildContext context, SmartProduct product) {
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
                    color: Color(0xFF1A1A1A),
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
                  color: selected == o ? Colors.white : const Color(0xFF6E6E73),
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

  // Brands matching the chosen סוג / מידה filters (derived from names).
  List<int> get _filteredBrandIdx {
    final brands = widget.product.brands;
    return [
      for (var i = 0; i < brands.length; i++)
        if ((_selType == null || brands[i].name.contains(_selType!)) &&
            (_selSize == null || brands[i].name.contains(_selSize!)))
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
      onTap: () => setState(() => _selectedBrand = i),
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
                            color: Color(0xFF1A1A1A),
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
              b.price != null ? '₪${b.price}' : 'לפי ספק',
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
    _selectedBrand = widget.product.brands
        .indexWhere((b) => b.rec)
        .clamp(0, widget.product.brands.length - 1);
    final acc = widget.product.acc;
    _accSelected = {for (var i = 0; i < acc.length; i++) i: false};
    _accQty = {for (var i = 0; i < acc.length; i++) i: 1};
  }

  void _tapStage(int i) =>
      setState(() => _activeStage = _activeStage == i ? null : i);

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
                  top: 6,
                  left: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                          color: Color(0xFF1A1A1A),
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
                // ── Selectors: מותג / סוג / מידה (collapsible) ──
                _SheetSection(
                  title: 'בחר מותג',
                  value: p.brands[_selectedBrand].name,
                  expanded: _brandOpen,
                  onToggle: () => setState(() => _brandOpen = !_brandOpen),
                  child: Column(
                    children: [for (final i in _filteredBrandIdx) _brandCard(i)],
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
                        _applyFilterSelection();
                      }),
                    ),
                  ),

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
                      onToggle: (v) =>
                          setState(() => _accSelected[gi] = v),
                      onQtyChanged: (q) => setState(() => _accQty[gi] = q),
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
                      onToggle: (v) =>
                          setState(() => _accSelected[gi] = v),
                      onQtyChanged: (q) => setState(() => _accQty[gi] = q),
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
                      Navigator.pop(context);
                      showToast(context,
                          '${p.name} · ${brand.name} (+${selectedAcc.length} אביזרים) נוסף לסל 🛒');
                    },
                    child: Text(
                      'הוסף לסל · ₪$_total',
                      style: const TextStyle(
                        color: Colors.white,
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
              color: isActive ? const Color(0xFFF2A516) : const Color(0xFF1A1A1A),
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
            // Checkbox / lock
            GestureDetector(
              onTap: () => onToggle?.call(!selected),
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
                    ? const Icon(Icons.check, color: Colors.white, size: 13)
                    : null,
              ),
            ),
            const SizedBox(width: 10),
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
                            color: Color(0xFF1A1A1A),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showAccInfo(context, acc),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          child: Icon(
                            Icons.info_outline,
                            color: BsTokens.brand,
                            size: 16,
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
                      ? '₪${acc.price! * qty}'
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
                            color: Color(0xFF1A1A1A),
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
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        child: Icon(
          icon,
          size: 12,
          color: onTap != null
              ? Colors.black54
              : const Color(0xFFCCCCCC),
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
                            color: Color(0xFF1A1A1A),
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
                  color: Color(0xFF1A1A1A),
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
                      '₪${acc.price}',
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
              Align(
                alignment: Alignment.centerLeft,
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
    final products =
        kLipskeyCatalog.where((p) => favSkus.contains(p.sku)).toList();
    return Column(
      children: [
        Container(
          color: const Color(0xFF1A1A1A),
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
              child: Image.asset(product.imageAsset!,
                  width: 48, height: 48, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Text(product.typeEmoji,
                      style: const TextStyle(fontSize: 30))),
            )
          : Text(product.typeEmoji,
              style: const TextStyle(fontSize: 30)),
      title: Text(product.nameHe,
          style: const TextStyle(
              color: Color(0xFF1A1A1A), fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(product.brand,
          style: const TextStyle(color: Color(0xFF9AA3B2), fontSize: 11)),
      onTap: () => showLipskeyProductSheet(context, product,
          kLipskeyCatalog.where((p) => p.categoryHe == product.categoryHe).toList()),
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
          color: const Color(0xFF1A1A1A),
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
                onPressed: () =>
                    ref.read(recentSearchesProvider.notifier).clear(),
                child: const Text('נקה הכל',
                    style:
                        TextStyle(color: BsTokens.brand, fontSize: 13)),
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
                        color: Color(0xFF1A1A1A), fontSize: 14)),
                trailing: IconButton(
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
            Text(label, style: TextStyle(color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(color: selected ? Colors.white.withOpacity(0.25) : const Color(0x14FF7A18), borderRadius: BorderRadius.circular(10)),
              child: Text('$count', style: TextStyle(color: selected ? Colors.white : const Color(0xFFCC6614), fontWeight: FontWeight.w700, fontSize: 11)),
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
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : cs.onSurface, fontWeight: FontWeight.w700, fontSize: 12)),
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
          Wrap(
            spacing: 0,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (int i = 0; i < (perMat[active]!.entries.toList()
                  ..sort((a, b) => _diameterSortKey(a.key).compareTo(_diameterSortKey(b.key)))).length; i++) ...[
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
                  final sorted = perMat[active]!.entries.toList()
                    ..sort((a, b) =>
                        _diameterSortKey(a.key).compareTo(_diameterSortKey(b.key)));
                  final e = sorted[i];
                  final key = '$active|${e.key}';
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
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
          ),
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
    final cs = Theme.of(context).colorScheme;
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
                      padding: const EdgeInsets.only(right: 4),
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

List<(String value, int count)> _diameterCounts() {
  final freq = <String, int>{};
  for (final fam in familiesByKind(AttrKind.size)) {
    for (final p in fam.products) {
      final v = variantValue(p, AttrKind.size);
      if (v.isEmpty) continue;
      for (final a in sizeDiameterAtoms(v)) {
        freq[a] = (freq[a] ?? 0) + 1;
      }
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

String _diameterBucket(String atom) {
  if (atom.contains('"') || atom.contains('/')) return 'תבריג';
  if (atom.startsWith('DN')) return 'DN';
  final n = int.tryParse(atom);
  if (n != null) {
    if (n >= 16 && n <= 63) return 'HDPE';
    if (n >= 75) return 'DN';
  }
  return 'אחר';
}

double _diameterSortKey(String atom) {
  final m = RegExp(r'\d+(?:\.\d+)?').firstMatch(atom);
  if (m == null) return 9999;
  return double.tryParse(m.group(0)!) ?? 9999;
}

List<List<(String value, int count)>> _diameterSubGroups() {
  final all = _diameterCounts();
  final by = <String, List<(String, int)>>{};
  for (final e in all) { by.putIfAbsent(_diameterBucket(e.$1), () => []).add(e); }
  for (final list in by.values) { list.sort((a, b) => _diameterSortKey(a.$1).compareTo(_diameterSortKey(b.$1))); }
  const order = ['תבריג', 'HDPE', 'DN', 'אחר'];
  return [for (final k in order) if (by[k] != null) by[k]!];
}

class _SizeFacetRow extends ConsumerWidget {
  const _SizeFacetRow({required this.label, required this.items, required this.provider, this.subGroups});
  final String label;
  final List<(String value, int count)> items;
  final StateProvider<Set<String>> provider;
  final List<List<(String value, int count)>>? subGroups;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(provider);
    final cs = Theme.of(context).colorScheme;
    void toggle(String v) {
      final next = {...selected};
      if (next.contains(v)) { next.remove(v); } else { next.add(v); }
      ref.read(provider.notifier).state = next;
    }
    final groups = subGroups ?? [items];
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
            Padding(padding: const EdgeInsets.only(right: 4), child: _FacetChip(label: groups[gi][i].$1, count: groups[gi][i].$2, isSelected: selected.contains(groups[gi][i].$1), onTap: () => toggle(groups[gi][i].$1))),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${family.emoji}  ${family.frame}', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text('${family.categoryHe} · ${family.brand}', style: TextStyle(color: cs.onSurface.withOpacity(0.55), fontSize: 11)),
              ],
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
              InkWell(
                onTap: () => ref.read(variantsActiveFamilyProvider.notifier).state = null,
                child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.arrow_forward, size: 20)),
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
