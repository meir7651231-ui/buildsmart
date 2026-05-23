import 'package:buildsmart/screens/barcode_scanner.dart';
import 'package:buildsmart/screens/bs_dial_widget.dart';
import 'package:buildsmart/screens/catalog_screen.dart';
import 'package:buildsmart/screens/menu_dial_widget.dart';
import 'package:buildsmart/screens/search_dial_widget.dart';
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
              _PlaceholderTab(title: 'שיחות',   emoji: '💬'),
              _PlaceholderTab(title: 'התראות', emoji: '🔔'),
              _PlaceholderTab(title: 'חנות',    emoji: '🛒'),
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
/// Actions (left in RTL): camera (opens barcode) · search · more-vert (menu).
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
          onPressed: () => openBarcodeScanner(context),
        ),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white70),
          tooltip: 'חיפוש',
          onPressed: () => _toggle(ref, OpenDial.search),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white70),
          tooltip: 'תפריט',
          onPressed: () => _toggle(ref, OpenDial.menu),
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

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF1A1A1A),
      selectedItemColor: BsTokens.brand,
      unselectedItemColor: const Color(0xFF888888),
      selectedFontSize: 12,
      unselectedFontSize: 11,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view),
          label: 'קטלוג',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'שיחות',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          label: 'התראות',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          label: 'חנות',
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
