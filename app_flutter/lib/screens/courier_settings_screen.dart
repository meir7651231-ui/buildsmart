// #73 — הגדרות מותאמות-שליח: רק הקטגוריות הרלוונטיות לשליח (פרופיל-שליח,
// התראות, אזור-ושפה, ממשק-ונגישות, מידע) — בלי קטלוג/סל/ספקים של הקבלן.
//
// כל המתגים מחווטים ל-providers הקיימים והנשמרים באמת:
//   notifSettingsProvider (התראות) · appSettingsProvider (שפה) ·
//   catalogSettingsProvider (גודל-טקסט/ניגודיות/הנפשות — כלל-אפליקציה).
// אותו מבנה _SectionTile/_SwitchRow כמו catalog/store settings (תבנית הקבצים
// האחים); ערבית/אנגלית נשארות "בקרוב" כמו במסך הקיים (task #53 — בלי לזייף
// החלפת שפה).

import 'package:buildsmart/screens/courier_profile_screen.dart';
import 'package:buildsmart/screens/legal_screen.dart';
import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/notif_settings.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full-screen courier settings — 4 categories + profile row, all leaves
/// persisted via the existing providers.
class CourierSettingsScreen extends ConsumerWidget {
  const CourierSettingsScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const CourierSettingsScreen());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFFFFF),
          elevation: 0,
          title: const Text(
            'הגדרות שליח',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black54),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: const [
            _CourierProfileRow(),
            _CourierNotifSection(),
            _CourierRegionSection(),
            _CourierAccessibilitySection(),
            _CourierInfoSection(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── 0. פרופיל שליח (שורת-ראש) ───────────────────────────────────────────────

class _CourierProfileRow extends StatelessWidget {
  const _CourierProfileRow();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: const Color(0xFFFFFFFF),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: const Text('🛵', style: TextStyle(fontSize: 22)),
        title: const Text(
          'פרופיל שליח',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.chevron_left, color: Colors.black54),
        onTap: () => Navigator.of(context).push(CourierProfileScreen.route()),
      ),
    );
  }
}

// ─── 1. התראות (notifSettingsProvider — רק מה שרלוונטי לשליח) ─────────────────

class _CourierNotifSection extends ConsumerWidget {
  const _CourierNotifSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notif = ref.watch(notifSettingsProvider);
    return _SectionTile(
      emoji: '🔔',
      title: 'התראות',
      children: [
        _SwitchRow(
          label: 'התראות Push',
          value: notif.pushEnabled,
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(pushEnabled: v)),
        ),
        _SwitchRow(
          label: 'עדכוני משלוחים',
          value: notif.typeShipments,
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(typeShipments: v)),
        ),
        _SwitchRow(
          label: 'הודעות צ׳אט חדשות',
          value: notif.typeNewChats,
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(typeNewChats: v)),
        ),
        _SwitchRow(
          label: 'שקט בזמן נהיגה',
          value: notif.quietWhileDriving,
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(quietWhileDriving: v)),
        ),
        _SwitchRow(
          label: 'צליל',
          value: notif.soundEnabled,
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(soundEnabled: v)),
        ),
        _SwitchRow(
          label: 'רטט',
          value: notif.vibrationEnabled,
          onChanged: (v) => ref
              .read(notifSettingsProvider.notifier)
              .update((s) => s.copyWith(vibrationEnabled: v)),
        ),
      ],
    );
  }
}

// ─── 2. אזור ושפה (appSettingsProvider — ערבית/אנגלית "בקרוב", task #53) ──────

class _CourierRegionSection extends ConsumerWidget {
  const _CourierRegionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    return _SectionTile(
      emoji: '🌐',
      title: 'אזור ושפה',
      children: [
        _RadioGroupRow<BsLang>(
          label: 'שפה',
          // רק עברית ממומשת (אין l10n אמיתי) — ערבית ואנגלית לא ניתנות לבחירה
          // ונושאות "בקרוב", כדי שהבורר לא יזייף החלפת שפה (כמו במסך הקיים).
          value: settings.lang,
          options: const [
            _RadioOption(value: BsLang.he, label: 'עברית'),
            _RadioOption(value: BsLang.ar, label: 'العربية', enabled: false),
            _RadioOption(value: BsLang.en, label: 'English', enabled: false),
          ],
          onChanged: (v) => ref
              .read(appSettingsProvider.notifier)
              .update((s) => s.copyWith(lang: v)),
        ),
      ],
    );
  }
}

// ─── 3. ממשק ונגישות (catalogSettingsProvider — מתגים כלל-אפליקציה) ───────────

class _CourierAccessibilitySection extends ConsumerWidget {
  const _CourierAccessibilitySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(catalogSettingsProvider);
    return _SectionTile(
      emoji: '📱',
      title: 'ממשק ונגישות',
      children: [
        _RadioGroupRow<CatalogTextSize>(
          label: 'גודל טקסט (כל האפליקציה)',
          value: settings.textSize,
          options: const [
            _RadioOption(value: CatalogTextSize.small, label: 'קטן'),
            _RadioOption(value: CatalogTextSize.medium, label: 'בינוני'),
            _RadioOption(value: CatalogTextSize.large, label: 'גדול'),
          ],
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(textSize: v)),
        ),
        _SwitchRow(
          label: 'ניגודיות גבוהה (כל האפליקציה)',
          value: settings.highContrast,
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(highContrast: v)),
        ),
        _SwitchRow(
          label: 'הנפשות מופחתות (כל האפליקציה)',
          value: settings.reducedMotion,
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(reducedMotion: v)),
        ),
      ],
    );
  }
}

// ─── 4. מידע ומשפטי ──────────────────────────────────────────────────────────

class _CourierInfoSection extends StatelessWidget {
  const _CourierInfoSection();

  @override
  Widget build(BuildContext context) {
    return _SectionTile(
      emoji: 'ℹ️',
      title: 'מידע',
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: const Text(
            'תנאי שימוש',
            style: TextStyle(color: BsTokens.inkLight),
          ),
          trailing: const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
          onTap: () => Navigator.of(context)
              .push(LegalScreen.route(initialTab: LegalTab.terms)),
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: const Text(
            'מדיניות פרטיות',
            style: TextStyle(color: BsTokens.inkLight),
          ),
          trailing: const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
          onTap: () => Navigator.of(context)
              .push(LegalScreen.route(initialTab: LegalTab.privacy)),
        ),
      ],
    );
  }
}

// ─── shared widgets (אותה תבנית כמו catalog/store settings) ───────────────────

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.emoji,
    required this.title,
    required this.children,
  });

  final String emoji;
  final String title;
  final List<Widget> children;

  int get _activeCount => children.length;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: const Color(0xFFFFFFFF),
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
          trailing: _activeCount == 0
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
      title: Text(label, style: const TextStyle(color: BsTokens.inkLight)),
      value: value,
      activeColor: BsTokens.brand,
      onChanged: onChanged,
    );
  }
}

/// אופציה לבורר רדיו — `enabled:false` מציג "בקרוב" ולא ניתן לבחירה (ביושר).
class _RadioOption<T> {
  const _RadioOption({
    required this.value,
    required this.label,
    this.enabled = true,
  });

  final T value;
  final String label;
  final bool enabled;
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
  final List<_RadioOption<T>> options;
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
            title: Row(
              children: [
                Text(
                  o.label,
                  style: TextStyle(
                    color: o.enabled
                        ? BsTokens.inkLight
                        : BsTokens.mutedLight,
                  ),
                ),
                if (!o.enabled) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F3F5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'בקרוב',
                      style: TextStyle(
                        color: BsTokens.mutedLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            value: o.value,
            groupValue: value,
            activeColor: BsTokens.brand,
            onChanged: o.enabled
                ? (v) {
                    if (v != null) onChanged(v);
                  }
                : null,
          ),
        ),
      ],
    );
  }
}
