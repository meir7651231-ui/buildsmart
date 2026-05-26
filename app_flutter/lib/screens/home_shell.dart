import 'package:buildsmart/screens/bs_dial_widget.dart';
import 'package:buildsmart/screens/camera_sheet.dart';
import 'package:buildsmart/screens/catalog_screen.dart';
import 'package:buildsmart/screens/catalog_settings_screen.dart';
import 'package:buildsmart/screens/chat_settings_screen.dart';
import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/screens/menu_dial_widget.dart';
import 'package:buildsmart/screens/notif_settings_screen.dart';
import 'package:buildsmart/screens/notifications_screen.dart';
import 'package:buildsmart/screens/search_dial_widget.dart';
import 'package:buildsmart/screens/store_screen.dart';
import 'package:buildsmart/screens/store_settings_screen.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// WhatsApp-style shell: AppBar + 4 bottom tabs + dial overlays.
/// Tabs: קטלוג · שיחות · התראות · חנות (RTL order: catalog on right).
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(openDialProvider);
    final tabIndex = ref.watch(mainTabProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const _HomeAppBar(),
      body: Stack(
        children: [
          IndexedStack(
            index: tabIndex,
            children: const [
              CatalogScreen(),
              ChatsScreen(),
              NotificationsScreen(),
              StoreScreen(),
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
          ref.read(mainTabProvider.notifier).state = i;
        },
      ),
      floatingActionButton:
          open == OpenDial.none ? const _CartFab() : null,
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

    // 3-layer design: white circle + orange border, orange cart, white plus.
    return FloatingActionButton(
      onPressed: () {
        resetAllDials(ref);
        ref.read(mainTabProvider.notifier).state = 3;
      },
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
          // Orange plus sitting on the cart basket.
          const Positioned(
            top: 7,
            child: Icon(Icons.add, color: BsTokens.brand, size: 12),
          ),
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
    return AppBar(
      backgroundColor: const Color(0xFFFFFFFF),
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: BsTokens.space4,
      title: Tooltip(
        message: 'BS',
        child: InkWell(
          onTap: () => _toggle(ref, OpenDial.bs),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                if (tabIndex == 0 &&
                    ref.watch(catalogSectionProvider) == 'עץ חכם')
                  const _PulsingStatus(text: 'עץ חכם הופעל')
                else
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: Color(0xFF4CAF50), size: 7),
                      SizedBox(width: 4),
                      Text(
                        'v3.52 · 26.5.26 · שיחות light mode',
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
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
        if (tabIndex == 0)
          const _CatalogMenuButton()
        else if (tabIndex == 1)
          const _ChatsMenuButton()
        else if (tabIndex == 2)
          const _NotificationsMenuButton()
        else
          const _StoreMenuButton(),
      ],
    );
  }

  void _toggle(WidgetRef ref, OpenDial dial) {
    final current = ref.read(openDialProvider);
    if (current == dial) {
      resetAllDials(ref);
      return;
    }
    ref.read(openDialProvider.notifier).state = dial;
    ref.read(activePersonaProvider.notifier).state = null;
    ref.read(bsDrillPathProvider.notifier).state = const [];
    ref.read(menuTabProvider.notifier).state = null;
    ref.read(searchToolProvider.notifier).state = null;
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
          icon: Icon(Icons.grid_view),
          label: 'קטלוג',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'שיחות',
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
          label: 'התראות',
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
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => const _ScanPlanSheet(),
        );
      case 'alternatives':
        showToast(context, 'חלופות זולות — בבנייה');
      case 'price_compare':
        showToast(context, 'השוואת מחירים — בבנייה');
      case 'favorites':
        ref.read(catalogSectionProvider.notifier).state = 'מועדפים';
      case 'settings':
        Navigator.of(context).push(CatalogSettingsScreen.route());
    }
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
      itemBuilder: (_) => const [
        PopupMenuItem<String>(
          value: 'new_chat',
          child: _MenuRow(emoji: '✏️', label: 'שיחה חדשה'),
        ),
        PopupMenuItem<String>(
          value: 'archive',
          child: _MenuRow(emoji: '🗂️', label: 'ארכיון שיחות'),
        ),
        PopupMenuItem<String>(
          value: 'mute_all',
          child: _MenuRow(emoji: '🔇', label: 'השתק הכל'),
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
        showToast(context, 'ארכיון שיחות — בבנייה');
      case 'mute_all':
        showToast(context, 'השתק הכל — בבנייה');
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

class _ScanPlanSheet extends StatelessWidget {
  const _ScanPlanSheet();

  static const _plans = [
    (emoji: '🚵', label: 'אינסטלציה'),
    (emoji: '⚡', label: 'חשמל'),
    (emoji: '🏙️', label: 'אדריכלות'),
    (emoji: '🎨', label: 'גמר'),
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
              '📐 סרוק תוכנית עבודה',
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
              'בחר סוג תוכנית לסריקה',
              style: TextStyle(color: Color(0xFF888888), fontSize: 13),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF5F5F5), height: 1),
          ..._plans.map(
            (p) => ListTile(
              leading: Text(p.emoji, style: const TextStyle(fontSize: 24)),
              title: Text(
                p.label,
                style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 15),
              ),
              trailing: const Icon(
                Icons.chevron_left,
                color: Color(0xFF888888),
              ),
              onTap: () {
                Navigator.pop(context);
                showToast(context, '${p.label} — בבנייה');
              },
            ),
          ),
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
                showToast(context, '${c.label} — בבנייה');
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
