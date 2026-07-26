import 'package:buildsmart/data/personas.dart';
import 'package:buildsmart/screens/courier_dashboard_screen.dart';
import 'package:buildsmart/screens/manager_dashboard_screen.dart';
import 'package:buildsmart/screens/store_dashboard_screen.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/screens/worker_app_screen.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/state/org_gates.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Persona one-liners — verbatim from the prototype's role drawer
/// (index.html @4088-4113).
const Map<String, String> kPersonaDesc = {
  'contractor': 'הזמנת חומרים, מלאי, משימות',
  'manager': 'ניהול מוצרים, חנויות, לקוחות',
  'store': 'הזמנות נכנסות, מלאי החנות',
  'courier': 'משלוחים ועדכוני סטטוס',
  'worker': 'המשימות שהוקצו לי בשטח',
};

/// "מי אתה?" role picker — a top-anchored card of the 5 personas, ported from
/// the prototype's role drawer (`toggleRoleDrawer`). Opened from the app-bar's
/// top-right button. Tapping a role sets [activePersonaProvider] and routes to
/// that persona's dashboard (or clears it, for contractor), then closes.
Future<void> showRolePicker(BuildContext context) {
  // S1.6 — persona = identity: when the signed-in user's custom claims carry
  // exactly ONE role, the switcher is locked (the server decides who you are;
  // no client-side role pick). Multi-role and signed-out users — and every
  // Firebase-free run — keep today's picker exactly. Read through the ambient
  // container so EVERY call site (app-bar logo, profile row) is gated by the
  // same rule without each one re-wiring.
  final locked = ProviderScope.containerOf(context, listen: false)
      .read(roleSwitchLockedProvider);
  if (locked) return Future<void>.value();
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'מי אתה?',
    barrierColor: Colors.black.withValues(alpha: 0.35),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, __, ___) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOut);
      return SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.06),
                end: Offset.zero,
              ).animate(curved),
              child: Padding(
                padding: const EdgeInsets.all(BsTokens.space3),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: const SizedBox(
                    width: double.infinity,
                    child: _RolePickerCard(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _RolePickerCard extends ConsumerWidget {
  const _RolePickerCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activePersonaProvider);
    // Org module gates — a board whose module is off gets NO row here, and
    // this picker is the ONE mount per board, so every entry path degrades
    // together. Keyed by persona id; contractor is deliberately absent (the
    // user's own app is never gated). Default all-on ⇒ all 5 rows unchanged.
    final moduleOn = <String, bool>{
      'manager': modOn(ref, 'manager'),
      'store': modOn(ref, 'supplier'),
      'courier': modOn(ref, 'courier'),
      'worker': modOn(ref, 'worker'),
    };
    return Container(
      padding: const EdgeInsets.all(BsTokens.space4),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 30,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CfgText(
            'role_picker_sheet.t01',
            'מי אתה?',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: BsTokens.inkLight,
            ),
          ),
          const SizedBox(height: 2),
          CfgText(
            'role_picker_sheet.t02',
            'בחר תפקיד כדי להיכנס',
            style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
          ),
          const SizedBox(height: BsTokens.space3),
          for (final p in kPersonas)
            if (moduleOn[p.id] ?? true)
              _RoleRow(persona: p, isActive: active == p.id),
        ],
      ),
    );
  }
}

class _RoleRow extends ConsumerWidget {
  const _RoleRow({required this.persona, required this.isActive});

  final Persona persona;
  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space2),
      child: Material(
        color: isActive ? const Color(0x14FF7A18) : const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            if (persona.id == 'contractor') {
              // Contractor IS the main app (HomeShell) — clear any persona.
              ref.read(activePersonaProvider.notifier).state = null;
              Navigator.of(context).pop();
              return;
            }
            if (persona.id == 'worker') {
              // Worker is a full role-app (same shell as the main app), not a dial.
              Navigator.of(context).pop();
              _pushBoard(context, BoardRole.worker,
                  (_) => const WorkerAppScreen());
              return;
            }
            if (persona.id == 'manager') {
              // Manager is a full role-app (the מרכז השליטה dashboard SHELL),
              // not a BS-dial drill — mirror the worker→WorkerAppScreen pattern.
              Navigator.of(context).pop();
              _pushBoard(context, BoardRole.manager,
                  (_) => const ManagerDashboardScreen());
              return;
            }
            if (persona.id == 'store') {
              // Supplier store — full role-app (4 tabs), not a dial (T9).
              Navigator.of(context).pop();
              _pushBoard(context, BoardRole.store,
                  (_) => const StoreDashboardScreen());
              return;
            }
            if (persona.id == 'courier') {
              // Courier — full role-app (delivery list), not a dial (T9).
              Navigator.of(context).pop();
              _pushBoard(context, BoardRole.courier,
                  (_) => const CourierDashboardScreen());
              return;
            }
            // Every persona is handled above; close for any unhandled id.
            Navigator.of(context).pop();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: BsTokens.space3,
              vertical: BsTokens.space3,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    persona.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(width: BsTokens.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        persona.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: BsTokens.inkLight,
                        ),
                      ),
                      Text(
                        kPersonaDesc[persona.id] ?? '',
                        style: const TextStyle(
                          color: BsTokens.mutedLight,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isActive ? Icons.check_circle : Icons.chevron_left,
                  color: isActive ? BsTokens.brand : const Color(0xFFBBBBBB),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// task #65 · push a role board behind its gate (חוק: מבחוץ לא רואים כלום).
/// An existing matching [BoardSession] builds the board directly; otherwise
/// ONLY the registration screen in role mode is built, and a successful
/// login/demo entry swaps it for the board in place ([_BoardGateRoute]).
void _pushBoard(
  BuildContext context,
  BoardRole role,
  WidgetBuilder boardBuilder,
) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => _BoardGateRoute(role: role, boardBuilder: boardBuilder),
    ),
  );
}

/// The gate route of a role board: while there is no matching [BoardSession]
/// it builds ONLY the registration screen in role mode — no board widget is
/// constructed. Login/demo success flips [boardAuthProvider] and this route
/// rebuilds into the board in place; logout flips it back to the gate.
class _BoardGateRoute extends ConsumerWidget {
  const _BoardGateRoute({required this.role, required this.boardBuilder});

  final BoardRole role;
  final WidgetBuilder boardBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(boardAuthProvider);
    if (session?.role != role) return WelcomeScreen(boardRole: role);
    return boardBuilder(context);
  }
}
