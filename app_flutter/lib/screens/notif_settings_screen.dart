import 'package:buildsmart/state/notif_settings.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full-screen Notification settings — 9 categories, ~40 leaves.
/// Most leaves are persisted via [notifSettingsProvider];
/// OS-level quick actions show "בבנייה" toast on tap.
class NotifSettingsScreen extends ConsumerWidget {
  const NotifSettingsScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const NotifSettingsScreen(),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        title: const Text(
          'הגדרות התראות',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
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
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text(
          'איפוס הגדרות?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'כל הגדרות ההתראות יוחזרו לברירת המחדל.',
          style: TextStyle(color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ביטול'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('אפס'),
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
        color: snoozed
            ? const Color(0xFF3A2A0F)
            : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: snoozed ? Colors.orange : Colors.transparent,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: snoozed
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
                        color: Colors.white,
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
      backgroundColor: const Color(0xFFFFFFFF),
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
            child: Text(
              '🔇 השתק התראות',
              style: TextStyle(
                color: Colors.white,
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
                style: const TextStyle(color: Colors.white, fontSize: 15),
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
        _SwitchRow(
          label: 'Push (אפליקציה)',
          value: settings.pushEnabled,
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(pushEnabled: v)),
        ),
        _SwitchRow(
          label: 'אימייל',
          value: settings.emailEnabled,
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(emailEnabled: v)),
        ),
        _SwitchRow(
          label: 'SMS',
          value: settings.smsEnabled,
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(smsEnabled: v)),
        ),
        _SwitchRow(
          label: 'WhatsApp',
          value: settings.whatsappEnabled,
          onChanged: (v) => ref
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
        _SwitchRow(
          label: 'הזמנות',
          value: settings.typeOrders,
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(typeOrders: v)),
        ),
        _SwitchRow(
          label: 'משלוחים',
          value: settings.typeShipments,
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(typeShipments: v)),
        ),
        _SwitchRow(
          label: 'מחירים במועדפים',
          value: settings.typePriceDrops,
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(typePriceDrops: v)),
        ),
        _SwitchRow(
          label: 'מבצעים',
          value: settings.typeDeals,
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(typeDeals: v)),
        ),
        _SwitchRow(
          label: 'הצעות ספקים',
          value: settings.typeSupplierOffers,
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(typeSupplierOffers: v)),
        ),
        _SwitchRow(
          label: 'חזר למלאי',
          value: settings.typeBackInStock,
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(typeBackInStock: v)),
        ),
        _SwitchRow(
          label: 'תזכורות',
          value: settings.typeReminders,
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(typeReminders: v)),
        ),
        _SwitchRow(
          label: 'שיחות חדשות',
          value: settings.typeNewChats,
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(typeNewChats: v)),
        ),
        _SwitchRow(
          label: 'עדכוני פרויקטים',
          value: settings.typeProjectUpdates,
          onChanged: (v) => ref
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
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(quietHoursEnabled: v)),
        ),
        if (settings.quietHoursEnabled) ...[
          _TimeRow(
            label: 'מתחיל בשעה',
            time: settings.quietStart,
            onChanged: (t) {
              ref.read(notifSettingsProvider.notifier).update(
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
              ref.read(notifSettingsProvider.notifier).update(
                    (s) => s.copyWith(
                      quietEndHour: t.hour,
                      quietEndMin: t.minute,
                    ),
                  );
            },
          ),
        ],
        _SwitchRow(
          label: 'ימי שבת/חג',
          value: settings.quietOnShabbat,
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(quietOnShabbat: v)),
        ),
        _SwitchRow(
          label: 'תוך פגישות',
          value: settings.quietInMeetings,
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(quietInMeetings: v)),
        ),
        _SwitchRow(
          label: 'מצב נהיגה',
          value: settings.quietWhileDriving,
          onChanged: (v) => ref
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
        _SwitchRow(
          label: 'צליל מופעל',
          value: settings.soundEnabled,
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(soundEnabled: v)),
        ),
        _SwitchRow(
          label: 'רטט',
          value: settings.vibrationEnabled,
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(vibrationEnabled: v)),
        ),
        _SwitchRow(
          label: 'צלילים שונים לפי סוג',
          value: settings.soundPerType,
          onChanged: (v) => ref
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
          options: const [
            (value: NotifImportance.all, label: 'הכל'),
            (value: NotifImportance.important, label: 'חשובות בלבד'),
            (value: NotifImportance.critical, label: 'קריטיות בלבד'),
          ],
          onChanged: (v) => ref
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
        _SwitchRow(
          label: '👷 קבלן — התראות פרויקט',
          value: settings.personaContractor,
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(personaContractor: v)),
        ),
        _SwitchRow(
          label: '🏪 חנות — הזמנות + מלאי',
          value: settings.personaStore,
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(personaStore: v)),
        ),
        _SwitchRow(
          label: '🛵 שליח — pickup + active',
          value: settings.personaCourier,
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(personaCourier: v)),
        ),
        _SwitchRow(
          label: '🦺 עובד — משימות',
          value: settings.personaWorker,
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(personaWorker: v)),
        ),
        _SwitchRow(
          label: '👔 מנהל מערכת — דשבורד',
          value: settings.personaAdmin,
          onChanged: (v) => ref
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
      children: [
        _SwitchRow(
          label: 'סיכום יומי',
          value: settings.dailySummary,
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(dailySummary: v)),
        ),
        if (settings.dailySummary)
          _TimeRow(
            label: 'שעת שליחה',
            time: settings.dailySummaryTime,
            onChanged: (t) {
              ref.read(notifSettingsProvider.notifier).update(
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
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(morningReport: v)),
        ),
        if (settings.morningReport)
          _TimeRow(
            label: 'שעת דוח בוקר',
            time: settings.morningReportTime,
            onChanged: (t) {
              ref.read(notifSettingsProvider.notifier).update(
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
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(eveningSummary: v)),
        ),
        if (settings.eveningSummary)
          _TimeRow(
            label: 'שעת סיכום ערב',
            time: settings.eveningSummaryTime,
            onChanged: (t) {
              ref.read(notifSettingsProvider.notifier).update(
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
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(weeklySummary: v)),
        ),
        _SwitchRow(
          label: 'סיכום חודשי',
          value: settings.monthlySummary,
          onChanged: (v) => ref
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
      children: [
        _RadioGroupRow<NotifLockScreen>(
          label: 'תצוגה במסך נעול',
          value: settings.lockScreen,
          options: const [
            (value: NotifLockScreen.full, label: 'הצג תוכן מלא'),
            (value: NotifLockScreen.senderOnly, label: 'רק שם השולח'),
            (value: NotifLockScreen.hidden, label: 'הסתר לחלוטין'),
          ],
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(lockScreen: v)),
        ),
        _SwitchRow(
          label: 'אישור ביומטרי לפתיחה',
          value: settings.biometricToOpen,
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(biometricToOpen: v)),
        ),
        _SwitchRow(
          label: 'אל תעבר לשעון/רכב',
          value: settings.dontForwardToWatch,
          onChanged: (v) => ref
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
  });

  final String emoji;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          iconColor: Colors.black54,
          collapsedIconColor: Colors.black54,
          leading: Text(emoji, style: const TextStyle(fontSize: 22)),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: children,
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      value: value,
      activeColor: BsTokens.brand,
      onChanged: onChanged,
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
            title: Text(o.label, style: const TextStyle(color: Colors.white)),
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
      title: Text(label, style: const TextStyle(color: Colors.white)),
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
          builder: (ctx, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
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
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: const Text(
        'בבנייה',
        style: TextStyle(color: Color(0xFF666666), fontSize: 12),
      ),
      onTap: () => showToast(context, '$label — בבנייה'),
    );
  }
}
