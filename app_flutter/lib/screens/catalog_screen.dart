import 'package:buildsmart/data/catalog.dart';
import 'package:buildsmart/data/sections.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';

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
        Expanded(child: _CatalogList()),
      ],
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
