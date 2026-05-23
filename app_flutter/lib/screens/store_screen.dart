import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Store section tabs.
enum StoreSection { all, cart, orders, services }

final storeSectionProvider =
    StateProvider<StoreSection>((_) => StoreSection.all);

// ─── static data ─────────────────────────────────────────────────────────────

typedef _Meta = ({String emoji, String title, String preview, String time, int badge});

const List<_Meta> _kAllItems = [
  (emoji: '🛒', title: 'הסל שלי',         preview: '3 פריטים ממתינים לסיכום',       time: 'עכשיו', badge: 3),
  (emoji: '📦', title: 'ההזמנות שלי',     preview: 'הזמנה #1234 · בדרך אליך',       time: 'אתמול', badge: 1),
  (emoji: '🔧', title: 'השכרת כלים',      preview: '2 כלים מושכרים עד 30.5',         time: '21.5',  badge: 0),
  (emoji: '💰', title: 'פקדונות',          preview: 'פיקדון פעיל · ₪350',             time: '21.5',  badge: 0),
  (emoji: '↩️', title: 'החזרה חדשה',      preview: 'בקשה #567 ממתינה לאישור',        time: '20.5',  badge: 0),
  (emoji: '📨', title: 'מכרז ספקים',      preview: '3 הצעות חדשות התקבלו',           time: '20.5',  badge: 3),
  (emoji: '🧪', title: 'גיליונות בטיחות', preview: '5 גיליונות זמינים להורדה',       time: '19.5',  badge: 0),
  (emoji: '📊', title: 'השוואת מחירים',   preview: '4 ספקים עדכנו מחירים',           time: '19.5',  badge: 2),
];

const _kCartItems = [
  (emoji: '🛒', title: 'הסל שלי',     preview: '3 פריטים ממתינים לסיכום', time: 'עכשיו', badge: 3),
];

const List<_Meta> _kOrderItems = [
  (emoji: '📦', title: 'ההזמנות שלי', preview: 'הזמנה #1234 · בדרך אליך', time: 'אתמול', badge: 1),
];

const List<_Meta> _kServiceItems = [
  (emoji: '🔧', title: 'השכרת כלים',      preview: '2 כלים מושכרים עד 30.5',   time: '21.5',  badge: 0),
  (emoji: '💰', title: 'פקדונות',          preview: 'פיקדון פעיל · ₪350',       time: '21.5',  badge: 0),
  (emoji: '↩️', title: 'החזרה חדשה',      preview: 'בקשה #567 ממתינה לאישור',  time: '20.5',  badge: 0),
  (emoji: '📨', title: 'מכרז ספקים',      preview: '3 הצעות חדשות התקבלו',     time: '20.5',  badge: 3),
  (emoji: '🧪', title: 'גיליונות בטיחות', preview: '5 גיליונות זמינים להורדה', time: '19.5',  badge: 0),
  (emoji: '📊', title: 'השוואת מחירים',   preview: '4 ספקים עדכנו מחירים',     time: '19.5',  badge: 2),
];

List<_Meta> _itemsForSection(StoreSection s) => switch (s) {
      StoreSection.all      => _kAllItems,
      StoreSection.cart     => _kCartItems,
      StoreSection.orders   => _kOrderItems,
      StoreSection.services => _kServiceItems,
    };

// ─── screen ──────────────────────────────────────────────────────────────────

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _SearchBar(),
        _SectionChipsRow(),
        Expanded(child: _StoreList()),
      ],
    );
  }
}

// ─── search bar ──────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'חיפוש הזמנות ומוצרים...',
          hintStyle: const TextStyle(color: Color(0xFF888888)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF888888), size: 20),
          filled: true,
          fillColor: const Color(0xFF2A2A2A),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

// ─── section chips ───────────────────────────────────────────────────────────

class _SectionChipsRow extends ConsumerWidget {
  const _SectionChipsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(storeSectionProvider);

    void select(StoreSection s) =>
        ref.read(storeSectionProvider.notifier).state = s;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _Pill(label: 'הכל',     active: section == StoreSection.all,      onTap: () => select(StoreSection.all)),
            const SizedBox(width: 8),
            _Pill(label: '🛒 הסל',  active: section == StoreSection.cart,     onTap: () => select(StoreSection.cart)),
            const SizedBox(width: 8),
            _Pill(label: '📦 הזמנות', active: section == StoreSection.orders, onTap: () => select(StoreSection.orders)),
            const SizedBox(width: 8),
            _Pill(label: '🔧 שירותים', active: section == StoreSection.services, onTap: () => select(StoreSection.services)),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.active, required this.onTap});

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

// ─── list ─────────────────────────────────────────────────────────────────────

class _StoreList extends ConsumerWidget {
  const _StoreList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(storeSectionProvider);
    final items = _itemsForSection(section);

    return ListView.separated(
      key: ValueKey(section),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        indent: 76,
        color: Color(0xFF2A2A2A),
      ),
      itemBuilder: (context, i) => _StoreRow(item: items[i]),
    );
  }
}

class _StoreRow extends StatelessWidget {
  const _StoreRow({required this.item});

  final _Meta item;

  @override
  Widget build(BuildContext context) {
    final hasBadge = item.badge > 0;
    return InkWell(
      onTap: () => showToast(context, '${item.title} — בבנייה'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
              child: Text(item.emoji, style: const TextStyle(fontSize: 24)),
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
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        item.time,
                        style: TextStyle(
                          color: hasBadge ? BsTokens.brand : const Color(0xFF888888),
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
                          item.preview,
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
                            '${item.badge}',
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
