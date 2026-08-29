// 🧼 אטום · QuickReplyBanner — באנר תשובות-מהירות: גליף + כותרת + קישור-עריכה + צ׳יפי-תבניות.
// מוצא: screens__chat_settings_screen.dart · _QuickReplyBanner (שורות 112–241).
// התבניות (בדרך-אליך וכו׳) והכותרת מוזרקות מהתוכן; הקשה-על-צ׳יפ מדווחת לקופסה
// דרך onTemplateTap — ההעתקה-ללוח והטוסט הם fx של הקופסה, לא של האטום.
// דיאלוג-המידע של עריכה עבר ל-ConfirmDialog (confirm_dialog.dart) בחיווט-הקופסה;
// onEditTap==null ⇒ הקישור נעלם כולו (ההסתרה-המרוכבת של CfgVisible — הכרעת-קופסה).
// יעד-הקשה 48dp סביב הקישור הקטן (a11y) נשמר מהמקור.
import 'package:flutter/material.dart';

class QuickReplyBanner extends StatelessWidget {
  const QuickReplyBanner({
    required this.leadingGlyph,
    required this.title,
    required this.templates,
    required this.onTemplateTap,
    required this.inkColor,
    required this.accentColor,
    required this.chipFillColor,
    required this.chipBorderColor,
    this.editLabel,
    this.onEditTap,
    super.key,
  });

  final String leadingGlyph;
  final String title;
  final List<String> templates;
  final ValueChanged<String> onTemplateTap;
  final Color inkColor;
  final Color accentColor;
  final Color chipFillColor;
  final Color chipBorderColor;

  /// Both null ⇒ the edit link is not rendered at all (composite hide).
  final String? editLabel;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(leadingGlyph, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: inkColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              const Spacer(),
              if (editLabel != null && onEditTap != null)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onEditTap,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: Text(
                        editLabel!,
                        style: TextStyle(color: accentColor, fontSize: 13),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final t in templates)
                GestureDetector(
                  onTap: () => onTemplateTap(t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: chipFillColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: chipBorderColor),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(color: inkColor, fontSize: 12),
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
