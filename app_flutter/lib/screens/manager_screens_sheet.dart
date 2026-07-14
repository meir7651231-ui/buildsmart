// שלב 3 — the manager's "access all screens" grid (the orchestrator view). The
// owner-manager opens any role's board by IMPERSONATING that role's seed account
// ([BoardAuthNotifier.impersonate]) — the board renders as a real seed user
// behind a visible "צופה כ…" banner with one-tap return ([_ImpersonationFrame]);
// the contractor tile opens the main app (HomeShell), which is not board-gated.
// No role-switch code: the manager IS the admin (recommendation-fleet approach
// (b) — scoped session-swap, NOT a per-board gate override).

import 'package:buildsmart/screens/courier_dashboard_screen.dart';
import 'package:buildsmart/screens/home_shell.dart';
import 'package:buildsmart/screens/store_dashboard_screen.dart';
import 'package:buildsmart/screens/supplier_onboarding_screen.dart'
    show SupplierOnboardingScreen;
import 'package:buildsmart/screens/worker_app_screen.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/feature_flags.dart' show featureFlagsProvider;
import 'package:buildsmart/state/trade_builder_flags.dart'
    show kTradeImportFlag;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One destination in the manager's screens grid.
class _Dest {
  const _Dest(this.emoji, this.label, this.role, this.build);
  final String emoji;
  final String label;

  /// The board role to impersonate, or null for the contractor (the main app —
  /// not a [BoardSession]-gated board, so no impersonation).
  final BoardRole? role;
  final Widget Function() build;
}

final List<_Dest> _kDests = [
  _Dest('🦺', 'עובד', BoardRole.worker, () => const WorkerAppScreen()),
  _Dest('🛵', 'שליח', BoardRole.courier, () => const CourierDashboardScreen()),
  _Dest('🏪', 'חנות ספק', BoardRole.store, () => const StoreDashboardScreen()),
  _Dest('👷', 'קבלן', null, () => const HomeShell()),
];

/// Open the manager's "מעבר בין מסכים" sheet — a grid of the four other surfaces.
void showManagerScreensSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFFFFFFFF),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _ManagerScreensSheet(),
  );
}

class _ManagerScreensSheet extends ConsumerWidget {
  const _ManagerScreensSheet();

  void _open(BuildContext context, WidgetRef ref, _Dest d) {
    Navigator.pop(context); // close the sheet first
    final role = d.role;
    if (role != null) {
      ref.read(boardAuthProvider.notifier).impersonate(role);
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _ImpersonationFrame(
          label: d.label,
          impersonated: role != null,
          child: d.build(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
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
            CfgText(
              'manager_screens_sheet.t01',
              'מעבר בין מסכים',
              style: TextStyle(
                color: BsTokens.inkLight,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            CfgText(
              'manager_screens_sheet.t02',
              'צפייה בכל לוח של המערכת — חזרה לניהול בכל רגע.',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFF0F0F0), height: 1),
            for (final d in _kDests)
              ListTile(
                leading: Text(d.emoji, style: const TextStyle(fontSize: 24)),
                title: Text(
                  d.label,
                  style: const TextStyle(color: BsTokens.inkLight, fontSize: 15),
                ),
                trailing:
                    const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
                onTap: () => _open(context, ref, d),
              ),
            // C4.1 · supplier self-onboarding — gated (kTradeImportFlag, default
            // OFF ⇒ this tile is ABSENT and the screen is unreachable). At go-live
            // the owner enables the flag AND wires supplierSubmitProvider; the
            // storeId is a demo store here (a real store session supplies it live).
            if (ref.watch(featureFlagsProvider).contains(kTradeImportFlag))
              ListTile(
                leading: const Text('🏪', style: TextStyle(fontSize: 24)),
                title: const Text(
                  'העלאת מוצר (ספק)',
                  style: TextStyle(color: BsTokens.inkLight, fontSize: 15),
                ),
                trailing:
                    const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
                onTap: () {
                  Navigator.pop(context); // close the sheet first
                  Navigator.of(context)
                      .push(SupplierOnboardingScreen.route('ahim_cohen'));
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Wraps an impersonated board with an honest "צפייה כ…" banner + one-tap return;
/// popping the route (banner button or system back) restores the manager session
/// via [BoardAuthNotifier.returnFromImpersonation] (only when [impersonated]).
class _ImpersonationFrame extends ConsumerWidget {
  const _ImpersonationFrame({
    required this.label,
    required this.impersonated,
    required this.child,
  });

  final String label;
  final bool impersonated;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && impersonated) {
          ref.read(boardAuthProvider.notifier).returnFromImpersonation();
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: BsTokens.bgLight,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Material(
                  color: BsTokens.brandDark,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        const Text('👔', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'צפייה כ$label · מצב מנהל',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: CfgText('manager_screens_sheet.t03', 'חזרה לניהול'),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
