import 'dart:convert';

import 'package:buildsmart/data/board_accounts_local.dart';
import 'package:buildsmart/logic/input_validators.dart';
import 'package:buildsmart/screens/role_picker_sheet.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/screens/worker_attendance_screen.dart';
import 'package:buildsmart/screens/worker_forms_screen.dart';
import 'package:buildsmart/screens/worker_payslips_sheet.dart';
import 'package:buildsmart/screens/worker_safety_screen.dart';
import 'package:buildsmart/screens/worker_settings_screen.dart';
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/state/worker_profile_store.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/contact_actions.dart';
import 'package:buildsmart/widgets/toast.dart';
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

    // #85ד — the worker's own editable profile (per username); every field is
    // an OVERRIDE that falls back honestly (name → session.displayName).
    final profile = ref.watch(workerProfileProvider)[session.username] ??
        const WorkerProfile();

    final body = ListView(
      padding: const EdgeInsets.fromLTRB(
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space5,
      ),
      children: [
        _IdentityCard(session: session, profile: profile),
        const SizedBox(height: BsTokens.space3),
        _StatsCard(
          done: done,
          inReview: inReview,
          rejected: rejected,
          total: mine.length,
        ),
        const SizedBox(height: BsTokens.space4),
        // cluster #85ח — אזור אישי v2: נוכחות · טפסים · תיק בטיחות · תלושי שכר.
        const _PersonalAreaCard(),
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

/// White header card: avatar + the display identity — the #85ד profile
/// overrides (photo/name/phone/specialty) layered over the [BoardSession]
/// (an empty override falls back to the session — nothing invented), plus
/// the ✏️ edit action that opens the profile editor sheet.
class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.session, required this.profile});

  final BoardSession session;
  final WorkerProfile profile;

  @override
  Widget build(BuildContext context) {
    // #85ד — the name override falls back to the live session displayName.
    final name = profile.name.isNotEmpty ? profile.name : session.displayName;
    final meta = [
      if (profile.specialty.isNotEmpty) '🔧 ${profile.specialty}',
      if (profile.phone.isNotEmpty) '📞 ${profile.phone}',
    ].join(' · ');

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
          _ProfileAvatar(photo: profile.photo, size: 56),
          const SizedBox(width: BsTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
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
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    style: const TextStyle(
                      color: BsTokens.mutedLight,
                      fontSize: 13,
                    ),
                  ),
                ],
                // 📞/💬 — call or WhatsApp this worker (hidden when no phone).
                ContactActions(phone: profile.phone),
              ],
            ),
          ),
          // #85ד — opens the profile editor (48dp IconButton).
          IconButton(
            tooltip: 'עריכת פרופיל',
            icon: const Icon(Icons.edit_outlined, color: BsTokens.mutedLight),
            onPressed: () =>
                showWorkerProfileEditSheet(context, session: session),
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

// ─── personal-area rows (cluster #85ח) ───────────────────────────────────────

/// אזור אישי v2 (#85ח) — the four personal-area entries: נוכחות (clock-in/out
/// + monthly table) · טפסים (101 / חופשה / מחלה) · תיק בטיחות (הדרכות +
/// ארנק תעודות) · תלושי שכר (SERVER-READY sheet — honest 'יחובר עם חיבור
/// השרת'). Same white-card ListTile style as [_ActionsCard]; rows are ≥48dp.
class _PersonalAreaCard extends StatelessWidget {
  const _PersonalAreaCard();

  @override
  Widget build(BuildContext context) {
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
            leading: const Text('🕐', style: TextStyle(fontSize: 20)),
            title: const Text(
              'נוכחות',
              style: TextStyle(color: BsTokens.inkLight, fontSize: 15),
            ),
            subtitle: const Text(
              'כניסה/יציאה ודוח חודשי',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
            ),
            trailing:
                const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
            onTap: () =>
                Navigator.of(context).push(WorkerAttendanceScreen.route()),
          ),
          const Divider(height: 1, color: Color(0xFFF2F3F5)),
          ListTile(
            leading: const Text('📄', style: TextStyle(fontSize: 20)),
            title: const Text(
              'טפסים',
              style: TextStyle(color: BsTokens.inkLight, fontSize: 15),
            ),
            subtitle: const Text(
              'טופס 101 · בקשת חופשה · אישור מחלה',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
            ),
            trailing:
                const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
            onTap: () => Navigator.of(context).push(WorkerFormsScreen.route()),
          ),
          const Divider(height: 1, color: Color(0xFFF2F3F5)),
          ListTile(
            leading: const Text('🛡️', style: TextStyle(fontSize: 20)),
            title: const Text(
              'תיק בטיחות',
              style: TextStyle(color: BsTokens.inkLight, fontSize: 15),
            ),
            subtitle: const Text(
              'הדרכות ותעודות מקצועיות',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
            ),
            trailing:
                const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
            onTap: () => Navigator.of(context).push(WorkerSafetyScreen.route()),
          ),
          const Divider(height: 1, color: Color(0xFFF2F3F5)),
          ListTile(
            leading: const Text('💰', style: TextStyle(fontSize: 20)),
            title: const Text(
              'תלושי שכר',
              style: TextStyle(color: BsTokens.inkLight, fontSize: 15),
            ),
            subtitle: const Text(
              'יחובר עם חיבור השרת',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
            ),
            trailing:
                const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
            onTap: () => showWorkerPayslipsSheet(context),
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
              // AA: redAccent על לבן נכשל — token חוזה 9.
              style: TextStyle(color: BsTokens.dangerDark, fontSize: 15),
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
        // F-46: בוני-מסלול modal אינם יורשים את עטיפת ה-RTL ברמת-האפליקציה.
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
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
                      // תווית נראית גם בזמן הקלדה (לא hint חולף בלבד).
                      labelText: 'קוד מעבר',
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
          ),
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

// ─── #85ד · editable profile ─────────────────────────────────────────────────

/// The profile avatar — the saved photo (data-URL → [Image.memory]) clipped
/// to a circle, or the default 🦺 emoji disc when no photo is set.
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.photo, required this.size});

  final String? photo;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = photo;
    if (p != null && p.startsWith('data:image') && p.contains(',')) {
      try {
        final bytes = base64Decode(p.substring(p.indexOf(',') + 1));
        return ClipOval(
          child: Image.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            // F-43 — decode the avatar at display size, not full-res.
            cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
            // A corrupt payload renders the default avatar, never a crash.
            errorBuilder: (_, __, ___) => _fallback(),
          ),
        );
      } on FormatException catch (_) {
        // Malformed base64 — fall through to the default avatar.
      }
    }
    return _fallback();
  }

  Widget _fallback() => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xFFFFF0E3),
          shape: BoxShape.circle,
        ),
        // Decorative: the full name is read just beside it.
        child: ExcludeSemantics(
          child: Text('🦺', style: TextStyle(fontSize: size * 0.46)),
        ),
      );
}

/// #85ד — opens the worker profile editor (modal bottom sheet, X to close).
Future<void> showWorkerProfileEditSheet(
  BuildContext context, {
  required BoardSession session,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EditProfileSheet(session: session),
  );
}

/// The profile editor — שם-תצוגה · טלפון · התמחות (chips) · תמונת-פרופיל (the
/// shared [pickTaskPhoto] capture seam, #85ב). Saved per username through
/// [workerProfileProvider] (key `bs.worker-profile.v1`); every empty field
/// keeps its honest fallback (name → session displayName, no photo → 🦺).
class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet({required this.session});

  final BoardSession session;

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late String _specialty;
  String? _photo;
  String? _phoneError;

  /// מגן in-flight: double-tap על "שמור" לא מריץ save כפול / pop כפול.
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = ref.read(workerProfileProvider)[widget.session.username] ??
        const WorkerProfile();
    _name = TextEditingController(
      text: p.name.isNotEmpty ? p.name : widget.session.displayName,
    );
    _phone = TextEditingController(text: p.phone);
    _specialty = p.specialty;
    _photo = p.photo;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  /// Real capture via the shared seam — null = honest cancel, no change.
  Future<void> _pickPhoto() async {
    final dataUrl = await pickTaskPhoto(context);
    if (!mounted) return;
    if (dataUrl == null) {
      showToast(context, 'לא נבחרה תמונה');
      return;
    }
    setState(() => _photo = dataUrl);
  }

  Future<void> _save() async {
    if (_saving) return; // מגן double-tap (in-flight)
    final phone = _phone.text.trim();
    // FORMAT validation only (the #64 validators) — the phone is optional,
    // but a non-empty value must be a valid Israeli mobile.
    if (phone.isNotEmpty && !validIsraeliMobile(phone)) {
      setState(
        () => _phoneError = 'מספר נייד לא תקין — 10 ספרות, מתחיל ב-05',
      );
      return;
    }
    setState(() => _saving = true);
    final name = _name.text.trim();
    // #17 — the persist is AWAITED: a quota failure (an oversized photo on
    // web localStorage) reports honestly instead of a fake '✓ נשמר'.
    final ok = await ref.read(workerProfileProvider.notifier).save(
          widget.session.username,
          WorkerProfile(
            // Storing '' keeps the honest fallback to the session displayName.
            name: name == widget.session.displayName ? '' : name,
            phone: phone,
            specialty: _specialty,
            photo: _photo,
          ),
        );
    if (!mounted) return;
    if (!ok) {
      setState(() => _saving = false); // מאפשר retry עם תמונה קטנה יותר
      showToast(context, 'התמונה גדולה מדי — לא נשמרה');
      return; // the sheet stays open — the worker can retry a smaller photo
    }
    showToast(context, '✓ הפרופיל נשמר');
    Navigator.of(context).pop();
  }

  /// One התמחות pill — brand fill when selected; re-tapping clears (≥48dp).
  Widget _specChip(String label) {
    final on = _specialty == label;
    return Material(
      color: on ? BsTokens.brand : BsTokens.cardLight,
      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        onTap: () => setState(() => _specialty = on ? '' : label),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: BsTokens.space4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            border: on ? null : Border.all(color: const Color(0xFFE2E2E2)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: on ? bsOnAccent(context) : BsTokens.inkLight,
              fontSize: 13.5,
              fontWeight: on ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        // Keep the fields above the keyboard.
        padding:
            EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: BsTokens.cardLight,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(BsTokens.radiusCard),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(BsTokens.space4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'עריכת פרופיל',
                          style: TextStyle(
                            color: BsTokens.inkLight,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      // X close (sheet rule).
                      IconButton(
                        tooltip: 'סגור',
                        icon: const Icon(
                          Icons.close,
                          color: BsTokens.mutedLight,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: BsTokens.space2),
                  // ── profile photo (#85ד, the #85ב capture seam) ──
                  Row(
                    children: [
                      _ProfileAvatar(photo: _photo, size: 64),
                      const SizedBox(width: BsTokens.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OutlinedButton(
                              onPressed: _pickPhoto,
                              child: Text(
                                _photo == null
                                    ? '📷 הוסף תמונת פרופיל'
                                    : '📷 החלף תמונה',
                              ),
                            ),
                            if (_photo != null)
                              TextButton(
                                onPressed: () =>
                                    setState(() => _photo = null),
                                child: const Text(
                                  'הסר תמונה',
                                  // AA: redAccent על לבן נכשל — token חוזה 9.
                                  style: TextStyle(color: BsTokens.dangerDark),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: BsTokens.space3),
                  // ── display name ──
                  TextField(
                    controller: _name,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'שם תצוגה',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: BsTokens.space3),
                  // ── phone ──
                  TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    onChanged: (_) {
                      if (_phoneError != null) {
                        setState(() => _phoneError = null);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'טלפון (אופציונלי)',
                      hintText: '050-1234567',
                      errorText: _phoneError,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: BsTokens.space3),
                  // ── specialty chips ──
                  const Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      'התמחות',
                      style: TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: BsTokens.space2),
                  Wrap(
                    spacing: BsTokens.space2,
                    runSpacing: BsTokens.space2,
                    children: [
                      for (final s in kWorkerSpecialties) _specChip(s),
                    ],
                  ),
                  const SizedBox(height: BsTokens.space4),
                  // ── save ──
                  Material(
                    color: BsTokens.brand,
                    borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(BsTokens.radiusPill),
                      onTap: _saving ? null : _save,
                      child: Opacity(
                        opacity: _saving ? 0.6 : 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          child: Text(
                            '✓ שמור פרופיל',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: bsOnAccent(context),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
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
}
