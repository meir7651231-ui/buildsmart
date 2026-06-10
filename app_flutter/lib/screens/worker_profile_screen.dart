import 'package:buildsmart/data/board_accounts_local.dart';
import 'package:buildsmart/screens/role_picker_sheet.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/screens/worker_settings_screen.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🦺 WORKER PROFILE (board W, task #68) — the worker's אזור אישי: the live
/// [BoardSession] identity (displayName / username / role), honest task stats
/// derived from [tasksProvider], an entry to the worker settings (#69), the
/// code-gated 'החלפת תפקיד' row ([kRoleSwitchCode] → [showRolePicker]) and
/// 'יציאה' (boardAuth logout → every board screen rebuilds into the gate).
///
/// Rendered two ways: [embedded] as the board's 4th tab (bare body — the board
/// shell owns AppBar/nav), or pushed standalone from the worker settings.

/// Board identity → seed worker index ([kWorkers], #66): ran→0 (רן) ·
/// omer→1 (עומר). A demo session enters as רן (the seed's first worker) and is
/// marked with an honest 'דמו' chip wherever the identity shows.
/// SERVER-SWAP: becomes the server's user↔worker mapping with Firebase Auth.
int workerIndexForSession(BoardSession session) =>
    session.username == 'omer' ? 1 : 0;

class WorkerProfileScreen extends ConsumerWidget {
  const WorkerProfileScreen({this.embedded = false, super.key});

  /// True when rendered as the board's אזור-אישי tab; false when pushed
  /// standalone (its own Scaffold + "פרופיל עובד" AppBar).
  final bool embedded;

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const WorkerProfileScreen());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔒 BOARD GATE (חוק: מבחוץ לא רואים כלום) — this is a worker-board screen:
    // without a worker session ONLY the registration gate is built (so right
    // after 'יציאה' the gate shows wherever the user is in the board stack).
    final session = ref.watch(boardAuthProvider);
    if (session == null || session.role != BoardRole.worker) {
      return WelcomeScreen(boardRole: BoardRole.worker);
    }

    final worker = workerIndexForSession(session);
    // Honest stats — derived LIVE from the worker's own tasks, no invented
    // numbers (#66: the logged worker sees only their own tasks everywhere).
    final mine =
        ref.watch(tasksProvider).where((t) => t.worker == worker).toList();
    final done = mine.where((t) => t.status == 'done').length;
    final inReview = mine.where((t) => t.status == 'review').length;
    final rejected = mine.where((t) => t.status == 'rejected').length;

    final body = ListView(
      padding: const EdgeInsets.fromLTRB(
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space5,
      ),
      children: [
        _IdentityCard(session: session),
        const SizedBox(height: BsTokens.space3),
        _StatsCard(
          done: done,
          inReview: inReview,
          rejected: rejected,
          total: mine.length,
        ),
        const SizedBox(height: BsTokens.space4),
        _ActionsCard(session: session),
      ],
    );

    if (embedded) return body;
    return Scaffold(
      backgroundColor: BsTokens.bgLight,
      appBar: AppBar(
        backgroundColor: BsTokens.cardLight,
        elevation: 0,
        title: const Text(
          'פרופיל עובד',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      body: body,
    );
  }
}

// ─── identity card ───────────────────────────────────────────────────────────

/// White header card: avatar + the session's displayName / username / role —
/// straight off [BoardSession], nothing invented.
class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.session});

  final BoardSession session;

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
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0E3),
              shape: BoxShape.circle,
            ),
            // Decorative: the full name is read just beside it.
            child: const ExcludeSemantics(
              child: Text('🦺', style: TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: BsTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        session.displayName,
                        style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    if (session.demo) ...[
                      const SizedBox(width: BsTokens.space2),
                      // Honest demo-session marker (#66).
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F3F5),
                          borderRadius:
                              BorderRadius.circular(BsTokens.radiusPill),
                        ),
                        child: const Text(
                          'דמו',
                          style: TextStyle(
                            color: BsTokens.mutedLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '@${session.username} · עובד',
                  style: const TextStyle(
                    color: BsTokens.mutedLight,
                    fontSize: 13,
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

// ─── task stats card ─────────────────────────────────────────────────────────

/// Honest task stats — counts derived live from [tasksProvider] (passed in).
class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.done,
    required this.inReview,
    required this.rejected,
    required this.total,
  });

  final int done;
  final int inReview;
  final int rejected;
  final int total;

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'המשימות שלי',
                  style: TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                '$done/$total',
                style: const TextStyle(
                  color: BsTokens.brandDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: BsTokens.space3),
          ClipRRect(
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              minHeight: 8,
              backgroundColor: const Color(0xFFEDEDED),
              valueColor: const AlwaysStoppedAnimation<Color>(BsTokens.brand),
            ),
          ),
          const SizedBox(height: BsTokens.space3),
          Row(
            children: [
              _Stat(value: '$done', label: 'הושלמו'),
              _Stat(value: '$inReview', label: 'ממתינות לאישור'),
              _Stat(value: '$rejected', label: 'נדחו'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ─── actions card ────────────────────────────────────────────────────────────

/// Settings entry (#69) · code-gated role switch (#68) · logout (#68).
class _ActionsCard extends ConsumerWidget {
  const _ActionsCard({required this.session});

  final BoardSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
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
        children: [
          ListTile(
            leading: const Text('⚙️', style: TextStyle(fontSize: 20)),
            title: const Text(
              'הגדרות עובד',
              style: TextStyle(color: BsTokens.inkLight, fontSize: 15),
            ),
            trailing:
                const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
            onTap: () =>
                Navigator.of(context).push(WorkerSettingsScreen.route()),
          ),
          const Divider(height: 1, color: Color(0xFFF2F3F5)),
          ListTile(
            leading: const Text('🔄', style: TextStyle(fontSize: 20)),
            title: const Text(
              'החלפת תפקיד',
              style: TextStyle(color: BsTokens.inkLight, fontSize: 15),
            ),
            subtitle: const Text(
              'מוגן בקוד',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
            ),
            trailing:
                const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
            onTap: () => _askRoleSwitchCode(context),
          ),
          const Divider(height: 1, color: Color(0xFFF2F3F5)),
          ListTile(
            leading: const Text('🚪', style: TextStyle(fontSize: 20)),
            title: const Text(
              'יציאה',
              style: TextStyle(color: Colors.redAccent, fontSize: 15),
            ),
            onTap: () => _logout(context, ref),
          ),
        ],
      ),
    );
  }

  /// #68 — the role switch is gated behind [kRoleSwitchCode]: a code dialog,
  /// honest 'קוד שגוי' on a wrong entry, [showRolePicker] on success.
  Future<void> _askRoleSwitchCode(BuildContext context) async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        String? error;
        return StatefulBuilder(
          builder: (ctx, setState) {
            void submit() {
              // Validated against the local seed code — SERVER-SWAP: becomes a
              // server-side permission check with Firebase Auth.
              if (controller.text.trim() == kRoleSwitchCode) {
                Navigator.pop(dialogCtx, true);
              } else {
                setState(() => error = 'קוד שגוי — נסה שוב');
              }
            }

            return AlertDialog(
              backgroundColor: const Color(0xFFFFFFFF),
              title: const Text(
                'החלפת תפקיד',
                style: TextStyle(color: BsTokens.inkLight),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'מעבר בין לוחות מוגן בקוד. הזן את קוד החלפת התפקיד:',
                    style: TextStyle(color: Colors.black54, fontSize: 13.5),
                  ),
                  const SizedBox(height: BsTokens.space3),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onSubmitted: (_) => submit(),
                    decoration: InputDecoration(
                      hintText: 'קוד',
                      errorText: error,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx, false),
                  child: const Text('ביטול'),
                ),
                TextButton(
                  onPressed: submit,
                  child: const Text('אישור'),
                ),
              ],
            );
          },
        );
      },
    );
    controller.dispose();
    if ((ok ?? false) && context.mounted) {
      await showRolePicker(context);
    }
  }

  /// #68 — 'יציאה': confirm, then boardAuth logout. No navigation needed —
  /// every worker-board screen watches [boardAuthProvider] and rebuilds into
  /// the registration gate on its own.
  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final ok = await confirmDestructive(
      context,
      title: 'יציאה מהחשבון?',
      message: 'תנותק מלוח העובד ותחזור למסך ההרשמה.',
      confirmLabel: 'התנתק',
    );
    if (!ok || !context.mounted) return;
    ref.read(boardAuthProvider.notifier).logout();
  }
}
