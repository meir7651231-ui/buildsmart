import 'package:buildsmart/screens/camera_sheet.dart';
import 'package:buildsmart/screens/bs_dial_widget.dart';
import 'package:buildsmart/screens/catalog_screen.dart';
import 'package:buildsmart/screens/menu_dial_widget.dart';
import 'package:buildsmart/screens/search_dial_widget.dart';
import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/screens/notifications_screen.dart';
import 'package:buildsmart/screens/store_screen.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/theme/tokens.dart';
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
      backgroundColor: const Color(0xFF111111),
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
    return AppBar(
      backgroundColor: const Color(0xFF1A1A1A),
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: BsTokens.space4,
      title: Tooltip(
        message: 'BS',
        child: InkWell(
          onTap: () => _toggle(ref, OpenDial.bs),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'BuildSmart',
              style: TextStyle(
                color: BsTokens.brand,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.photo_camera_outlined, color: Colors.white70),
          tooltip: 'מצלמה',
          onPressed: () => openCameraSheet(context),
        ),
        PopupMenuButton<MenuTab>(
          icon: const Icon(Icons.more_vert, color: Colors.white70),
          tooltip: 'תפריט',
          color: const Color(0xFF1A1A1A),
          position: PopupMenuPosition.under,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onSelected: (tab) {
            ref.read(openDialProvider.notifier).state = OpenDial.menu;
            ref.read(menuTabProvider.notifier).state = tab;
          },
          itemBuilder: (_) => const [
            PopupMenuItem<MenuTab>(
              value: MenuTab.home,
              child: Text(
                'בית',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            PopupMenuItem<MenuTab>(
              value: MenuTab.projects,
              child: Text(
                'הפרויקטים',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            PopupMenuItem<MenuTab>(
              value: MenuTab.cart,
              child: Text(
                'רכש',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            PopupMenuItem<MenuTab>(
              value: MenuTab.settings,
              child: Text(
                'הגדרות',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
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
      backgroundColor: const Color(0xFF1A1A1A),
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

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title, required this.emoji});

  final String title;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'בבנייה',
            style: TextStyle(color: Color(0xFF888888), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
