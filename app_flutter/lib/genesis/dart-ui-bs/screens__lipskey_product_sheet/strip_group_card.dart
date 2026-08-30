// 🧼 אטום · StripGroupCard — מסגרת-קבוצת-הרצועות: כרטיס מעוגל-פינות עם ילדים אנכיים.
// מוצא: screens__lipskey_product_sheet.dart:2308-2341 (Container-המסגרת של
// _QuickInfoStrips.build). הילדים = שקע: הקופסה משרשרת InfoStripRow + פאנל-פתוח +
// InsetDivider (thickness 0.7 / indent 12) לפי מצב-הרצועות ומנועי-העובדות.
import 'package:flutter/material.dart';

class StripGroupCard extends StatelessWidget {
  const StripGroupCard({
    required this.children,
    required this.surfaceColor,
    required this.borderColor,
    super.key,
  });
  final List<Widget> children;
  final Color surfaceColor, borderColor;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      );
}
