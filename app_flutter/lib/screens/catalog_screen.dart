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

/// Catalog section tabs — selectable pills.
enum CatalogSection { all, recent, favorites, categories }

final catalogSortProvider =
    StateProvider<CatalogSort>((_) => CatalogSort.defaultSort);
final catalogFilterProvider =
    StateProvider<CatalogFilter>((_) => CatalogFilter.all);
final catalogSectionProvider =
    StateProvider<CatalogSection>((_) => CatalogSection.all);

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

/// Horizontal pill tabs — הכל · חיפושים אחרונים · מועדפים · קטגוריות · +
/// Non-הכל sections highlight the chip and show a toast (בבנייה).
class _SectionChipsRow extends ConsumerWidget {
  const _SectionChipsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(catalogSectionProvider);

    void select(CatalogSection s) {
      ref.read(catalogSectionProvider.notifier).state = s;
      if (s != CatalogSection.all) {
        final label = switch (s) {
          CatalogSection.recent     => 'חיפושים אחרונים',
          CatalogSection.favorites  => 'מועדפים',
          CatalogSection.categories => 'קטגוריות',
          CatalogSection.all        => '',
        };
        showToast(context, '$label — בבנייה');
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _SectionPill(
              label: 'הכל',
              active: section == CatalogSection.all,
              onTap: () => select(CatalogSection.all),
            ),
            const SizedBox(width: 8),
            _SectionPill(
              label: 'חיפושים אחרונים',
              active: section == CatalogSection.recent,
              onTap: () => select(CatalogSection.recent),
            ),
            const SizedBox(width: 8),
            _SectionPill(
              label: 'מועדפים',
              active: section == CatalogSection.favorites,
              onTap: () => select(CatalogSection.favorites),
            ),
            const SizedBox(width: 8),
            _SectionPill(
              label: 'קטגוריות',
              active: section == CatalogSection.categories,
              onTap: () => select(CatalogSection.categories),
            ),
            const SizedBox(width: 8),
            _AddPill(),
          ],
        ),
      ),
    );
  }
}

class _SectionPill extends StatelessWidget {
  const _SectionPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? BsTokens.brand : const Color(0xFF2A2A2A),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
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
  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2A2A2A),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => showToast(context, 'הוספה — בבנייה'),
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
