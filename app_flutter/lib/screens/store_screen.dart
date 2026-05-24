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
        _QuickActionsRow(),
        Expanded(child: _StoreList()),
      ],
    );
  }
}

// ─── quick actions ────────────────────────────────────────────────────────────

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _QuickAction(
            icon: Icons.favorite_border,
            label: 'מועדפים',
            onTap: () => showToast(context, 'מועדפים — בבנייה'),
          ),
          _QuickAction(
            icon: Icons.grid_view_rounded,
            label: 'מועדים',
            onTap: () => _showSheet(context, const _MoadimSheet()),
          ),
          _QuickAction(
            icon: Icons.calendar_today_outlined,
            label: 'תזמון',
            onTap: () => _showSheet(context, const _TizmonSheet()),
          ),
          _QuickAction(
            icon: Icons.phone_outlined,
            label: 'שיחה',
            onTap: () => _showSheet(context, const _SichaSheet()),
          ),
        ],
      ),
    );
  }

  void _showSheet(BuildContext context, Widget sheet) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => sheet,
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
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
      borderRadius: BorderRadius.circular(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              color: Color(0xFF2A2A2A),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white70, size: 28),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 12)),
        ],
      ),
    );
  }
}

// ─── bottom sheets ────────────────────────────────────────────────────────────

class _MoadimSheet extends StatelessWidget {
  const _MoadimSheet();
  @override
  Widget build(BuildContext context) => _SheetScaffold(
        title: 'מועדים',
        emoji: '📅',
        children: const [
          _SheetTile(emoji: '📅', label: 'לוח שנה'),
          _SheetTile(emoji: '🗓️', label: 'אירועים קרובים'),
          _SheetTile(emoji: '🏗️', label: 'לוח עבודה'),
          _SheetTile(emoji: '⏰', label: 'תזכורות'),
        ],
      );
}

class _TizmonSheet extends StatelessWidget {
  const _TizmonSheet();
  @override
  Widget build(BuildContext context) => _SheetScaffold(
        title: 'תזמון',
        emoji: '📆',
        children: const [
          _SheetTile(emoji: '📆', label: 'תזמן פגישה'),
          _SheetTile(emoji: '🚛', label: 'תזמן משלוח'),
          _SheetTile(emoji: '👷', label: 'תזמן עובד'),
          _SheetTile(emoji: '📋', label: 'תזמן ביקורת'),
        ],
      );
}

class _SichaSheet extends StatelessWidget {
  const _SichaSheet();

  static const _contacts = [
    (avatar: '👷', name: 'הקבלן הראשי'),
    (avatar: '🏪', name: 'ספק חומרי בנייה'),
    (avatar: '🛵', name: 'השליח'),
    (avatar: '👔', name: 'מנהל המערכת'),
  ];

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: 'שיחה חדשה',
      emoji: '📞',
      children: _contacts
          .map((c) => ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF333333),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(c.avatar,
                      style: const TextStyle(fontSize: 20)),
                ),
                title: Text(c.name,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 15)),
                trailing: const Icon(Icons.phone_outlined,
                    color: Colors.white38),
                onTap: () {
                  Navigator.pop(context);
                  showToast(context, 'שיחה עם ${c.name} — בבנייה');
                },
              ))
          .toList(),
    );
  }
}

class _SheetScaffold extends StatelessWidget {
  const _SheetScaffold({
    required this.title,
    required this.emoji,
    required this.children,
  });

  final String title;
  final String emoji;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$emoji $title',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  const _SheetTile({required this.emoji, required this.label});
  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 22)),
      title: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 15)),
      onTap: () {
        Navigator.pop(context);
        showToast(context, '$label — בבנייה');
      },
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

// ─── orders data ─────────────────────────────────────────────────────────────

typedef _Order = ({
  String id,
  String items,
  String total,
  String stage,
  String stageLabel,
  String time,
  Color stageColor,
});

const List<_Order> _kOrders = [
  (
    id: 'BS-1234', items: '12 פריטים', total: '₪5,420',
    stage: 'transit',    stageLabel: 'בדרך 🚛',
    time: '24.5, 14:00', stageColor: Color(0xFF4CAF50),
  ),
  (
    id: 'BS-1221', items: '5 פריטים',  total: '₪1,890',
    stage: 'ready',      stageLabel: 'מוכן 📦',
    time: '24.5, 09:30', stageColor: Color(0xFF2196F3),
  ),
  (
    id: 'BS-1198', items: '3 פריטים',  total: '₪630',
    stage: 'preparing',  stageLabel: 'בהכנה 🔧',
    time: '23.5',        stageColor: Color(0xFFFF9800),
  ),
  (
    id: 'BS-1171', items: '8 פריטים',  total: '₪2,240',
    stage: 'delivered',  stageLabel: 'הסתיימה ✓',
    time: '21.5',        stageColor: Color(0xFF888888),
  ),
  (
    id: 'BS-1155', items: '2 פריטים',  total: '₪310',
    stage: 'delivered',  stageLabel: 'הסתיימה ✓',
    time: '19.5',        stageColor: Color(0xFF888888),
  ),
];

// ─── services data ────────────────────────────────────────────────────────────

typedef _Service = ({String emoji, String title, String sub});

const List<_Service> _kServices = [
  (emoji: '🔧', title: 'השכרת כלים',     sub: '2 כלים פעילים'),
  (emoji: '💰', title: 'פקדונות',         sub: 'פיקדון ₪350'),
  (emoji: '↩️', title: 'החזרה חדשה',     sub: 'בקשה #567'),
  (emoji: '📨', title: 'מכרז ספקים',     sub: '3 הצעות חדשות'),
  (emoji: '🧪', title: 'גיליונות בטיחות', sub: '5 גיליונות'),
  (emoji: '📊', title: 'השוואת מחירים',  sub: '4 ספקים עודכנו'),
];

class _StoreList extends ConsumerWidget {
  const _StoreList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(storeSectionProvider);
    return switch (section) {
      StoreSection.services => const _ServicesGrid(),
      StoreSection.orders   => const _OrdersList(),
      _                     => _AllList(section: section),
    };
  }
}

// ─── all / cart list ──────────────────────────────────────────────────────────

class _AllList extends StatelessWidget {
  const _AllList({required this.section});
  final StoreSection section;

  @override
  Widget build(BuildContext context) {
    final items = _itemsForSection(section);
    return ListView.separated(
      key: ValueKey(section),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1, indent: 76, color: Color(0xFF2A2A2A),
      ),
      itemBuilder: (context, i) => _StoreRow(item: items[i]),
    );
  }
}

class _StoreRow extends StatelessWidget {
  const _StoreRow({required this.item, this.onTap});

  final _Meta item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasBadge = item.badge > 0;
    return InkWell(
      onTap: onTap ?? () => showToast(context, '${item.title} — בבנייה'),
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

// ─── services list ────────────────────────────────────────────────────────────

class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid();

  static void _openSheet(BuildContext context, int i) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ServiceSheet(index: i),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: _kServiceItems.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1, indent: 76, color: Color(0xFF2A2A2A),
      ),
      itemBuilder: (context, i) => _StoreRow(
        item: _kServiceItems[i],
        onTap: () => _openSheet(context, i),
      ),
    );
  }
}

// ─── service sheet ────────────────────────────────────────────────────────────

const _kServiceSheets = [
  // 🔧 השכרת כלים
  [
    (emoji: '🔨', label: 'מקדחה', sub: 'מושכרת עד 30.5'),
    (emoji: '🪚', label: 'משור חשמלי', sub: 'מושכר עד 28.5'),
    (emoji: '➕', label: 'הוסף כלי', sub: ''),
  ],
  // 💰 פקדונות
  [
    (emoji: '💳', label: 'פיקדון #123', sub: '₪350 · פעיל'),
    (emoji: '↩️', label: 'בקשת החזר', sub: ''),
  ],
  // ↩️ החזרה חדשה
  [
    (emoji: '📋', label: 'בקשה #567', sub: 'ממתינה לאישור'),
    (emoji: '📦', label: 'פריטים להחזרה', sub: '3 יחידות'),
    (emoji: '🚛', label: 'תיאום איסוף', sub: ''),
  ],
  // 📨 מכרז ספקים
  [
    (emoji: '🏪', label: 'ספק A', sub: '₪4,200 · הצעה חדשה'),
    (emoji: '🏪', label: 'ספק B', sub: '₪3,980 · הצעה חדשה'),
    (emoji: '🏪', label: 'ספק C', sub: '₪4,500 · הצעה חדשה'),
  ],
  // 🧪 גיליונות בטיחות
  [
    (emoji: '📄', label: 'ברזל 12mm', sub: 'עודכן 20.5'),
    (emoji: '📄', label: 'צבע אפוקסי', sub: 'עודכן 18.5'),
    (emoji: '📄', label: 'דבק אפוקסי', sub: 'עודכן 15.5'),
    (emoji: '📄', label: 'ממס ניקוי', sub: 'עודכן 12.5'),
    (emoji: '📄', label: 'בטון יצוק', sub: 'עודכן 10.5'),
  ],
  // 📊 השוואת מחירים
  [
    (emoji: '🏪', label: 'רוט', sub: 'ברזל 12mm · ₪4.20'),
    (emoji: '🏪', label: 'מ.א. שלמה', sub: 'ברזל 12mm · ₪3.85'),
    (emoji: '🏪', label: 'אחים כהן', sub: 'ברזל 12mm · ₪4.10'),
    (emoji: '🏪', label: 'בני ברק מבנים', sub: 'ברזל 12mm · ₪3.95'),
  ],
];

class _ServiceSheet extends StatelessWidget {
  const _ServiceSheet({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final svc = _kServices[index];
    final rows = _kServiceSheets[index];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${svc.emoji} ${svc.title}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              svc.sub,
              style: const TextStyle(color: Color(0xFF888888), fontSize: 13),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF2A2A2A), height: 1),
          ...rows.map(
            (r) => ListTile(
              leading: Text(r.emoji, style: const TextStyle(fontSize: 22)),
              title: Text(r.label,
                  style: const TextStyle(color: Colors.white, fontSize: 15)),
              subtitle: r.sub.isEmpty
                  ? null
                  : Text(r.sub,
                      style: const TextStyle(
                          color: Color(0xFF888888), fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                showToast(context, '${r.label} — בבנייה');
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── orders list ──────────────────────────────────────────────────────────────

class _OrdersList extends StatelessWidget {
  const _OrdersList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: _kOrders.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1, indent: 76, color: Color(0xFF2A2A2A),
      ),
      itemBuilder: (context, i) => _OrderRow(order: _kOrders[i]),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order});
  final _Order order;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showToast(context, 'הזמנה ${order.id} — בבנייה'),
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
              child: const Text('📦', style: TextStyle(fontSize: 24)),
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
                          order.id,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        order.time,
                        style: const TextStyle(
                          color: Color(0xFF888888),
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
                          '${order.items} · ${order.total}',
                          style: const TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: order.stageColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: order.stageColor.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          order.stageLabel,
                          style: TextStyle(
                            color: order.stageColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
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
