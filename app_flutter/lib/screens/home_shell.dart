import 'dart:async';

import 'package:buildsmart/data/contractor_seeds.dart';
import 'package:buildsmart/logic/system_division.dart';
import 'package:buildsmart/screens/bs_dial_widget.dart';
import 'package:buildsmart/screens/camera_sheet.dart';
import 'package:buildsmart/screens/catalog_screen.dart';
import 'package:buildsmart/screens/departments_screen.dart';
import 'package:buildsmart/screens/catalog_settings_screen.dart';
import 'package:buildsmart/screens/chat_settings_screen.dart';
import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/screens/menu_dial_widget.dart';
import 'package:buildsmart/screens/notif_settings_screen.dart';
import 'package:buildsmart/screens/notifications_screen.dart';
import 'package:buildsmart/screens/onboarding_screen.dart';
import 'package:buildsmart/screens/role_picker_sheet.dart';
import 'package:buildsmart/screens/search_dial_widget.dart';
import 'package:buildsmart/screens/store_screen.dart';
import 'package:buildsmart/screens/store_settings_screen.dart';
import 'package:buildsmart/screens/updates_screen.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/version.g.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cart line indices whose recent-add chat bubble the user dismissed (via its
/// X). Cleared whenever the cart shrinks so later adds surface fresh bubbles.
final cartBubbleDismissedProvider = StateProvider<Set<int>>((_) => {});

/// WhatsApp-style shell: AppBar + 4 bottom tabs + dial overlays.
/// Tabs: קטלוג · שיחות · התראות · חנות (RTL order: catalog on right).
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(openDialProvider);
    final tabIndex = ref.watch(mainTabProvider);

    // Benzi #4 — one-time "לאן לשלוח" popup on the FIRST product selection
    // (cart 0→1, not on load), never at checkout. Persisted flag stops repeats.
    ref.listen<List<SmartCartLine>>(smartCartProvider, (prev, next) {
      if (prev != null &&
          prev.isEmpty &&
          next.isNotEmpty &&
          !ref.read(shipToPromptedProvider)) {
        ref.read(shipToPromptedProvider.notifier).state = true;
        saveShipToPrompted();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) openShipToSheet(context, ref);
        });
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const _HomeAppBar(),
      body: Stack(
        children: [
          IndexedStack(
            index: tabIndex,
            children: const [
              CatalogScreen(), // 0 · בית — the "הכל" catalog window
              DepartmentsScreen(), // 1 · מחלקות
              UpdatesScreen(), // 2 · עדכונים — התראות + שיחות merged
              StoreScreen(), // 3 · חנות
            ],
          ),

          // Scrim — tapping it closes any open dial.
          if (open != OpenDial.none)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => resetAllDials(ref),
                child: Container(color: Colors.black.withValues(alpha: 0.45)),
              ),
            ),

          // BS dial — anchored to right (leading in RTL).
          if (open == OpenDial.bs)
            const Positioned(
              right: BsTokens.space5,
              bottom: BsTokens.space5,
              child: BsDialWidget(),
            ),

          // Search dial — centered.
          if (open == OpenDial.search)
            const Positioned(
              left: BsTokens.space4,
              right: BsTokens.space4,
              bottom: BsTokens.space5,
              child: SearchDialWidget(),
            ),

          // Menu dial — anchored to left (trailing in RTL).
          if (open == OpenDial.menu)
            const Positioned(
              left: BsTokens.space5,
              bottom: BsTokens.space5,
              child: MenuDialWidget(),
            ),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: tabIndex,
        onTap: (i) {
          resetAllDials(ref);
          if (i == 0) {
            // בית — the catalog's "הכל" window, unscoped (clear any department).
            ref.read(homeDepartmentProvider.notifier).state = null;
            ref.read(catalogSystemFilterProvider.notifier).state = null;
            ref.read(catalogTreePathProvider.notifier).state = const [];
            ref.read(catalogSectionProvider.notifier).state = 'הכל';
          } else if (i == 1) {
            // מחלקות — back to the departments grid.
            ref.read(homeDepartmentProvider.notifier).state = null;
            ref.read(catalogSystemFilterProvider.notifier).state = null;
            ref.read(catalogTreePathProvider.notifier).state = const [];
          }
          ref.read(mainTabProvider.notifier).state = i;
        },
      ),
      floatingActionButton: (open == OpenDial.none && tabIndex != 3)
          ? const _CartFab()
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

/// Floating cart button — visible whenever the cart has items (and no dial is
/// open and we're not already on the store tab). Tapping jumps to the store.
class _CartFab extends ConsumerWidget {
  const _CartFab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = ref.watch(smartCartProvider);
    final count = lines.fold<int>(0, (sum, l) => sum + l.productQty);
    final dismissed = ref.watch(cartBubbleDismissedProvider);

    // Clear dismissals when the cart shrinks (indices would otherwise drift),
    // so a later add surfaces fresh bubbles. Side-effect via listen.
    ref.listen<List<SmartCartLine>>(smartCartProvider, (prev, next) {
      if (prev != null && next.length < prev.length) {
        ref.read(cartBubbleDismissedProvider.notifier).state = {};
      }
    });

    // Last two added (chronological: older on top, newest nearest the FAB),
    // minus any the user closed.
    final n = lines.length;
    final recentIdx = [
      for (var i = n - 2 < 0 ? 0 : n - 2; i < n; i++)
        if (!dismissed.contains(i)) i,
    ];

    void openCart() {
      resetAllDials(ref);
      // Land on the store's "הסל" filter so only cart items show.
      ref.read(storeSectionProvider.notifier).state = StoreSection.cart;
      ref.read(mainTabProvider.notifier).state = 3;
    }

    // White cart on the orange FAB + a count badge. (Removed the decorative
    // "+", which read as "add to cart" rather than "open cart".)
    final fab = FloatingActionButton(
      heroTag: 'cart-fab',
      onPressed: openCart,
      backgroundColor: BsTokens.brand,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: const CircleBorder(
        side: BorderSide(color: Colors.white, width: 2),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          const Icon(Icons.shopping_cart, color: Colors.white, size: 26),
          if (count > 0)
            Positioned(
              top: -10,
              right: -12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                constraints: const BoxConstraints(minWidth: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: BsTokens.brand, width: 1.5),
                ),
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: BsTokens.brand,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final i in recentIdx) ...[
          _CartChatBubble(
            line: lines[i],
            onTap: () => openCartLineProductSheet(context, lines[i]),
            onClose: () => ref.read(cartBubbleDismissedProvider.notifier).state =
                {...dismissed, i},
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 2),
        fab,
      ],
    );
  }
}

/// A single recent-add product styled as a chat bubble above the cart FAB.
/// Tapping the bubble re-opens that product's detail sheet for editing
/// (everything but the name); the small circular X dismisses just this bubble.
/// Inline floating message — no full window/modal (R2).
class _CartChatBubble extends StatelessWidget {
  const _CartChatBubble({
    required this.line,
    required this.onTap,
    required this.onClose,
  });

  final SmartCartLine line;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final d = cartLineDisplay(line);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 250),
            decoration: BoxDecoration(
              color: Colors.white,
              // Chat-bubble shape: tail-corner (bottom-left, toward the FAB)
              // squared off, the rest rounded.
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: BsTokens.brand.withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(line.productEmoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 7),
                // Main name + product-type description (two compact lines).
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                      if (d.attrs.isNotEmpty)
                        Text(
                          d.attrs,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 10.5,
                            height: 1.2,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Price + quantity.
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₪${line.total}',
                      style: const TextStyle(
                        color: BsTokens.brand,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      '×${line.productQty}',
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 10.5,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                const Icon(Icons.edit_outlined,
                    size: 13, color: Colors.black38),
              ],
            ),
          ),
        ),
        // Close X — small circle floating at the top-start corner.
        PositionedDirectional(
          top: -7,
          start: -7,
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(
              side: BorderSide(color: Color(0x22000000)),
            ),
            elevation: 2,
            child: InkWell(
              onTap: onClose,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 20,
                height: 20,
                child: Icon(Icons.close, size: 13, color: Colors.black54),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// AppBar — mirrors WhatsApp Business layout in RTL.
/// Title "BuildSmart" (right in RTL) — tap to open BS/profile dial.
/// Actions (left in RTL): camera (opens barcode) · more-vert (menu).
class _HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _HomeAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(mainTabProvider);
    // Registered user's first name → chip beside the logo (guest/demo → none).
    final profile = ref.watch(userProfileProvider);
    final firstName = profile.registered && profile.name.trim().isNotEmpty
        ? profile.name.trim().split(RegExp(r'\s+')).first
        : '';
    return AppBar(
      backgroundColor: const Color(0xFFFFFFFF),
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: BsTokens.space4,
      title: Tooltip(
        message: 'BS',
        child: InkWell(
          onTap: () => showRolePicker(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'BuildSmart',
                      style: TextStyle(
                        color: BsTokens.brand,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                    if (firstName.isNotEmpty) ...[
                      const SizedBox(width: BsTokens.space2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0E3),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          firstName,
                          style: const TextStyle(
                            color: BsTokens.brandDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (tabIndex == 0 &&
                    ref.watch(catalogSectionProvider) == 'עץ חכם')
                  const _PulsingStatus(text: 'עץ חכם הופעל')
                else
                  // תווית-גרסה: kVersionLabel בלבד (secondary/אפור, לא ירוק — ליטוש).
                  // ירוק שמור ל-_PulsingStatus החי. kBuild/kReleaseNote → "אודות" בלבד.
                  // הגרסה נגזרת מ-version.g.dart (gitignored, אוטומטי — לקח #72).
                  const Row(
                    key: Key('version_chrome'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          kVersionLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: BsTokens.mutedLight,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        // Search icon — appears when the active tab's header is scrolled away.
        if (ref.watch(tabHeaderHiddenProvider))
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black54),
            tooltip: 'חיפוש',
            onPressed: () {
              ref.read(tabHeaderHiddenProvider.notifier).state = false;
            },
          ),
        IconButton(
          icon: const Icon(Icons.photo_camera_outlined, color: Colors.black54),
          tooltip: 'מצלמה',
          onPressed: () => openCameraSheet(context),
        ),
        if (tabIndex == 0 || tabIndex == 1)
          const _CatalogMenuButton() // בית + מחלקות both drill into the catalog
        else if (tabIndex == 2)
          // עדכונים — menu follows the active sub-toggle (התראות / שיחות).
          (ref.watch(updatesSubTabProvider) == 1
              ? const _ChatsMenuButton()
              : const _NotificationsMenuButton())
        else
          const _StoreMenuButton(),
        // Intro tour — far-left (RTL end). Replays the first-run slides.
        IconButton(
          icon: const Icon(Icons.lightbulb_outline, color: BsTokens.brand),
          tooltip: 'סיור היכרות',
          onPressed: () => showIntroTour(context),
        ),
      ],
    );
  }
}

class _BottomNav extends ConsumerWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(notifUnreadCountProvider);
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFFFFFFFF),
      selectedItemColor: BsTokens.brand,
      unselectedItemColor: const Color(0xFF888888),
      selectedFontSize: 12,
      unselectedFontSize: 11,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'בית',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.apps),
          label: 'מחלקות',
        ),
        BottomNavigationBarItem(
          icon: _BadgedIcon(
            icon: Icons.notifications_outlined,
            count: unreadCount,
          ),
          activeIcon: _BadgedIcon(
            icon: Icons.notifications,
            count: unreadCount,
          ),
          label: 'עדכונים',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          label: 'חנות',
        ),
      ],
    );
  }
}

class _BadgedIcon extends StatelessWidget {
  const _BadgedIcon({required this.icon, required this.count});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return Icon(icon);
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        Positioned(
          top: -5,
          right: -6,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: BsTokens.brand,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
            child: Text(
              count > 9 ? '9+' : '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── catalog 3-dot menu ────────────────────────────────────────────────────────

class _CatalogMenuButton extends ConsumerWidget {
  const _CatalogMenuButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.black54),
      tooltip: 'תפריט',
      color: const Color(0xFFFFFFFF),
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (value) => _onSelected(context, ref, value),
      itemBuilder: (_) => const [
        PopupMenuItem<String>(
          value: 'scan_plan',
          child: _MenuRow(emoji: '📐', label: 'סרוק תוכנית עבודה'),
        ),
        PopupMenuItem<String>(
          value: 'alternatives',
          child: _MenuRow(emoji: '💡', label: 'חלופות זולות'),
        ),
        PopupMenuItem<String>(
          value: 'price_compare',
          child: _MenuRow(emoji: '📊', label: 'השוואת מחירים'),
        ),
        PopupMenuItem<String>(
          value: 'favorites',
          child: _MenuRow(emoji: '❤️', label: 'מועדפים'),
        ),
        PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'settings',
          child: _MenuRow(emoji: '⚙️', label: 'הגדרות'),
        ),
      ],
    );
  }

  void _onSelected(BuildContext context, WidgetRef ref, String value) {
    switch (value) {
      case 'scan_plan':
        showModalBottomSheet<void>(
          context: context,
          backgroundColor: const Color(0xFFFFFFFF),
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => const _ScanPlanSheet(),
        );
      case 'alternatives':
        showModalBottomSheet<void>(
          context: context,
          backgroundColor: const Color(0xFFFFFFFF),
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => const _CheaperAlternativesSheet(),
        );
      case 'price_compare':
        showModalBottomSheet<void>(
          context: context,
          backgroundColor: const Color(0xFFFFFFFF),
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => const _StorePriceComparisonSheet(),
        );
      case 'favorites':
        ref.read(catalogSectionProvider.notifier).state = 'מועדפים';
      case 'settings':
        Navigator.of(context).push(CatalogSettingsScreen.route());
    }
  }
}

/// (T1 · לוח-קבלן) A cheaper same-product brand alternative across the smart-tree.
class CheaperAlt {
  const CheaperAlt({
    required this.product,
    required this.recName,
    required this.recPrice,
    required this.altName,
    required this.altPrice,
  });
  final String product;
  final String recName;
  final int recPrice;
  final String altName;
  final int altPrice;
  int get savings => recPrice - altPrice;
}

/// (T1) Products whose recommended brand has a cheaper same-product
/// alternative, from [kHomeProductBrands] (proto §1b HOME_PRODUCTS price
/// tiers — verbatim). Cheaper same-item options, sorted by savings desc.
List<CheaperAlt> cheaperAlternativesAcrossCatalog() {
  final out = <CheaperAlt>[];
  for (final pb in kHomeProductBrands) {
    final recI = pb.tiers.indexWhere((t) => t.rec);
    final ri = recI >= 0 ? recI : 0;
    final rec = pb.tiers[ri];
    BrandTier? alt; // cheapest tier below the recommended one
    for (var i = 0; i < pb.tiers.length; i++) {
      if (i == ri) continue;
      final t = pb.tiers[i];
      if (t.price < rec.price && (alt == null || t.price < alt.price)) alt = t;
    }
    if (alt == null) continue;
    out.add(CheaperAlt(
      product: pb.product,
      recName: rec.brand,
      recPrice: rec.price,
      altName: alt.brand,
      altPrice: alt.price,
    ));
  }
  out.sort((a, b) => b.savings.compareTo(a.savings));
  return out;
}

/// (T1) "חלופות זולות" sheet — cheaper same-product brand options + savings.
/// R9-inline (modal sheet, no new view); live supplier comparison is בפרודקשן.
class _CheaperAlternativesSheet extends StatelessWidget {
  const _CheaperAlternativesSheet();

  @override
  Widget build(BuildContext context) {
    final alts = cheaperAlternativesAcrossCatalog();
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
          const SizedBox(height: 14),
          const Text('💡 חלופות זולות',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A))),
          const SizedBox(height: 4),
          const Text('מותג חלופי זול יותר לאותו מוצר — אותה התקנה, פחות עלות.',
              style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
          const SizedBox(height: 14),
          if (alts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('אין חלופות זולות כרגע.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF888888))),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: alts.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 18, color: Color(0xFFEEEEEE)),
                itemBuilder: (_, i) {
                  final a = alts[i];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.product,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A))),
                      const SizedBox(height: 4),
                      Text('המלצה: ${a.recName} · ₪${a.recPrice}',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF888888))),
                      Row(
                        children: [
                          Expanded(
                            child: Text('חלופה: ${a.altName} · ₪${a.altPrice}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A1A))),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: const Color(0xFFFFE8D6),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text('חיסכון ₪${a.savings}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: BsTokens.brand)),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          const SizedBox(height: 14),
          const Text('⚙️ בפרודקשן: השוואת-מחירים חיה מול מחירוני הספקים.',
              style: TextStyle(fontSize: 11, color: Color(0xFF9AA3B2))),
        ],
      ),
    );
  }
}

/// (T2 · לוח-קבלן) A per-product store price comparison: the named partner-store
/// offers (proto §9b, verbatim) and the index of the cheapest ([bestStore]).
class StoreCompareRow {
  const StoreCompareRow({
    required this.product,
    required this.emoji,
    required this.stores,
    required this.bestIndex,
  });
  final String product;
  final String emoji;
  final List<StoreOffer> stores;
  final int bestIndex;
  StoreOffer get best => stores[bestIndex];
}

/// (T2) Per-product store comparison across the plan-type catalog
/// ([kPlanTypes] — proto §9b store offers, verbatim). Each product carries its
/// partner-store prices; [bestStore] marks the cheapest. No invented numbers.
List<StoreCompareRow> storePriceComparisonAcrossCatalog() {
  final out = <StoreCompareRow>[];
  for (final pt in kPlanTypes) {
    for (final z in pt.zones) {
      for (final it in z.items) {
        if (it.stores.length < 2) continue;
        out.add(StoreCompareRow(
          product: it.name,
          emoji: it.emoji,
          stores: it.stores,
          bestIndex: bestStore(it.stores),
        ));
      }
    }
  }
  return out;
}

/// (T2) "השוואת מחירים" sheet — each product's partner-store prices with the
/// cheapest highlighted. R9-inline (modal sheet, no new view). Prices §9b.
class _StorePriceComparisonSheet extends StatelessWidget {
  const _StorePriceComparisonSheet();

  @override
  Widget build(BuildContext context) {
    final rows = storePriceComparisonAcrossCatalog();
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
          const SizedBox(height: 14),
          const Text('📊 השוואת מחירים',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A))),
          const SizedBox(height: 4),
          const Text('מחירים מ-3 חנויות שותפות — הזול ביותר מסומן.',
              style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
          const SizedBox(height: 14),
          if (rows.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('אין מחירים להשוואה כרגע.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF888888))),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: rows.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 18, color: Color(0xFFEEEEEE)),
                itemBuilder: (_, i) {
                  final r = rows[i];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${r.emoji} ${r.product}',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A))),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          for (var s = 0; s < r.stores.length; s++)
                            _StoreChip(
                                offer: r.stores[s], best: s == r.bestIndex),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          const SizedBox(height: 14),
          const Text(
              '💰 המחירים נמשכים מ-3 חנויות שותפות. BuildSmart בוחר אוטומטית את ההצעה המשתלמת ביותר לכל פריט.',
              style: TextStyle(fontSize: 11, color: Color(0xFF9AA3B2))),
        ],
      ),
    );
  }
}

/// (T2) A single store-offer chip; the cheapest is brand-highlighted with ✓.
class _StoreChip extends StatelessWidget {
  const _StoreChip({required this.offer, required this.best});
  final StoreOffer offer;
  final bool best;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: best ? const Color(0xFFFFE8D6) : const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(8),
        border: best ? Border.all(color: BsTokens.brand) : null,
      ),
      child: Text(
        '${best ? '✓ ' : ''}${offer.store} · ₪${offer.price}',
        style: TextStyle(
            fontSize: 12,
            fontWeight: best ? FontWeight.w700 : FontWeight.w500,
            color: best ? BsTokens.brand : const Color(0xFF555555)),
      ),
    );
  }
}

// ─── chats 3-dot menu ───────────────────────────────────────────────────────────

class _ChatsMenuButton extends ConsumerWidget {
  const _ChatsMenuButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.black54),
      tooltip: 'תפריט',
      color: const Color(0xFFFFFFFF),
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (value) => _onSelected(context, ref, value),
      itemBuilder: (_) {
        final allMuted = allChatsMuted(ref);
        return [
          const PopupMenuItem<String>(
            value: 'new_chat',
            child: _MenuRow(emoji: '✏️', label: 'שיחה חדשה'),
          ),
          const PopupMenuItem<String>(
            value: 'archive',
            child: _MenuRow(emoji: '🗂️', label: 'ארכיון שיחות'),
          ),
          PopupMenuItem<String>(
            value: 'mute_all',
            child: _MenuRow(
              emoji: allMuted ? '🔔' : '🔇',
              label: allMuted ? 'בטל השתקת הכל' : 'השתק הכל',
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem<String>(
            value: 'settings',
            child: _MenuRow(emoji: '⚙️', label: 'הגדרות'),
          ),
        ];
      },
    );
  }

  void _onSelected(BuildContext context, WidgetRef ref, String value) {
    switch (value) {
      case 'new_chat':
        showModalBottomSheet<void>(
          context: context,
          backgroundColor: const Color(0xFFFFFFFF),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => const _NewChatSheet(),
        );
      case 'archive':
        Navigator.of(context).push(ChatsArchiveScreen.route());
      case 'mute_all':
        final wasAllMuted = allChatsMuted(ref);
        toggleMuteAllChats(ref);
        showToast(
          context,
          wasAllMuted ? 'ההשתקה בוטלה' : 'כל השיחות הושתקו',
        );
      case 'settings':
        Navigator.of(context).push(ChatSettingsScreen.route());
    }
  }
}

// ─── notifications 3-dot menu ──────────────────────────────────────────────────────

class _NotificationsMenuButton extends ConsumerWidget {
  const _NotificationsMenuButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.black54),
      tooltip: 'תפריט',
      color: const Color(0xFFFFFFFF),
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (value) => _onSelected(context, ref, value),
      itemBuilder: (_) => const [
        PopupMenuItem<String>(
          value: 'mark_all_read',
          child: _MenuRow(emoji: '✅', label: 'סמן הכל כנקרא'),
        ),
        PopupMenuItem<String>(
          value: 'clear_all',
          child: _MenuRow(emoji: '🗑️', label: 'נקה הכל'),
        ),
        PopupMenuItem<String>(
          value: 'notif_settings',
          child: _MenuRow(emoji: '🔔', label: 'הגדרות התראות'),
        ),
      ],
    );
  }

  void _onSelected(BuildContext context, WidgetRef ref, String value) {
    switch (value) {
      case 'mark_all_read':
        markAllNotifsRead(ref);
        showToast(context, 'כל ההתראות סומנו כנקרא');
      case 'clear_all':
        dismissAllNotifs(ref);
        showToast(context, 'כל ההתראות נמחקו');
      case 'notif_settings':
        Navigator.of(context).push(NotifSettingsScreen.route());
    }
  }
}

// ─── store 3-dot menu ───────────────────────────────────────────────────────────────

class _StoreMenuButton extends ConsumerWidget {
  const _StoreMenuButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.black54),
      tooltip: 'תפריט',
      color: const Color(0xFFFFFFFF),
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (value) => _onSelected(context, ref, value),
      itemBuilder: (_) => const [
        PopupMenuItem<String>(
          value: 'cart',
          child: _MenuRow(emoji: '🛒', label: 'הסל שלי'),
        ),
        PopupMenuItem<String>(
          value: 'orders',
          child: _MenuRow(emoji: '📦', label: 'הזמנות'),
        ),
        PopupMenuItem<String>(
          value: 'services',
          child: _MenuRow(emoji: '🔧', label: 'שירותים'),
        ),
        PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'settings',
          child: _MenuRow(emoji: '⚙️', label: 'הגדרות'),
        ),
      ],
    );
  }

  void _onSelected(BuildContext context, WidgetRef ref, String value) {
    switch (value) {
      case 'cart':
        ref.read(storeSectionProvider.notifier).state = StoreSection.cart;
      case 'orders':
        ref.read(storeSectionProvider.notifier).state = StoreSection.orders;
      case 'services':
        ref.read(storeSectionProvider.notifier).state = StoreSection.services;
      case 'settings':
        Navigator.of(context).push(StoreSettingsScreen.route());
    }
  }
}

// ─── shared menu row ──────────────────────────────────────────────────────────────────

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.emoji, required this.label});
  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 15),
          ),
        ),
      ],
    );
  }
}

// ─── scan plan sheet ──────────────────────────────────────────────────────────────────

/// (T3 · לוח-קבלן) Cart lines for a scanned plan type — each detected zone item
/// at its cheapest partner-store offer (proto §9 `addScanToCart`). Pure → tested.
List<SmartCartLine> scanPlanCartLines(PlanType plan) {
  final out = <SmartCartLine>[];
  for (final z in plan.zones) {
    for (final it in z.items) {
      if (it.stores.isEmpty) continue;
      final best = it.stores[bestStore(it.stores)];
      out.add(SmartCartLine(
        productKey: 'scan:${plan.key}:${it.name}',
        productName: it.name,
        productEmoji: it.emoji,
        brandName: best.store,
        brandPrice: best.price,
        productQty: 1,
        accessories: const [],
      ));
    }
  }
  return out;
}

/// (T3) "סרוק תוכנית" — pick a plan type → scan animation → detected zones with
/// per-item store comparison → "הוסף לסל". R9-inline (modal sheet, no new route).
/// Data verbatim from [kPlanTypes] (proto §9); scan is simulated (sim, not toast).
class _ScanPlanSheet extends ConsumerStatefulWidget {
  const _ScanPlanSheet();
  @override
  ConsumerState<_ScanPlanSheet> createState() => _ScanPlanSheetState();
}

class _ScanPlanSheetState extends ConsumerState<_ScanPlanSheet> {
  PlanType? _plan; // null → picker phase
  bool _scanning = false;
  int _stepIdx = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start(PlanType p) {
    setState(() {
      _plan = p;
      _scanning = true;
      _stepIdx = 0;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 750), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_stepIdx < p.steps.length - 1) {
        setState(() => _stepIdx++);
      } else {
        t.cancel();
        setState(() => _scanning = false);
      }
    });
  }

  void _addToCart(PlanType p) {
    final lines = scanPlanCartLines(p);
    final cart = ref.read(smartCartProvider.notifier);
    for (final l in lines) {
      cart.add(l);
    }
    ref.read(storeSectionProvider.notifier).state = StoreSection.cart;
    ref.read(mainTabProvider.notifier).state = 3;
    Navigator.pop(context);
    showToast(context, '${lines.length} פריטים מהתוכנית נוספו לסל');
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plan;
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
          const SizedBox(height: 14),
          if (plan == null)
            ..._picker()
          else if (_scanning)
            ..._scanningView(plan)
          else
            ..._results(plan),
        ],
      ),
    );
  }

  List<Widget> _picker() => [
        const Text('📐 סרוק תוכנית עבודה',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A))),
        const SizedBox(height: 4),
        const Text('בחר סוג תוכנית לסריקה',
            style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
        const SizedBox(height: 8),
        for (final p in kPlanTypes)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Text(p.icon, style: const TextStyle(fontSize: 24)),
            title: Text(p.label,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A))),
            subtitle: Text(p.sub,
                style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
            trailing:
                const Icon(Icons.chevron_left, color: Color(0xFF888888)),
            onTap: () => _start(p),
          ),
      ];

  List<Widget> _scanningView(PlanType p) => [
        const SizedBox(height: 10),
        const Center(
            child: SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                    strokeWidth: 3, color: BsTokens.brand))),
        const SizedBox(height: 16),
        const Text('מנתח את תצורת הבנייה ומחלץ כמויות חומרים…',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A))),
        const SizedBox(height: 10),
        Text(p.steps[_stepIdx],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFF888888))),
        const SizedBox(height: 18),
      ];

  List<Widget> _results(PlanType p) {
    final lines = scanPlanCartLines(p);
    final total = lines.fold<int>(0, (s, l) => s + l.brandPrice);
    return [
      Text('✓ זוהו ${p.zones.length} ${p.summaryUnit}',
          style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A))),
      const SizedBox(height: 2),
      Text('${lines.length} פריטים · ההצעה הזולה ₪$total',
          style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
      const SizedBox(height: 6),
      const Text(
          '💰 המחירים נמשכים מ-3 חנויות שותפות. BuildSmart בוחר אוטומטית את ההצעה המשתלמת ביותר לכל פריט.',
          style: TextStyle(fontSize: 11, color: Color(0xFF9AA3B2))),
      const SizedBox(height: 8),
      Flexible(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final z in p.zones) ..._zoneCard(z),
          ],
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        child: FilledButton(
          style: FilledButton.styleFrom(backgroundColor: BsTokens.brand),
          onPressed: () => _addToCart(p),
          child: Text('אשר הכל — הוסף ${lines.length} פריטים לסל'),
        ),
      ),
      Center(
        child: TextButton(
          onPressed: () => setState(() {
            _plan = null;
            _scanning = false;
          }),
          child: const Text('סרוק תוכנית אחרת'),
        ),
      ),
    ];
  }

  List<Widget> _zoneCard(ScanZone z) => [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 2),
          child: Row(
            children: [
              Expanded(
                child: Text('${z.emoji} ${z.name}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A))),
              ),
              Text('ודאות ${z.conf}%',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: z.conf < 88
                          ? const Color(0xFFE08A00)
                          : const Color(0xFF4CAF50))),
            ],
          ),
        ),
        for (final it in z.items) _scanItemRow(it),
      ];

  Widget _scanItemRow(ScanItem it) {
    final bi = it.stores.isEmpty ? 0 : bestStore(it.stores);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${it.emoji} ${it.name}',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A))),
          Text(it.meta,
              style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
          if (it.stores.isNotEmpty) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (var s = 0; s < it.stores.length; s++)
                  _StoreChip(offer: it.stores[s], best: s == bi),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── new chat sheet ──────────────────────────────────────────────────────────────────────

class _NewChatSheet extends StatelessWidget {
  const _NewChatSheet();

  static const _contacts = [
    (emoji: '👷', label: 'קבלן'),
    (emoji: '🏪', label: 'ספק'),
    (emoji: '🛵', label: 'שליח'),
    (emoji: '🦺', label: 'עובד'),
    (emoji: '💬', label: 'תמיכה'),
  ];

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
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              '✏️ שיחה חדשה',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'בחר סוג איש קשר',
              style: TextStyle(color: Color(0xFF888888), fontSize: 13),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF5F5F5), height: 1),
          ..._contacts.map(
            (c) => ListTile(
              leading: Text(c.emoji, style: const TextStyle(fontSize: 24)),
              title: Text(
                c.label,
                style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 15),
              ),
              trailing: const Icon(
                Icons.chevron_left,
                color: Color(0xFF888888),
              ),
              onTap: () {
                Navigator.pop(context);
                openNewChatWith(context, emoji: c.emoji, name: c.label);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Pulsing green status shown in the app-bar logo area (e.g. when the
/// "עץ חכם" section is active).
class _PulsingStatus extends ConsumerStatefulWidget {
  const _PulsingStatus({required this.text});
  final String text;

  @override
  ConsumerState<_PulsingStatus> createState() => _PulsingStatusState();
}

class _PulsingStatusState extends ConsumerState<_PulsingStatus>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  );

  @override
  void initState() {
    super.initState();
    if (ref.read(catalogSettingsProvider).reducedMotion) {
      _ctrl.value = 1;
    } else {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, color: Color(0xFF22C55E), size: 7),
          const SizedBox(width: 4),
          Text(
            widget.text,
            style: const TextStyle(
              color: Color(0xFF22C55E),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
