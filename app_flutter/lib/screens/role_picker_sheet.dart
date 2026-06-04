import 'package:buildsmart/data/personas.dart';
import 'package:buildsmart/screens/courier_dashboard_screen.dart';
import 'package:buildsmart/screens/store_dashboard_screen.dart';
import 'package:buildsmart/screens/worker_app_screen.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/theme/tokens.dart';
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
/// top-right button. Tapping a role sets [activePersonaProvider] (the same
/// state the BS dial drives off) and closes.
Future<void> showRolePicker(BuildContext context) {
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
          const Text(
            'מי אתה?',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: BsTokens.inkLight,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'בחר תפקיד כדי להיכנס',
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
          ),
          const SizedBox(height: BsTokens.space3),
          for (final p in kPersonas)
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
              Navigator.of(context).push(WorkerAppScreen.route());
              return;
            }
            if (persona.id == 'store') {
              // Supplier store — full role-app (4 tabs), not a dial (T9).
              Navigator.of(context).pop();
              Navigator.of(context).push(StoreDashboardScreen.route());
              return;
            }
            if (persona.id == 'courier') {
              // Courier — full role-app (delivery list), not a dial (T9).
              Navigator.of(context).pop();
              Navigator.of(context).push(CourierDashboardScreen.route());
              return;
            }
            // Manager still surfaces its existing BS-dial section tree
            // (deferred to PLAN-manager-completion).
            ref.read(activePersonaProvider.notifier).state = persona.id;
            ref.read(bsDrillPathProvider.notifier).state = const [];
            ref.read(openDialProvider.notifier).state = OpenDial.bs;
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
