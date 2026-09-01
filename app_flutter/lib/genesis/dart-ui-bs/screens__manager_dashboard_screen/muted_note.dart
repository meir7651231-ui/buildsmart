// 🧼 אטום · MutedNote — שורת-טקסט מושתקת (מצבי-ריק, רמזים, שורות-הסבר).
// איחד: _JourneyEmpty (fs13) · _ManageHint (fs12, height 1.3, top space2) ·
// שורות-הריק של הטאבים ('לא נמצאו…', ריפוד-אנכי space5, ממורכז) ·
// גוף-הפאנל-הממתין (fs12.5) — פיגמנטים כ-params.
import 'package:flutter/material.dart';

class MutedNote extends StatelessWidget {
  const MutedNote({
    required this.text, required this.color,
    this.fontSize = 13, this.lineHeight, this.centered = false,
    this.padding = EdgeInsets.zero, super.key,
  });

  final String text;
  final Color color;
  final double fontSize;
  final double? lineHeight;
  final bool centered;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding,
        child: Text(
          text,
          textAlign: centered ? TextAlign.center : null,
          style: TextStyle(color: color, fontSize: fontSize, height: lineHeight),
        ),
      );
}
