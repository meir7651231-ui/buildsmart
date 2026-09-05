// 🧼 הקובץ-הראשי · פירוק screens__chat_settings_screen (בנייה-חכמה) לאטומים-נקיים.
// מוצא: scratchpad/all-screens/screens__chat_settings_screen.dart (קדוש, חוק-4) — שורות 22–62.
//
// ── אטומי-מדף שנצרכים (הכרעה-5: אסור לשכפל) ─────────────────────────────────
// • PlaceholderRow (new/dart-ui-bs/placeholder_row.dart) — מחליף את _PlaceholderRow
//   של המסך (10 שורות-בבנייה: מקור 344,345,399,431,432,524,525,565,672,691).
//   הקופסה מזרימה: label מהתוכן · badge=placeholderRowContent.underConstructionBadge ·
//   onTap ⇒ toast לפי placeholderRowContent.tapToastTemplate (התבנית-$ מפורמטת בקופסה).
//
// ── אטומים חדשים בתיקייה זו ──────────────────────────────────────────────────
// • settings_section_tile.dart   — SettingsSectionTile (מקור _SectionTile, שורה 755)
// • settings_switch_row.dart     — SettingsSwitchRow (מקור _SwitchRow, שורה 863)
// • settings_radio_group_row.dart— SettingsRadioGroupRow (מקור _RadioGroupRow, שורה 896)
// • settings_time_row.dart       — SettingsTimeRow (מקור _TimeRow, שורה 958; מאחד גם את
//   screens__notif_settings_screen:_TimeRow — widget-dedup.json קבוצה n=2, loc=47)
// • settings_inline_text_row.dart— SettingsInlineTextRow (מקור _InlineTextRow, שורה 1006)
// • settings_action_row.dart     — SettingsActionRow (מקור _ActionRow, שורה 1081)
// • quick_reply_banner.dart      — QuickReplyBanner (מקור _QuickReplyBanner, שורה 112)
// • confirm_dialog.dart          — ConfirmDialog (מאחד את שלושת ה-AlertDialog: איפוס
//   שורה 64, מחיקת-היסטוריה שורה 443, מידע-עריכה שורה 124)
//
// ── התרת-סבך: מה הקופסה תזרים (קריאות-provider ⇒ props/callbacks) ────────────
// המקור קורא chatSettingsProvider בכל 9 הסקציות ו-chatHistoryClearedProvider בפרטיות.
// באטומים אין ref: כל value מגיע כ-prop, כל update כ-callback. הקופסה תזרים:
// • ref.watch(chatSettingsProvider) ⇒ ערכי value/time/text של כל השורות
// • ref.read(chatSettingsProvider.notifier).update(copyWith...) ⇒ onChanged של כל שורה
// • ref.read(chatSettingsProvider.notifier).reset() ⇒ onResetTap (אחרי ConfirmDialog=true)
// • ref.read(chatHistoryClearedProvider.notifier).clearAll() ⇒ onTap של שורת מחיקת-היסטוריה
// • showToast (הגדרות-אופסו / ההיסטוריה-נמחקה / התבנית-הועתקה / בבנייה) — fx של הקופסה
// • Clipboard.setData על תבנית-מהירה ⇒ onTemplateTap של QuickReplyBanner
// • CfgText/CfgVisible עם מזהי chat_settings_screen.tNN — חיווט-סטודיו של הקופסה
//   (הסתרה-מרוכבת = הקופסה מוסרת את ה-prop, האטום לא מכיר מזהי-קונפיג)
// • שער kHideUnderConstruction + ספירת-שורות-פעילות (_isUnderConstruction, מקור 774–785):
//   היה אינטרוספקציית-טיפוסים בתוך _SectionTile — עובר לקופסה, שמחשבת activeCount
//   ומסננת children לפני ההזרמה ל-SettingsSectionTile (חוק-5: אפס ידע-הקשר באטום)
// • הרכב 9 הסקציות וסדרן (מקור 47–59) — תוכנית-חיווט של הקופסה
//
// התוכן: new/dart-data-bs/screens__chat_settings_screen_content.dart (verbatim מהמקור).
import 'package:flutter/material.dart';

/// שלד-מסך-הגדרות: Scaffold + AppBar עם פעולת-איפוס + ListView של סקציות.
/// כל הטקסטים, האייקון והצבעים מוזרקים; הסקציות עצמן נבנות בקופסה.
class SettingsScreenShell extends StatelessWidget {
  const SettingsScreenShell({
    required this.title,
    required this.resetTooltip,
    required this.resetIcon,
    required this.onResetTap,
    required this.titleColor,
    required this.iconColor,
    required this.children,
    this.bottomGap = 24,
    super.key,
  });

  final String title;
  final String resetTooltip;
  final IconData resetIcon;
  final VoidCallback onResetTap;
  final Color titleColor;
  final Color iconColor;
  final List<Widget> children;
  final double bottomGap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          title,
          style: TextStyle(color: titleColor, fontWeight: FontWeight.w700),
        ),
        iconTheme: IconThemeData(color: iconColor),
        actions: [
          IconButton(
            tooltip: resetTooltip,
            icon: Icon(resetIcon, color: iconColor),
            onPressed: onResetTap,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [...children, SizedBox(height: bottomGap)],
      ),
    );
  }
}
