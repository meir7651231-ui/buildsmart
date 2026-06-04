import 'package:buildsmart/state/manager_dashboard_state.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 👔 מרכז השליטה — the manager-of-the-system role app (the "מנהל המערכת"
/// persona). Same full-role-app shell/style as the worker app
/// (`worker_app_screen.dart`): a LIGHT [Scaffold] (`bgLight`), a WHITE AppBar
/// (`cardLight`) with dark text, and a top segmented toggle that drives an
/// [IndexedStack] (the `updates_screen.dart` pattern).
///
/// M1 = SHELL ONLY. The four tabs (📊 לוח בקרה · 🚚 הזמנות · 👥 לקוחות ·
/// 🛠️ ניהול) are PLACEHOLDERS this wave — each shows a centred "בקרוב" note;
/// LATER waves (M2–M5) fill them with the real manager content (the live orders
/// engine derivations). Reached from the role picker ("מי אתה?" → מנהל המערכת),
/// which `Navigator.push`es this route instead of opening the old BS-dial drill.
class ManagerDashboardScreen extends ConsumerWidget {
  const ManagerDashboardScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const ManagerDashboardScreen());

  /// Number of top tabs (📊 לוח בקרה · 🚚 הזמנות · 👥 לקוחות · 🛠️ ניהול);
  /// kept in lockstep with [_kManagerTabs] (asserted in the screen's test).
  static const int tabCount = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(managerTabProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.cardLight,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: BsTokens.space4,
          title: const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'מרכז השליטה',
                      style: TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'מנהל המערכת',
                      style: TextStyle(
                        color: BsTokens.mutedLight,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _LivePill(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text(
                '‹ יציאה',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 14),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _ManagerToggle(active: active),
            Expanded(
              child: IndexedStack(
                index: active,
                children: [
                  for (final t in _kManagerTabs)
                    _TabPlaceholder(emoji: t.emoji, label: t.label),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small green "חי" status pill in the AppBar — signals the dashboard is on
/// the LIVE shared data (the orders engine), mirroring the role drawer's tone.
class _LivePill extends StatelessWidget {
  const _LivePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: BsTokens.space3, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F6EC),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Dot(),
          SizedBox(width: 6),
          Text(
            'חי',
            style: TextStyle(
              color: Color(0xFF1B7A3D),
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFF22A75A),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// The 4-tab segmented toggle — replicates `updates_screen`'s `seg()` helper,
/// but in the PILL style the manager shell uses: the selected pill is a
/// [BsTokens.brand] fill with white text, an unselected pill is a
/// [BsTokens.cardLight] fill with [BsTokens.inkLight] text; both are pill-radius
/// (icon-emoji + Hebrew label). Tapping a pill sets [managerTabProvider].
class _ManagerToggle extends ConsumerWidget {
  const _ManagerToggle({required this.active});

  final int active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget seg(int i, String emoji, String label) {
      final on = active == i;
      return Expanded(
        child: Padding(
          // Half-gap on each inner edge → an even gap between pills, none at the
          // row's outer edges. Directional (start/end) so RTL/LTR both lay out
          // correctly (gate 62 — no hard-coded edge inset).
          padding: EdgeInsetsDirectional.only(
            start: i == 0 ? 0 : BsTokens.space2 / 2,
            end: i == ManagerDashboardScreen.tabCount - 1
                ? 0
                : BsTokens.space2 / 2,
          ),
          child: Material(
            color: on ? BsTokens.brand : BsTokens.cardLight,
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            child: InkWell(
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              onTap: () => ref.read(managerTabProvider.notifier).state = i,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 15)),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: on ? Colors.white : BsTokens.inkLight,
                          fontSize: 13.5,
                          fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      color: BsTokens.cardLight,
      // Directional (start/top/end/bottom) so RTL/LTR both lay out correctly
      // (gate 62 — no hard-coded edge inset).
      padding: const EdgeInsetsDirectional.fromSTEB(
        BsTokens.space3,
        BsTokens.space2,
        BsTokens.space3,
        BsTokens.space3,
      ),
      child: Row(
        children: [
          for (var i = 0; i < _kManagerTabs.length; i++)
            seg(i, _kManagerTabs[i].emoji, _kManagerTabs[i].label),
        ],
      ),
    );
  }
}

/// A centred "בקרוב" placeholder for a tab whose real content is a LATER wave
/// (M2–M5). Names the tab so each of the four is visibly distinct.
class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({required this.emoji, required this.label});

  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: BsTokens.space3),
          Text(
            label,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: BsTokens.space1),
          const Text(
            'בקרוב',
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

/// One manager tab descriptor — emoji icon + Hebrew label.
class _ManagerTab {
  const _ManagerTab({required this.emoji, required this.label});

  final String emoji;
  final String label;
}

/// The four manager tabs — emoji + Hebrew label, verbatim from the legacy
/// manager sections (📊 לוח בקרה · 🚚 הזמנות · 👥 לקוחות · 🛠️ ניהול). Private so
/// the screen exposes only [ManagerDashboardScreen.tabCount] publicly.
const List<_ManagerTab> _kManagerTabs = [
  _ManagerTab(emoji: '📊', label: 'לוח בקרה'),
  _ManagerTab(emoji: '🚚', label: 'הזמנות'),
  _ManagerTab(emoji: '👥', label: 'לקוחות'),
  _ManagerTab(emoji: '🛠️', label: 'ניהול'),
];
