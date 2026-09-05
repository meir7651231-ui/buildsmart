// 🧼 אטום · StripPanelFrame — רקע-הפאנל שנפתח מתחת לרצועה: מלוא-רוחב, גוון-רצועה 5%.
// מוצא: screens__lipskey_product_sheet.dart:2472-2490 (Container-העוטף של _StripPanel;
// ה-switch פר-סוג = חיווט-קופסה — הקופסה בוחרת את גוף-הפאנל ומזרימה אותו כ-child).
import 'package:flutter/material.dart';

class StripPanelFrame extends StatelessWidget {
  const StripPanelFrame({
    required this.tint,
    required this.child,
    super.key,
  });
  final Color tint;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
        color: tint.withValues(alpha: 0.05),
        child: child,
      );
}
