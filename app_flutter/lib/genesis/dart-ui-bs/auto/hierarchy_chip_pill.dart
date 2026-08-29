// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__lipskey_products_screen:_HierarchyChipPill (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/app_theme.dart';

class HierarchyChipPill extends StatelessWidget {
  const HierarchyChipPill(
      {required this.word, this.onTap, this.isOpen = false});
  final String word;
  final VoidCallback? onTap;
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final isSize = RegExp(r'^["”]?\d|^\d').hasMatch(word);
    final bg = isOpen
        ? BsTokens.brand
        : (isSize ? BsTokens.brand : const Color(0xFFF1F1F4));
    final fg = (isOpen || isSize) ? bsOnAccent(context) : const Color(0xFF1C1C1E);
    final border = isOpen
        ? BsTokens.brand
        : (isSize
            ? BsTokens.brand
            : const Color(0xFFE0E0E5));
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: border, width: 1),
        ),
        child: Text(
          word,
          textDirection: word.contains(RegExp(r'\d')) ? TextDirection.ltr : null,
          style: TextStyle(
            color: fg,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
