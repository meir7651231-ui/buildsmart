import 'package:buildsmart/screens/bs_dial_widget.dart';
import 'package:buildsmart/screens/menu_dial_widget.dart';
import 'package:buildsmart/screens/search_dial_widget.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// HomeShell — the only screen in the app per R2. The body stays
/// minimal; every feature opens as a dial above one of the 5 FABs.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(openDialProvider);

    return Scaffold(
      body: Stack(
        children: [
          const _ContentPlaceholder(),

          if (open != OpenDial.none)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => resetAllDials(ref),
                child: Container(color: Colors.black.withValues(alpha: 0.45)),
              ),
            ),

          // BS dial — anchored to start (right in RTL) FAB.
          if (open == OpenDial.bs)
            const Positioned(
              right: BsTokens.space5,
              bottom: 96,
              child: BsDialWidget(),
            ),
          // Search dial — anchored to second FAB from start.
          if (open == OpenDial.search)
            const Positioned(
              right: 96,
              bottom: 96,
              child: SearchDialWidget(),
            ),
          // Menu dial — anchored to fourth FAB from start.
          if (open == OpenDial.menu)
            const Positioned(
              left: 96,
              bottom: 96,
              child: MenuDialWidget(),
            ),
        ],
      ),
      bottomNavigationBar: const _FabRail(),
    );
  }
}

class _ContentPlaceholder extends StatelessWidget {
  const _ContentPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'BuildSmart',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: BsTokens.brand,
                  ),
            ),
            const SizedBox(height: BsTokens.space2),
            const Text(
              'הקש על כפתור צף כדי להתחיל',
              style: TextStyle(color: BsTokens.mutedDark),
            ),
          ],
        ),
      ),
    );
  }
}

class _FabRail extends ConsumerWidget {
  const _FabRail();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: BsTokens.space4,
          vertical: BsTokens.space3,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Fab(
              tooltip: 'BS',
              icon: Icons.dashboard_outlined,
              onTap: () => _toggle(ref, OpenDial.bs),
            ),
            _Fab(
              tooltip: 'חיפוש',
              icon: Icons.search,
              onTap: () => _toggle(ref, OpenDial.search),
            ),
            _Fab(
              tooltip: 'מצב עבודה',
              icon: Icons.workspaces_outline,
              onTap: () => _toggle(ref, OpenDial.bsMode),
            ),
            _Fab(
              tooltip: 'תפריט',
              icon: Icons.menu,
              onTap: () => _toggle(ref, OpenDial.menu),
            ),
            _Fab(
              tooltip: 'BS',
              icon: Icons.bolt,
              onTap: () => _toggle(ref, OpenDial.bs),
            ),
          ],
        ),
      ),
    );
  }

  void _toggle(WidgetRef ref, OpenDial dial) {
    final current = ref.read(openDialProvider);
    if (current == dial) {
      resetAllDials(ref);
      return;
    }
    ref.read(openDialProvider.notifier).state = dial;
    // Reset every drill state when switching dials.
    ref.read(activePersonaProvider.notifier).state = null;
    ref.read(bsDrillPathProvider.notifier).state = const [];
    ref.read(menuTabProvider.notifier).state = null;
    ref.read(searchToolProvider.notifier).state = null;
  }
}

class _Fab extends StatelessWidget {
  const _Fab({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: BsTokens.brand,
        elevation: 6,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: BsTokens.fabSize,
            height: BsTokens.fabSize,
            child: Icon(icon, color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }
}
