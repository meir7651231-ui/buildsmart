import 'package:buildsmart/state/cart_lists_state.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Store section tabs.
enum StoreSection { all, cart, orders, services }

final storeSectionProvider =
    StateProvider<StoreSection>((_) => StoreSection.all);
final storeSearchQueryProvider = StateProvider<String>((_) => '');
final storeFavoritesProvider =
    StateProvider<Set<String>>((_) => const {});

// ─── cart state ──────────────────────────────────────────────────────────────

enum CartDelivery { express, standard, pickup }

enum CartPaymentMethod { card, bit, supplierCredit }

final cartQtysProvider = StateProvider<Map<String, int>>(
  (_) => const {'blk': 150, 'pls': 5, 'blt': 80, 'bm': 10},
);
final cartDeliveryProvider =
    StateProvider<CartDelivery>((_) => CartDelivery.standard);
final cartProjectProvider = StateProvider<String>((_) => 'בית דוד 3');
final cartPaymentProvider =
    StateProvider<CartPaymentMethod>((_) => CartPaymentMethod.card);

// ─── static data ─────────────────────────────────────────────────────────────

typedef _Meta = ({
  String emoji,
  String title,
  String preview,
  String time,
  int badge,
});

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

const List<_Meta> _kCartItems = [
  (emoji: '🛒', title: 'הסל שלי', preview: '3 פריטים ממתינים לסיכום', time: 'עכשיו', badge: 3),
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

// ─── cart data ────────────────────────────────────────────────────────────────

typedef _CartItem = ({String emoji, String name, String qty, String price});

const List<_CartItem> _kCartItemDetails = [
  (emoji: '🪨', name: 'בלוקים 20x20', qty: "200 יח'", price: '₪680'),
  (emoji: '🔩', name: 'ברגים 8cm',    qty: "500 יח'", price: '₪210'),
  (emoji: '🪵', name: 'קורות עץ 3m',  qty: "10 יח'",  price: '₪450'),
];
const _kCartTotal = '₪1,340';

// ─── cart items ──────────────────────────────────────────────────────────────

typedef _CItem = ({
  String id,
  String emoji,
  String name,
  String supplier,
  String unit,
  int unitPrice,
});

const List<_CItem> _kCItems = [
  (id: 'blk', emoji: '🪨', name: "בלוקים 20×20",   supplier: "מרינוביץ'",  unit: "יח'", unitPrice: 4),
  (id: 'pls', emoji: '🪣', name: 'שפכטל 20 ק"ג',  supplier: "מרינוביץ'",  unit: "שק'", unitPrice: 42),
  (id: 'blt', emoji: '🔩', name: 'ברגי אנקר M12',  supplier: 'פריגו',       unit: "יח'", unitPrice: 3),
  (id: 'bm',  emoji: '🪵', name: "קורות עץ 3מ'",   supplier: 'פריגו',       unit: "יח'", unitPrice: 45),
];

const _kProjects = ['בית דוד 3', 'מגדל עזריאלי', 'ללא פרויקט'];

typedef _DOption = ({CartDelivery method, String emoji, String label, int fee});
typedef _POption = ({CartPaymentMethod method, String emoji, String label});

const _kDeliveryOptions = <_DOption>[
  (method: CartDelivery.express,  emoji: '⚡', label: '4 שעות',      fee: 120),
  (method: CartDelivery.standard, emoji: '📦', label: 'יום-יומיים',  fee: 45),
  (method: CartDelivery.pickup,   emoji: '🏪', label: 'איסוף עצמי',  fee: 0),
];

const _kPaymentOptions = <_POption>[
  (method: CartPaymentMethod.card,           emoji: '💳', label: 'כרטיס'),
  (method: CartPaymentMethod.bit,            emoji: '📲', label: 'ביט'),
  (method: CartPaymentMethod.supplierCredit, emoji: '🤝', label: 'אשראי ספק'),
];

String _price(int n) {
  if (n < 1000) return '₪$n';
  return '₪${n ~/ 1000},${(n % 1000).toString().padLeft(3, '0')}';
}

// ─── screen ──────────────────────────────────────────────────────────────────

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  bool _headerVisible = true;

  void _setHeaderVisible(bool v) {
    if (_headerVisible == v) return;
    setState(() => _headerVisible = v);
    ref.read(tabHeaderHiddenProvider.notifier).state = !v;
  }

  bool _handleScroll(ScrollNotification n) {
    if (n is ScrollUpdateNotification && n.depth == 0) {
      final delta = n.scrollDelta ?? 0;
      final px = n.metrics.pixels;
      if (delta > 6 && _headerVisible && px > 50) {
        _setHeaderVisible(false);
      } else if (delta < -6 && !_headerVisible) {
        _setHeaderVisible(true);
      } else if (px <= 2 && !_headerVisible) {
        _setHeaderVisible(true);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(tabHeaderHiddenProvider, (_, hidden) {
      if (!hidden && !_headerVisible) _setHeaderVisible(true);
    });
    return Column(
      children: [
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _headerVisible
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SearchBar(),
                      _SectionChipsRow(),
                      _SummaryRow(),
                      _QuickActionsRow(),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScroll,
            child: const _StoreList(),
          ),
        ),
      ],
    );
  }
}

// ─── summary row ─────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: const [
          _SummaryChip(label: '🛒 3 פריטים בסל',    color: BsTokens.brand),
          SizedBox(width: 8),
          _SummaryChip(label: '📦 2 הזמנות פתוחות', color: Color(0xFF4CAF50)),
          SizedBox(width: 8),
          _SummaryChip(label: '📨 3 הצעות ספקים',   color: Color(0xFFFF9800)),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── search bar ──────────────────────────────────────────────────────────────

class _SearchBar extends ConsumerStatefulWidget {
  const _SearchBar();

  @override
  ConsumerState<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<_SearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(storeSearchQueryProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: TextField(
        controller: _controller,
        onChanged: (v) =>
            ref.read(storeSearchQueryProvider.notifier).state = v,
        decoration: InputDecoration(
          hintText: 'חיפוש הזמנות ומוצרים...',
          hintStyle: const TextStyle(color: Color(0xFF888888)),
          prefixIcon:
              const Icon(Icons.search, color: Color(0xFF888888), size: 20),
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close,
                      color: Color(0xFF888888), size: 18),
                  onPressed: () {
                    _controller.clear();
                    ref.read(storeSearchQueryProvider.notifier).state = '';
                  },
                ),
          filled: true,
          fillColor: const Color(0xFF2A2A2A),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            _Pill(
              label: 'הכל',
              active: section == StoreSection.all,
              onTap: () => select(StoreSection.all),
            ),
            const SizedBox(width: 8),
            _Pill(
              label: '🛒 הסל',
              active: section == StoreSection.cart,
              onTap: () => select(StoreSection.cart),
            ),
            const SizedBox(width: 8),
            _Pill(
              label: '📦 הזמנות',
              active: section == StoreSection.orders,
              onTap: () => select(StoreSection.orders),
            ),
            const SizedBox(width: 8),
            _Pill(
              label: '🔧 שירותים',
              active: section == StoreSection.services,
              onTap: () => select(StoreSection.services),
            ),
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
    showModalBottomSheet<void>(
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
  Widget build(BuildContext context) => const _SheetScaffold(
        title: 'מועדים',
        emoji: '📅',
        children: [
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
  Widget build(BuildContext context) => const _SheetScaffold(
        title: 'תזמון',
        emoji: '📆',
        children: [
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
          .map(
            (c) => ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF333333),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(c.avatar, style: const TextStyle(fontSize: 20)),
              ),
              title: Text(c.name,
                  style: const TextStyle(color: Colors.white, fontSize: 15)),
              trailing:
                  const Icon(Icons.phone_outlined, color: Colors.white38),
              onTap: () {
                Navigator.pop(context);
                showToast(context, 'שיחה עם ${c.name} — בבנייה');
              },
            ),
          )
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
      title:
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 15)),
      onTap: () {
        Navigator.pop(context);
        showToast(context, '$label — בבנייה');
      },
    );
  }
}

// ─── store list with pull-to-refresh ─────────────────────────────────────────

class _StoreList extends ConsumerStatefulWidget {
  const _StoreList();

  @override
  ConsumerState<_StoreList> createState() => _StoreListState();
}

class _StoreListState extends ConsumerState<_StoreList> {
  Future<void> _onRefresh() =>
      Future<void>.delayed(const Duration(milliseconds: 800));

  @override
  Widget build(BuildContext context) {
    final section = ref.watch(storeSectionProvider);
    return RefreshIndicator(
      color: BsTokens.brand,
      backgroundColor: const Color(0xFF2A2A2A),
      onRefresh: _onRefresh,
      child: switch (section) {
        StoreSection.services => const _ServicesGrid(),
        StoreSection.orders   => const _OrdersList(),
        StoreSection.cart     => const _CartView(),
        _                     => _AllList(section: section),
      },
    );
  }
}

// ─── all / cart list ──────────────────────────────────────────────────────────

// maps service emoji → index in _kServices (for sheet lookup)
const _kServiceByEmoji = {
  '🔧': 0, '💰': 1, '↩️': 2, '📨': 3, '🧪': 4, '📊': 5,
};

class _AllList extends ConsumerWidget {
  const _AllList({required this.section});
  final StoreSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(storeSearchQueryProvider).trim().toLowerCase();
    final favorites = ref.watch(storeFavoritesProvider);
    final allItems = _itemsForSection(section);
    final items = query.isEmpty
        ? allItems
        : allItems
            .where(
              (item) =>
                  item.title.toLowerCase().contains(query) ||
                  item.preview.toLowerCase().contains(query),
            )
            .toList();

    if (items.isEmpty) {
      return _EmptyState(query: query);
    }

    return ListView.separated(
      key: ValueKey(section),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        indent: 76,
        color: Color(0xFF2A2A2A),
      ),
      itemBuilder: (context, i) {
        final item = items[i];
        final svcIdx = _kServiceByEmoji[item.emoji];
        final isFav = favorites.contains(item.title);
        return _DismissibleStoreRow(
          key: ValueKey(item.title),
          item: item,
          isFav: isFav,
          onFavToggle: () {
            final notifier = ref.read(storeFavoritesProvider.notifier);
            final current = Set<String>.from(notifier.state);
            if (isFav) {
              current.remove(item.title);
            } else {
              current.add(item.title);
            }
            notifier.state = current;
          },
          onTap: svcIdx != null
              ? () => _ServicesGrid._openSheet(context, svcIdx)
              : item.emoji == '🛒'
                  ? () => ref.read(storeSectionProvider.notifier).state =
                        StoreSection.cart
                  : item.emoji == '📦'
                      ? () => ref.read(storeSectionProvider.notifier).state =
                            StoreSection.orders
                      : null,
        );
      },
    );
  }

  void _showCartSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _CartSheet(),
    );
  }
}

// ─── swipe-to-favorite ────────────────────────────────────────────────────────

class _DismissibleStoreRow extends StatelessWidget {
  const _DismissibleStoreRow({
    super.key,
    required this.item,
    required this.isFav,
    required this.onFavToggle,
    this.onTap,
  });

  final _Meta item;
  final bool isFav;
  final VoidCallback onFavToggle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('fav_${item.title}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onFavToggle();
        return false;
      },
      background: const ColoredBox(color: Color(0xFF1A1A1A)),
      secondaryBackground: ColoredBox(
        color: Colors.pink.withValues(alpha: 0.15),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 20),
            child: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: Colors.pinkAccent,
              size: 26,
            ),
          ),
        ),
      ),
      child: _StoreRow(item: item, isFav: isFav, onTap: onTap),
    );
  }
}

// ─── store row ───────────────────────────────────────────────────────────────

class _StoreRow extends StatelessWidget {
  const _StoreRow({required this.item, required this.isFav, this.onTap});

  final _Meta item;
  final bool isFav;
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
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2A2A2A),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child:
                      Text(item.emoji, style: const TextStyle(fontSize: 24)),
                ),
                if (isFav)
                  const Positioned(
                    bottom: 0,
                    right: 0,
                    child: Icon(
                      Icons.favorite,
                      color: Colors.pinkAccent,
                      size: 14,
                    ),
                  ),
              ],
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

// ─── empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: constraints.maxHeight,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔍', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(
                  query.isEmpty
                      ? 'אין פריטים'
                      : 'לא נמצאו תוצאות\nעבור "$query"',
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── cart sheet ──────────────────────────────────────────────────────────────

class _CartSheet extends StatelessWidget {
  const _CartSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
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
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              '🛒 הסל שלי',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF2A2A2A), height: 1),
          ..._kCartItemDetails.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Text(item.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.name,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  Text(
                    item.qty,
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item.price,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: Color(0xFF2A2A2A), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'סה"כ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                _kCartTotal,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: BsTokens.brand,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              Navigator.pop(context);
              showToast(context, 'מעבר לתשלום — בבנייה');
            },
            child: const Text(
              'מעבר לתשלום →',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── cart view ────────────────────────────────────────────────────────────────

class _CartView extends ConsumerStatefulWidget {
  const _CartView();

  @override
  ConsumerState<_CartView> createState() => _CartViewState();
}

class _CartViewState extends ConsumerState<_CartView> {
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qtys = ref.watch(cartQtysProvider);
    final delivery = ref.watch(cartDeliveryProvider);
    final project = ref.watch(cartProjectProvider);
    final payment = ref.watch(cartPaymentProvider);
    final smartLines = ref.watch(smartCartProvider);

    final grouped = <String, List<_CItem>>{};
    for (final item in _kCItems) {
      (grouped[item.supplier] ??= []).add(item);
    }

    var subtotal = 0;
    for (final item in _kCItems) {
      subtotal += item.unitPrice * (qtys[item.id] ?? 0);
    }
    for (final line in smartLines) {
      subtotal += line.total;
    }
    final vat = (subtotal * 0.18).round();
    final deliveryFee = switch (delivery) {
      CartDelivery.express  => 120,
      CartDelivery.standard => 45,
      CartDelivery.pickup   => 0,
    };
    final total = subtotal + vat + deliveryFee;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        _ProjectSelector(selected: project),
        const SizedBox(height: 12),
        if (smartLines.isNotEmpty) ...[
          const _SupplierHeader(name: '🛠️ מוצרים חכמים'),
          for (var i = 0; i < smartLines.length; i++)
            _SmartCartRow(line: smartLines[i], index: i),
          const SizedBox(height: 4),
        ],
        for (final entry in grouped.entries) ...[
          _SupplierHeader(name: entry.key),
          for (final item in entry.value)
            _CartItemRow(item: item, qty: qtys[item.id] ?? 0),
          const SizedBox(height: 4),
        ],
        _DeliverySelector(selected: delivery),
        const SizedBox(height: 12),
        _NotesField(controller: _notesCtrl),
        const SizedBox(height: 12),
        _SummaryCard(
          subtotal: subtotal,
          vat: vat,
          deliveryFee: deliveryFee,
          total: total,
        ),
        const SizedBox(height: 12),
        _PaymentSelector(selected: payment),
        const SizedBox(height: 16),
        _CheckoutButton(total: total),
        const SizedBox(height: 4),
        const _CartActionsRow(),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── project selector ─────────────────────────────────────────────────────────

class _ProjectSelector extends ConsumerWidget {
  const _ProjectSelector({required this.selected});
  final String selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🏗️ שיוך לפרויקט',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final p in _kProjects) ...[
                _ProjectChip(
                  label: p,
                  active: p == selected,
                  onTap: () =>
                      ref.read(cartProjectProvider.notifier).state = p,
                ),
                const SizedBox(width: 8),
              ],
              GestureDetector(
                onTap: () => showToast(context, 'הוספת פרויקט — בבנייה'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF444444)),
                  ),
                  child: const Text(
                    '+ הוסף',
                    style: TextStyle(color: Color(0xFF888888), fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProjectChip extends StatelessWidget {
  const _ProjectChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? BsTokens.brand : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFFAAAAAA),
            fontSize: 13,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ─── smart cart row (from product sheet) ─────────────────────────────────────

class _SmartCartRow extends ConsumerWidget {
  const _SmartCartRow({required this.line, required this.index});
  final SmartCartLine line;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: BsTokens.brand.withAlpha(60),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: BsTokens.brand.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(line.productEmoji,
                    style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${line.productName} × ${line.productQty}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      line.brandName,
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₪${line.total}',
                style: const TextStyle(
                  color: BsTokens.brand,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close,
                    color: Color(0xFF666666), size: 18),
                onPressed: () =>
                    ref.read(smartCartProvider.notifier).remove(index),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          if (line.accessories.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(height: 1, color: Color(0xFF2A2A2A)),
            const SizedBox(height: 6),
            for (final a in line.accessories)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text(a.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${a.name} × ${a.qty}',
                        style: const TextStyle(
                          color: Color(0xFFAAAAAA),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      '₪${a.price * a.qty}',
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ─── supplier header ──────────────────────────────────────────────────────────

class _SupplierHeader extends StatelessWidget {
  const _SupplierHeader({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            '🏪 $name',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'אספקה: יום-יומיים',
            style: TextStyle(color: Color(0xFF888888), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ─── cart item row ────────────────────────────────────────────────────────────

class _CartItemRow extends ConsumerWidget {
  const _CartItemRow({required this.item, required this.qty});

  final _CItem item;
  final int qty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineTotal = item.unitPrice * qty;

    void setQty(int newQty) {
      final current = Map<String, int>.from(ref.read(cartQtysProvider));
      if (newQty <= 0) {
        current.remove(item.id);
      } else {
        current[item.id] = newQty;
      }
      ref.read(cartQtysProvider.notifier).state = current;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${_price(item.unitPrice)} / ${item.unit}',
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setQty(0),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 16, color: Color(0xFF666666)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StepBtn(
                      icon: Icons.remove,
                      onTap: qty > 1 ? () => setQty(qty - 1) : null,
                    ),
                    SizedBox(
                      width: 44,
                      child: Text(
                        '$qty',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    _StepBtn(
                      icon: Icons.add,
                      onTap: () => setQty(qty + 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                _price(lineTotal),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? BsTokens.brand : const Color(0xFF444444),
        ),
      ),
    );
  }
}

// ─── delivery selector ────────────────────────────────────────────────────────

class _DeliverySelector extends ConsumerWidget {
  const _DeliverySelector({required this.selected});
  final CartDelivery selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🚚 אפשרויות משלוח',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (int i = 0; i < _kDeliveryOptions.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: _DeliveryCard(
                  option: _kDeliveryOptions[i],
                  active: _kDeliveryOptions[i].method == selected,
                  onTap: () => ref.read(cartDeliveryProvider.notifier).state =
                      _kDeliveryOptions[i].method,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({
    required this.option,
    required this.active,
    required this.onTap,
  });

  final _DOption option;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: active
              ? BsTokens.brand.withValues(alpha: 0.12)
              : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? BsTokens.brand : const Color(0xFF333333),
          ),
        ),
        child: Column(
          children: [
            Text(option.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              option.label,
              style: TextStyle(
                color: active ? BsTokens.brand : Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              option.fee == 0 ? 'חינם' : _price(option.fee),
              style: const TextStyle(
                color: Color(0xFF888888),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── notes field ──────────────────────────────────────────────────────────────

class _NotesField extends StatelessWidget {
  const _NotesField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📝 הערות לשליח',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          cursorColor: BsTokens.brand,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'קומה / כניסה / שם האתר / הוראות לנהג...',
            hintStyle: const TextStyle(color: Color(0xFF666666)),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── summary card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.subtotal,
    required this.vat,
    required this.deliveryFee,
    required this.total,
  });

  final int subtotal;
  final int vat;
  final int deliveryFee;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _SummaryLine(label: 'סכום ביניים', value: _price(subtotal)),
          const SizedBox(height: 6),
          _SummaryLine(label: 'מע"מ 18%', value: _price(vat)),
          const SizedBox(height: 6),
          _SummaryLine(
            label: 'משלוח',
            value: deliveryFee == 0 ? 'חינם' : _price(deliveryFee),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Color(0xFF2A2A2A), height: 1),
          ),
          _SummaryLine(label: 'סה"כ לתשלום', value: _price(total), bold: true),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          )
        : const TextStyle(color: Color(0xFF888888), fontSize: 13);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}

// ─── payment selector ─────────────────────────────────────────────────────────

class _PaymentSelector extends ConsumerWidget {
  const _PaymentSelector({required this.selected});
  final CartPaymentMethod selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💳 אמצעי תשלום',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < _kPaymentOptions.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                _PaymentChip(
                  option: _kPaymentOptions[i],
                  active: _kPaymentOptions[i].method == selected,
                  onTap: () =>
                      ref.read(cartPaymentProvider.notifier).state =
                          _kPaymentOptions[i].method,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentChip extends StatelessWidget {
  const _PaymentChip({
    required this.option,
    required this.active,
    required this.onTap,
  });

  final _POption option;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? BsTokens.brand : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(20),
          border: active ? null : Border.all(color: const Color(0xFF444444)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(option.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              option.label,
              style: TextStyle(
                color: active ? Colors.white : const Color(0xFFAAAAAA),
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── checkout button ──────────────────────────────────────────────────────────

class _CheckoutButton extends StatelessWidget {
  const _CheckoutButton({required this.total});
  final int total;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: BsTokens.brand,
        foregroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: () => showToast(context, 'מעבר לתשלום — בבנייה'),
      child: Text(
        'הזמן עכשיו · ${_price(total)} →',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ─── cart actions row ─────────────────────────────────────────────────────────

class _CartActionsRow extends ConsumerWidget {
  const _CartActionsRow();

  static void _showSaveDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'שמור סל כרשימה',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'שם הרשימה',
            hintStyle: const TextStyle(color: Color(0xFF666666)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) {
                showToast(context, 'שם הרשימה לא יכול להיות ריק');
                return;
              }
              final items = _kCartItemDetails
                  .map((item) => (
                        emoji: item.emoji,
                        name: item.name,
                        qty: int.tryParse(item.qty.split(' ')[0]) ?? 0,
                        price: item.price,
                      ))
                  .toList();
              ref
                  .read(cartListsProvider.notifier)
                  .saveCart(controller.text.trim(), items);
              Navigator.pop(context);
              showToast(context, 'הרשימה נשמרה בהצלחה');
            },
            child: const Text('שמור', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton.icon(
          onPressed: () => _showSaveDialog(context, ref),
          icon: const Icon(Icons.bookmark_border, size: 16),
          label: const Text('שמור'),
          style: TextButton.styleFrom(foregroundColor: Colors.white54),
        ),
        TextButton.icon(
          onPressed: () => showToast(context, 'שיתוף — בבנייה'),
          icon: const Icon(Icons.share_outlined, size: 16),
          label: const Text('שתף'),
          style: TextButton.styleFrom(foregroundColor: Colors.white54),
        ),
        TextButton.icon(
          onPressed: () => showToast(context, 'נקה סל — בבנייה'),
          icon: const Icon(Icons.delete_outline, size: 16),
          label: const Text('נקה'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.redAccent.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

// ─── services list ────────────────────────────────────────────────────────────

class _ServicesGrid extends ConsumerWidget {
  const _ServicesGrid();

  static void _openSheet(BuildContext context, int i) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ServiceSheet(index: i),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(storeSearchQueryProvider).trim().toLowerCase();
    final services = query.isEmpty
        ? _kServiceItems
        : _kServiceItems
            .where(
              (s) =>
                  s.title.toLowerCase().contains(query) ||
                  s.preview.toLowerCase().contains(query),
            )
            .toList();

    if (services.isEmpty) {
      return _EmptyState(query: query);
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: services.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        indent: 76,
        color: Color(0xFF2A2A2A),
      ),
      itemBuilder: (context, i) {
        final idx = _kServiceByEmoji[services[i].emoji] ?? i;
        return _StoreRow(
          item: services[i],
          isFav: false,
          onTap: () => _openSheet(context, idx),
        );
      },
    );
  }
}

// ─── service sheet ────────────────────────────────────────────────────────────

typedef _Service = ({String emoji, String title, String sub});

const List<_Service> _kServices = [
  (emoji: '🔧', title: 'השכרת כלים',     sub: '2 כלים פעילים'),
  (emoji: '💰', title: 'פקדונות',         sub: 'פיקדון ₪350'),
  (emoji: '↩️', title: 'החזרה חדשה',     sub: 'בקשה #567'),
  (emoji: '📨', title: 'מכרז ספקים',     sub: '3 הצעות חדשות'),
  (emoji: '🧪', title: 'גיליונות בטיחות', sub: '5 גיליונות'),
  (emoji: '📊', title: 'השוואת מחירים',  sub: '4 ספקים עודכנו'),
];

const _kServiceSheets = [
  // 🔧 השכרת כלים
  [
    (emoji: '🔨', label: 'מקדחה',        sub: 'מושכרת עד 30.5'),
    (emoji: '🪚', label: 'משור חשמלי',   sub: 'מושכר עד 28.5'),
    (emoji: '➕', label: 'הוסף כלי',     sub: ''),
  ],
  // 💰 פקדונות
  [
    (emoji: '💳', label: 'פיקדון #123',  sub: '₪350 · פעיל'),
    (emoji: '↩️', label: 'בקשת החזר',   sub: ''),
  ],
  // ↩️ החזרה חדשה
  [
    (emoji: '📋', label: 'בקשה #567',    sub: 'ממתינה לאישור'),
    (emoji: '📦', label: 'פריטים להחזרה', sub: '3 יחידות'),
    (emoji: '🚛', label: 'תיאום איסוף',  sub: ''),
  ],
  // 📨 מכרז ספקים
  [
    (emoji: '🏪', label: 'ספק A',        sub: '₪4,200 · הצעה חדשה'),
    (emoji: '🏪', label: 'ספק B',        sub: '₪3,980 · הצעה חדשה'),
    (emoji: '🏪', label: 'ספק C',        sub: '₪4,500 · הצעה חדשה'),
  ],
  // 🧪 גיליונות בטיחות
  [
    (emoji: '📄', label: 'ברזל 12mm',    sub: 'עודכן 20.5'),
    (emoji: '📄', label: 'צבע אפוקסי',  sub: 'עודכן 18.5'),
    (emoji: '📄', label: 'דבק אפוקסי',  sub: 'עודכן 15.5'),
    (emoji: '📄', label: 'ממס ניקוי',   sub: 'עודכן 12.5'),
    (emoji: '📄', label: 'בטון יצוק',   sub: 'עודכן 10.5'),
  ],
  // 📊 השוואת מחירים
  [
    (emoji: '🏪', label: 'רוט',           sub: 'ברזל 12mm · ₪4.20'),
    (emoji: '🏪', label: 'מ.א. שלמה',    sub: 'ברזל 12mm · ₪3.85'),
    (emoji: '🏪', label: 'אחים כהן',     sub: 'ברזל 12mm · ₪4.10'),
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
              style:
                  const TextStyle(color: Color(0xFF888888), fontSize: 13),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF2A2A2A), height: 1),
          ...rows.map(
            (r) => ListTile(
              leading:
                  Text(r.emoji, style: const TextStyle(fontSize: 22)),
              title: Text(r.label,
                  style:
                      const TextStyle(color: Colors.white, fontSize: 15)),
              subtitle: r.sub.isEmpty
                  ? null
                  : Text(
                      r.sub,
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 12,
                      ),
                    ),
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

// ─── mini pill ───────────────────────────────────────────────────────────────

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.search, color: Color(0xFF888888), size: 18),
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

// ─── orders list ──────────────────────────────────────────────────────────────

class _OrdersList extends ConsumerWidget {
  const _OrdersList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(storeSearchQueryProvider).trim().toLowerCase();
    final orders = query.isEmpty
        ? _kOrders
        : _kOrders
            .where(
              (o) =>
                  o.id.toLowerCase().contains(query) ||
                  o.items.toLowerCase().contains(query) ||
                  o.stageLabel.toLowerCase().contains(query),
            )
            .toList();

    if (orders.isEmpty) {
      return _EmptyState(query: query);
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        indent: 76,
        color: Color(0xFF2A2A2A),
      ),
      itemBuilder: (context, i) => _OrderRow(order: orders[i]),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order});
  final _Order order;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showModalBottomSheet<void>(
        context: context,
        backgroundColor: const Color(0xFF1A1A1A),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _OrderSheet(order: order),
      ),
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
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: order.stageColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: order.stageColor.withValues(alpha: 0.4),
                          ),
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

// ─── order sheet ──────────────────────────────────────────────────────────────

typedef _OrderItem = ({String name, String qty, String price});

const Map<String, List<_OrderItem>> _kOrderDetails = {
  'BS-1234': [
    (name: 'ברזל 12mm',  qty: "200 יח'", price: '₪840'),
    (name: 'בטון B30',   qty: '5 מ"ק',   price: '₪2,200'),
    (name: 'קורות עץ',  qty: "30 יח'",  price: '₪1,380'),
    (name: 'ברגים 10cm', qty: "500 יח'", price: '₪1,000'),
  ],
  'BS-1221': [
    (name: 'צבע לבן',      qty: "20 ל'",  price: '₪640'),
    (name: 'מברשות צבע',  qty: "10 יח'", price: '₪350'),
    (name: 'סיר בלויד',   qty: "5 יח'",  price: '₪900'),
  ],
  'BS-1198': [
    (name: 'מסמרים 8cm', qty: "1000 יח'", price: '₪420'),
    (name: 'כוכביות',    qty: "200 יח'",  price: '₪210'),
  ],
  'BS-1171': [
    (name: 'אריחים 60x60', qty: "80 יח'",  price: '₪1,600'),
    (name: 'דבק אריחים',  qty: "10 שק'",  price: '₪640'),
  ],
  'BS-1155': [
    (name: 'נורות לד',   qty: "10 יח'", price: '₪180'),
    (name: 'שקע חשמל',  qty: "5 יח'",  price: '₪130'),
  ],
};

class _OrderSheet extends StatelessWidget {
  const _OrderSheet({required this.order});
  final _Order order;

  @override
  Widget build(BuildContext context) {
    final items = _kOrderDetails[order.id] ?? [];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'הזמנה ${order.id}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: order.stageColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: order.stageColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  order.stageLabel,
                  style: TextStyle(
                    color: order.stageColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${order.items} · ${order.total} · ${order.time}',
            style:
                const TextStyle(color: Color(0xFF888888), fontSize: 13),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF2A2A2A), height: 1),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  const Text('📦', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    item.qty,
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item.price,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: Color(0xFF2A2A2A), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'סה"כ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                order.total,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A2A2A),
              foregroundColor: Colors.white70,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              Navigator.pop(context);
              showToast(context, 'מעקב הזמנה ${order.id} — בבנייה');
            },
            child: const Text(
              'מעקב הזמנה 🚛',
              style: TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
