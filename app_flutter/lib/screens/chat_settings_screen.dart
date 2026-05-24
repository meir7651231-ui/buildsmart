import 'package:buildsmart/state/chat_settings.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full-screen Chat settings — 9 categories, ~40 leaves.
/// Active leaves persisted via [chatSettingsProvider];
/// the rest show "בבנייה" toast on tap.
class ChatSettingsScreen extends ConsumerWidget {
  const ChatSettingsScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const ChatSettingsScreen(),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          'הגדרות שיחות',
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
          _QuickReplyBanner(),
          _PresenceSection(),
          _ChatNotifSection(),
          _MediaSection(),
          _ChatPrivacySection(),
          _BackupSection(),
          _LangSection(),
          _BusinessSection(),
          _BotSection(),
          _ArchiveSection(),
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
          'כל הגדרות השיחות יוחזרו לברירת המחדל.',
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
      await ref.read(chatSettingsProvider.notifier).reset();
      if (context.mounted) showToast(context, 'הגדרות אופסו');
    }
  }
}

// ─── quick-reply banner (top) ─────────────────────────────────────────────────

class _QuickReplyBanner extends StatelessWidget {
  const _QuickReplyBanner();

  static const _templates = [
    'בדרך אליך 🚗',
    'אאשר בקרוב ✅',
    'קיבלתי, תודה 🙏',
    'נחזור אליך 📞',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              const Text(
                'תשובות מהירות',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => showToast(context, 'עריכת תבניות — בבנייה'),
                child: const Text(
                  'ערוך',
                  style: TextStyle(color: BsTokens.brand, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final t in _templates)
                GestureDetector(
                  onTap: () => showToast(context, 'תבנית — בבנייה'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF222222),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF333333)),
                    ),
                    child: Text(
                      t,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── 1. presence & read receipts ─────────────────────────────────────────────

class _PresenceSection extends ConsumerWidget {
  const _PresenceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(chatSettingsProvider);
    return _SectionTile(
      emoji: '💬',
      title: 'שיחות וחיווי',
      children: [
        _SwitchRow(
          label: 'אישורי קריאה',
          value: settings.readReceipts,
          onChanged: (v) => ref
              .read(chatSettingsProvider.notifier)
              .update((s) => s.copyWith(readReceipts: v)),
        ),
        _SwitchRow(
          label: 'חיווי הקלדה',
          value: settings.typingIndicator,
          onChanged: (v) => ref
              .read(chatSettingsProvider.notifier)
              .update((s) => s.copyWith(typingIndicator: v)),
        ),
        _SwitchRow(
          label: 'תצוגה מקדימה בנעילה',
          value: settings.lockScreenPreview,
          onChanged: (v) => ref
              .read(chatSettingsProvider.notifier)
              .update((s) => s.copyWith(lockScreenPreview: v)),
        ),
        _SwitchRow(
          label: 'פתיחת שיחה (מענה ראשוני)',
          value: settings.initialResponseEnabled,
          onChanged: (v) => ref
              .read(chatSettingsProvider.notifier)
              .update((s) => s.copyWith(initialResponseEnabled: v)),
        ),
        _RadioGroupRow<ChatLastSeen>(
          label: 'זמן מקוון אחרון',
          value: settings.lastSeenPrivacy,
          options: const [
            (value: ChatLastSeen.everyone, label: 'כולם'),
            (value: ChatLastSeen.contacts, label: 'אנשי קשר'),
            (value: ChatLastSeen.nobody, label: 'אף אחד'),
          ],
          onChanged: (v) => ref
              .read(chatSettingsProvider.notifier)
              .update((s) => s.copyWith(lastSeenPrivacy: v)),
        ),
      ],
    );
  }
}

// ─── 2. chat notifications ───────────────────────────────────────────────────

class _ChatNotifSection extends ConsumerWidget {
  const _ChatNotifSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(chatSettingsProvider);
    return _SectionTile(
      emoji: '🔔',
      title: 'התראות שיחה',
      children: [
        _SwitchRow(
          label: 'צלצול שיחה נכנסת',
          value: settings.callRingEnabled,
          onChanged: (v) => ref
              .read(chatSettingsProvider.notifier)
              .update((s) => s.copyWith(callRingEnabled: v)),
        ),
        _SwitchRow(
          label: 'התראת הודעה חדשה',
          value: settings.messageAlertEnabled,
          onChanged: (v) => ref
              .read(chatSettingsProvider.notifier)
              .update((s) => s.copyWith(messageAlertEnabled: v)),
        ),
        _SwitchRow(
          label: 'רטט',
          value: settings.chatVibration,
          onChanged: (v) => ref
              .read(chatSettingsProvider.notifier)
              .update((s) => s.copyWith(chatVibration: v)),
        ),
        const _PlaceholderRow(label: 'צלצול לפי איש קשר'),
        const _PlaceholderRow(label: 'השתקת שיחה ספציפית'),
      ],
    );
  }
}

// ─── 3. media & audio ────────────────────────────────────────────────────────

class _MediaSection extends ConsumerWidget {
  const _MediaSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(chatSettingsProvider);
    return _SectionTile(
      emoji: '🎙️',
      title: 'מדיה ושמע',
      children: [
        _RadioGroupRow<ChatMediaDownload>(
          label: 'הורדה אוטומטית',
          value: settings.mediaDownload,
          options: const [
            (value: ChatMediaDownload.wifiOnly, label: 'WiFi בלבד'),
            (value: ChatMediaDownload.cellular, label: 'WiFi + סלולרי'),
            (value: ChatMediaDownload.both, label: 'תמיד'),
            (value: ChatMediaDownload.never, label: 'אף פעם'),
          ],
          onChanged: (v) => ref
              .read(chatSettingsProvider.notifier)
              .update((s) => s.copyWith(mediaDownload: v)),
        ),
        _RadioGroupRow<ChatImageQuality>(
          label: 'איכות תמונות נשלחות',
          value: settings.imageQuality,
          options: const [
            (value: ChatImageQuality.original, label: 'מקורית'),
            (value: ChatImageQuality.high, label: 'גבוהה'),
            (value: ChatImageQuality.medium, label: 'בינונית'),
          ],
          onChanged: (v) => ref
              .read(chatSettingsProvider.notifier)
              .update((s) => s.copyWith(imageQuality: v)),
        ),
        _SwitchRow(
          label: 'דחיסת וידאו',
          value: settings.compressVideo,
          onChanged: (v) => ref
              .read(chatSettingsProvider.notifier)
              .update((s) => s.copyWith(compressVideo: v)),
        ),
        _ActionRow(
          label: 'ניהול אחסון',
          buttonLabel: 'נקה',
          onTap: () => showToast(context, 'אחסון נוקה'),
        ),
      ],
    );
  }
}

// ─── 4. privacy ──────────────────────────────────────────────────────────────

class _ChatPrivacySection extends ConsumerWidget {
  const _ChatPrivacySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(chatSettingsProvider);
    return _SectionTile(
      emoji: '👥',
      title: 'פרטיות',
      children: [
        _RadioGroupRow<ChatPrivacy>(
          label: 'מי יכול לפתוח שיחה',
          value: settings.chatPrivacy,
          options: const [
            (value: ChatPrivacy.everyone, label: 'כולם'),
            (value: ChatPrivacy.contacts, label: 'אנשי קשר בלבד'),
            (value: ChatPrivacy.saved, label: 'שמורים בלבד'),
          ],
          onChanged: (v) => ref
              .read(chatSettingsProvider.notifier)
              .update((s) => s.copyWith(chatPrivacy: v)),
        ),
        const _PlaceholderRow(label: 'חסימת משתמשים'),
        const _PlaceholderRow(label: 'פרטי הפרופיל (תמונה / ביוגרפיה)'),
        _ActionRow(
          label: 'מחיקת היסטוריה',
          buttonLabel: 'מחק',
          destructive: true,
          onTap: () => showToast(context, 'היסטוריה נמחקה'),
        ),
      ],
    );
  }
}

// ─── 5. backup & export ──────────────────────────────────────────────────────

class _BackupSection extends ConsumerWidget {
  const _BackupSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(chatSettingsProvider);
    return _SectionTile(
      emoji: '💾',
      title: 'גיבוי וייצוא',
      children: [
        _SwitchRow(
          label: 'גיבוי לענן',
          value: settings.backupEnabled,
          onChanged: (v) => ref
              .read(chatSettingsProvider.notifier)
              .update((s) => s.copyWith(backupEnabled: v)),
        ),
        if (settings.backupEnabled)
          _RadioGroupRow<ChatBackupFreq>(
            label: 'תדירות גיבוי',
            value: settings.backupFreq,
            options: const [
              (value: ChatBackupFreq.daily, label: 'יומי'),
              (value: ChatBackupFreq.weekly, label: 'שבועי'),
              (value: ChatBackupFreq.monthly, label: 'חודשי'),
            ],
            onChanged: (v) => ref
                .read(chatSettingsProvider.notifier)
                .update((s) => s.copyWith(backupFreq: v)),
          ),
        _ActionRow(
          label: 'ייצוא היסטוריה (CSV)',
          buttonLabel: 'ייצא',
          onTap: () => showToast(context, 'מייצא...'),
        ),
        _ActionRow(
          label: 'מחיקת גיבוי ענן',
          buttonLabel: 'מחק',
          destructive: true,
          onTap: () => showToast(context, 'גיבוי נמחק'),
        ),
      ],
    );
  }
}

// ─── 6. language & translation ───────────────────────────────────────────────

class _LangSection extends ConsumerWidget {
  const _LangSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(chatSettingsProvider);
    return _SectionTile(
      emoji: '🌐',
      title: 'שפה ותרגום',
      children: [
        _RadioGroupRow<ChatLang>(
          label: 'שפת ממשק',
          value: settings.lang,
          options: const [
            (value: ChatLang.he, label: 'עברית'),
            (value: ChatLang.ar, label: 'ערבית'),
            (value: ChatLang.en, label: 'אנגלית'),
          ],
          onChanged: (v) => ref
              .read(chatSettingsProvider.notifier)
              .update((s) => s.copyWith(lang: v)),
        ),
        _SwitchRow(
          label: 'תרגום אוטומטי',
          value: settings.autoTranslate,
          onChanged: (v) => ref
              .read(chatSettingsProvider.notifier)
              .update((s) => s.copyWith(autoTranslate: v)),
        ),
        const _PlaceholderRow(label: 'שפת מקלדת'),
      ],
    );
  }
}

// ─── 7. business hours ───────────────────────────────────────────────────────

class _BusinessSection extends ConsumerWidget {
  const _BusinessSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(chatSettingsProvider);
    return _SectionTile(
      emoji: '🏪',
      title: 'שיחות עסקיות',
      children: [
        _SwitchRow(
          label: 'שעות פעילות עסקית',
          value: settings.businessHoursEnabled,
          onChanged: (v) => ref
              .read(chatSettingsProvider.notifier)
              .update((s) => s.copyWith(businessHoursEnabled: v)),
        ),
        if (settings.businessHoursEnabled) ...[
          _TimeRow(
            label: 'פתיחה',
            time: settings.businessStart,
            onChanged: (t) {
              ref.read(chatSettingsProvider.notifier).update(
                    (s) => s.copyWith(
                      businessStartHour: t.hour,
                      businessStartMin: t.minute,
                    ),
                  );
            },
          ),
          _TimeRow(
            label: 'סגירה',
            time: settings.businessEnd,
            onChanged: (t) {
              ref.read(chatSettingsProvider.notifier).update(
                    (s) => s.copyWith(
                      businessEndHour: t.hour,
                      businessEndMin: t.minute,
                    ),
                  );
            },
          ),
          _InlineTextRow(
            label: 'הודעת מחוץ לשעות',
            hint: 'אנחנו סגורים, נחזור אליך בשעות הפעילות...',
            value: settings.autoReplyMessage,
            onChanged: (v) => ref
                .read(chatSettingsProvider.notifier)
                .update((s) => s.copyWith(autoReplyMessage: v)),
          ),
        ],
        _SwitchRow(
          label: 'קטלוג מוצרים בשיחה',
          value: settings.catalogInChat,
          onChanged: (v) => ref
              .read(chatSettingsProvider.notifier)
              .update((s) => s.copyWith(catalogInChat: v)),
        ),
        _SwitchRow(
          label: 'תשלום מתוך שיחה',
          value: settings.paymentInChat,
          onChanged: (v) => ref
              .read(chatSettingsProvider.notifier)
              .update((s) => s.copyWith(paymentInChat: v)),
        ),
      ],
    );
  }
}

// ─── 8. bot & automation ─────────────────────────────────────────────────────

class _BotSection extends ConsumerWidget {
  const _BotSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(chatSettingsProvider);
    return _SectionTile(
      emoji: '🤖',
      title: 'בוט ואוטומציה',
      children: [
        _SwitchRow(
          label: 'בוט שאלות נפוצות',
          value: settings.botEnabled,
          onChanged: (v) => ref
              .read(chatSettingsProvider.notifier)
              .update((s) => s.copyWith(botEnabled: v)),
        ),
        const _PlaceholderRow(label: 'ניתוב שיחות'),
        _SwitchRow(
          label: 'ברכת פתיחה',
          value: settings.greetingEnabled,
          onChanged: (v) => ref
              .read(chatSettingsProvider.notifier)
              .update((s) => s.copyWith(greetingEnabled: v)),
        ),
        if (settings.greetingEnabled)
          _InlineTextRow(
            label: 'טקסט הברכה',
            hint: 'שלום! איך אפשר לעזור?',
            value: settings.greetingMessage,
            onChanged: (v) => ref
                .read(chatSettingsProvider.notifier)
                .update((s) => s.copyWith(greetingMessage: v)),
          ),
        const _PlaceholderRow(label: 'תגובה מחוץ לשעות פעילות'),
      ],
    );
  }
}

// ─── 9. archive & cleanup ────────────────────────────────────────────────────

class _ArchiveSection extends ConsumerWidget {
  const _ArchiveSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(chatSettingsProvider);
    return _SectionTile(
      emoji: '🗂️',
      title: 'ארכיון וניקיון',
      children: [
        _SwitchRow(
          label: 'ארכוב אוטומטי',
          value: settings.autoArchive,
          onChanged: (v) => ref
              .read(chatSettingsProvider.notifier)
              .update((s) => s.copyWith(autoArchive: v)),
        ),
        _RadioGroupRow<ChatAutoDelete>(
          label: 'מחיקה אוטומטית',
          value: settings.autoDeletePolicy,
          options: const [
            (value: ChatAutoDelete.disabled, label: 'כבוי'),
            (value: ChatAutoDelete.days30, label: '30 יום'),
            (value: ChatAutoDelete.days90, label: '90 יום'),
            (value: ChatAutoDelete.days180, label: '180 יום'),
          ],
          onChanged: (v) => ref
              .read(chatSettingsProvider.notifier)
              .update((s) => s.copyWith(autoDeletePolicy: v)),
        ),
        _SwitchRow(
          label: 'סינון ספאם',
          value: settings.spamFilter,
          onChanged: (v) => ref
              .read(chatSettingsProvider.notifier)
              .update((s) => s.copyWith(spamFilter: v)),
        ),
        _SwitchRow(
          label: 'גיבוי לפני מחיקה',
          value: settings.backupBeforeDelete,
          onChanged: (v) => ref
              .read(chatSettingsProvider.notifier)
              .update((s) => s.copyWith(backupBeforeDelete: v)),
        ),
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

class _InlineTextRow extends StatefulWidget {
  const _InlineTextRow({
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_InlineTextRow> createState() => _InlineTextRowState();
}

class _InlineTextRowState extends State<_InlineTextRow> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(covariant _InlineTextRow old) {
    super.didUpdateWidget(old);
    if (widget.value != _ctrl.text) {
      _ctrl.text = widget.value;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _ctrl,
            style: const TextStyle(color: Colors.white),
            cursorColor: BsTokens.brand,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: Color(0xFF666666)),
              filled: true,
              fillColor: const Color(0xFF222222),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.label,
    required this.buttonLabel,
    required this.onTap,
    this.destructive = false,
  });

  final String label;
  final String buttonLabel;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: destructive ? Colors.redAccent : BsTokens.brand,
        ),
        child: Text(buttonLabel),
      ),
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
