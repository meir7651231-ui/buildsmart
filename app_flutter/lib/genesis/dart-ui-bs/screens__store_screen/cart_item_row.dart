// 🧼 אטום · CartItemRow — שורת-פריט-סל: גליף, שם+מחיר-יחידה, הסרה, סטפר-גלולה וסה״כ-שורה.
// מוצא: screens__store_screen.dart:2163 (_CartItemRow). קריאת/כתיבת cartQtysProvider
// (setQty) עברה לקופסה ⇒ onRemove + כפתורי-מדרגה כ-slots (minusButton/plusButton =
// step_btn מחווט-קופסה; אטום לא מייבא אטום — חוק-1). התוויות מפורמטות בקופסה:
// unitPriceLabel (מחיר/יחידה) · qtyLabel · lineTotalLabel · removeLabel (t_a530b6eb).
import 'package:flutter/material.dart';

class CartItemRow extends StatelessWidget {
  const CartItemRow({
    required this.emoji, required this.name, required this.unitPriceLabel,
    required this.qtyLabel, required this.lineTotalLabel,
    required this.removeLabel, required this.onRemove,
    required this.minusButton, required this.plusButton,
    required this.surfaceColor, required this.stepperColor,
    required this.inkColor, required this.mutedColor, required this.removeIconColor,
    super.key,
  });
  final String emoji, name, unitPriceLabel, qtyLabel, lineTotalLabel, removeLabel;
  final VoidCallback onRemove;
  final Widget minusButton, plusButton;
  final Color surfaceColor, stepperColor, inkColor, mutedColor, removeIconColor;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(color: inkColor, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Text(unitPriceLabel, style: TextStyle(color: mutedColor, fontSize: 12)),
                    ],
                  ),
                ),
                Tooltip(
                  message: removeLabel,
                  child: Semantics(
                    button: true,
                    label: removeLabel,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onRemove,
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(child: Icon(Icons.close, size: 16, color: removeIconColor)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: stepperColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      minusButton,
                      SizedBox(
                        width: 44,
                        child: Text(
                          qtyLabel,
                          style: TextStyle(color: inkColor, fontSize: 14, fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      plusButton,
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  lineTotalLabel,
                  style: TextStyle(color: inkColor, fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      );
}
