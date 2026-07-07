import 'package:buildsmart/features/global_search/global_search.dart'
    show kGlobalSearch;
import 'package:buildsmart/screens/contractor_tools_sheets.dart';
import 'package:buildsmart/screens/finance_hub_sheets.dart';
import 'package:buildsmart/screens/order_notif_sheet.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/cart_lists_state.dart';
import 'package:buildsmart/state/catalog_settings.dart' show kVatRate;
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/state/projects_engine.dart';
import 'package:buildsmart/state/share_seam.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/state/store_settings.dart';
import 'package:buildsmart/state/telemetry.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/smart_input/nav/category_suggestion_strip.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reconstructs a saved cart line's (per-unit price, qty) so the resulting
/// [SmartCartLine.total] equals [total] exactly. A single int brandPrice can
/// represent it as brandPrice*qty only when total is divisible by qty; otherwise
/// collapse to one unit at the full total (total wins over qty granularity).
/// Guards the W1 reload bug where `total ~/ qty` shaved up to (qty-1) ₪ off the
/// line. Pinned by test/saved_line_reconstruct_test.dart.
({int brandPrice, int qty}) savedLineReconstruct(int total, int qty) {
  final q = qty > 0 ? qty : 1;
  return total % q == 0
      ? (brandPrice: total ~/ q, qty: q)
      : (brandPrice: total, qty: 1);
}

/// Store section tabs.
enum StoreSection { all, cart, orders, services }

final storeSectionProvider = StateProvider<StoreSection>(
  (_) => StoreSection.all,
);
final storeSearchQueryProvider = StateProvider<String>((_) => '');

/// GLOBAL SEARCH seam ([kGlobalSearch]) — the order id a global-search hit asks
/// the store to open. [_StoreScreenState] listens (flag-gated) and opens that
/// order's detail sheet, then nulls this so a repeat hit re-fires. Mirrors the
/// chats' updatesChatOpenProvider. Never set when the flag is OFF (the source is
/// tree-shaken), so the listener + opener fold out and the screen stays
/// byte-identical.
final storeOrderOpenProvider = StateProvider<String?>((_) => null);

/// Favorited store-hub rows (by title). Persisted to SharedPreferences so the
/// ⭐ set survives restarts.
class StoreFavoritesNotifier extends StateNotifier<Set<String>> {
  StoreFavoritesNotifier() : super(const {}) {
    _load();
  }
  static const _prefsKey = 'bs.store-favorites.v1';

  /// True once any mutation has been applied (or _load completes).
  /// Guards against _load clobbering a toggle that arrived before prefs.
  bool _loaded = false;

  @override
  set state(Set<String> value) {
    _loaded = true; // mutation happened — block any pending _load
    super.state = value;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_prefsKey);
      if (!_loaded && list != null) {
        super.state = list.toSet(); // bypass setter to avoid blocking self
        _loaded = true;
      } else {
        _loaded = true;
      }
    } catch (_) {
      _loaded = true;
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, state.toList());
    } catch (_) {}
  }

  void toggle(String key) {
    state =
        state.contains(key)
            ? (Set<String>.of(state)..remove(key))
            : (Set<String>.of(state)..add(key));
    _persist();
  }
}

final storeFavoritesProvider =
    StateNotifierProvider<StoreFavoritesNotifier, Set<String>>(
      (_) => StoreFavoritesNotifier(),
    );

// ─── cart state ──────────────────────────────────────────────────────────────

enum CartDelivery { express, standard, pickup }

enum CartPaymentMethod { card, bit, supplierCredit }

final cartQtysProvider = StateProvider<Map<String, int>>((_) => const {});
// Initial delivery/payment honor the store-settings defaults (read once).
// Pure mappings (regression-tested in test/gaps_test.dart).
CartDelivery cartDeliveryFor(bool selfPickupDefault) =>
    selfPickupDefault ? CartDelivery.pickup : CartDelivery.standard;
CartPaymentMethod cartPaymentFor(StorePayment p) => switch (p) {
  StorePayment.bit => CartPaymentMethod.bit,
  StorePayment.supplierCredit => CartPaymentMethod.supplierCredit,
  StorePayment.card || StorePayment.applePay => CartPaymentMethod.card,
};

final cartDeliveryProvider = StateProvider<CartDelivery>(
  (ref) => cartDeliveryFor(ref.read(storeSettingsProvider).selfPickupDefault),
);
/// The checkout's selected project (the order's recorded `site`). The projects
/// engine is canonical: this holds only the *checkout selection*, and its
/// default IS the active project's name. Watching [activeProjectProvider] means
/// switching the active project (in projects_screen) recomputes this initial
/// value, so checkout defaults to the newly-active project. The user may still
/// pick a different project (or 'ללא פרויקט') for this order via the picker.
final cartProjectProvider = StateProvider<String>(
  (ref) => ref.watch(activeProjectProvider).name,
);

/// Benzi #4 — optional, NON-binding "where to ship" address chosen during the
/// purchase (empty = not set; checkout never requires it).
final shipToProvider = StateProvider<String>((_) => '');

/// Benzi #4 — whether the one-time "לאן לשלוח" popup has already been shown. It
/// pops up ONCE, the first time a product is added to the cart (the selection
/// stage) — never at checkout.
///
/// Default **true** (mirrors `welcomeSeenProvider`) so widget tests never trip
/// the popup; `main()` overrides it with the persisted value, where an absent
/// key → `false` → a fresh install sees the popup on its first product.
const String kShipToPromptedKey = 'bs.shipto-prompted.v1';
final shipToPromptedProvider = StateProvider<bool>((ref) => true);

/// Read the persisted "already-prompted" flag (absent → false → will prompt).
Future<bool> loadShipToPrompted() async =>
    (await SharedPreferences.getInstance()).getBool(kShipToPromptedKey) ??
    false;

/// Persist that the one-time popup has been shown — so it never prompts again.
Future<void> saveShipToPrompted() async =>
    (await SharedPreferences.getInstance()).setBool(kShipToPromptedKey, true);
final cartPaymentProvider = StateProvider<CartPaymentMethod>(
  (ref) => cartPaymentFor(ref.read(storeSettingsProvider).defaultPayment),
);

/// Free-text delivery note carried into the confirmed order.
final cartNotesProvider = StateProvider<String>((_) => '');

// ─── static data ─────────────────────────────────────────────────────────────

typedef _Meta =
    ({String emoji, String title, String preview, String time, int badge});

const List<_Meta> _kAllItems = [
  (
    emoji: '🛒',
    title: 'הסל שלי',
    preview: '3 פריטים ממתינים לסיכום',
    time: 'עכשיו',
    badge: 3,
  ),
  (
    emoji: '📦',
    title: 'ההזמנות שלי',
    preview: 'הזמנה #1234 · בדרך אליך',
    time: 'אתמול',
    badge: 1,
  ),
  (
    emoji: '🔧',
    title: 'השכרת כלים',
    preview: '2 כלים מושכרים עד 30.5',
    time: '21.5',
    badge: 0,
  ),
  (
    emoji: '💰',
    title: 'פקדונות',
    preview: 'פיקדון פעיל · ₪350',
    time: '21.5',
    badge: 0,
  ),
  (
    emoji: '↩️',
    title: 'החזרה חדשה',
    preview: 'בקשה #567 ממתינה לאישור',
    time: '20.5',
    badge: 0,
  ),
  (
    emoji: '📨',
    title: 'מכרז ספקים',
    preview: '3 הצעות חדשות התקבלו',
    time: '20.5',
    badge: 3,
  ),
  (
    emoji: '🧪',
    title: 'גיליונות בטיחות',
    preview: '5 גיליונות זמינים להורדה',
    time: '19.5',
    badge: 0,
  ),
  (
    emoji: '📊',
    title: 'השוואת מחירים',
    preview: '4 ספקים עדכנו מחירים',
    time: '19.5',
    badge: 2,
  ),
];

const List<_Meta> _kCartItems = [
  (
    emoji: '🛒',
    title: 'הסל שלי',
    preview: '3 פריטים ממתינים לסיכום',
    time: 'עכשיו',
    badge: 3,
  ),
];

const List<_Meta> _kOrderItems = [
  (
    emoji: '📦',
    title: 'ההזמנות שלי',
    preview: 'הזמנה #1234 · בדרך אליך',
    time: 'אתמול',
    badge: 1,
  ),
];

const List<_Meta> _kServiceItems = [
  (
    emoji: '🔧',
    title: 'השכרת כלים',
    preview: '2 כלים מושכרים עד 30.5',
    time: '21.5',
    badge: 0,
  ),
  (
    emoji: '💰',
    title: 'פקדונות',
    preview: 'פיקדון פעיל · ₪350',
    time: '21.5',
    badge: 0,
  ),
  (
    emoji: '↩️',
    title: 'החזרה חדשה',
    preview: 'בקשה #567 ממתינה לאישור',
    time: '20.5',
    badge: 0,
  ),
  (
    emoji: '📨',
    title: 'מכרז ספקים',
    preview: '3 הצעות חדשות התקבלו',
    time: '20.5',
    badge: 3,
  ),
  (
    emoji: '🧪',
    title: 'גיליונות בטיחות',
    preview: '5 גיליונות זמינים להורדה',
    time: '19.5',
    badge: 0,
  ),
  (
    emoji: '📊',
    title: 'השוואת מחירים',
    preview: '4 ספקים עדכנו מחירים',
    time: '19.5',
    badge: 2,
  ),
];

List<_Meta> _itemsForSection(StoreSection s) => switch (s) {
  StoreSection.all => _kAllItems,
  StoreSection.cart => _kCartItems,
  StoreSection.orders => _kOrderItems,
  StoreSection.services => _kServiceItems,
};

// ─── cart data ────────────────────────────────────────────────────────────────

// ─── cart items ──────────────────────────────────────────────────────────────

typedef _CItem =
    ({
      String id,
      String emoji,
      String name,
      String supplier,
      String unit,
      int unitPrice,
    });

// Real cart is driven entirely by smartCartProvider (products the user added).
// No injected demo items.
const List<_CItem> _kCItems = [];

const _kProjects = ['בית דוד 3', 'מגדל עזריאלי', 'ללא פרויקט'];

/// DEPRECATED / VESTIGIAL. The store-local project list. As of the
/// projects-engine unification, the checkout picker reads the PROJECTS ENGINE
/// ([projectsProvider]) and adds via its API; nothing in the checkout path uses
/// this provider anymore. It is kept defined only so the legacy
/// `test/state_deep_test.dart` (which asserts this exact store seed) still
/// compiles — that test should be retired/updated by the orchestrator. Do not
/// wire new behavior to it.
class StoreProjectsNotifier extends StateNotifier<List<String>> {
  StoreProjectsNotifier() : super(List.of(_kProjects)) {
    _load();
  }
  static const _prefsKey = 'bs.store-projects.v1';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_prefsKey);
      if (list != null && list.isNotEmpty) state = list;
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, state);
    } catch (_) {}
  }

  void add(String name) {
    if (state.contains(name)) return;
    state = [...state, name];
    _persist();
  }
}

/// DEPRECATED / VESTIGIAL — see [StoreProjectsNotifier]. Retained for the legacy
/// `state_deep_test.dart` only; the checkout now sources projects from the
/// projects engine ([projectsProvider]).
final storeProjectsProvider =
    StateNotifierProvider<StoreProjectsNotifier, List<String>>(
  (_) => StoreProjectsNotifier(),
);

typedef _DOption = ({CartDelivery method, String emoji, String label, int fee});
typedef _POption = ({CartPaymentMethod method, String emoji, String label});

const _kDeliveryOptions = <_DOption>[
  (method: CartDelivery.express, emoji: '⚡', label: '4 שעות', fee: 120),
  (method: CartDelivery.standard, emoji: '📦', label: 'יום-יומיים', fee: 45),
  (method: CartDelivery.pickup, emoji: '🏪', label: 'איסוף עצמי', fee: 0),
];

const _kPaymentOptions = <_POption>[
  (method: CartPaymentMethod.card, emoji: '💳', label: 'כרטיס'),
  (method: CartPaymentMethod.bit, emoji: '📲', label: 'ביט'),
  (method: CartPaymentMethod.supplierCredit, emoji: '🤝', label: 'אשראי ספק'),
];

String _price(int n) {
  if (n < 0) return '-${_price(-n)}';
  final s = n.toString();
  final b = StringBuffer('₪');
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

// ─── cart math (pure, regression-tested in test/gaps_test.dart) ───────────────

int deliveryFeeFor(CartDelivery d) => switch (d) {
  CartDelivery.express => 120,
  CartDelivery.standard => 45,
  CartDelivery.pickup => 0,
};

/// VAT amount for a subtotal. When [vatInclusive] the VAT is already embedded
/// in the prices (so it's the VAT portion of the gross); otherwise it's added
/// on top. Derives from the single-source [kVatRate] so the cart CHARGE always
/// matches the catalog's browse price (`priceWithVat`) — never a 17/18 split.
int cartVat(int subtotal, {required bool vatInclusive}) =>
    vatInclusive
        ? subtotal - (subtotal / (1 + kVatRate)).round()
        : (subtotal * kVatRate).round();

int cartTotal(int subtotal, int deliveryFee, {required bool vatInclusive}) =>
    vatInclusive
        ? subtotal + deliveryFee
        : subtotal + cartVat(subtotal, vatInclusive: false) + deliveryFee;

/// Total number of units in the cart: summed fixed-item quantities plus the
/// quantity of every smart-cart line (so 3× of one product counts as 3).
int cartItemCount(Map<String, int> qtys, List<SmartCartLine> smartLines) =>
    qtys.values.where((q) => q > 0).fold<int>(0, (s, q) => s + q) +
    smartLines.fold<int>(0, (s, l) => s + l.productQty);

/// Order stage that means the order is finished (no longer "open").
const String kDeliveredStage = 'delivered';

/// An order is "open" until it has been delivered.
bool isOrderOpen(String stage) => stage != kDeliveredStage;

/// Checkout is blocked when a positive minimum is set and the subtotal is below it.
bool cartBelowMinimum(int subtotal, StoreSettings s) =>
    s.minOrderAmount > 0 && subtotal < s.minOrderAmount;

/// Checkout asks for confirmation when the total reaches the large-order threshold.
bool cartNeedsLargeConfirm(int total, StoreSettings s) =>
    s.confirmLargeOrder && total >= s.largeOrderThreshold;

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

  /// GLOBAL SEARCH ([kGlobalSearch]) — open the order [id]'s detail sheet, the
  /// SAME modal a store order row shows on tap. Nulls the trigger first (so a
  /// repeat hit on the same order re-fires) and no-ops if the order vanished
  /// after the hit rendered. Only reached from the flag-gated listener below.
  void _openOrderById(String id) {
    ref.read(storeOrderOpenProvider.notifier).state = null;
    final match = ref.read(storeOrdersProvider).where((o) => o.id == id);
    if (match.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _OrderSheet(order: match.first),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(tabHeaderHiddenProvider, (_, hidden) {
      if (!hidden && !_headerVisible) _setHeaderVisible(true);
    });
    // GLOBAL SEARCH ([kGlobalSearch], const ⇒ tree-shaken when OFF) — a hit sets
    // storeOrderOpenProvider; open its detail sheet. Flag OFF ⇒ this folds out
    // and the build stays byte-identical.
    if (kGlobalSearch) {
      ref.listen<String?>(storeOrderOpenProvider, (_, id) {
        if (id != null) _openOrderById(id);
      });
    }
    return Column(
      children: [
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child:
                _headerVisible
                    ? const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // OWNER: the store's search BAR is deleted — the floating
                        // keyboard IS the store search now (on the store tab the
                        // typed query drives storeSearchQueryProvider, filtering the
                        // orders + products live). No separate search field remains.
                        CategorySuggestionStrip(),
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

class _SummaryRow extends ConsumerWidget {
  const _SummaryRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = cartItemCount(
      ref.watch(cartQtysProvider),
      ref.watch(smartCartProvider),
    );
    final openOrders = ref.watch(
      storeOrdersProvider.select(
        (orders) => orders.where((x) => isOrderOpen(x.stage)).length,
      ),
    );
    final offers = _kSupplierOffersCount;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          _SummaryChip(
            label: '🛒 $cartCount פריטים בסל',
            color: BsTokens.brand,
          ),
          const SizedBox(width: 8),
          _SummaryChip(
            label: '📦 $openOrders הזמנות פתוחות',
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(width: 8),
          _SummaryChip(
            label: '📨 $offers הצעות ספקים',
            color: const Color(0xFFFF9800),
          ),
        ],
      ),
    );
  }
}

/// Open supplier-tender offers — single-sourced from the "מכרז ספקים" row badge
/// so the chip and the list row never drift.
final int _kSupplierOffersCount =
    _kAllItems.firstWhere((m) => m.title == 'מכרז ספקים').badge;

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
      child: Row(
        children: [
          Expanded(
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
            // 🔧 שירותים — the whole section is "🚧 בבנייה" placeholder rows
            // (backend-blocked). Hidden for Apple review (kHideUnderConstruction);
            // the StoreSection enum + grid + sheets stay in code (reversible).
            if (!kHideUnderConstruction) ...[
              const SizedBox(width: 8),
              _Pill(
                label: '🔧 שירותים',
                active: section == StoreSection.services,
                onTap: () => select(StoreSection.services),
              ),
            ],
          ],
        ),
      ),
          ),
          // 🔔 #52 — order/shipment notification toggles live HERE in the
          // orders world (relocated from settings). Shown only on 📦 הזמנות.
          if (section == StoreSection.orders)
            IconButton(
              tooltip: 'התראות הזמנות ומשלוחים',
              icon: const Text('🔔', style: TextStyle(fontSize: 18)),
              onPressed: () => showOrderNotifSheet(context),
            ),
        ],
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
      color: active ? BsTokens.brand : const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: active ? bsOnAccent(context) : const Color(0xFF595959),
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

class _QuickActionsRow extends ConsumerWidget {
  const _QuickActionsRow();

  void _showSheet(BuildContext context, Widget sheet) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => sheet,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(storeFavoritesProvider);
    final allItems = _kAllItems;
    final favItems =
        allItems.where((item) => favorites.contains(item.title)).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: _QuickAction(
              icon: Icons.favorite_border,
              label: 'מועדפים',
              badge: favItems.length,
              onTap: () {
                if (favItems.isEmpty) {
                  showToast(context, 'אין פריטים מועדפים');
                  return;
                }
                _showSheet(context, _FavoritesSheet(items: favItems));
              },
            ),
          ),
          // מועדים / תזמון / שיחה open all-"בבנייה" placeholder sheets
          // (every _SheetTile toasts "$label — בבנייה"). Hidden for Apple
          // review; the sheets stay in code (reversible). מועדפים + כספים are
          // real and always shown.
          if (!kHideUnderConstruction) ...[
            Expanded(
              child: _QuickAction(
                icon: Icons.grid_view_rounded,
                label: 'מועדים',
                onTap: () => _showSheet(context, const _MoadimSheet()),
              ),
            ),
            Expanded(
              child: _QuickAction(
                icon: Icons.calendar_today_outlined,
                label: 'תזמון',
                onTap: () => _showSheet(context, const _TizmonSheet()),
              ),
            ),
            Expanded(
              child: _QuickAction(
                icon: Icons.phone_outlined,
                label: 'שיחה',
                onTap: () => _showSheet(context, const _SichaSheet()),
              ),
            ),
          ],
          Expanded(
            child: _QuickAction(
              icon: Icons.account_balance_wallet_outlined,
              label: 'כספים',
              onTap: () => openFinanceHub(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.black54, size: 28),
              ),
              if (badge > 0)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge.toString(),
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ─── bottom sheets ────────────────────────────────────────────────────────────

class _FavoritesSheet extends ConsumerWidget {
  const _FavoritesSheet({required this.items});

  final List<_Meta> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SheetScaffold(
      title: 'מועדפים',
      emoji: '❤️',
      children:
          items
              .map(
                (item) => _SheetTile(
                  emoji: item.emoji,
                  label: item.title,
                  onTap: () {
                    Navigator.pop(context);
                    final svcIdx = _kServiceByEmoji[item.emoji];
                    if (svcIdx != null) {
                      _ServicesGrid._openSheet(context, svcIdx);
                    } else if (item.emoji == '🛒') {
                      ref.read(storeSectionProvider.notifier).state =
                          StoreSection.cart;
                    } else if (item.emoji == '📦') {
                      ref.read(storeSectionProvider.notifier).state =
                          StoreSection.orders;
                    }
                  },
                ),
              )
              .toList(),
    );
  }
}

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
      children:
          _contacts
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
                  title: Text(
                    c.name,
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontSize: 15,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.phone_outlined,
                    color: Colors.black38,
                  ),
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
                color: Colors.black12,
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
                color: BsTokens.inkLight,
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
  const _SheetTile({required this.emoji, required this.label, this.onTap});
  final String emoji;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 22)),
      title: Text(
        label,
        style: const TextStyle(color: BsTokens.inkLight, fontSize: 15),
      ),
      onTap:
          onTap ??
          () {
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
      backgroundColor: const Color(0xFFF5F5F5),
      onRefresh: _onRefresh,
      child: switch (section) {
        StoreSection.services => const _ServicesGrid(),
        StoreSection.orders => const _OrdersList(),
        StoreSection.cart => const _CartView(),
        _ => _AllList(section: section),
      },
    );
  }
}

// ─── all / cart list ──────────────────────────────────────────────────────────

// maps service emoji → index in _kServices (for sheet lookup)
const _kServiceByEmoji = {'🔧': 0, '💰': 1, '↩️': 2, '📨': 3, '🧪': 4, '📊': 5};

class _AllList extends ConsumerWidget {
  const _AllList({required this.section});
  final StoreSection section;

  VoidCallback? _tapFor(
    BuildContext context,
    WidgetRef ref,
    _Meta item,
    int? svcIdx,
  ) {
    if (svcIdx != null) return () => _ServicesGrid._openSheet(context, svcIdx);
    if (item.emoji == '🛒') {
      return () =>
          ref.read(storeSectionProvider.notifier).state = StoreSection.cart;
    }
    if (item.emoji == '📦') {
      return () =>
          ref.read(storeSectionProvider.notifier).state = StoreSection.orders;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(storeSearchQueryProvider).trim().toLowerCase();
    final favorites = ref.watch(storeFavoritesProvider);
    final cartCount = cartItemCount(
      ref.watch(cartQtysProvider),
      ref.watch(smartCartProvider),
    );
    // Drive view-mode from settings (list vs grid).
    final displayMode = ref.watch(
      storeSettingsProvider.select((s) => s.displayMode),
    );
    final isGrid = displayMode == StoreDisplayMode.grid;

    // Reflect the real cart count on the "הסל שלי" hub row.
    final allItems =
        _itemsForSection(section)
            .map(
              (m) =>
                  m.emoji == '🛒'
                      ? (
                        emoji: m.emoji,
                        title: m.title,
                        preview: '$cartCount פריטים ממתינים לסיכום',
                        time: m.time,
                        badge: cartCount,
                      )
                      : m,
            )
            .toList();
    var items =
        query.isEmpty
            ? allItems
            : allItems
                .where(
                  (item) =>
                      item.title.toLowerCase().contains(query) ||
                      item.preview.toLowerCase().contains(query),
                )
                .toList();

    // Apple-readiness: the store hub mixes genuinely-wired tiles (🛒 cart / 📦
    // orders) with placeholder tiles — some toast "$title — בבנייה" (_tapFor →
    // null), others open the all-"בבנייה" service sheets (service-indexed).
    // Hide BOTH placeholder kinds for review; the data lists stay intact
    // (reversible). A tile survives only if it has a real non-service handler.
    if (kHideUnderConstruction) {
      items = [
        for (final item in items)
          if (_kServiceByEmoji[item.emoji] == null &&
              _tapFor(context, ref, item, null) != null)
            item,
      ];
    }

    if (items.isEmpty) {
      return _EmptyState(query: query);
    }

    if (isGrid) {
      return GridView.builder(
        key: ValueKey('grid_$section'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.4,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          final svcIdx = _kServiceByEmoji[item.emoji];
          return _GridHubCard(
            item: item,
            isFav: favorites.contains(item.title),
            onFavToggle: () =>
                ref.read(storeFavoritesProvider.notifier).toggle(item.title),
            onTap: _tapFor(context, ref, item, svcIdx),
          );
        },
      );
    }

    return ListView.separated(
      key: ValueKey(section),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder:
          (_, __) =>
              const Divider(height: 1, indent: 76, color: Color(0xFFF5F5F5)),
      itemBuilder: (context, i) {
        final item = items[i];
        final svcIdx = _kServiceByEmoji[item.emoji];
        final isFav = favorites.contains(item.title);
        return _DismissibleStoreRow(
          key: ValueKey(item.title),
          item: item,
          isFav: isFav,
          onFavToggle: () {
            ref.read(storeFavoritesProvider.notifier).toggle(item.title);
          },
          onTap: _tapFor(context, ref, item, svcIdx),
        );
      },
    );
  }
}

/// Compact grid tile for the hub-row items when `displayMode == grid`.
class _GridHubCard extends StatelessWidget {
  const _GridHubCard({
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
    final hasBadge = item.badge > 0;
    return GestureDetector(
      onTap: onTap ?? () => showToast(context, '${item.title} — בבנייה'),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF0F0F0)),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(item.emoji, style: const TextStyle(fontSize: 22)),
                    const Spacer(),
                    if (hasBadge)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: BsTokens.brand,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${item.badge}',
                          style: TextStyle(
                            color: bsOnAccent(context),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    // Layout placeholder — the real (48dp) favorite target is
                    // overlaid at the top-end corner below (a11y).
                    const SizedBox(width: 24, height: 24),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.title,
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.preview,
                  style: const TextStyle(color: Color(0xFF888888), fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // ≥48dp favorite tap target (a11y) — overlaid so the tile layout
          // and icon visuals stay identical.
          PositionedDirectional(
            top: 0,
            end: 0,
            child: Tooltip(
              message: isFav ? 'הסר ממועדפים' : 'הוסף למועדפים',
              child: Semantics(
                button: true,
                label: isFav ? 'הסר ממועדפים' : 'הוסף למועדפים',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onFavToggle,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.pinkAccent : Colors.black26,
                        size: 16,
                      ),
                    ),
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
      background: const ColoredBox(color: Color(0xFFFFFFFF)),
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
                    color: Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(item.emoji, style: const TextStyle(fontSize: 24)),
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
                            color: BsTokens.inkLight,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        item.time,
                        style: TextStyle(
                          color:
                              hasBadge
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
                              color: Color(0xFFFFFFFF),
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
      builder:
          (context, constraints) => SingleChildScrollView(
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

// ─── cart view ────────────────────────────────────────────────────────────────

class _CartView extends ConsumerStatefulWidget {
  const _CartView();

  @override
  ConsumerState<_CartView> createState() => _CartViewState();
}

class _CartViewState extends ConsumerState<_CartView> {
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notesCtrl.text = ref.read(cartNotesProvider);
    _notesCtrl.addListener(
      () => ref.read(cartNotesProvider.notifier).state = _notesCtrl.text,
    );
  }

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
    final vatInclusive = ref.watch(
      storeSettingsProvider.select((s) => s.vatInclusive),
    );
    // Inclusive: VAT is already embedded in the prices (shown for info only).
    // Exclusive: VAT is added on top of the subtotal.
    final vat = cartVat(subtotal, vatInclusive: vatInclusive);
    final deliveryFee = deliveryFeeFor(delivery);
    final total = cartTotal(subtotal, deliveryFee, vatInclusive: vatInclusive);

    final saveToProject = ref.watch(
      storeSettingsProvider.select((s) => s.saveCartToProject),
    );

    if (smartLines.isEmpty && grouped.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('🛒', style: TextStyle(fontSize: 52)),
              SizedBox(height: 12),
              Text(
                'הסל ריק',
                style: TextStyle(
                  color: BsTokens.inkLight,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'הוסיפו מוצרים מהקטלוג',
                style: TextStyle(color: Color(0xFF888888), fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        if (saveToProject) ...[
          _ProjectSelector(selected: project),
          const SizedBox(height: 12),
        ],
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
          vatInclusive: vatInclusive,
        ),
        const SizedBox(height: 12),
        _PaymentSelector(selected: payment),
        const SizedBox(height: 16),
        _CheckoutButton(subtotal: subtotal, total: total),
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
    // Projects engine is canonical: the chips are the live engine projects'
    // names, plus the 'ללא פרויקט' (no-project) option at the end.
    final projects = [
      for (final p in ref.watch(projectsProvider).projects) p.name,
      'ללא פרויקט',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🏗️ שיוך לפרויקט',
          style: TextStyle(color: Colors.black54, fontSize: 12),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final p in projects) ...[
                _ProjectChip(
                  label: p,
                  active: p == selected,
                  onTap: () => ref.read(cartProjectProvider.notifier).state = p,
                ),
                const SizedBox(width: 8),
              ],
              GestureDetector(
                onTap: () => _addProjectDialog(context, ref),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
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

  static void _addProjectDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: const Color(0xFFFFFFFF),
            title: const Text(
              'הוספת פרויקט',
              style: TextStyle(color: BsTokens.inkLight),
            ),
            content: TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: BsTokens.inkLight),
              decoration: const InputDecoration(hintText: 'שם הפרויקט'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'ביטול',
                  style: TextStyle(color: Colors.black38),
                ),
              ),
              TextButton(
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isEmpty) return;
                  // Add through the canonical projects engine (saveProject), so
                  // the new site is a real LiveProject the picker, app-bar and
                  // projects screen all see. Then select it for this checkout.
                  ref.read(projectsProvider.notifier).addProject(name: name);
                  ref.read(cartProjectProvider.notifier).state = name;
                  Navigator.pop(ctx);
                },
                style: TextButton.styleFrom(foregroundColor: BsTokens.brand),
                child: const Text('הוסף'),
              ),
            ],
          ),
    ).whenComplete(() => controller.dispose());
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
          color: active ? BsTokens.brand : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? bsOnAccent(context) : const Color(0xFF595959),
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
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BsTokens.brand.withAlpha(60)),
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
                child: Text(
                  line.productEmoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${line.productName} × ${line.productQty}',
                      style: const TextStyle(
                        color: BsTokens.inkLight,
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
              // Quantity stepper — adjust the real cart line.
              _SmartQtyStepper(
                qty: line.productQty,
                onMinus:
                    () => ref
                        .read(smartCartProvider.notifier)
                        .setLineQty(index, line.productQty - 1),
                onPlus:
                    () => ref
                        .read(smartCartProvider.notifier)
                        .setLineQty(index, line.productQty + 1),
              ),
              const SizedBox(width: 8),
              Text(
                '₪${line.total}',
                style: const TextStyle(
                  color: BsTokens.brand,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                tooltip: 'הסר מהסל',
                icon: const Icon(
                  Icons.close,
                  color: Color(0xFF666666),
                  size: 18,
                ),
                onPressed:
                    () => ref.read(smartCartProvider.notifier).remove(index),
                padding: EdgeInsets.zero,
                // ≥48dp tap target (a11y) — icon visuals unchanged.
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
            ],
          ),
          if (line.accessories.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(height: 1, color: Color(0xFFF5F5F5)),
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
                          color: BsTokens.mutedLight,
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

/// Compact −/qty/+ stepper for a smart-cart row.
class _SmartQtyStepper extends StatelessWidget {
  const _SmartQtyStepper({
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });

  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    Widget btn(IconData icon, VoidCallback onTap) => Tooltip(
      message: icon == Icons.add ? 'הוסף כמות' : 'הפחת כמות',
      child: Semantics(
        button: true,
        label: icon == Icons.add ? 'הוסף כמות' : 'הפחת כמות',
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          // ≥48dp tap target (a11y) — icon visuals unchanged.
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: Icon(icon, size: 18, color: BsTokens.brand),
            ),
          ),
        ),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        color: BsTokens.brand.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(Icons.remove, onMinus),
          SizedBox(
            width: 22,
            child: Text(
              '$qty',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          btn(Icons.add, onPlus),
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
              color: BsTokens.inkLight,
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
        color: const Color(0xFFFFFFFF),
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
                        color: BsTokens.inkLight,
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
              Tooltip(
                message: 'הסר מהסל',
                child: Semantics(
                  button: true,
                  label: 'הסר מהסל',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setQty(0),
                    // ≥48dp tap target (a11y) — icon visuals unchanged.
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Center(
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                  ),
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
                  color: const Color(0xFFF5F5F5),
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
                          color: BsTokens.inkLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    _StepBtn(icon: Icons.add, onTap: () => setQty(qty + 1)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                _price(lineTotal),
                style: const TextStyle(
                  color: BsTokens.inkLight,
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
    return Tooltip(
      message: icon == Icons.add ? 'הוסף כמות' : 'הפחת כמות',
      child: Semantics(
        button: true,
        label: icon == Icons.add ? 'הוסף כמות' : 'הפחת כמות',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          // ≥48dp tap target (a11y) — icon visuals unchanged.
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: Icon(
                icon,
                size: 18,
                color: onTap != null ? BsTokens.brand : const Color(0xFF444444),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── ship-to popup (Benzi #4) — one-time, on the first product selection ──────

/// Non-binding "where to ship" popup. Auto-opened ONCE the first time a product
/// is added to the cart (see `home_shell` + `shipToPromptedProvider`), never at
/// checkout. The order can be confirmed with or without an address.
void openShipToSheet(BuildContext context, WidgetRef ref) {
  // The field pre-fills with the in-progress shipTo address; when that is empty
  // (the common one-time-popup case) it falls back to the saved 'כתובת ברירת
  // מחדל' (storeSettings.defaultAddress) so a contractor who set a default sees
  // it ready to confirm instead of an empty box. This is the live client effect
  // of that setting.
  final shipTo = ref.read(shipToProvider);
  final defaultAddress = ref.read(storeSettingsProvider).defaultAddress.trim();
  final ctrl = TextEditingController(
    text: shipTo.isNotEmpty ? shipTo : defaultAddress,
  );
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder:
        (sheetCtx) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'לאן לשלוח?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: BsTokens.inkLight,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'לא חובה — אפשר לאשר את ההזמנה גם בלי כתובת ולהשלים בהמשך.',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                autofocus: true,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'כתובת / אתר העבודה',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(sheetCtx),
                      child: const Text('דלג'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: BsTokens.brand,
                      ),
                      onPressed: () {
                        ref.read(shipToProvider.notifier).state =
                            ctrl.text.trim();
                        Navigator.pop(sheetCtx);
                      },
                      child: const Text('שמירה'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
  ).whenComplete(() => ctrl.dispose());
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
          style: TextStyle(color: Colors.black54, fontSize: 12),
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
                  onTap:
                      () =>
                          ref.read(cartDeliveryProvider.notifier).state =
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
          color:
              active
                  ? BsTokens.brand.withValues(alpha: 0.12)
                  : const Color(0xFFFFFFFF),
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
                color: active ? BsTokens.brand : BsTokens.inkLight,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              option.fee == 0 ? 'חינם' : _price(option.fee),
              style: const TextStyle(color: Color(0xFF888888), fontSize: 11),
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
          style: TextStyle(color: Colors.black54, fontSize: 12),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: BsTokens.inkLight, fontSize: 13),
          cursorColor: BsTokens.brand,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'קומה / כניסה / שם האתר / הוראות לנהג...',
            hintStyle: const TextStyle(color: Color(0xFF666666)),
            filled: true,
            fillColor: const Color(0xFFFFFFFF),
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
    required this.vatInclusive,
  });

  final int subtotal;
  final int vat;
  final int deliveryFee;
  final int total;
  final bool vatInclusive;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // When VAT is inclusive, show the net (pre-VAT) subtotal so the
          // lines add up to the total (net + VAT + delivery = total).
          _SummaryLine(
            label: vatInclusive ? 'סכום ביניים (ללא מע"מ)' : 'סכום ביניים',
            value: _price(vatInclusive ? subtotal - vat : subtotal),
          ),
          const SizedBox(height: 6),
          _SummaryLine(label: 'מע"מ 18%', value: _price(vat)),
          const SizedBox(height: 6),
          _SummaryLine(
            label: 'משלוח',
            value: deliveryFee == 0 ? 'חינם' : _price(deliveryFee),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Color(0xFFF5F5F5), height: 1),
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
    final style =
        bold
            ? const TextStyle(
              color: BsTokens.inkLight,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            )
            : const TextStyle(color: Color(0xFF888888), fontSize: 13);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style)],
    );
  }
}

// ─── payment selector ─────────────────────────────────────────────────────────

class _PaymentSelector extends ConsumerWidget {
  const _PaymentSelector({required this.selected});
  final CartPaymentMethod selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 'הסדר אשראי ספק' (storeSettings.supplierCreditEnabled) gates the supplier-
    // credit ('אשראי ספק') payment chip: a contractor who hasn't arranged a
    // supplier-credit line shouldn't be offered it at checkout. Off (the
    // default) ⇒ the chip is removed from the selector entirely. The other
    // methods (כרטיס/ביט) are always available. This is the live client effect
    // of that toggle.
    final supplierCreditEnabled = ref.watch(
      storeSettingsProvider.select((s) => s.supplierCreditEnabled),
    );
    final options = [
      for (final o in _kPaymentOptions)
        if (o.method != CartPaymentMethod.supplierCredit ||
            supplierCreditEnabled)
          o,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💳 אמצעי תשלום',
          style: TextStyle(color: Colors.black54, fontSize: 12),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < options.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                _PaymentChip(
                  option: options[i],
                  active: options[i].method == selected,
                  onTap:
                      () =>
                          ref.read(cartPaymentProvider.notifier).state =
                              options[i].method,
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
          color: active ? BsTokens.brand : const Color(0xFFF5F5F5),
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
                color: active ? bsOnAccent(context) : const Color(0xFF595959),
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

class _CheckoutButton extends ConsumerStatefulWidget {
  const _CheckoutButton({required this.subtotal, required this.total});
  final int subtotal;
  final int total;

  @override
  ConsumerState<_CheckoutButton> createState() => _CheckoutButtonState();
}

class _CheckoutButtonState extends ConsumerState<_CheckoutButton> {
  bool _inFlight = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: BsTokens.brand,
        foregroundColor: Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: _inFlight ? null : () => _checkout(context),
      child: Text(
        'הזמן עכשיו · ${_price(widget.total)} →',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }

  Future<void> _checkout(BuildContext context) async {
    if (_inFlight) return;
    setState(() => _inFlight = true);
    try {
      final s = ref.read(storeSettingsProvider);
      // Minimum-order gate.
      if (cartBelowMinimum(widget.subtotal, s)) {
        showToast(context, 'מינימום להזמנה: ${_price(s.minOrderAmount)}');
        return;
      }
      // Large-order confirmation.
      if (cartNeedsLargeConfirm(widget.total, s)) {
        final ok = await showDialog<bool>(
          context: context,
          builder:
              (ctx) => AlertDialog(
                backgroundColor: const Color(0xFFFFFFFF),
                title: const Text(
                  'אישור הזמנה גדולה',
                  style: TextStyle(color: BsTokens.inkLight),
                ),
                content: Text(
                  'סכום ההזמנה ${_price(widget.total)} חורג מהסף שהגדרת '
                  '(${_price(s.largeOrderThreshold)}). להמשיך?',
                  style: const TextStyle(color: Colors.black54),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('ביטול'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: TextButton.styleFrom(foregroundColor: BsTokens.brand),
                    child: const Text('אשר והמשך'),
                  ),
                ],
              ),
        );
        if (ok != true || !context.mounted) return;
      }
      _showCheckoutSheet(context);
    } finally {
      if (mounted) setState(() => _inFlight = false);
    }
  }

  void _showCheckoutSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CheckoutSheet(total: widget.total),
    );
  }
}

// ─── checkout sheet ───────────────────────────────────────────────────────────

class _CheckoutSheet extends ConsumerStatefulWidget {
  const _CheckoutSheet({required this.total});
  final int total;

  @override
  ConsumerState<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends ConsumerState<_CheckoutSheet> {
  /// One-shot guard: true once the confirm button has been tapped.
  /// Prevents a double-tap from placing two orders.
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    final delivery = ref.watch(cartDeliveryProvider);
    final payment = ref.watch(cartPaymentProvider);
    final project = ref.watch(cartProjectProvider);

    final deliveryLabel =
        _kDeliveryOptions.firstWhere((d) => d.method == delivery).label;
    final paymentLabel =
        _kPaymentOptions.firstWhere((p) => p.method == payment).label;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 16,
        right: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'סיכום הזמנה',
              style: TextStyle(
                color: BsTokens.inkLight,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'פרויקט',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    project,
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFEEEEEE), height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '📦 משלוח',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      Text(
                        deliveryLabel,
                        style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '💳 תשלום',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      Text(
                        paymentLabel,
                        style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFEEEEEE), height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'סה"כ לתשלום',
                        style: TextStyle(
                          color: BsTokens.inkLight,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _price(widget.total),
                        style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: BsTokens.brand,
                foregroundColor: Color(0xFFFFFFFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _confirmed ? null : () {
                // One-shot guard: ignore any tap after the first.
                if (_confirmed) return;
                setState(() => _confirmed = true);
                final itemCount = cartItemCount(
                  ref.read(cartQtysProvider),
                  ref.read(smartCartProvider),
                );
                // Capture cart lines for the order detail view before clearing.
                final smartLines = ref.read(smartCartProvider);
                final capturedLines = smartLines
                    .map(
                      (l) => OrderLineItem(
                        name: l.productName,
                        emoji: l.productEmoji,
                        qty: l.productQty,
                        price: l.total,
                      ),
                    )
                    .toList();
                // Capture shipTo + notes before clearing the cart state.
                final shipTo = ref.read(shipToProvider);
                final notes = ref.read(cartNotesProvider);
                final contractor = ref.read(userProfileProvider).name.trim();
                // A3 (launch uid) — stamp the signed-in contractor's auth.uid on
                // the order (additive; '' when signed-out / Firebase-free). The
                // display still uses [who]; A4 will scope the listen on this.
                final contractorUid = ref.read(currentUidProvider) ?? '';
                // The placer's phone (profile `contact`) — stamped so the
                // store/courier/manager order card can show the 📞/💬 buttons
                // reaching the contractor who placed this order. Empty (e.g. a
                // demo user with no contact, or an email-only contact) → the
                // card shows no buttons (ContactActions' own empty-guard).
                final customerPhone = ref.read(userProfileProvider).contact;
                // Single placeOrder call — ONE id, ONE stage, persisted via
                // the engine's bs.orders.v1 key. storeOrdersProvider derives
                // from the engine so the orders list updates automatically.
                final placed = ref.read(ordersEngineProvider.notifier).placeOrder(
                      who: contractor.isEmpty ? 'קבלן' : contractor,
                      site: ref.read(cartProjectProvider),
                      items: itemCount,
                      sum: widget.total,
                      lines: capturedLines,
                      shipTo: shipTo,
                      notes: notes,
                      contractorUid: contractorUid,
                      customerPhone: customerPhone,
                    );
                // G4 — key funnel event: a contractor completed checkout. Only
                // forwards to FirebaseAnalytics when Firebase is up; a no-op on
                // the demo path (byte-identical). Params kept honest + minimal.
                ref.read(telemetryProvider).logEvent(
                  TelemetryEvents.orderPlaced,
                  params: {
                    'order_id': placed.id,
                    'items': itemCount,
                    'sum': widget.total,
                  },
                );
                // Mirror into storeOrdersProvider for legacy test compatibility:
                // the test checks storeOrdersProvider.first.items == '$n פריטים'.
                // Since storeOrdersProvider is now a derived Provider (not
                // StateProvider), it already reflects the placed order via the
                // engine — no explicit write needed.
                // Clear the cart + notes + checkout fields.
                ref.read(smartCartProvider.notifier).clear();
                ref.read(cartQtysProvider.notifier).state = const {};
                ref.read(cartNotesProvider.notifier).state = '';
                ref.read(shipToProvider.notifier).state = '';
                ref.read(cartDeliveryProvider.notifier).state =
                    cartDeliveryFor(
                      ref.read(storeSettingsProvider).selfPickupDefault,
                    );
                ref.read(cartPaymentProvider.notifier).state =
                    cartPaymentFor(
                      ref.read(storeSettingsProvider).defaultPayment,
                    );
                // Projects engine is canonical: reset the checkout selection
                // back to the currently-active project (not the retired
                // store-seed default), so the next order again defaults to it.
                ref.read(cartProjectProvider.notifier).state =
                    ref.read(activeProjectProvider).name;
                Navigator.pop(context);
                showToast(context, 'הזמנה ${placed.id} אושרה! 🎉');
              },
              child: const Text(
                'אישור הזמנה',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
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
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFFFFFFFF),
            title: const Text(
              'שמור סל כרשימה',
              style: TextStyle(color: BsTokens.inkLight),
            ),
            content: TextField(
              controller: controller,
              style: const TextStyle(color: BsTokens.inkLight),
              decoration: InputDecoration(
                hintText: 'שם הרשימה',
                hintStyle: const TextStyle(color: Color(0xFF666666)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'ביטול',
                  style: TextStyle(color: Colors.black38),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (controller.text.trim().isEmpty) {
                    showToast(context, 'שם הרשימה לא יכול להיות ריק');
                    return;
                  }
                  final lines = ref.read(smartCartProvider);
                  if (lines.isEmpty) {
                    showToast(context, 'הסל ריק');
                    return;
                  }
                  final items =
                      lines
                          .map(
                            (l) => (
                              emoji: l.productEmoji,
                              name: l.productName,
                              qty: l.productQty,
                              price: '₪${l.total}',
                            ),
                          )
                          .toList();
                  ref
                      .read(cartListsProvider.notifier)
                      .saveCart(controller.text.trim(), items);
                  Navigator.pop(context);
                  showToast(context, 'הרשימה נשמרה בהצלחה');
                },
                child: const Text(
                  'שמור',
                  style: TextStyle(color: BsTokens.brand),
                ),
              ),
            ],
          ),
    ).whenComplete(() => controller.dispose());
  }

  /// Re-add a saved [CartItem] to the live smart cart via the existing
  /// [SmartCartNotifier.add] path. The saved model only keeps
  /// {emoji, name, qty, price} (brand/key/accessories are lost on save), so we
  /// reconstruct one line whose [SmartCartLine.total] matches the saved price:
  /// brandPrice is the per-unit share of the parsed total, accessories empty.
  static void _loadItem(WidgetRef ref, CartItem item) {
    // Strip the '₪' (and any separators) from the saved total string.
    final total = int.tryParse(item.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final r = savedLineReconstruct(total, item.qty);
    ref.read(smartCartProvider.notifier).add(
          SmartCartLine(
            productKey: 'saved:${item.name}',
            productName: item.name,
            productEmoji: item.emoji,
            brandName: 'רשימה שמורה',
            brandPrice: r.brandPrice,
            productQty: r.qty,
            accessories: const [],
          ),
        );
  }

  /// Saved-cart-lists load UI: lists every persisted [CartList] so the
  /// write-only saveCart path becomes round-trippable. Tap → load all lines
  /// into the cart; trailing 🗑️ → delete the list.
  static void _showSavedListsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Consumer(
            builder: (context, ref, _) {
              final lists = ref.watch(cartListsProvider);
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
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '🔖 רשימות שמורות',
                        style: TextStyle(
                          color: BsTokens.inkLight,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFFF5F5F5), height: 1),
                    if (lists.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Text(
                          'אין רשימות שמורות עדיין',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 14,
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            for (final list in lists)
                              ListTile(
                                leading: const Text(
                                  '🛒',
                                  style: TextStyle(fontSize: 22),
                                ),
                                title: Text(
                                  list.name,
                                  style: const TextStyle(
                                    color: BsTokens.inkLight,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  '${list.items.length} פריטים',
                                  style: const TextStyle(
                                    color: Color(0xFF888888),
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: IconButton(
                                  tooltip: 'מחק',
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Color(0xFF666666),
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    final ok = await confirmDestructive(
                                      context,
                                      title: 'מחיקת רשימה שמורה?',
                                      message:
                                          'הרשימה "${list.name}" תימחק לצמיתות.',
                                      confirmLabel: 'מחק',
                                    );
                                    if (!ok || !context.mounted) return;
                                    await ref
                                        .read(cartListsProvider.notifier)
                                        .deleteList(list.id);
                                  },
                                ),
                                // Load every saved line back into the live cart.
                                onTap: () {
                                  for (final item in list.items) {
                                    _loadItem(ref, item);
                                  }
                                  Navigator.pop(context);
                                  showToast(
                                    context,
                                    'הרשימה "${list.name}" נטענה לסל',
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shareCartWithTeam = ref.watch(
      storeSettingsProvider.select((s) => s.shareCartWithTeam),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton.icon(
          onPressed: () => _showSavedListsSheet(context, ref),
          icon: const Icon(Icons.folder_open_outlined, size: 16),
          label: const Text('רשימות'),
          style: TextButton.styleFrom(foregroundColor: Colors.black38),
        ),
        TextButton.icon(
          onPressed: () => _showSaveDialog(context, ref),
          icon: const Icon(Icons.bookmark_border, size: 16),
          label: const Text('שמור'),
          style: TextButton.styleFrom(foregroundColor: Colors.black38),
        ),
        // 'שיתוף סל עם צוות' (storeSettings.shareCartWithTeam) gates the cart
        // 'שתף' button: off (the default) ⇒ the button is not shown, so the
        // cart summary can't be handed to the native/Web share sheet. On ⇒ the
        // button appears and shares the real summary. This is the live client
        // effect of that toggle.
        if (shareCartWithTeam)
          TextButton.icon(
            onPressed: () async {
              final lines = ref.read(smartCartProvider);
              if (lines.isEmpty) {
                showToast(context, 'הסל ריק');
                return;
              }
              final items = lines
                  .map(
                    (l) =>
                        '${l.productEmoji} ${l.productName} × ${l.productQty} = ₪${l.total}',
                  )
                  .join('\n');
              // Real share — hand the cart summary to the native/Web share sheet
              // (via the injectable seam so a test captures the exact text).
              final total = lines.fold<int>(0, (s, l) => s + l.total);
              final text = 'סל BuildSmart:\n$items\n\nסה״כ: ₪$total';
              await ref.read(shareTextProvider)(text);
            },
            icon: const Icon(Icons.share_outlined, size: 16),
            label: const Text('שתף'),
            style: TextButton.styleFrom(foregroundColor: Colors.black38),
          ),
        TextButton.icon(
          onPressed: () async {
            final ok = await confirmDestructive(
              context,
              title: 'ניקוי הסל?',
              message: 'כל הפריטים יוסרו מהסל.',
              confirmLabel: 'נקה',
            );
            if (!ok || !context.mounted) return;
            ref.read(smartCartProvider.notifier).clear();
            ref.read(cartQtysProvider.notifier).state = const {};
            ref.read(cartNotesProvider.notifier).state = '';
            ref.read(shipToProvider.notifier).state = '';
            ref.read(cartDeliveryProvider.notifier).state =
                cartDeliveryFor(
                  ref.read(storeSettingsProvider).selfPickupDefault,
                );
            ref.read(cartPaymentProvider.notifier).state =
                cartPaymentFor(
                  ref.read(storeSettingsProvider).defaultPayment,
                );
            // Canonical: clearing the cart resets the checkout selection to the
            // active project (the retired store-seed default is no longer used).
            ref.read(cartProjectProvider.notifier).state =
                ref.read(activeProjectProvider).name;
            showToast(context, 'הסל נוקה');
          },
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
    // 📊 השוואת מחירים (svc 5) is fully built — route to the real comparison
    // sheet instead of the generic "🚧 בבנייה" placeholder.
    if (i == 5) {
      openPriceCompareSheet(context);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ServiceSheet(index: i),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(storeSearchQueryProvider).trim().toLowerCase();
    final services =
        query.isEmpty
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
      separatorBuilder:
          (_, __) =>
              const Divider(height: 1, indent: 76, color: Color(0xFFF5F5F5)),
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
  (emoji: '🔧', title: 'השכרת כלים', sub: '2 כלים פעילים'),
  (emoji: '💰', title: 'פקדונות', sub: 'פיקדון ₪350'),
  (emoji: '↩️', title: 'החזרה חדשה', sub: 'בקשה #567'),
  (emoji: '📨', title: 'מכרז ספקים', sub: '3 הצעות חדשות'),
  (emoji: '🧪', title: 'גיליונות בטיחות', sub: '5 גיליונות'),
  (emoji: '📊', title: 'השוואת מחירים', sub: '4 ספקים עודכנו'),
];

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
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
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
                color: BsTokens.inkLight,
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
          const Divider(color: Color(0xFFF5F5F5), height: 1),
          ...rows.map(
            (r) => ListTile(
              leading: Text(
                r.emoji,
                style: const TextStyle(
                  fontSize: 22,
                  color: Color(0xFF888888),
                ),
              ),
              title: Text(
                r.label,
                style: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 15,
                ),
              ),
              subtitle:
                  r.sub.isEmpty
                      ? null
                      : Text(
                        r.sub,
                        style: const TextStyle(
                          color: BsTokens.mutedLight,
                          fontSize: 12,
                        ),
                      ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9C4),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFFD600)),
                ),
                child: const Text(
                  '🚧 בבנייה',
                  style: TextStyle(
                    color: Color(0xFF795548),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Non-actionable: tapping shows the placeholder toast but the
              // disabled visual (muted colors + badge) signals it clearly.
              onTap: () => showToast(context, '${r.label} — בבנייה'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── orders data ─────────────────────────────────────────────────────────────

typedef _Order =
    ({
      String id,
      String items,
      String total,
      String stage,
      String stageLabel,
      String time,
      Color stageColor,
    });

/// Map an engine stage string to the Hebrew label + color used in the
/// contractor view — single place so stage labels never drift.
String _stageLabelFor(String stage) => switch (stage) {
      'new' => 'התקבלה 🆕',
      'preparing' => 'בהכנה 🔧',
      'ready' => 'מוכן 📦',
      'pickup' => 'ממתין לאיסוף 🏪',
      'transit' => 'בדרך 🚛',
      'delivered' => 'נמסר ✓',
      _ => stage,
    };

Color _stageColorFor(String stage) => switch (stage) {
      'new' => const Color(0xFF9C27B0),
      'preparing' => const Color(0xFFFF9800),
      'ready' => const Color(0xFF2196F3),
      'pickup' => const Color(0xFF00BCD4),
      'transit' => const Color(0xFF4CAF50),
      'delivered' => const Color(0xFF888888),
      _ => const Color(0xFF888888),
    };

String _orderTimeFor(Order o) {
  final dt = o.createdAt;
  if (dt == null) return '';
  return '${dt.day}.${dt.month}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

/// Map a live engine [Order] to the view-model [_Order] the contractor UI reads.
/// Always reads the LIVE stage so manager/courier advances are reflected.
_Order _orderViewOf(Order o) => (
      id: o.id,
      items: '${o.items} פריטים',
      total: _price(o.sum),
      stage: o.stage,
      stageLabel: _stageLabelFor(o.stage),
      time: _orderTimeFor(o),
      stageColor: _stageColorFor(o.stage),
    );

///// Static contractor demo orders shown before any real orders are placed.
/// These are the historical demo rows the contractor UI seeded with; they are
/// NOT in the engine seed (different IDs) so the manager analytics are
/// unaffected. Kept here so the contractor sees a realistic starting state.
const List<_Order> _kContractorDemoOrders = [
  (
    id: 'BS-1234',
    items: '12 פריטים',
    total: '₪5,420',
    stage: 'transit',
    stageLabel: 'בדרך 🚛',
    time: '24.5, 14:00',
    stageColor: Color(0xFF4CAF50),
  ),
  (
    id: 'BS-1221',
    items: '5 פריטים',
    total: '₪1,890',
    stage: 'ready',
    stageLabel: 'מוכן 📦',
    time: '24.5, 09:30',
    stageColor: Color(0xFF2196F3),
  ),
  (
    id: 'BS-1198',
    items: '3 פריטים',
    total: '₪630',
    stage: 'preparing',
    stageLabel: 'בהכנה 🔧',
    time: '23.5',
    stageColor: Color(0xFFFF9800),
  ),
  (
    id: 'BS-1171',
    items: '8 פריטים',
    total: '₪2,240',
    stage: 'delivered',
    stageLabel: 'נמסר ✓',
    time: '21.5',
    stageColor: const Color(0xFF888888),
  ),
  (
    id: 'BS-1155',
    items: '2 פריטים',
    total: '₪310',
    stage: 'delivered',
    stageLabel: 'נמסר ✓',
    time: '19.5',
    stageColor: const Color(0xFF888888),
  ),
];

/// The contractor order list — a merge of:
///   • The live engine orders placed via checkout (stage is always read LIVE so
///     manager/courier advances are reflected), filtered to exclude the manager
///     demo seed (which the contractor didn't place).
///   • The static demo contractor rows for orders not in the engine (shown
///     as-is; stage is static demo data, consistent with the legacy behavior).
///
/// New orders from `placeOrder` prepend into the engine, so they appear first.
/// Persistence comes free from `bs.orders.v1` for all real orders.
final storeOrdersProvider = Provider<List<_Order>>((ref) {
  final engineOrders = ref.watch(ordersEngineProvider);
  // Live engine orders that were placed by the contractor (have createdAt),
  // mapped to _Order with their LIVE stage.
  final liveOrders = engineOrders
      .where((o) => o.createdAt != null)
      .map(_orderViewOf)
      .toList(growable: false);
  // Demo rows not already present in the live list.
  final liveIds = {for (final o in liveOrders) o.id};
  final demoOrders = _kContractorDemoOrders
      .where((o) => !liveIds.contains(o.id))
      .toList(growable: false);
  return [...liveOrders, ...demoOrders];
});

// ─── orders list ──────────────────────────────────────────────────────────────

class _OrdersList extends ConsumerWidget {
  const _OrdersList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🟢 WIRED — 'היסטוריית רכישות' privacy toggle (store_settings → פרטיות):
    // off ⇒ the purchase-history list is hidden behind a privacy notice (a real,
    // observable, local effect — no backend). The orders still exist in the
    // engine; only this buyer-facing display is suppressed.
    final showHistory = ref.watch(
      storeSettingsProvider.select((s) => s.purchaseHistory),
    );
    if (!showHistory) return const _OrdersHidden();

    final query = ref.watch(storeSearchQueryProvider).trim().toLowerCase();
    // Apply sortDefault from store settings to the order list.
    // priceAsc  → ascending by total (sum); others → engine/chronological order
    // (newest first, as the engine prepends).
    final sortDefault = ref.watch(
      storeSettingsProvider.select((s) => s.sortDefault),
    );
    var allOrders = ref.watch(storeOrdersProvider).toList();
    if (sortDefault == StoreSortDefault.priceAsc) {
      allOrders.sort((a, b) {
        // Parse the ₪ price string back to int for comparison. Fall back to 0.
        int parsePrice(String s) {
          final digits = s.replaceAll(RegExp('[^0-9]'), '');
          return int.tryParse(digits) ?? 0;
        }
        return parsePrice(a.total).compareTo(parsePrice(b.total));
      });
    }
    // rating / distance: no meaningful equivalent for orders; preserve order.

    final orders =
        query.isEmpty
            ? allOrders
            : allOrders
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
      separatorBuilder:
          (_, __) =>
              const Divider(height: 1, indent: 76, color: Color(0xFFF5F5F5)),
      itemBuilder: (context, i) => _OrderRow(order: orders[i]),
    );
  }
}

/// Shown in the הזמנות tab when 'היסטוריית רכישות' (store_settings → פרטיות) is
/// OFF: the purchase history is hidden by the user's own privacy choice. A tap
/// re-enables it (real round-trip, no backend).
class _OrdersHidden extends ConsumerWidget {
  const _OrdersHidden();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: constraints.maxHeight,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔒', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  const Text(
                    'היסטוריית הרכישות מוסתרת',
                    style: TextStyle(
                      color: BsTokens.inkLight,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'הפעלת "היסטוריית רכישות" בהגדרות תציג שוב את ההזמנות.',
                    style: TextStyle(color: Color(0xFF888888), fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => ref
                        .read(storeSettingsProvider.notifier)
                        .update((s) => s.copyWith(purchaseHistory: true)),
                    child: const Text('הצג היסטוריה'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order});
  final _Order order;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: const Color(0xFFFFFFFF),
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
                color: Color(0xFFF5F5F5),
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
                            color: BsTokens.inkLight,
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

/// Order detail sheet — reads live engine lines so new orders show real items.
/// For seed orders (which carry no lines) a placeholder row is shown.
class _OrderSheet extends ConsumerWidget {
  const _OrderSheet({required this.order});
  final _Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Look up the live engine order to get its persisted line items, shipTo,
    // and notes. Null = order not (yet) in engine (should not happen).
    final engineOrders = ref.watch(ordersEngineProvider);
    Order? engineOrder;
    for (final o in engineOrders) {
      if (o.id == order.id) {
        engineOrder = o;
        break;
      }
    }
    final lines = engineOrder?.lines ?? const [];
    final shipTo = engineOrder?.shipTo ?? '';
    final notes = engineOrder?.notes ?? '';
    // Reconcile the line column with the displayed total: the per-line prices are
    // item subtotals, while order.total is the grand total (subtotal + VAT +
    // delivery). Surface the difference so the items visibly add up (audit H3).
    final lineSubtotal = lines.fold<int>(0, (s, l) => s + l.price);
    final grandTotal = engineOrder?.sum ?? lineSubtotal;
    final extras = grandTotal - lineSubtotal;
    // gate 32: wrap in a scroll view so the order sheet never overflows on
    // short viewports (was a 3.6px RenderFlex overflow at the test viewport).
    return SingleChildScrollView(
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
                  color: Colors.black12,
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
                      color: BsTokens.inkLight,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
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
              '${order.items} · ${order.total}${order.time.isNotEmpty ? ' · ${order.time}' : ''}',
              style: const TextStyle(color: Color(0xFF888888), fontSize: 13),
            ),
            // Show ship-to address if set.
            if (shipTo.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('📍', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      shipTo,
                      style: const TextStyle(
                        color: Color(0xFF555555),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            // Show courier notes if set.
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('📝', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      notes,
                      style: const TextStyle(
                        color: Color(0xFF555555),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFF5F5F5), height: 1),
            if (lines.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'פרטי הפריטים אינם זמינים',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...lines.map(
                (line) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Text(
                        line.emoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          line.name,
                          style: const TextStyle(
                            color: BsTokens.inkLight,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        '× ${line.qty}',
                        style: const TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _price(line.price),
                        style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const Divider(color: Color(0xFFF5F5F5), height: 1),
            const SizedBox(height: 12),
            if (lines.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('סכום ביניים',
                      style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
                  Text(_price(lineSubtotal),
                      style:
                          const TextStyle(color: Color(0xFF888888), fontSize: 13)),
                ],
              ),
              if (extras != 0) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('מע"מ + משלוח',
                        style:
                            TextStyle(color: Color(0xFF888888), fontSize: 13)),
                    Text(_price(extras),
                        style: const TextStyle(
                            color: Color(0xFF888888), fontSize: 13)),
                  ],
                ),
              ],
              const SizedBox(height: 8),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'סה"כ',
                  style: TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  order.total,
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                '🚛 מעקב הזמנה',
                style: TextStyle(
                  color: BsTokens.inkLight,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _OrderTimeline(stage: order.stage),
            // 'סרוק תעודת-משלוח' is an OCR feature that does not exist (toast
            // "(OCR) — בקרוב"). Hidden for Apple review; restored with the flag.
            if (!kHideUnderConstruction) ...[
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: () =>
                    showToast(context, 'סריקת תעודת-משלוח (OCR) — בקרוב'),
                icon: const Text('📄', style: TextStyle(fontSize: 16)),
                label: const Text('סרוק תעודת-משלוח'),
              ),
            ],
          ],
        ),
    );
  }
}

/// Real order-status timeline driven by [_Order.stage]: every stage up to and
/// including the current one is marked done; later stages stay pending.
class _OrderTimeline extends StatelessWidget {
  const _OrderTimeline({required this.stage});
  final String stage;

  // All 6 stages of kManagerOrderFlow — kept in order so the connector lines
  // and filled/empty circles track correctly.
  static const _steps = <(String, String, IconData)>[
    ('new', 'התקבלה', Icons.assignment_outlined),
    ('preparing', 'בהכנה', Icons.build_outlined),
    ('ready', 'מוכן', Icons.inventory_2_outlined),
    ('pickup', 'נאסף', Icons.store_outlined),
    ('transit', 'בדרך', Icons.local_shipping_outlined),
    ('delivered', 'נמסר', Icons.check_circle_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final found = _steps.indexWhere((s) => s.$1 == stage);
    final cur = found < 0 ? 0 : found;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _steps.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  height: 2,
                  color: i <= cur ? BsTokens.brand : const Color(0xFFE0E0E0),
                ),
              ),
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= cur ? BsTokens.brand : const Color(0xFFEDEDED),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _steps[i].$3,
                  size: 18,
                  color: i <= cur ? bsOnAccent(context) : Colors.black38,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _steps[i].$2,
                style: TextStyle(
                  fontSize: 11,
                  color: i <= cur ? BsTokens.inkLight : Colors.black38,
                  fontWeight: i == cur ? FontWeight.w800 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
