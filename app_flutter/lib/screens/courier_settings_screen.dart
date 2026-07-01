// #73 — הגדרות מותאמות-שליח: רק הקטגוריות הרלוונטיות לשליח (התראות,
// אזור-ושפה, ממשק-ונגישות, מידע) — בלי קטלוג/סל/ספקים של הקבלן.
//
// F-11 — ההגדרות הן עלה (leaf) בגרף הניווט: אין כאן שורת "פרופיל שליח"
// (הצלע הגדרות→פרופיל מול פרופיל→הגדרות יצרה לולאת-ניווט אינסופית). הפרופיל
// נשאר נגיש משתי הכניסות הקנוניות — אייקון ה-person ב-AppBar של הלוח וטאב 4
// "אזור אישי". אסור להחזיר את הצלע — גם לא בכרטיס האזור-האישי (#86.7).
//
// כל המתגים מחווטים ל-providers הקיימים והנשמרים באמת:
//   notifSettingsProvider (התראות) · appSettingsProvider (שפה) ·
//   catalogSettingsProvider (גודל-טקסט/ניגודיות/הנפשות — כלל-אפליקציה).
// אותו מבנה _SectionTile/_SwitchRow כמו catalog/store settings (תבנית הקבצים
// האחים); ערבית/אנגלית נשארות "בקרוב" כמו במסך הקיים (task #53 — בלי לזייף
// החלפת שפה).

import 'package:buildsmart/screens/keyboard_tool_tree.dart'
    show KbToolNode, kbCourierSettingsNodes;
import 'package:buildsmart/screens/legal_screen.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/keyboard_overlay.dart' show kKbGlobal;
import 'package:buildsmart/state/keyboard_screen_tools.dart' show KbScreen;
import 'package:buildsmart/state/notif_settings.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full-screen courier settings — 4 categories, all leaves persisted via the
/// existing providers. Gated by [boardAuthProvider] (F-4: "מבחוץ לא רואים
/// כלום" — logout while this screen is stacked rebuilds it as the gate).
class CourierSettingsScreen extends ConsumerWidget {
  const CourierSettingsScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const CourierSettingsScreen());

  static final List<KbToolNode> _kbNodes = kbCourierSettingsNodes();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔒 BOARD GATE (חוק הלוחות, כלל 4 — "מבחוץ לא רואים כלום") — F-4: בלי
    // session של שליח נבנה אך ורק שער הרישום במצב-תפקיד; כך גם כל המסך הזה
    // בערימה אחרי logout נבנה-מחדש כשער (האידיום של העובד —
    // worker_settings_screen).
    final session = ref.watch(boardAuthProvider);
    if (session == null || session.role != BoardRole.courier) {
      return const WelcomeScreen(boardRole: BoardRole.courier);
    }

    final Widget body = Directionality(
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
          // 💡 מצב היכרות — בלעדיו לא ניתן להיכנס למצב ההיכרות במסך זה וכל
          // HelpTarget יהיה מת. (לא עוטפים את ה-toggle עצמו — חוק c.)
          actions: const [HelpToggleButton()],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: const [
            _CourierNotifSection(),
            _CourierRegionSection(),
            _CourierAccessibilitySection(),
            _CourierInfoSection(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
    return kKbGlobal ? KbScreen(tools: _kbNodes, child: body) : body;
  }
}

// ─── 1. התראות (notifSettingsProvider — רק מה שרלוונטי לשליח) ─────────────────

class _CourierNotifSection extends ConsumerWidget {
  const _CourierNotifSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notif = ref.watch(notifSettingsProvider);
    // #31 — כל מתג עטוף ב-HelpTarget (טבעת כתומה + בועה במצב היכרות); מחוץ
    // למצב היכרות ה-onChanged נשמר כפי שהוא (אפס שינוי-התנהגות).
    const notifBody =
        'מפעילים/מכבים סוגי התראות: Push, עדכוני משלוחים, הודעות צ׳אט, '
        'שקט בזמן נהיגה, צליל ורטט. כל מתג נשמר מיד.';
    return _SectionTile(
      emoji: '🔔',
      title: 'התראות',
      children: [
        HelpTarget(
          title: 'התראות Push',
          body: notifBody,
          child: _SwitchRow(
            label: 'התראות Push',
            value: notif.pushEnabled,
            onChanged:
                (v) => ref
                    .read(notifSettingsProvider.notifier)
                    .update((s) => s.copyWith(pushEnabled: v)),
          ),
        ),
        HelpTarget(
          title: 'עדכוני משלוחים',
          body: notifBody,
          child: _SwitchRow(
            label: 'עדכוני משלוחים',
            value: notif.typeShipments,
            onChanged:
                (v) => ref
                    .read(notifSettingsProvider.notifier)
                    .update((s) => s.copyWith(typeShipments: v)),
          ),
        ),
        HelpTarget(
          title: 'הודעות צ׳אט חדשות',
          body: notifBody,
          child: _SwitchRow(
            label: 'הודעות צ׳אט חדשות',
            value: notif.typeNewChats,
            onChanged:
                (v) => ref
                    .read(notifSettingsProvider.notifier)
                    .update((s) => s.copyWith(typeNewChats: v)),
          ),
        ),
        HelpTarget(
          title: 'שקט בזמן נהיגה',
          body: notifBody,
          child: _SwitchRow(
            label: 'שקט בזמן נהיגה',
            value: notif.quietWhileDriving,
            onChanged:
                (v) => ref
                    .read(notifSettingsProvider.notifier)
                    .update((s) => s.copyWith(quietWhileDriving: v)),
          ),
        ),
        HelpTarget(
          title: 'צליל',
          body: notifBody,
          child: _SwitchRow(
            label: 'צליל',
            value: notif.soundEnabled,
            onChanged:
                (v) => ref
                    .read(notifSettingsProvider.notifier)
                    .update((s) => s.copyWith(soundEnabled: v)),
          ),
        ),
        HelpTarget(
          title: 'רטט',
          body: notifBody,
          child: _SwitchRow(
            label: 'רטט',
            value: notif.vibrationEnabled,
            onChanged:
                (v) => ref
                    .read(notifSettingsProvider.notifier)
                    .update((s) => s.copyWith(vibrationEnabled: v)),
          ),
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
        HelpTarget(
          title: 'בחירת שפה',
          body:
              'בוחר את שפת האפליקציה. כרגע רק עברית פעילה; '
              'ערבית ואנגלית מסומנות "בקרוב".',
          child: _RadioGroupRow<BsLang>(
            label: 'שפה',
            // רק עברית ממומשת (אין l10n אמיתי) — ערבית ואנגלית לא ניתנות
            // לבחירה ונושאות "בקרוב", כדי שהבורר לא יזייף החלפת שפה (כמו
            // במסך הקיים).
            value: settings.lang,
            options: const [
              _RadioOption(value: BsLang.he, label: 'עברית'),
              _RadioOption(value: BsLang.ar, label: 'العربية', enabled: false),
              _RadioOption(value: BsLang.en, label: 'English', enabled: false),
            ],
            onChanged:
                (v) => ref
                    .read(appSettingsProvider.notifier)
                    .update((s) => s.copyWith(lang: v)),
          ),
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
    // #31 — כל פקד עטוף ב-HelpTarget עם אותו הסבר-מקטע (אפס שינוי-התנהגות).
    const accessBody =
        'שולט בגודל הטקסט, ניגודיות גבוהה והנפשות מופחתות — כלל-אפליקציה. '
        'כל שינוי נשמר ומשפיע על כל הלוחות.';
    return _SectionTile(
      emoji: '📱',
      title: 'ממשק ונגישות',
      children: [
        HelpTarget(
          title: 'ממשק ונגישות',
          body: accessBody,
          child: _RadioGroupRow<CatalogTextSize>(
            label: 'גודל טקסט (כל האפליקציה)',
            value: settings.textSize,
            options: const [
              _RadioOption(value: CatalogTextSize.small, label: 'קטן'),
              _RadioOption(value: CatalogTextSize.medium, label: 'בינוני'),
              _RadioOption(value: CatalogTextSize.large, label: 'גדול'),
            ],
            onChanged:
                (v) => ref
                    .read(catalogSettingsProvider.notifier)
                    .update((s) => s.copyWith(textSize: v)),
          ),
        ),
        HelpTarget(
          title: 'ממשק ונגישות',
          body: accessBody,
          child: _SwitchRow(
            label: 'ניגודיות גבוהה (כל האפליקציה)',
            value: settings.highContrast,
            onChanged:
                (v) => ref
                    .read(catalogSettingsProvider.notifier)
                    .update((s) => s.copyWith(highContrast: v)),
          ),
        ),
        HelpTarget(
          title: 'ממשק ונגישות',
          body: accessBody,
          child: _SwitchRow(
            label: 'הנפשות מופחתות (כל האפליקציה)',
            value: settings.reducedMotion,
            onChanged:
                (v) => ref
                    .read(catalogSettingsProvider.notifier)
                    .update((s) => s.copyWith(reducedMotion: v)),
          ),
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
        HelpTarget(
          title: 'תנאי שימוש',
          body: 'פותח את מסמך תנאי-השימוש של האפליקציה.',
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: const Text(
              'תנאי שימוש',
              style: TextStyle(color: BsTokens.inkLight),
            ),
            trailing: const Icon(
              Icons.chevron_left,
              color: BsTokens.mutedLight,
            ),
            onTap:
                () => Navigator.of(
                  context,
                ).push(LegalScreen.route(initialTab: LegalTab.terms)),
          ),
        ),
        HelpTarget(
          title: 'מדיניות פרטיות',
          body: 'פותח את מסמך מדיניות-הפרטיות של האפליקציה.',
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: const Text(
              'מדיניות פרטיות',
              style: TextStyle(color: BsTokens.inkLight),
            ),
            trailing: const Icon(
              Icons.chevron_left,
              color: BsTokens.mutedLight,
            ),
            onTap:
                () => Navigator.of(
                  context,
                ).push(LegalScreen.route(initialTab: LegalTab.privacy)),
          ),
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
          trailing:
              _activeCount == 0
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
                      style: TextStyle(
                        // F-28 — bsOnAccent על מילוי-מותג (לא לבן קשיח): מכבד
                        // את מתג הניגודיות-הגבוהה שנמצא במסך הזה עצמו.
                        color: bsOnAccent(context),
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
                    color: o.enabled ? BsTokens.inkLight : BsTokens.mutedLight,
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
            onChanged:
                o.enabled
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
