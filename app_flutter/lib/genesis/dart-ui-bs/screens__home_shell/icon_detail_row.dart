// 🧼 אטום · IconDetailRow — שורת-פרט בכרטיס-הפרופיל: אייקון-עמום 18 + ערך.
// מוצא: גוף _ProfileCard, לולאת-השורות (screens__home_shell.dart:1654-1674).
// התרת-סבך: בניית-הרשימה (רק שדות מלאים — profession/address/businessId/contact
// אחרי trim) = דין-קופסה; האטום מקבל icon+value מוכנים. היו צרובים:
// BsTokens.mutedLight · BsTokens.inkLight · BsTokens.space2/space3 ⇒ params.
import 'package:flutter/material.dart';

class IconDetailRow extends StatelessWidget {
  const IconDetailRow({
    required this.icon,
    required this.value,
    required this.iconColor,
    required this.textColor,
    required this.vPad,
    required this.gap,
    super.key,
  });

  final IconData icon;
  final String value;
  final Color iconColor, textColor;
  final double vPad, gap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: vPad),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            SizedBox(width: gap),
            Expanded(
              child: Text(
                value,
                style: TextStyle(color: textColor, fontSize: 15),
              ),
            ),
          ],
        ),
      );
}
