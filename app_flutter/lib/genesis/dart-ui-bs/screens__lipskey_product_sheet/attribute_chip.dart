// 🧼 אטום · AttributeChip — צ'יפ-תכונה: תווית-אפורה + ערך-צבעוני (+מחוון ›/× כשנלחץ).
// מוצא: screens__lipskey_product_sheet.dart:3433-3474 (_buildChip של _InteractiveChips).
// התרת-סבך: זיהוי-אחים (_hasSiblings — לוגיקת-קטלוג) ⇒ הקופסה מחשבת ומזרימה tappable;
// התוויות (attributeChipLabels ב-content: t_f45000d5 סוג · t_ccb77538 · t_a4617429 ·
// t_be49d01c · t_8cd6a827 · t_4f70dfd4) והערכים מוזרמים; tapAccent = הכתום 0xFFFF9D4D.
import 'package:flutter/material.dart';

class AttributeChip extends StatelessWidget {
  const AttributeChip({
    required this.label,
    required this.value,
    required this.color,
    required this.tappable,
    required this.active,
    required this.onTap,
    required this.labelColor,
    required this.tapAccentColor,
    super.key,
  });
  final String label, value;
  final Color color;
  final bool tappable;

  /// true = הבורר של הצ'יפ הזה פתוח (isOpen במקור).
  final bool active;
  final VoidCallback onTap;
  final Color labelColor, tapAccentColor;

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? color.withValues(alpha: 0.22)
            : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: tappable ? tapAccentColor : color.withValues(alpha: 0.35),
          width: tappable ? 1.5 : 1.0,
        ),
      ),
      child: Text.rich(
        TextSpan(children: [
          TextSpan(
            text: '$label ',
            style: TextStyle(color: labelColor, fontSize: 10),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (tappable)
            TextSpan(
              text: active ? ' ×' : ' ›',
              style: TextStyle(color: tapAccentColor, fontSize: 10),
            ),
        ]),
      ),
    );
    if (!tappable) return chip;
    return GestureDetector(onTap: onTap, child: chip);
  }
}
