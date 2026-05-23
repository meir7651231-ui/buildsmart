import 'package:buildsmart/data/personas.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/dial.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// HomeShell — the only "screen" in the app per R2.
/// Renders the 5-FAB rail at the bottom and the currently-open dial.
/// New features always open as a dial above the matching FAB; nothing
/// replaces the body.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openDial = ref.watch(openDialProvider);

    return Scaffold(
      body: Stack(
        children: [
          // The "main content" — intentionally minimal per R2. The
          // Preact app has the same placeholder behavior (no persona
          // views, no full-page dashboards).
          const _ContentPlaceholder(),

          // Tap-outside backdrop while a dial is open.
          if (openDial != OpenDial.none)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _closeAll(ref),
                child: Container(color: Colors.black.withValues(alpha: 0.45)),
              ),
            ),

          // The dial itself, anchored above whichever FAB triggered it.
          if (openDial == OpenDial.bs)
            const Positioned(
              left: BsTokens.space5,
              bottom: 96,
              child: _BsDial(),
            ),
          if (openDial == OpenDial.menu)
            const Positioned(
              right: BsTokens.space5,
              bottom: 96,
              child: _MenuDial(),
            ),
        ],
      ),
      bottomNavigationBar: const _FabRail(),
    );
  }

  void _closeAll(WidgetRef ref) {
    ref.read(openDialProvider.notifier).state = OpenDial.none;
    ref.read(activePersonaProvider.notifier).state = null;
    ref.read(menuTabProvider.notifier).state = null;
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
    ref.read(openDialProvider.notifier).state =
        current == dial ? OpenDial.none : dial;
    // Reset drill state whenever the dial changes/closes.
    ref.read(activePersonaProvider.notifier).state = null;
    ref.read(menuTabProvider.notifier).state = null;
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

class _BsDial extends ConsumerWidget {
  const _BsDial();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeId = ref.watch(activePersonaProvider);
    final active = activeId == null
        ? null
        : kPersonas.firstWhere((p) => p.id == activeId);

    if (active != null) {
      // Drilled-in state — show only the active persona anchor (placeholder
      // for now; Phase 1 will add sections per persona).
      return DialColumn(
        children: [
          DialRow(
            label: active.title,
            emoji: active.emoji,
            icon: Icons.circle,
            active: true,
            onTap: () =>
                ref.read(activePersonaProvider.notifier).state = null,
          ),
          // TODO(phase-1): port persona sections (manager/store/courier/worker).
        ],
      );
    }

    return DialColumn(
      children: [
        for (final p in kPersonas)
          DialRow(
            label: p.title,
            emoji: p.emoji,
            icon: Icons.circle,
            onTap: () =>
                ref.read(activePersonaProvider.notifier).state = p.id,
          ),
      ],
    );
  }
}

class _MenuDial extends ConsumerWidget {
  const _MenuDial();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Phase 0 — placeholder 4-tab labels (port matches MenuTab order).
    const tabs = [
      (label: 'בית',        emoji: '🏠', tab: MenuTab.home),
      (label: 'הפרויקטים',  emoji: '🏗️', tab: MenuTab.projects),
      (label: 'רכש',        emoji: '🛒', tab: MenuTab.cart),
      (label: 'הגדרות',     emoji: '⚙️', tab: MenuTab.settings),
    ];
    return DialColumn(
      children: [
        for (final t in tabs)
          DialRow(
            label: t.label,
            emoji: t.emoji,
            icon: Icons.circle,
            onTap: () =>
                ref.read(menuTabProvider.notifier).state = t.tab,
          ),
      ],
    );
  }
}
