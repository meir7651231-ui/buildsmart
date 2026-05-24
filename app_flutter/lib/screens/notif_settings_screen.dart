import 'package:buildsmart/state/notif_settings.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full-screen Notification settings — 9 categories, ~40 leaves.
/// 8 active leaves persisted via [notifSettingsProvider];
/// the rest show "בבנייה" toast on tap.
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
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          'הגדרות התראות',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: Colors.white70),
        actions: [
          IconButton(
            tooltip: 'איפוס לברירת מחדל',
            icon: const Icon(Icons.restart_alt, color: Colors.white70),
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
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'איפוס הגדרות?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'כל הגדרות ההתראות יוחזרו לברירת המחדל.',
          style: TextStyle(color: Colors.white70),
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
            : const Color(0xFF1A1A1A),
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
                color: Colors.white54,
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
      backgroundColor: const Color(0xFF1A1A1A),
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
                color: Colors.white24,
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
          const Divider(color: Color(0xFF2A2A2A), height: 1),
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
        const _PlaceholderRow(label: 'SMS'),
        const _PlaceholderRow(label: 'WhatsApp'),
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
        const _PlaceholderRow(label: 'מבצעים'),
        const _PlaceholderRow(label: 'הצעות ספקים'),
        const _PlaceholderRow(label: 'חזר למלאי'),
        const _PlaceholderRow(label: 'תזכורות'),
        const _PlaceholderRow(label: 'שיחות חדשות'),
        const _PlaceholderRow(label: 'עדכוני פרויקטים'),
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
        const _PlaceholderRow(label: 'ימי שבת/חג'),
        const _PlaceholderRow(label: 'תוך פגישות'),
        const _PlaceholderRow(label: 'מצב נהיגה'),
      ],
    );
  }
}

// ─── 4. sound & vibration ────────────────────────────────────────────────────

class _SoundSection extends StatelessWidget {
  const _SoundSection();

  @override
  Widget build(BuildContext context) {
    return const _SectionTile(
      emoji: '🔊',
      title: 'צליל ורטט',
      children: [
        _PlaceholderRow(label: 'צליל ברירת מחדל'),
        _PlaceholderRow(label: 'רטט'),
        _PlaceholderRow(label: 'צלילים לפי סוג'),
        _PlaceholderRow(label: 'LED (אנדרואיד)'),
      ],
    );
  }
}

// ─── 5. importance & filtering ───────────────────────────────────────────────

class _ImportanceSection extends StatelessWidget {
  const _ImportanceSection();

  @override
  Widget build(BuildContext context) {
    return const _SectionTile(
      emoji: '🎯',
      title: 'חשיבות וסינון',
      children: [
        _PlaceholderRow(label: 'כל ההתראות'),
        _PlaceholderRow(label: 'חשובות בלבד'),
        _PlaceholderRow(label: "דחייה (1ש' / 4ש' / יום)"),
        _PlaceholderRow(label: 'חסימת שולח'),
      ],
    );
  }
}

// ─── 6. per persona ──────────────────────────────────────────────────────────

class _PersonaSection extends StatelessWidget {
  const _PersonaSection();

  @override
  Widget build(BuildContext context) {
    return const _SectionTile(
      emoji: '👤',
      title: 'לפי תפקיד',
      children: [
        _PlaceholderRow(label: '👷 קבלן — התראות פרויקט'),
        _PlaceholderRow(label: '🏪 חנות — הזמנות + מלאי'),
        _PlaceholderRow(label: '🛵 שליח — pickup + active'),
        _PlaceholderRow(label: '🦺 עובד — משימות'),
        _PlaceholderRow(label: '👔 מנהל מערכת — דשבורד'),
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
        const _PlaceholderRow(label: 'דוח בוקר (07:00)'),
        const _PlaceholderRow(label: 'סיכום ערב (18:00)'),
        const _PlaceholderRow(label: 'שבועי (ראשון 09:00)'),
        const _PlaceholderRow(label: 'חודשי'),
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
        const _PlaceholderRow(label: 'אישור ביומטרי לפתיחה'),
        const _PlaceholderRow(label: 'אל תעבר לשעון/רכב'),
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
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          iconColor: Colors.white70,
          collapsedIconColor: Colors.white70,
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
            style: const TextStyle(color: Colors.white70, fontSize: 13),
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
                surface: Color(0xFF1A1A1A),
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
