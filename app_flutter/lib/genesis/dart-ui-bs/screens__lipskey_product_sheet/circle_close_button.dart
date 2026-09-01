// 🧼 אטום · CircleCloseButton — כפתור-X עגול 48dp עם Semantics (ו-Tooltip אופציונלי).
// מוצא: screens__lipskey_product_sheet.dart:106-124 (המציג-המלא, בלי tooltip)
// + 766-792 (כותרת-הסל, עם tooltip) — אותו מנגנון, צבעים שונים ⇒ פיגמנטים כ-props.
// semanticLabel (במקור: t_55247199) מוזרק מ-content; onTap = הקופסה (Navigator.pop = חיווט).
import 'package:flutter/material.dart';

class CircleCloseButton extends StatelessWidget {
  const CircleCloseButton({
    required this.onTap,
    required this.semanticLabel,
    required this.bgColor,
    required this.iconColor,
    this.iconSize = 22,
    this.tapSize = 48,
    this.withTooltip = false,
    super.key,
  });
  final VoidCallback onTap;
  final String semanticLabel;
  final Color bgColor, iconColor;
  final double iconSize, tapSize;
  final bool withTooltip;

  @override
  Widget build(BuildContext context) {
    Widget inner = InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: SizedBox(
        width: tapSize,
        height: tapSize,
        child: Icon(Icons.close, color: iconColor, size: iconSize),
      ),
    );
    if (withTooltip) inner = Tooltip(message: semanticLabel, child: inner);
    return Material(
      color: bgColor,
      shape: const CircleBorder(),
      child: Semantics(button: true, label: semanticLabel, child: inner),
    );
  }
}
