import 'package:buildsmart/data/catalog.dart';
import 'package:buildsmart/data/catalog_tree.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/search_index.dart';
import 'package:buildsmart/data/sections.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/screens/barcode_scanner.dart';
import 'package:buildsmart/screens/lipskey_brand_screen.dart';
import 'package:buildsmart/screens/lipskey_product_sheet.dart';
import 'package:buildsmart/screens/lipskey_products_screen.dart';
import 'package:buildsmart/services/voice.dart';
import 'package:buildsmart/screens/compat_screen.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/state/product_favorites.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Catalog sort options — cycles on chip tap.
enum CatalogSort { defaultSort, nameAZ, nameZA, priceUp, priceDown }

/// Catalog filter options — cycles on chip tap.
enum CatalogFilter { all, withImage, withPrice }

final catalogSortProvider =
    StateProvider<CatalogSort>((_) => CatalogSort.defaultSort);
final catalogFilterProvider =
    StateProvider<CatalogFilter>((_) => CatalogFilter.all);

/// Active section label — 'הכל' is always first and fixed.
final catalogSectionProvider = StateProvider<String>((_) => 'הכל');

/// Ordered list of user section labels (הכל is NOT stored here).
final catalogSectionsListProvider = StateProvider<List<String>>(
  (_) => ['תאימות', 'חיפושים אחרונים', 'מועדפים', 'קטגוריות', 'עץ חכם'],
);

/// Per-list catalog items: map of section-label → set of catalog category
/// titles included in that list. Lists not present default to empty.
final catalogListItemsProvider =
    StateProvider<Map<String, Set<String>>>((_) => {});

/// True while the search panel is open (search bar focused / has input).
final searchPanelOpenProvider = StateProvider<bool>((_) => false);

/// Current search query text.
final searchQueryProvider = StateProvider<String>((_) => '');

/// Active search scope chip (הכל / מוצרים / קטגוריות / מסכים).
final searchScopeProvider = StateProvider<String>((_) => 'הכל');

/// Recent search queries, newest first, max 8.
final recentSearchesProvider = StateProvider<List<String>>((_) => []);

/// Currently selected category in the smart tree section. Null = show categories.
final smartTreeCatProvider = StateProvider<String?>((_) => null);

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

String _sortLabel(CatalogSort s) => switch (s) {
      CatalogSort.defaultSort => 'ברירת מחדל',
      CatalogSort.nameAZ      => 'א-ת',
      CatalogSort.nameZA      => 'ת-א',
      CatalogSort.priceUp     => 'מחיר ↑',
      CatalogSort.priceDown   => 'מחיר ↓',
    };

String _filterLabel(CatalogFilter f) => switch (f) {
      CatalogFilter.all       => 'הכל',
      CatalogFilter.withImage => 'עם תמונה',
      CatalogFilter.withPrice => 'עם מחיר',
    };

CatalogSort _nextSort(CatalogSort s) =>
    CatalogSort.values[(s.index + 1) % CatalogSort.values.length];

CatalogFilter _nextFilter(CatalogFilter f) =>
    CatalogFilter.values[(f.index + 1) % CatalogFilter.values.length];

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
        color: const Color(0xFF1E1E1E),
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
                  style: TextStyle(color: Colors.white, fontSize: 15),
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
                  style: TextStyle(color: Colors.white, fontSize: 15),
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
              color: const Color(0xFF444444),
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
                  icon: const Icon(Icons.check, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'ניהול רשימות',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
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
                      color: Colors.white,
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
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'רשימה חדשה',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'שם הרשימה',
            hintStyle: TextStyle(color: Color(0xFF888888)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF444444)),
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
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text(
        'שינוי שם הרשימה',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      content: TextField(
        controller: controller,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'שם הרשימה',
          hintStyle: TextStyle(color: Color(0xFF888888)),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF444444)),
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
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'שינוי שם הרשימה',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'שם הרשימה',
            hintStyle: TextStyle(color: Color(0xFF888888)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF444444)),
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
              color: const Color(0xFF444444),
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
                            color: Colors.white,
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
                  icon: const Icon(Icons.close, color: Colors.white),
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
                            color: Colors.white,
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
      'חיפושים אחרונים' => Icons.history,
      'מועדפים'         => Icons.favorite_border,
      'קטגוריות'        => Icons.grid_view_outlined,
      'עץ חכם'          => Icons.account_tree_outlined,
      'תאימות'          => Icons.compare_arrows_outlined,
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
                  color: Colors.white,
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
    final list = List<String>.from(ref.read(recentSearchesProvider))
      ..remove(q)
      ..insert(0, q);
    if (list.length > 8) list.removeRange(8, list.length);
    ref.read(recentSearchesProvider.notifier).state = list;
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
    return ColoredBox(
      color: const Color(0xFF111111),
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

class _SearchToolsRow extends StatelessWidget {
  const _SearchToolsRow();

  @override
  Widget build(BuildContext context) {
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
            onTap: () => showToast(context, 'פילטרים — בקרוב'),
          ),
          _SearchToolButton(
            emoji: '↕️',
            label: 'מיון',
            onTap: () => showToast(context, 'מיון — בקרוב'),
          ),
          _SearchToolButton(
            emoji: '▦',
            label: 'קטלוג',
            onTap: () => showToast(context, 'קטלוג — בקרוב'),
          ),
        ],
      ),
    );
  }
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
                    ref.read(recentSearchesProvider.notifier).state = [],
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
                  style: const TextStyle(color: Colors.white, fontSize: 14),
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
    final products = showProducts
        ? kLipskeyCatalog
            .where((p) =>
                p.nameHe.contains(query) ||
                p.sku.toLowerCase().contains(query.toLowerCase()))
            .take(40)
            .toList()
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
                style: const TextStyle(color: Colors.white, fontSize: 14),
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
            style: const TextStyle(color: Colors.white, fontSize: 14),
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
            final list = List<String>.from(ref.read(recentSearchesProvider))
              ..remove(entry.title)
              ..insert(0, entry.title);
            if (list.length > 8) list.removeRange(8, list.length);
            ref.read(recentSearchesProvider.notifier).state = list;
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
    if (active == 'הכל') return _CatalogList(scrollCtrl: scrollCtrl);
    if (active == 'עץ חכם') return const _SmartTreeSection();
    if (active == 'קטגוריות') return const _CatalogDrillSection();
    if (active == 'מועדפים') return const _FavoritesSection();
    if (active == 'חיפושים אחרונים') return const _RecentSearchesSection();
    if (active == 'תאימות') return const CompatScreen();

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
              color: Colors.white,
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
                children: [
                  Container(
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
                        Text('ליפסקי ברקן',
                            style: TextStyle(
                                color: Color(0xFF64FFDA),
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      LipskeyBrandScreen.route(),
                    ),
                    child: const Row(
                      children: [
                        Text('כל הקטגוריות',
                            style: TextStyle(color: Colors.black38, fontSize: 12)),
                        SizedBox(width: 3),
                        Icon(Icons.chevron_left, color: Colors.white38, size: 16),
                      ],
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
    return '${_treeNodeCount(node)} מוצרים · ליפסקי ברקן';
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

    // A leaf that maps to a faceted lipskey category drills by product facets
    // (e.g. תיקני/קומקום → למקלחת/כללי → פתוח/סגור) before the product list.
    final facetGroups = current.isLeaf && current.lipskeyCategory != null
        ? kProductFacets[current.lipskeyCategory]
        : null;

    void resetQuery() =>
        ref.read(catalogTreeQueryProvider.notifier).state = '';
    void resetFacets() =>
        ref.read(catalogFacetProvider.notifier).state = const [];

    void goBack() {
      resetQuery();
      if (facetSel.isNotEmpty) {
        ref.read(catalogFacetProvider.notifier).state = [...facetSel]
          ..removeLast();
      } else {
        resetFacets();
        ref.read(catalogTreePathProvider.notifier).state = [...path]
          ..removeLast();
      }
    }

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
        // Faceted leaf → enter facet drill instead of opening products.
        if (n.lipskeyCategory != null &&
            kProductFacets.containsKey(n.lipskeyCategory)) {
          resetQuery();
          resetFacets();
          ref.read(catalogTreePathProvider.notifier).state = [...path, n];
          return;
        }
        if (n.lipskeyCategory != null) {
          final products = kLipskeyCatalog
              .where((p) => p.categoryHe == n.lipskeyCategory)
              .toList();
          if (products.isNotEmpty) {
            Navigator.push(
              context,
              LipskeyProductsScreen.route(
                  category: n.title, products: products),
            );
            return;
          }
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

    Widget body;
    if (facetGroups != null) {
      // Facet drill: split the leaf's products by the next facet group.
      final base = kLipskeyCatalog
          .where((p) => p.categoryHe == current.lipskeyCategory)
          .toList();
      final filtered = _applyFacets(base, facetGroups, facetSel);
      final group = facetGroups[facetSel.length];
      final options = [
        for (final f in group)
          (facet: f, count: filtered.where((p) => _matchesFacet(p, group, f)).length),
      ].where((o) => o.count > 0).toList();

      void chooseFacet(ProductFacet f) {
        final sel = [...facetSel, f.label];
        if (sel.length >= facetGroups.length) {
          final prods = _applyFacets(base, facetGroups, sel);
          Navigator.push(
            context,
            LipskeyProductsScreen.route(
              category: '${current.title} · ${sel.join(' · ')}',
              products: prods,
            ),
          );
        } else {
          ref.read(catalogFacetProvider.notifier).state = sel;
        }
      }

      body = options.isEmpty
          ? const Center(
              child: Text('אין מוצרים',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 14)),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
              itemCount: options.length,
              itemBuilder: (_, i) => _FacetRow(
                label: options[i].facet.label,
                count: options[i].count,
                onTap: () => chooseFacet(options[i].facet),
              ),
            );
    } else if (current.children.isEmpty) {
      // Childless node = category without tree data → designed "coming soon".
      body = _TreeComingSoon(node: current);
    } else {
      // Query empty → direct children. Otherwise → every descendant of the
      // current node whose title matches (search scoped to the drill).
      final rows = query.isEmpty
          ? current.children
          : _searchSubtree(current, query);
      body = rows.isEmpty
          ? Center(
              child: Text(
                'לא נמצאו תוצאות עבור "$query"',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF888888), fontSize: 14),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
              itemCount: rows.length,
              itemBuilder: (_, i) => _TreeCatRow(
                node: rows[i],
                onTap: () => openNode(rows[i]),
              ),
            );
    }

    return Column(
      children: [
        _TreeDrillBar(
          key: ValueKey('${current.id}.${facetSel.length}'),
          crumbs: crumbs,
          onBack: goBack,
          onCancel: cancel,
        ),
        Expanded(child: body),
      ],
    );
  }
}

// Bordered row for a product facet option (label + product-count badge).
class _FacetRow extends StatelessWidget {
  const _FacetRow({
    required this.label,
    required this.count,
    required this.onTap,
  });
  final String label;
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
                        '$count מוצרים',
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
          // Breadcrumb of the drill path — every chip flexes/ellipsizes so the
          // active chip's X is always visible (no clipping, no scroll).
          // Breadcrumb scrolls horizontally; reverse keeps the active chip (and
          // its X) in view by default, with older ancestors reachable by swipe.
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
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
        // Header
        Container(
          color: const Color(0xFFFFFFFF),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: const Row(
            children: [
              Text('🌳', style: TextStyle(fontSize: 20)),
              SizedBox(width: 10),
              Text(
                'עץ חכם — בחר קטגוריה',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFF5F5F5)),
        Expanded(
          child: ListView.separated(
            itemCount: cats.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 76, color: Color(0xFFF5F5F5)),
            itemBuilder: (_, i) {
              final cat = cats[i];
              final count = smartProductsForCat(cat).length;
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
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '$count מוצרים בעץ',
                              style: const TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_left,
                          color: Color(0xFF555555), size: 20),
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

class _SmartTreeProductList extends ConsumerWidget {
  const _SmartTreeProductList({required this.cat});

  final String cat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = smartProductsForCat(cat);
    return Column(
      children: [
        // Breadcrumb header with back button
        Container(
          color: const Color(0xFFFFFFFF),
          padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    color: BsTokens.brand, size: 18),
                onPressed: () =>
                    ref.read(smartTreeCatProvider.notifier).state = null,
              ),
              const Text('🌳 ', style: TextStyle(fontSize: 16)),
              Text(
                cat,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFF5F5F5)),
        Expanded(
          child: ListView.separated(
            itemCount: products.length,
            separatorBuilder: (_, __) => const Divider(
                height: 1, indent: 76, color: Color(0xFFF5F5F5)),
            itemBuilder: (_, i) {
              final p = products[i];
              return InkWell(
                onTap: () => _openProductSheet(context, p),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    p.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  p.recBrand.price != null ? '₪${p.recBrand.price}' : '—',
                                  style: const TextStyle(
                                    color: Color(0xFF888888),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '⚡ ${p.mustCount} פריטי חובה · ${p.acc.length} סה"כ',
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
              );
            },
          ),
        ),
      ],
    );
  }

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
                  color: Colors.white,
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
                  color: Colors.white,
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
                  style: TextStyle(color: Colors.white38, fontSize: 16)),
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
                                                      color: Colors.white,
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
                                                color: Colors.white,
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

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Column(
        children: [
          // Header with handle + close (X)
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF444444),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Positioned(
                top: 4,
                left: 4,
                child: IconButton(
                  icon: const Icon(Icons.close,
                      color: Colors.black54, size: 22),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'סגור',
                ),
              ),
            ],
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
                          color: Colors.white,
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
                // Brand selector
                const Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(
                    'בחר מותג',
                    style: TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...List.generate(p.brands.length, (i) {
                  final b = p.brands[i];
                  final selected = i == _selectedBrand;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedBrand = i),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? BsTokens.brand.withAlpha(30)
                            : const Color(0xFF252525),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? BsTokens.brand
                              : const Color(0xFF333333),
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
                                    Text(
                                      b.name,
                                      style: TextStyle(
                                        color: selected
                                            ? Colors.white
                                            : const Color(0xFFCCCCCC),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (b.rec) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: BsTokens.brand,
                                          borderRadius:
                                              BorderRadius.circular(6),
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
                              color: selected
                                  ? BsTokens.brand
                                  : const Color(0xFF888888),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
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

// ── Installation diagram with staggered pop-in animation ─────────────────
// Mirrors the prototype's tdiagram — gradient card, 4 stages, amber title dot.
// Each stage pops in 180 ms after the previous (elasticOut spring).

class _DiagramFlow extends StatefulWidget {
  const _DiagramFlow({
    required this.product,
    this.activeStage,
    this.onStageTap,
  });
  final SmartProduct product;
  final int? activeStage;
  final void Function(int)? onStageTap;

  @override
  State<_DiagramFlow> createState() => _DiagramFlowState();
}

class _DiagramFlowState extends State<_DiagramFlow>
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
    _ctrl.forward();
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1D22), Color(0xFF2C3036)],
        ),
        borderRadius: BorderRadius.circular(15),
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
                color: Color(0x66FFFFFF),
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
                      ? const Color(0xFF1F6F6B).withAlpha(64)
                      : Colors.white.withAlpha(18),
              border: Border.all(
                color: isActive
                    ? const Color(0xFFF2A516)
                    : stage.isFinal
                        ? BsTokens.brand
                        : Colors.white.withAlpha(31),
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
              color: isActive ? const Color(0xFFF2A516) : Colors.white,
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
                      : const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: selected
                        ? BsTokens.brand
                        : const Color(0xFF555555),
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
                      color: Color(0xFF252525),
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
                            color: Colors.white,
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
                    color: const Color(0xFF1E1E1E),
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
                            color: Colors.white,
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
              : const Color(0xFF444444),
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
                      color: Color(0xFF252525),
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
                            color: Colors.white,
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
                                : const Color(0xFF333333),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            acc.must ? '⚡ פריט חובה' : '💡 אופציונלי',
                            style: TextStyle(
                              color: acc.must
                                  ? const Color(0xFFF2A516)
                                  : const Color(0xFFAAAAAA),
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
                  color: Colors.white,
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
                        color: Color(0xFFAAAAAA),
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
    final isFav = ref.watch(productFavoritesProvider).contains(product.sku);
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
              color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(product.brand,
          style: const TextStyle(color: Color(0xFF9AA3B2), fontSize: 11)),
      trailing: GestureDetector(
        onTap: () =>
            ref.read(productFavoritesProvider.notifier).toggle(product.sku),
        child: Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          size: 20,
          color: isFav ? const Color(0xFFFF4D6D) : const Color(0xFF3A4151),
        ),
      ),
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
                    ref.read(recentSearchesProvider.notifier).state = [],
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
                height: 1, indent: 56, color: Color(0xFF2A2A2A)),
            itemBuilder: (_, i) {
              final q = items[i];
              return ListTile(
                leading: const Icon(Icons.history,
                    color: Color(0xFF9AA3B2), size: 20),
                title: Text(q,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14)),
                trailing: IconButton(
                  icon: const Icon(Icons.close,
                      color: Color(0xFF9AA3B2), size: 18),
                  onPressed: () {
                    final list =
                        List<String>.from(ref.read(recentSearchesProvider))
                          ..remove(q);
                    ref.read(recentSearchesProvider.notifier).state =
                        list;
                  },
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
