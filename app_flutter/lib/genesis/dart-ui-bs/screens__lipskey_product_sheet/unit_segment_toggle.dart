// 🧼 אטום · UnitSegmentToggle — בורר-מקטעים שווי-רוחב עם אפשרויות-מנוטרלות.
// מוצא: screens__lipskey_product_sheet.dart:1361-1413 (_UnitToggle).
// התרת-סבך: enum _Unit + התוויות הצרובות (t_4f815ce8 בודד · t_2efbb17a ארגז ·
// t_a9857806 משטח, unitToggleOptions ב-content) ⇒ options+selectedIndex+onSelect —
// הקופסה ממפה אינדקס⇄יחידה ומנטרלת לפי qtyPack/qtyPallet של המוצר.
import 'package:flutter/material.dart';

class UnitSegmentToggle extends StatelessWidget {
  const UnitSegmentToggle({
    required this.options,
    required this.selectedIndex,
    required this.onSelect,
    required this.selectedBgColor,
    required this.selectedFgColor,
    required this.enabledFgColor,
    required this.disabledFgColor,
    required this.borderColor,
    super.key,
  });
  final List<({String label, bool enabled})> options;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Color selectedBgColor, selectedFgColor, enabledFgColor, disabledFgColor, borderColor;

  @override
  Widget build(BuildContext context) {
    Widget opt(int i) {
      final o = options[i];
      final sel = selectedIndex == i;
      return Expanded(
        child: InkWell(
          onTap: o.enabled ? () => onSelect(i) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            color: sel ? selectedBgColor : Colors.transparent,
            alignment: Alignment.center,
            child: Text(o.label,
                style: TextStyle(
                    fontSize: 12,
                    color: sel
                        ? selectedFgColor
                        : (o.enabled ? enabledFgColor : disabledFgColor),
                    fontWeight: sel ? FontWeight.w800 : FontWeight.w500)),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(children: [for (var i = 0; i < options.length; i++) opt(i)]),
    );
  }
}
