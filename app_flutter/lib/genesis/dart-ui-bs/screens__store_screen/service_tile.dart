// 🧼 אטום · ServiceTile — שורת-שירות ב-sheet: גליף, תווית מעומעמת, תת-שורה ו-trailing.
// מוצא: screens__store_screen.dart:3698-3753 (שורות _ServiceSheet). שורות-התוכן =
// content (serviceSheetRows); תג-הבבנייה (CfgVisible + t_eb0da3be) = slot trailing
// (under_construction_badge מחווט-קופסה — חוק-1); טוסט-הלחיצה (t_35f5eb31) = קופסה.
import 'package:flutter/material.dart';

class ServiceTile extends StatelessWidget {
  const ServiceTile({
    required this.emoji, required this.label, required this.onTap,
    required this.labelColor, required this.subColor,
    this.subLabel, this.trailing, super.key,
  });
  final String emoji, label;
  final String? subLabel;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color labelColor, subColor;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Text(emoji, style: TextStyle(fontSize: 22, color: labelColor)),
        title: Text(label, style: TextStyle(color: labelColor, fontSize: 15)),
        subtitle: subLabel == null || subLabel!.isEmpty
            ? null
            : Text(subLabel!, style: TextStyle(color: subColor, fontSize: 12)),
        trailing: trailing,
        onTap: onTap,
      );
}
