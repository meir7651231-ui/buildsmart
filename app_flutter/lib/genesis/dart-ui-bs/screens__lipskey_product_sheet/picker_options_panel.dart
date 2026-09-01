// 🧼 אטום · PickerOptionsPanel — לוח-האפשרויות שנפתח מתחת לצ'יפ-תכונה: Wrap ממוסגר-כהה.
// מוצא: screens__lipskey_product_sheet.dart:3477-3514 (_ChipPickerRow).
// התרת-סבך: List<(String, LipskeyCatalogProduct)> + השוואת-sku ⇒ הילדים = שקע —
// הקופסה מרכיבה PickerOptionChip פר-אפשרות (חוק-1: אטום לא מייבא אטום) ומטפלת בבחירה.
import 'package:flutter/material.dart';

class PickerOptionsPanel extends StatelessWidget {
  const PickerOptionsPanel({
    required this.children,
    required this.bgColor,
    required this.borderColor,
    super.key,
  });
  final List<Widget> children;
  final Color bgColor, borderColor;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Wrap(spacing: 6, runSpacing: 6, children: children),
    );
  }
}
