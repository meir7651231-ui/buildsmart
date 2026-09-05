// 🧼 אטום · ApprovalTaskCard — פאנל-משימה-לאישור: שם, שורת-מטא, תמונת-הוכחה,
// הערה, ושורת-פעולות. מוצא: _ApprovalRow.
// התרת-סבך: tasksProvider (תמונה/הערה חיות) ⇒ הקופסה פותרת ומזרימה note/photo;
// taskPhotoWidget המשותף ⇒ סלוט photo; כפתורי ✅/↩️ (PillCtaButton עטופי-HelpTarget
// וממופתחי-ValueKey) ⇒ סלוט actions; המטא מפורמט בקופסה (approvalRowContent.metaTpl).
import 'package:flutter/material.dart';

class ApprovalTaskCard extends StatelessWidget {
  const ApprovalTaskCard({
    required this.title, required this.metaLabel, required this.actions,
    required this.surfaceColor, required this.borderColor,
    required this.inkColor, required this.mutedColor,
    required this.padding, required this.gap,
    this.note = '', this.photo, super.key,
  });

  final String title, metaLabel, note;
  final Widget? photo;
  final Widget actions;
  final Color surfaceColor, borderColor, inkColor, mutedColor;

  /// EdgeInsets.all(space3) במקור.
  final EdgeInsetsGeometry padding;

  /// BsTokens.space2 במקור (הרווח לפני התמונה); שורת-הפעולות = gap*1.5 (space3).
  final double gap;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: inkColor,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              metaLabel,
              style: TextStyle(color: mutedColor, fontSize: 12.5),
            ),
            if (photo != null) ...[
              SizedBox(height: gap),
              photo!,
            ],
            if (note.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(note, style: TextStyle(color: mutedColor, fontSize: 12)),
            ],
            SizedBox(height: gap * 1.5),
            actions,
          ],
        ),
      );
}
