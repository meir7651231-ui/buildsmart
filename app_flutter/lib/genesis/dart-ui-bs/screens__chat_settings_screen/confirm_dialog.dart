// 🧼 אטום · ConfirmDialog — דיאלוג אישור/מידע: כותרת + הודעה + עד שני כפתורי-טקסט.
// מוצא: screens__chat_settings_screen.dart — מאחד שלושה AlertDialog זהי-מבנה:
// איפוס-הגדרות (שורות 64–102) · מחיקת-היסטוריה (443–481) · מידע-עריכת-תבניות (124–146).
// סוגר עם Navigator.pop(context, true/false); הקופסה עוטפת ב-showDialog<bool> ומבצעת.
// cancelLabel==null או confirmLabel==null ⇒ הכפתור לא מרונדר כלל — זו ההסתרה-המרוכבת
// של CfgVisible במקור (הקופסה, שמכירה את מזהי-הקונפיג tNN, מוסרת את ה-prop).
// confirmColor==null ⇒ צבע-ברירת-מחדל; הקופסה מזריקה redAccent לפעולות הרסניות.
import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    required this.title,
    required this.message,
    required this.titleColor,
    required this.messageColor,
    this.cancelLabel,
    this.confirmLabel,
    this.confirmColor,
    this.messageAlign,
    super.key,
  });

  final String title;
  final String message;
  final Color titleColor;
  final Color messageColor;
  final String? cancelLabel;
  final String? confirmLabel;
  final Color? confirmColor;
  final TextAlign? messageAlign;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(title, style: TextStyle(color: titleColor)),
      content: Text(
        message,
        textAlign: messageAlign,
        style: TextStyle(color: messageColor),
      ),
      actions: [
        if (cancelLabel != null)
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelLabel!),
          ),
        if (confirmLabel != null)
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: confirmColor == null
                ? null
                : TextButton.styleFrom(foregroundColor: confirmColor),
            child: Text(confirmLabel!),
          ),
      ],
    );
  }
}
