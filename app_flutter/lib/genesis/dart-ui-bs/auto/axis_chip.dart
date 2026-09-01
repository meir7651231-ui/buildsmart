// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__catalog_screen:_AxisChip (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/app_theme.dart';

class AxisChip extends StatelessWidget {
  const AxisChip({required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? BsTokens.brand : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? BsTokens.brand : cs.outline.withOpacity(0.35), width: 1.2),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? bsOnAccent(context) : cs.onSurface, fontWeight: FontWeight.w700, fontSize: 12)),
      ),
    );
  }
}
