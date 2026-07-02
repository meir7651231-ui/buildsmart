import 'package:buildsmart/screens/courier_certs_screen.dart';
import 'package:buildsmart/screens/keyboard_tool_tree.dart';
import 'package:buildsmart/screens/worker_forms_screen.dart';
import 'package:buildsmart/screens/worker_safety_screen.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/docs_readiness.dart';
import 'package:buildsmart/state/keyboard_overlay.dart';
import 'package:buildsmart/state/keyboard_screen_tools.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// #101 · שער-מוכנות מסמכים (HARD gate) — the blocking screen the worker board
/// (and the courier board) shows INSTEAD of their board content while the
/// logged user's documents are incomplete or out-of-date (see
/// [DocsReadiness]). A prior product decision set this to a HARD gate for both
/// roles: no work begins until the docs are in order.
///
/// HONESTY: the message states plainly that the required-set is a DEMO rule to
/// be defined by the employer server-side. The blocking list ([DocsReadiness.
/// missing]) and the soft warnings ([DocsReadiness.expiring]) are shown
/// verbatim — nothing is invented.
///
/// 🔄 'בדוק שוב' is IMPLICIT: this gate is rebuilt by the board's `watch` of the
/// readiness provider, so the moment the user signs their 101 / adds a valid
/// cert (via the deep-link buttons below), readiness flips and the board opens —
/// no manual refresh. The visible '🔄 בדוק שוב' button simply re-reads (a no-op
/// when nothing changed) so the affordance is explicit too.
class DocsReadinessGate extends ConsumerWidget {
  DocsReadinessGate({
    super.key,
    required this.role,
    required this.readiness,
  });

  /// Which board is blocked — drives the deep-link buttons (worker → 101 +
  /// תיק-בטיחות; courier → driver certificates).
  final BoardRole role;

  /// The honest readiness result to render (blocking [DocsReadiness.missing] +
  /// the soft [DocsReadiness.expiring] warnings).
  final DocsReadiness readiness;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWorker = role == BoardRole.worker;
    final Widget body = Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        // '‹ יציאה' so a demo worker/courier who can't pass the docs gate is not
        // trapped on it (only OS-back would otherwise escape). Navigation-only
        // (Navigator.maybePop) — pops the board route back to the home shell;
        // it does NOT log out (the board keeps its boardAuth session).
        appBar: AppBar(
          backgroundColor: BsTokens.cardLight,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: BsTokens.space4,
          title: const Text(
            '🔒 מסמכים חסרים',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
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
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(BsTokens.space5),
            children: [
              const SizedBox(height: BsTokens.space5),
              const Text('🔒', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 48)),
              const SizedBox(height: BsTokens.space3),
              const Text(
                '🔒 מסמכים חסרים — לא ניתן להתחיל עבודה',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: BsTokens.space2),
              Text(
                isWorker
                    ? 'כדי להתחיל לעבוד צריך להשלים את המסמכים הנדרשים ולוודא שהם בתוקף.'
                    : 'כדי להתחיל משמרת צריך להשלים את תעודות-הנהג הנדרשות ולוודא שהן בתוקף.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: BsTokens.space5),

              // ── Blocking gaps (the HARD reasons the board is shut) ──
              _SectionCard(
                title: '⛔ חוסם — חובה להשלים',
                lines: readiness.missing,
                emptyText: 'אין פריטים חוסמים', // defensive — gate implies ≥1
                accent: BsTokens.danger,
              ),

              // ── Soft warnings (expiring soon — NOT blocking) ──
              if (readiness.expiring.isNotEmpty) ...[
                const SizedBox(height: BsTokens.space3),
                _SectionCard(
                  title: '⚠️ לתשומת לבך — יפוג בקרוב',
                  lines: readiness.expiring,
                  accent: BsTokens.warnBright,
                ),
              ],

              const SizedBox(height: BsTokens.space4),

              // ── Deep-link actions to fix the gaps ──
              if (isWorker) ...[
                _GateButton(
                  label: '📝 מלא/חתום טופס 101',
                  onPressed: () =>
                      Navigator.of(context).push(WorkerFormsScreen.route()),
                ),
                const SizedBox(height: BsTokens.space2),
                _GateButton(
                  label: '🦺 תיק בטיחות — תעודות',
                  onPressed: () =>
                      Navigator.of(context).push(WorkerSafetyScreen.route()),
                ),
              ] else ...[
                _GateButton(
                  label: '🚗 תעודות נהג',
                  onPressed: () =>
                      Navigator.of(context).push(CourierCertsScreen.route()),
                ),
              ],

              const SizedBox(height: BsTokens.space3),
              // 🔄 explicit re-check (the gate also re-evaluates live as the
              // providers update — invalidating is a harmless no-op when
              // nothing changed).
              _RecheckButton(role: role),

              const SizedBox(height: BsTokens.space4),
              // HONEST note: the required-set is a demo rule, server-defined.
              Container(
                padding: const EdgeInsets.all(BsTokens.space3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F3F5),
                  borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                ),
                child: const Text(
                  'ℹ️ רשימת המסמכים הנדרשים כאן היא כלל-הדגמה זמני. '
                  'המעסיק יגדיר את רשימת המסמכים המחייבת בצד-השרת.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: BsTokens.mutedLight,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: BsTokens.space5),
            ],
          ),
        ),
      ),
    );
    // #101 keyboard mirror: the gate's own fix-it actions live on the grid
    // too. `kKbGlobal ?` keeps flag-off byte-identical (KbScreen unbuilt off).
    return kKbGlobal ? KbScreen(tools: _kbTools, child: body) : body;
  }

  /// This gate's own keyboard tools (live-mirror), built ONCE so the stable
  /// list identity keeps KbScreen from re-pushing on every rebuild.
  late final List<KbToolNode> _kbTools = _buildTools();

  /// The gate's fix-it actions, mirrored into the floating grid. Same targets
  /// as the on-screen [_GateButton]s / [_RecheckButton], picked by [role].
  List<KbToolNode> _buildTools() {
    if (role == BoardRole.worker) {
      return <KbToolNode>[
        KbToolNode.leaf(
          icon: Icons.description_outlined,
          label: 'טופס 101',
          action: (ref, context) =>
              Navigator.of(context).push(WorkerFormsScreen.route()),
        ),
        KbToolNode.leaf(
          icon: Icons.health_and_safety_outlined,
          label: 'תיק בטיחות',
          action: (ref, context) =>
              Navigator.of(context).push(WorkerSafetyScreen.route()),
        ),
        KbToolNode.leaf(
          icon: Icons.refresh,
          label: 'בדוק שוב',
          action: (ref, context) => _recheck(ref),
        ),
      ];
    }
    return <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.badge_outlined,
        label: 'תעודות נהג',
        action: (ref, context) =>
            Navigator.of(context).push(CourierCertsScreen.route()),
      ),
      KbToolNode.leaf(
        icon: Icons.refresh,
        label: 'בדוק שוב',
        action: (ref, context) => _recheck(ref),
      ),
    ];
  }

  /// Re-read the readiness provider (explicit '🔄 בדוק שוב') — mirrors
  /// [_RecheckButton]; a harmless no-op when nothing changed.
  void _recheck(WidgetRef ref) {
    final s = ref.read(boardAuthProvider);
    if (s == null) return;
    if (role == BoardRole.worker) {
      ref.invalidate(workerDocsReadyProvider(s.username));
    } else {
      ref.invalidate(courierDocsReadyProvider(s.username));
    }
  }
}

/// One titled list card (the blocking-gaps card / the soft-warnings card) — a
/// white rounded card with a colored leading bar per row.
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.lines,
    required this.accent,
    this.emptyText,
  });

  final String title;
  final List<String> lines;
  final Color accent;
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BsTokens.space4),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: BsTokens.space2),
          if (lines.isEmpty && emptyText != null)
            Text(
              emptyText!,
              style: const TextStyle(
                color: BsTokens.mutedLight,
                fontSize: 13.5,
              ),
            )
          else
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: BsTokens.space2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsetsDirectional.only(top: 6),
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: BsTokens.space2),
                    Expanded(
                      child: Text(
                        line,
                        style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontSize: 13.5,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

/// A brand-fill deep-link action (≥48dp; label in bsOnAccent on the fill).
class _GateButton extends StatelessWidget {
  const _GateButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: BsTokens.brand,
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: onPressed,
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(
              horizontal: BsTokens.space4,
              vertical: BsTokens.space3,
            ),
            child: Text(
              label,
              style: TextStyle(
                color: bsOnAccent(context),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 🔄 'בדוק שוב' — an explicit re-check affordance. The gate already
/// re-evaluates live (the board watches the readiness provider), so this just
/// invalidates it; harmless no-op when nothing changed. Outlined so it reads as
/// secondary to the brand-fill deep-links above.
class _RecheckButton extends ConsumerWidget {
  const _RecheckButton({required this.role});

  final BoardRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      button: true,
      label: '🔄 בדוק שוב',
      excludeSemantics: true,
      child: Center(
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: BsTokens.brandDark,
            side: const BorderSide(color: BsTokens.brand, width: 1.5),
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(
              horizontal: BsTokens.space5,
              vertical: 9,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            ),
          ),
          onPressed: () {
            // Re-read the live providers (the gate re-evaluates on the next
            // build anyway — this makes the affordance explicit).
            if (role == BoardRole.worker) {
              final s = ref.read(boardAuthProvider);
              if (s != null) {
                ref.invalidate(workerDocsReadyProvider(s.username));
              }
            } else {
              final s = ref.read(boardAuthProvider);
              if (s != null) {
                ref.invalidate(courierDocsReadyProvider(s.username));
              }
            }
          },
          child: const Text(
            '🔄 בדוק שוב',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}
