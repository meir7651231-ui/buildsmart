// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__lipskey_product_sheet:_PickerOption (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';

class PickerOption extends StatelessWidget {
  const PickerOption({
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF9D4D).withValues(alpha: 0.2)
              : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFFF9D4D) : const Color(0xFF444444),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          value,
          style: TextStyle(
            color:
                isSelected ? const Color(0xFFFF9D4D) : const Color(0xFFCCCCCC),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
