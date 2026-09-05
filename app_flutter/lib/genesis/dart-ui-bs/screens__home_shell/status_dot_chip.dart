// 🧼 אטום · StatusDotChip — צ׳יפ-סטטוס לחיץ: נקודה 7dp בצבע-מצב + תווית על גלולה
// צבועה. מוצא: גוף _RoleStatusChip (screens__home_shell.dart:1758-1795).
// התרת-סבך: roleChipStateProvider + מיפוי-4-המצבים (תווית+3 צבעים פר-מצב) ⇒ הקופסה
// בוחרת מ-content (תוויות) ומהפיגמנטים (צבעים) ומזריקה; _onTap (שער-הרשמה-קודם,
// authState, reloadRole, ניווטים) ⇒ onTap; תבנית-הנגישות (semanticsTpl ב-content)
// מפורמטת בקופסה ⇒ semanticsLabel מוכן; Key(role_status_chip) ⇒ chipKey של הקופסה.
// שער kUserSystem (רינדור-בכלל) = קופסה. שונה מ-LiveStatusPill של מסך-המנהל
// (לא-לחיץ, נקודה=צבע-הטקסט, בלי Semantics) — כאן נקודה עצמאית + InkWell + Semantics.
import 'package:flutter/material.dart';

class StatusDotChip extends StatelessWidget {
  const StatusDotChip({
    required this.label,
    required this.semanticsLabel,
    required this.onTap,
    required this.dotColor,
    required this.textColor,
    required this.fillColor,
    this.chipKey,
    super.key,
  });

  final String label;
  final String semanticsLabel;
  final VoidCallback onTap;
  final Color dotColor, textColor, fillColor;

  /// Key-איתור לבדיקות/כלים (במקור Key קבוע) — זהות = ענין-הקופסה.
  final Key? chipKey;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Semantics(
          button: true,
          label: semanticsLabel,
          child: InkWell(
            key: chipKey,
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
