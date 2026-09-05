// 🧼 אטום · TintedNoticeBar — פס-הודעה ממורכז במילוי-רך (ההזמנה-הושלמה בגיליון).
// מוצא: קונטיינר-ההשלמה של _OrderDetailSheet (מילוי 0xFFE7F6EC / טקסט 0xFF1B7A3D
// במקור — מוזרקים). הטקסט מהקופסה (orderDetailSheetContent.completedNote דרך CfgText).
import 'package:flutter/material.dart';

class TintedNoticeBar extends StatelessWidget {
  const TintedNoticeBar({
    required this.text, required this.fillColor, required this.textColor,
    required this.pillRadius, required this.verticalPadding,
    this.fontSize = 14, super.key,
  });

  final String text;
  final Color fillColor, textColor;
  final double pillRadius, verticalPadding, fontSize;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(pillRadius),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
}
