import 'package:buildsmart/data/catalog.dart';
import 'package:buildsmart/data/sections.dart';
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
  (_) => ['חיפושים אחרונים', 'מועדפים', 'קטגוריות'],
);

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

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _SearchBar(),
        _FilterChipsRow(),
        _SectionChipsRow(),
        Expanded(child: _CatalogList()),
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
                        onPressed: () => _showEditDialog(context, i, s),
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

  void _showEditDialog(BuildContext ctx, int index, String current) {
    final controller = TextEditingController(text: current);
    showDialog<void>(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'עריכת רשימה',
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
                final list = List<String>.from(
                  ref.read(catalogSectionsListProvider),
                )..[index] = name;
                ref.read(catalogSectionsListProvider.notifier).state = list;
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
}

IconData _sectionIcon(String label) => switch (label) {
      'חיפושים אחרונים' => Icons.history,
      'מועדפים'         => Icons.favorite_border,
      'קטגוריות'        => Icons.grid_view_outlined,
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

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'חיפוש...',
          hintStyle: const TextStyle(color: Color(0xFF888888)),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF888888),
            size: 20,
          ),
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
