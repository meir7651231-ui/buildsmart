// task #85ו · 🔔 WORKER NOTIFICATIONS — the bell on the worker board AppBar
// (unread badge) + the notifications sheet (list · mark-read · clear-all).
// Reads ONLY the logged worker's own feed off `state/worker_notifs.dart`
// (per-username isolation, #66). Style mirrors the worker board: white card
// sheet, RTL, X close button, ≥48dp targets.

import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/notif_settings.dart';
import 'package:buildsmart/data/repositories/worker_notifs_repository.dart'
    show workerNotifsRepositoryProvider, workerNotifsServerProvider;
import 'package:buildsmart/state/worker_notifs.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Relative Hebrew timestamp for a notification row — honest coarse buckets
/// (the feed is runtime-only, so minute precision is plenty).
String workerNotifAgo(DateTime ts) {
  final d = DateTime.now().difference(ts);
  if (d.inMinutes < 1) return 'עכשיו';
  if (d.inMinutes < 60) return 'לפני ${d.inMinutes} דק׳';
  if (d.inHours < 24) return 'לפני ${d.inHours} שע׳';
  return 'לפני ${d.inDays} ימים';
}

/// The AppBar bell: unread badge off [currentWorkerUnreadCountProvider], tap
/// opens [showWorkerNotifsSheet]. IconButton keeps the ≥48dp target.
class WorkerNotifsBell extends ConsumerWidget {
  const WorkerNotifsBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔊 'צליל ורטט' (notif_settings, wave-2 batch-3): when the logged worker's
    // unread count RISES (a real new bell event landed), fire the configured
    // sound/vibration. notifFeedbackFor also honours snooze / quiet-hours.
    ref.listen<int>(currentWorkerUnreadCountProvider, (prev, next) {
      if (next > (prev ?? 0)) {
        playInAppNotifFeedback(ref.read(notifSettingsProvider));
      }
    });
    final unread = ref.watch(currentWorkerUnreadCountProvider);
    return HelpTarget(
      title: 'התראות',
      body:
          'פותח את רשימת ההתראות שלך. התג האדום מציג כמה התראות לא-נקראו. '
          'ממוקם ב-AppBar של הלוח שיש בו 💡, כך שניתן לעטיפה.',
      child: IconButton(
        key: const ValueKey('worker-notifs-bell'),
        tooltip: 'התראות',
        onPressed: () => showWorkerNotifsSheet(context),
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.notifications_outlined,
              color: BsTokens.mutedLight,
            ),
            if (unread > 0)
              PositionedDirectional(
                start: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  decoration: BoxDecoration(
                    color: BsTokens.danger,
                    borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    unread > 9 ? '9+' : '$unread',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Opens the worker notifications sheet (list + mark-read + clear).
Future<void> showWorkerNotifsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _WorkerNotifsSheet(),
  );
}

class _WorkerNotifsSheet extends ConsumerWidget {
  const _WorkerNotifsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(boardAuthProvider);
    final username =
        (session != null && session.role == BoardRole.worker)
            ? session.username
            : null;
    final notifs = ref.watch(currentWorkerNotifsProvider);
    final unread = notifs.where((n) => !n.read).length;
    // Wave T3 (2d) — the SERVER task-bell feed + its repo (null OFF). A read/clear
    // of a SERVER bell writes to `workerNotifs/{uid}`; a LOCAL (HR) bell stays on
    // the local notifier. OFF both are null/empty → only the local path runs.
    final serverNotifs =
        ref.watch(workerNotifsServerProvider).asData?.value ?? const <WorkerNotif>[];
    final notifsRepo = ref.watch(workerNotifsRepositoryProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder:
            (_, scroll) => Container(
              decoration: const BoxDecoration(
                color: BsTokens.cardLight,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(BsTokens.radiusCard),
                ),
              ),
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.all(BsTokens.space4),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: BsTokens.space3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDDDDD),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // ── header: title + X close ──
                  Row(
                    children: [
                      const Expanded(
                        child: CfgText(
                          'worker_notifs_sheet.t01',
                          '🔔 התראות',
                          style: TextStyle(
                            color: BsTokens.inkLight,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'סגירה',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: BsTokens.mutedLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: BsTokens.space2),

                  if (notifs.isEmpty)
                    // Honest empty state — the feed fills only from real events
                    // (אישור/דחייה של המנהל, משימה חדשה שנכנסה לביצוע).
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: BsTokens.space5),
                      child: CfgText(
                        'worker_notifs_sheet.t02',
                        'אין התראות עדיין.\nאישורים, החזרות לתיקון ומשימות חדשות יופיעו כאן.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: BsTokens.mutedLight,
                          fontSize: 13.5,
                        ),
                      ),
                    )
                  else ...[
                    // ── actions row: mark-all-read · clear-all (confirmed) ──
                    Row(
                      children: [
                        if (unread > 0)
                          // composite hide: whole button gone when the org hides this element
                          CfgVisible(
                            'worker_notifs_sheet.t03',
                            child: TextButton(
                            onPressed:
                                username == null
                                    ? null
                                    : () {
                                        ref
                                            .read(workerNotifsProvider.notifier)
                                            .markAllRead(username);
                                        notifsRepo?.markAllRead(serverNotifs);
                                      },
                            child: const CfgText(
                              'worker_notifs_sheet.t03',
                              'סמן הכל כנקרא',
                              style: TextStyle(
                                color: BsTokens.brandDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          ),
                        const Spacer(),
                        // composite hide: whole button gone when the org hides this element
                        CfgVisible(
                          'worker_notifs_sheet.t04',
                          child: TextButton(
                          onPressed:
                              username == null
                                  ? null
                                  : () async {
                                    final ok = await confirmDestructive(
                                      context,
                                      title: 'לנקות את כל ההתראות?',
                                      message:
                                          'כל ההתראות יימחקו — פעולה בלתי הפיכה.',
                                      confirmLabel: 'נקה',
                                    );
                                    if (!ok) return;
                                    ref
                                        .read(workerNotifsProvider.notifier)
                                        .clear(username);
                                    notifsRepo?.clear();
                                  },
                          child: const CfgText(
                            'worker_notifs_sheet.t04',
                            'נקה הכל',
                            style: TextStyle(
                              color: BsTokens.danger,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        ),
                      ],
                    ),
                    const SizedBox(height: BsTokens.space1),
                    for (final n in notifs)
                      _NotifRow(
                        notif: n,
                        onTap:
                            username == null || n.read
                                ? null
                                : () {
                                    // route by source: a SERVER bell → the repo;
                                    // a LOCAL (HR) bell → the local notifier.
                                    if (serverNotifs.any((x) => x.id == n.id)) {
                                      notifsRepo?.markRead(serverNotifs, n.id);
                                    } else {
                                      ref
                                          .read(workerNotifsProvider.notifier)
                                          .markRead(username, n.id);
                                    }
                                  },
                      ),
                  ],
                  const SizedBox(height: BsTokens.space4),
                ],
              ),
            ),
      ),
    );
  }
}

/// One notification row — unread shows an ink title + a brand dot; tapping an
/// unread row marks it read. Min height keeps the ≥48dp target.
class _NotifRow extends StatelessWidget {
  const _NotifRow({required this.notif, this.onTap});

  final WorkerNotif notif;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: notif.read ? BsTokens.cardLight : const Color(0xFFFFF8F2),
      borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(
            horizontal: BsTokens.space3,
            vertical: BsTokens.space2,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notif.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: BsTokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notif.title,
                      style: TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight:
                            notif.read ? FontWeight.w600 : FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                    if (notif.body.isNotEmpty)
                      Text(
                        notif.body,
                        style: const TextStyle(
                          color: BsTokens.mutedLight,
                          fontSize: 12.5,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      workerNotifAgo(notif.ts),
                      style: const TextStyle(
                        color: BsTokens.mutedLight,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (!notif.read)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: BsTokens.space2,
                    top: 6,
                  ),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: BsTokens.brand,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
