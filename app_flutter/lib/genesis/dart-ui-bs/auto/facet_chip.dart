// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__catalog_screen:_FacetChip (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class FacetChip extends StatelessWidget {
  const FacetChip({required this.label, required this.count, required this.isSelected, required this.onTap});
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x22FF7A18) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? BsTokens.brand : cs.outline.withOpacity(0.25), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(color: isSelected ? const Color(0xFFCC6614) : cs.onSurface.withOpacity(0.8), fontWeight: FontWeight.w600, fontSize: 11)),
            const SizedBox(width: 3),
            Text('$count', style: TextStyle(color: cs.onSurface.withOpacity(0.45), fontWeight: FontWeight.w600, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}
