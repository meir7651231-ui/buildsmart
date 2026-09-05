// 🧼 אטום · PickerOptionChip — אפשרות-בורר בודדת: ערך על צ'יפ, מודגש כשנבחר.
// מוצא: screens__lipskey_product_sheet.dart:3516-3556 (_PickerOption).
// isSelected מחושב בקופסה (השוואת-sku); הצבעים (0xFFFF9D4D / 0xFF2A2A2A / 0xFF444444 /
// 0xFFCCCCCC במקור) = פיגמנטים מוזרקים.
import 'package:flutter/material.dart';

class PickerOptionChip extends StatelessWidget {
  const PickerOptionChip({
    required this.value,
    required this.isSelected,
    required this.onTap,
    required this.accentColor,
    required this.idleBgColor,
    required this.idleBorderColor,
    required this.idleFgColor,
    super.key,
  });
  final String value;
  final bool isSelected;
  final VoidCallback onTap;
  final Color accentColor, idleBgColor, idleBorderColor, idleFgColor;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: 0.2)
                : idleBgColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? accentColor : idleBorderColor,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: isSelected ? accentColor : idleFgColor,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      );
}
