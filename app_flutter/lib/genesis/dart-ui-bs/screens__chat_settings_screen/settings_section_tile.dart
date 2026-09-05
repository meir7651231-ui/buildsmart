// 🧼 אטום · SettingsSectionTile — כרטיס-סקציה מתקפל: אימוג׳י + כותרת + תג-ספירה + שורות.
// מוצא: screens__chat_settings_screen.dart · _SectionTile (שורות 755–855), verbatim ויזואלית.
// הוסר ידע-ההקשר (חוק-5): שער kHideUnderConstruction, אינטרוספקציית _isUnderConstruction
// וחישוב activeCount עברו לקופסה — האטום מקבל badgeCount מוכן (null ⇒ אין תג, כמו
// underConstruction/ריק במקור) ו-subtitleNote מוכן (null ⇒ אין תת-כותרת). התווית
// "בבנייה — ההגדרות נשמרות..." מוזרקת מהתוכן דרך subtitleNote.
import 'package:flutter/material.dart';

class SettingsSectionTile extends StatelessWidget {
  const SettingsSectionTile({
    required this.emoji,
    required this.title,
    required this.children,
    required this.inkColor,
    required this.mutedColor,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.chevronColor,
    this.badgeCount,
    this.subtitleNote,
    super.key,
  });

  final String emoji;
  final String title;
  final List<Widget> children;
  final Color inkColor;
  final Color mutedColor;
  final Color badgeColor;
  final Color badgeTextColor;
  final Color chevronColor;

  /// null ⇒ no count badge (default chevron shows instead).
  final int? badgeCount;

  /// null ⇒ no subtitle row.
  final String? subtitleNote;

  @override
  Widget build(BuildContext context) {
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
          iconColor: chevronColor,
          collapsedIconColor: chevronColor,
          leading: Text(emoji, style: const TextStyle(fontSize: 22)),
          trailing: badgeCount == null
              ? null
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      color: badgeTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
          title: Text(
            title,
            style: TextStyle(
              color: inkColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: subtitleNote == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    subtitleNote!,
                    style: TextStyle(color: mutedColor, fontSize: 12),
                  ),
                ),
          children: children,
        ),
      ),
    );
  }
}
