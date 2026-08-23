import 'package:buildsmart/screens/keyboard_tool_tree.dart'
    show KbToolNode, kbNotifSettingsNodes;
import 'package:buildsmart/state/keyboard_overlay.dart' show kKbGlobal;
import 'package:buildsmart/state/keyboard_screen_tools.dart' show KbScreen;
import 'package:buildsmart/state/notif_settings.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full-screen Notification settings — 9 categories, ~40 leaves.
/// Most leaves are persisted via [notifSettingsProvider];
/// OS-level quick actions show "בבנייה" toast on tap.
class NotifSettingsScreen extends ConsumerWidget {
  const NotifSettingsScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const NotifSettingsScreen());

  /// STABLE [KbScreen] tool list — built once so the floating-keyboard mirror
  /// never re-registers on rebuild. Tree-shaken with the [KbScreen] path off-flag.
  static final List<KbToolNode> _kbNodes = kbNotifSettingsNodes();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // KbScreen: while this pushed route is front-most under [kKbGlobal], the
    // floating ▦ grid mirrors THIS screen's tools ([_kbNodes]); reverts on pop.
    // Pure pass-through (byte-identical) when the flag is off.
    final Widget body = Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: const CfgText(
          'notif_settings_screen.t01',
          'הגדרות התראות',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black54),
        actions: [
          IconButton(
            tooltip: 'איפוס לברירת מחדל',
            icon: const Icon(Icons.restart_alt, color: Colors.black54),
            onPressed: () => _confirmReset(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: const [
          _SnoozeBanner(),
          _ChannelsSection(),
          _TypesSection(),
          _QuietHoursSection(),
          _SoundSection(),
          _ImportanceSection(),
          _PersonaSection(),
          _SummariesSection(),
          _LockScreenSection(),
          _QuickActionsSection(),
          SizedBox(height: 24),
        ],
      ),
    );
    return kKbGlobal ? KbScreen(tools: _kbNodes, child: body) : body;
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Theme.of(ctx).colorScheme.surface,
            title: const CfgText(
              'notif_settings_screen.t02',
              'איפוס הגדרות?',
              style: TextStyle(color: BsTokens.inkLight),
            ),
            content: const CfgText(
              'notif_settings_screen.t03',
              'כל הגדרות ההתראות יוחזרו לברירת המחדל.',
              style: TextStyle(color: Colors.black54),
            ),
            actions: [
              // composite hide: whole cancel button vanishes, not just its label.
              CfgVisible(
                'notif_settings_screen.t04',
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const CfgText('notif_settings_screen.t04', 'ביטול'),
                ),
              ),
              // composite hide: whole reset button vanishes, not just its label.
              CfgVisible(
                'notif_settings_screen.t05',
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                  child: const CfgText('notif_settings_screen.t05', 'אפס'),
                ),
              ),
            ],
          ),
    );
    if ((ok ?? false) && context.mounted) {
      await ref.read(notifSettingsProvider.notifier).reset();
      if (context.mounted) showToast(context, 'הגדרות אופסו');
    }
  }
}

// ─── snooze banner (top) ─────────────────────────────────────────────────────

class _SnoozeBanner extends ConsumerWidget {
  const _SnoozeBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notifSettingsProvider);
    final snoozed = settings.isSnoozedNow;
    final until = DateTime.fromMillisecondsSinceEpoch(settings.snoozeUntilMs);
    final untilLabel =
        '${until.hour.toString().padLeft(2, '0')}:${until.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      decoration: BoxDecoration(
        color: snoozed ? const Color(0xFF3A2A0F) : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: snoozed ? Colors.orange : Colors.transparent),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap:
            snoozed
                ? () {
                  ref.read(notifSettingsProvider.notifier).cancelSnooze();
                  showToast(context, 'השתקה בוטלה');
                }
                : () => _showSnoozeMenu(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(
                snoozed ? Icons.notifications_off : Icons.notifications_paused,
                color: snoozed ? Colors.orange : BsTokens.brand,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snoozed
                          ? 'התראות מושתקות עד $untilLabel'
                          : '🔇 השתק התראות זמנית',
                      style: const TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      snoozed ? 'לחץ לביטול' : 'בחר משך זמן',
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                snoozed ? Icons.close : Icons.chevron_left,
                color: Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSnoozeMenu(BuildContext context, WidgetRef ref) async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _SnoozeSheet(),
    );
    if (picked != null && context.mounted) {
      ref.read(notifSettingsProvider.notifier).snoozeForMinutes(picked);
      showToast(context, 'התראות הושתקו');
    }
  }
}

class _SnoozeSheet extends StatelessWidget {
  const _SnoozeSheet();

  static const _options = [
    (mins: 15, label: '15 דקות'),
    (mins: 60, label: 'שעה'),
    (mins: 240, label: '4 שעות'),
    (mins: 1440, label: 'יום שלם'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          const Align(
            alignment: Alignment.centerRight,
            child: CfgText(
              'notif_settings_screen.t06',
              '🔇 השתק התראות',
              style: TextStyle(
                color: BsTokens.inkLight,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF5F5F5), height: 1),
          ..._options.map(
            (o) => ListTile(
              title: Text(
                o.label,
                style: const TextStyle(color: BsTokens.inkLight, fontSize: 15),
              ),
              trailing: const Icon(
                Icons.chevron_left,
                color: Color(0xFF888888),
              ),
              onTap: () => Navigator.pop(context, o.mins),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 1. channels ─────────────────────────────────────────────────────────────

class _ChannelsSection extends ConsumerWidget {
  const _ChannelsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notifSettingsProvider);
    return _SectionTile(
      emoji: '📱',
      title: 'ערוצי קבלה',
      children: [
        // הערוץ היחיד שניתן לחווט בכנות ללא שרת: כשהוא כבוי, חיווי
        // ההתראות החדשות בתוך האפליקציה (בדג' ה'עדכונים' + מונה 'חדשות')
        // מושתק דרך notifUnreadCountProvider.
        _SwitchRow(
          label: 'התראות בתוך האפליקציה',
          value: settings.pushEnabled,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(pushEnabled: v)),
        ),
        // ערוצים התלויים בשרת — מושבתים ביושר ('דורש חיבור שרת') במקום
        // מתג ששומר ערך בלי שום השפעה.
        _SwitchRow(
          label: 'אימייל',
          value: settings.emailEnabled,
          requiresServer: true,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(emailEnabled: v)),
        ),
        _SwitchRow(
          label: 'SMS',
          value: settings.smsEnabled,
          requiresServer: true,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(smsEnabled: v)),
        ),
        _SwitchRow(
          label: 'WhatsApp',
          value: settings.whatsappEnabled,
          requiresServer: true,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(whatsappEnabled: v)),
        ),
      ],
    );
  }
}

// ─── 2. types ────────────────────────────────────────────────────────────────

class _TypesSection extends ConsumerWidget {
  const _TypesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notifSettingsProvider);
    return _SectionTile(
      emoji: '🔔',
      title: 'סוגי התראות',
      children: [
        // 🔔 #52 — 'הזמנות' + 'משלוחים' notifications RELOCATED to the orders
        // world (store_screen · 📦 הזמנות → OrderNotifSheet). They bind the SAME
        // notifSettingsProvider (typeOrders / typeShipments); every other type
        // below stays here.
        // 🔑 This toggle gates the BUDGET-overrun feed ('חריגת תקציב',
        // high-priority) via notifMutedSections (typePriceDrops →
        // NotifSection.budget) — NOT price drops. Label matches the true
        // effect; the persisted field name (typePriceDrops) is left unchanged.
        _SwitchRow(
          label: 'התראות תקציב',
          value: settings.typePriceDrops,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(typePriceDrops: v)),
        ),
        _SwitchRow(
          label: 'מבצעים',
          value: settings.typeDeals,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(typeDeals: v)),
        ),
        _SwitchRow(
          label: 'הצעות ספקים',
          value: settings.typeSupplierOffers,
          underConstruction: true,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(typeSupplierOffers: v)),
        ),
        _SwitchRow(
          label: 'חזר למלאי',
          value: settings.typeBackInStock,
          underConstruction: true,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(typeBackInStock: v)),
        ),
        _SwitchRow(
          label: 'תזכורות',
          value: settings.typeReminders,
          underConstruction: true,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(typeReminders: v)),
        ),
        _SwitchRow(
          label: 'שיחות חדשות',
          value: settings.typeNewChats,
          underConstruction: true,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(typeNewChats: v)),
        ),
        _SwitchRow(
          label: 'עדכוני פרויקטים',
          value: settings.typeProjectUpdates,
          underConstruction: true,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(typeProjectUpdates: v)),
        ),
      ],
    );
  }
}

// ─── 3. quiet hours ──────────────────────────────────────────────────────────

class _QuietHoursSection extends ConsumerWidget {
  const _QuietHoursSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notifSettingsProvider);
    return _SectionTile(
      emoji: '⏰',
      title: 'שעות שקט (DND)',
      children: [
        _SwitchRow(
          label: 'הפעל שעות שקט',
          value: settings.quietHoursEnabled,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(quietHoursEnabled: v)),
        ),
        if (settings.quietHoursEnabled) ...[
          _TimeRow(
            label: 'מתחיל בשעה',
            time: settings.quietStart,
            onChanged: (t) {
              ref
                  .read(notifSettingsProvider.notifier)
                  .update(
                    (s) => s.copyWith(
                      quietStartHour: t.hour,
                      quietStartMin: t.minute,
                    ),
                  );
            },
          ),
          _TimeRow(
            label: 'מסתיים בשעה',
            time: settings.quietEnd,
            onChanged: (t) {
              ref
                  .read(notifSettingsProvider.notifier)
                  .update(
                    (s) =>
                        s.copyWith(quietEndHour: t.hour, quietEndMin: t.minute),
                  );
            },
          ),
        ],
        _SwitchRow(
          label: 'ימי שבת/חג',
          value: settings.quietOnShabbat,
          underConstruction: true,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(quietOnShabbat: v)),
        ),
        _SwitchRow(
          label: 'תוך פגישות',
          value: settings.quietInMeetings,
          underConstruction: true,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(quietInMeetings: v)),
        ),
        _SwitchRow(
          label: 'מצב נהיגה',
          value: settings.quietWhileDriving,
          underConstruction: true,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(quietWhileDriving: v)),
        ),
      ],
    );
  }
}

// ─── 4. sound & vibration ────────────────────────────────────────────────────

class _SoundSection extends ConsumerWidget {
  const _SoundSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notifSettingsProvider);
    return _SectionTile(
      emoji: '🔊',
      title: 'צליל ורטט',
      children: [
        // 🟢 WIRED — צליל מופעל / רטט drive the LIVE in-app bell feedback
        // (worker + courier boards) via playInAppNotifFeedback; silenced during
        // snooze / quiet-hours by notifFeedbackFor. No 'בבנייה' marker.
        _SwitchRow(
          label: 'צליל מופעל',
          value: settings.soundEnabled,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(soundEnabled: v)),
        ),
        _SwitchRow(
          label: 'רטט',
          value: settings.vibrationEnabled,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(vibrationEnabled: v)),
        ),
        // 🔑 Per-type sound + LED need a native notification-channel pipeline
        // (Android channels / a sound asset per type) — kept honest, not faked.
        _SwitchRow(
          label: 'צלילים שונים לפי סוג',
          value: settings.soundPerType,
          underConstruction: true,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(soundPerType: v)),
        ),
        const _PlaceholderRow(label: 'LED (אנדרואיד)'),
      ],
    );
  }
}

// ─── 5. importance & filtering ───────────────────────────────────────────────

class _ImportanceSection extends ConsumerWidget {
  const _ImportanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notifSettingsProvider);
    return _SectionTile(
      emoji: '🎯',
      title: 'חשיבות וסינון',
      children: [
        _RadioGroupRow<NotifImportance>(
          label: 'רמת חשיבות',
          value: settings.importanceFilter,
          // No 'critical' tier exists in the data model — passesImportance
          // treats every non-'all' filter identically (== all || highPriority),
          // so a 'קריטיות בלבד' option would behave exactly like 'חשובות בלבד'.
          // Only the two meaningful tiers are offered.
          options: const [
            (value: NotifImportance.all, label: 'הכל'),
            (value: NotifImportance.important, label: 'חשובות בלבד'),
          ],
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(importanceFilter: v)),
        ),
        const _PlaceholderRow(label: "דחייה (1ש' / 4ש' / יום)"),
        const _PlaceholderRow(label: 'חסימת שולח'),
      ],
    );
  }
}

// ─── 6. per persona ──────────────────────────────────────────────────────────

class _PersonaSection extends ConsumerWidget {
  const _PersonaSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notifSettingsProvider);
    return _SectionTile(
      emoji: '👤',
      title: 'לפי תפקיד',
      children: [
        // 🔑 Contractor / store / admin have no dedicated in-app bell FEED to
        // gate yet (the contractor reads the shared 'התראות' feed, already
        // filtered by 'סוגי התראות'); kept honest until each gets its own feed.
        _SwitchRow(
          label: '👷 קבלן — התראות פרויקט',
          value: settings.personaContractor,
          underConstruction: true,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(personaContractor: v)),
        ),
        _SwitchRow(
          label: '🏪 חנות — הזמנות + מלאי',
          value: settings.personaStore,
          underConstruction: true,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(personaStore: v)),
        ),
        // 🟢 WIRED — these two gate the LIVE per-username bell feed on the
        // courier / worker boards via boardFeedEnabled (currentWorkerNotifs +
        // _courierFeed): off ⇒ that board's bell goes quiet.
        _SwitchRow(
          label: '🛵 שליח — pickup + active',
          value: settings.personaCourier,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(personaCourier: v)),
        ),
        _SwitchRow(
          label: '🦺 עובד — משימות',
          value: settings.personaWorker,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(personaWorker: v)),
        ),
        _SwitchRow(
          label: '👔 מנהל המערכת — דשבורד',
          value: settings.personaAdmin,
          underConstruction: true,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(personaAdmin: v)),
        ),
      ],
    );
  }
}

// ─── 7. periodic summaries ───────────────────────────────────────────────────

class _SummariesSection extends ConsumerWidget {
  const _SummariesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notifSettingsProvider);
    return _SectionTile(
      emoji: '📊',
      title: 'סיכומים תקופתיים',
      underConstruction: true,
      children: [
        _SwitchRow(
          label: 'סיכום יומי',
          value: settings.dailySummary,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(dailySummary: v)),
        ),
        if (settings.dailySummary)
          _TimeRow(
            label: 'שעת שליחה',
            time: settings.dailySummaryTime,
            onChanged: (t) {
              ref
                  .read(notifSettingsProvider.notifier)
                  .update(
                    (s) => s.copyWith(
                      dailySummaryHour: t.hour,
                      dailySummaryMin: t.minute,
                    ),
                  );
            },
          ),
        _SwitchRow(
          label: 'דוח בוקר',
          value: settings.morningReport,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(morningReport: v)),
        ),
        if (settings.morningReport)
          _TimeRow(
            label: 'שעת דוח בוקר',
            time: settings.morningReportTime,
            onChanged: (t) {
              ref
                  .read(notifSettingsProvider.notifier)
                  .update(
                    (s) => s.copyWith(
                      morningReportHour: t.hour,
                      morningReportMin: t.minute,
                    ),
                  );
            },
          ),
        _SwitchRow(
          label: 'סיכום ערב',
          value: settings.eveningSummary,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(eveningSummary: v)),
        ),
        if (settings.eveningSummary)
          _TimeRow(
            label: 'שעת סיכום ערב',
            time: settings.eveningSummaryTime,
            onChanged: (t) {
              ref
                  .read(notifSettingsProvider.notifier)
                  .update(
                    (s) => s.copyWith(
                      eveningSummaryHour: t.hour,
                      eveningSummaryMin: t.minute,
                    ),
                  );
            },
          ),
        _SwitchRow(
          label: 'סיכום שבועי (ראשון)',
          value: settings.weeklySummary,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(weeklySummary: v)),
        ),
        _SwitchRow(
          label: 'סיכום חודשי',
          value: settings.monthlySummary,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(monthlySummary: v)),
        ),
      ],
    );
  }
}

// ─── 8. lock screen privacy ──────────────────────────────────────────────────

class _LockScreenSection extends ConsumerWidget {
  const _LockScreenSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notifSettingsProvider);
    return _SectionTile(
      emoji: '🔐',
      title: 'פרטיות במסך נעול',
      underConstruction: true,
      children: [
        _RadioGroupRow<NotifLockScreen>(
          label: 'תצוגה במסך נעול',
          value: settings.lockScreen,
          options: const [
            (value: NotifLockScreen.full, label: 'הצג תוכן מלא'),
            (value: NotifLockScreen.senderOnly, label: 'רק שם השולח'),
            (value: NotifLockScreen.hidden, label: 'הסתר לחלוטין'),
          ],
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(lockScreen: v)),
        ),
        _SwitchRow(
          label: 'אישור ביומטרי לפתיחה',
          value: settings.biometricToOpen,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(biometricToOpen: v)),
        ),
        _SwitchRow(
          label: 'אל תעבר לשעון/רכב',
          value: settings.dontForwardToWatch,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(dontForwardToWatch: v)),
        ),
      ],
    );
  }
}

// ─── 9. quick actions ────────────────────────────────────────────────────────

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return const _SectionTile(
      emoji: '⚡',
      title: 'פעולות מהירות',
      children: [
        _PlaceholderRow(label: 'כפתורי תגובה בהתראה'),
        _PlaceholderRow(label: 'אישור בלי פתיחת אפליקציה'),
        _PlaceholderRow(label: 'דחייה מהירה'),
        _PlaceholderRow(label: 'תשובה ישירה'),
      ],
    );
  }
}

// ─── shared widgets ──────────────────────────────────────────────────────────

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.emoji,
    required this.title,
    required this.children,
    this.underConstruction = false,
  });

  final String emoji;
  final String title;
  final List<Widget> children;

  // When true: this section's persisted toggles have no engine yet — show an
  // honest "בבנייה" subtitle and suppress the active-count badge (Wave 8 / D2).
  final bool underConstruction;

  // A row is a backend-blocked "under construction" placeholder when it is a
  // _PlaceholderRow, a server-only channel, or an _Inert row flagged
  // underConstruction. Single source of truth for the count badge AND the
  // Apple-readiness hide-filter.
  static bool _isUnderConstruction(Widget w) =>
      w is _PlaceholderRow ||
      (w is _SwitchRow && w.requiresServer) ||
      (w is _Inert && (w as _Inert).underConstruction);

  // Count only functional rows — exclude "בבנייה" placeholders and rows
  // that require a server connection (honestly disabled in this build).
  int get _activeCount =>
      children.where((w) => !_isUnderConstruction(w)).length;

  // For Apple review (kHideUnderConstruction) we render only the functional
  // rows; the placeholder rows stay defined in code (reversible) but are hidden.
  List<Widget> get _visibleChildren =>
      kHideUnderConstruction
          ? children.where((w) => !_isUnderConstruction(w)).toList()
          : children;

  @override
  Widget build(BuildContext context) {
    // A whole section that is itself "under construction" — or one whose every
    // row is a hidden placeholder — disappears entirely for Apple review.
    if (kHideUnderConstruction &&
        (underConstruction || _visibleChildren.isEmpty)) {
      return const SizedBox.shrink();
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: Theme.of(context).colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          iconColor: Colors.black54,
          collapsedIconColor: Colors.black54,
          leading: Text(emoji, style: const TextStyle(fontSize: 22)),
          // Count badge replaces the default expand chevron.
          trailing:
              (underConstruction || _activeCount == 0)
                  ? null
                  : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: BsTokens.brand,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      '$_activeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          title: Text(
            title,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle:
              underConstruction
                  ? const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: CfgText(
                      'notif_settings_screen.t07',
                      'בבנייה — ההגדרות נשמרות אך עדיין אינן משפיעות',
                      style: TextStyle(
                        color: BsTokens.mutedLight,
                        fontSize: 12,
                      ),
                    ),
                  )
                  : null,
          children: _visibleChildren,
        ),
      ),
    );
  }
}

/// Marker for settings rows that persist a value no engine consumes yet
/// (honesty pass). Excluded from the section active-count badge.
abstract interface class _Inert {
  bool get underConstruction;
}

class _SwitchRow extends StatelessWidget implements _Inert {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.underConstruction = false,
    this.requiresServer = false,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  /// Channels that cannot work without a server (אימייל/SMS/WhatsApp):
  /// rendered disabled with an honest 'דורש חיבור שרת' caption — never fake.
  final bool requiresServer;
  @override
  final bool underConstruction;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: const TextStyle(color: BsTokens.inkLight)),
      subtitle:
          requiresServer
              ? const CfgText(
                'notif_settings_screen.t08',
                'דורש חיבור שרת — לא זמין בגרסה זו',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
              )
              : underConstruction
              ? const CfgText(
                'notif_settings_screen.t09',
                'בבנייה — עדיין לא משפיע',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
              )
              : null,
      value: value,
      activeColor: BsTokens.brand,
      onChanged: requiresServer ? null : onChanged,
    );
  }
}

class _RadioGroupRow<T> extends StatelessWidget {
  const _RadioGroupRow({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<({T value, String label})> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ),
        ...options.map(
          (o) => RadioListTile<T>(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(
              o.label,
              style: const TextStyle(color: BsTokens.inkLight),
            ),
            value: o.value,
            groupValue: value,
            activeColor: BsTokens.brand,
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.label,
    required this.time,
    required this.onChanged,
  });

  final String label;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onChanged;

  String get _formatted =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: const TextStyle(color: BsTokens.inkLight)),
      trailing: Text(
        _formatted,
        style: const TextStyle(
          color: BsTokens.brand,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder:
              (ctx, child) => Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: BsTokens.brand,
                    surface: Color(0xFFFFFFFF),
                  ),
                ),
                child: child!,
              ),
        );
        if (picked != null) onChanged(picked);
      },
    );
  }
}

class _PlaceholderRow extends StatelessWidget {
  const _PlaceholderRow({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: const TextStyle(color: BsTokens.inkLight)),
      trailing: const CfgText(
        'notif_settings_screen.t10',
        'בבנייה',
        style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
      ),
      onTap: () => showToast(context, '$label — בבנייה'),
    );
  }
}
