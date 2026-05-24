import 'package:buildsmart/data/catalog.dart';
import 'package:buildsmart/data/search_index.dart';
import 'package:buildsmart/data/sections.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/screens/barcode_scanner.dart';
import 'package:buildsmart/services/voice.dart';
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
  (_) => ['חיפושים אחרונים', 'מועדפים', 'קטגוריות', 'עץ חכם'],
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

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchOpen = ref.watch(searchPanelOpenProvider);
    return Column(
      children: [
        const _SearchBar(),
        if (searchOpen)
          const Expanded(child: _SearchPanel())
        else ...const [
          _FilterChipsRow(),
          _SectionChipsRow(),
          Expanded(child: _CatalogBody()),
        ],
      ],
    );
  }
}

/// Row of filter chips — מיון · פילטרים. Each chip cycles its value on tap.
/// Mirrors WhatsApp's search-screen chip strip.
class _FilterChipsRow extends ConsumerWidget {
  const _FilterChipsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(catalogSortProvider);
    final filter = ref.watch(catalogFilterProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _Chip(
              icon: '↕️',
              label: _sortLabel(sort),
              onTap: () =>
                  ref.read(catalogSortProvider.notifier).state = _nextSort(sort),
            ),
            const SizedBox(width: 8),
            _Chip(
              icon: '⚙️',
              label: _filterLabel(filter),
              onTap: () => ref.read(catalogFilterProvider.notifier).state =
                  _nextFilter(filter),
            ),
          ],
        ),
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
                Icon(Icons.list, color: Colors.white70, size: 20),
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
                  color: Colors.white70,
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
    backgroundColor: const Color(0xFF1A1A1A),
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
          const Divider(color: Color(0xFF2A2A2A), height: 1),
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
                  tileColor: const Color(0xFF1A1A1A),
                  // Leading: icon matching section
                  leading: Icon(
                    _sectionIcon(s),
                    color: Colors.white70,
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
          const Divider(color: Color(0xFF2A2A2A), height: 1),
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
    backgroundColor: const Color(0xFF1A1A1A),
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
          const Divider(color: Color(0xFF2A2A2A), height: 1),
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
                  tileColor: const Color(0xFF1A1A1A),
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
      color: active ? BsTokens.brand : const Color(0xFF2A2A2A),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFFAAAAAA),
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
      color: const Color(0xFF2A2A2A),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Icon(Icons.add, color: Color(0xFFAAAAAA), size: 18),
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
      color: const Color(0xFF2A2A2A),
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

    final open = ref.watch(searchPanelOpenProvider);
    final hasText = ref.watch(searchQueryProvider).isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        textInputAction: TextInputAction.search,
        onChanged: (v) =>
            ref.read(searchQueryProvider.notifier).state = v,
        onSubmitted: _submit,
        decoration: InputDecoration(
          hintText: 'חיפוש מוצרים, קטגוריות, מסכים...',
          hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 14),
          prefixIcon: open
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF888888),
                    size: 20,
                  ),
                  onPressed: _closePanel,
                )
              : const Icon(
                  Icons.search,
                  color: Color(0xFF888888),
                  size: 20,
                ),
          suffixIcon: hasText
              ? IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF888888),
                    size: 18,
                  ),
                  onPressed: () {
                    _controller.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF2A2A2A),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: BsTokens.brand, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _SearchPanel extends ConsumerWidget {
  const _SearchPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    return ColoredBox(
      color: const Color(0xFF111111),
      child: Column(
        children: [
          const _SearchToolsRow(),
          const _SearchScopeRow(),
          const Divider(height: 1, color: Color(0xFF2A2A2A)),
          Expanded(
            child: query.isEmpty
                ? const _RecentSearchesList()
                : const _SearchResultsList(),
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
                color: Color(0xFF2A2A2A),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
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
      if (!e.matches(query)) return false;
      return switch (scope) {
        'מוצרים'   => e.type == SearchType.category,
        'קטגוריות' => e.type == SearchType.setting || e.type == SearchType.menu,
        'מסכים'    => e.type == SearchType.screen ||
            e.type == SearchType.persona ||
            e.type == SearchType.action,
        _ => true,
      };
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'לא נמצאו תוצאות עבור "$query"',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF888888), fontSize: 14),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final entry = filtered[i];
        return ListTile(
          leading: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF2A2A2A),
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
              color: const Color(0xFF2A2A2A),
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
  const _CatalogBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(catalogSectionProvider);
    if (active == 'הכל') return const _CatalogList();

    // Smart tree section gets its own dedicated view
    if (active == 'עץ חכם') return const _SmartTreeSection();

    final selected = ref.watch(catalogListItemsProvider)[active];
    final hasItems = selected != null && selected.isNotEmpty;

    final emoji = switch (active) {
      'חיפושים אחרונים' => '🕐',
      'מועדפים'         => '⭐',
      'קטגוריות'        => '▦',
      _                 => '📋',
    };

    return Column(
      children: [
        _SectionHeader(label: active),
        Expanded(
          child: hasItems
              ? _FilteredCatalogList(selected: selected)
              : _EmptySection(emoji: emoji, label: active),
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
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
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
        color: Color(0xFF2A2A2A),
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
  const _CatalogList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const Key('catalog-list'),
      itemCount: kCatalogCats.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        indent: 76,
        color: Color(0xFF2A2A2A),
      ),
      itemBuilder: (context, i) => _CatalogRow(
        cat: kCatalogCats[i],
        meta: _kMeta[i],
      ),
    );
  }
}

class _CatalogRow extends StatelessWidget {
  const _CatalogRow({required this.cat, required this.meta});

  final Section cat;
  final ({String preview, String time, int badge}) meta;

  @override
  Widget build(BuildContext context) {
    final hasBadge = meta.badge > 0;
    return InkWell(
      onTap: () => showToast(context, '${cat.title} — בבנייה'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Avatar circle with emoji — appears on right in RTL.
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFF2A2A2A),
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
                            color: Colors.white,
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
          color: const Color(0xFF1A1A1A),
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
        const Divider(height: 1, color: Color(0xFF2A2A2A)),
        Expanded(
          child: ListView.separated(
            itemCount: cats.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 76, color: Color(0xFF2A2A2A)),
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
                          color: Color(0xFF2A2A2A),
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
          color: const Color(0xFF1A1A1A),
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
        const Divider(height: 1, color: Color(0xFF2A2A2A)),
        Expanded(
          child: ListView.separated(
            itemCount: products.length,
            separatorBuilder: (_, __) => const Divider(
                height: 1, indent: 76, color: Color(0xFF2A2A2A)),
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
                          color: Color(0xFF2A2A2A),
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
                                  '₪${p.recBrand.price}',
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
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SmartProductSheet(product: p),
    );
  }
}

class _SmartProductSheet extends StatefulWidget {
  const _SmartProductSheet({required this.product});

  final SmartProduct product;

  @override
  State<_SmartProductSheet> createState() => _SmartProductSheetState();
}

class _SmartProductSheetState extends State<_SmartProductSheet> {
  late int _selectedBrand;

  @override
  void initState() {
    super.initState();
    _selectedBrand =
        widget.product.brands.indexWhere((b) => b.rec).clamp(0, widget.product.brands.length - 1);
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
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF444444),
              borderRadius: BorderRadius.circular(2),
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
                    color: Color(0xFF2A2A2A),
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
          const Divider(height: 1, color: Color(0xFF2A2A2A)),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
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
                            '₪${b.price}',
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
                  ...mustItems.map((a) => _AccRow(acc: a)),
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
                  ...optItems.map((a) => _AccRow(acc: a)),
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
                      Navigator.pop(context);
                      showToast(context,
                          '${p.name} · ${brand.name} הוסף לסל 🛒');
                    },
                    child: Text(
                      'הוסף לסל · ₪${brand.price}',
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

class _AccRow extends StatelessWidget {
  const _AccRow({required this.acc});

  final SmartAcc acc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF252525),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(acc.emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  acc.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  acc.why,
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₪${acc.price}',
            style: const TextStyle(
              color: Color(0xFF888888),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
