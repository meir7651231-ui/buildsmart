// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: features__catalog_config__catalog_config_screen:_MaterialDots (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class MaterialDots extends StatelessWidget {
  const MaterialDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '↔',
          style: TextStyle(
            color: BsTokens.mutedLight,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: BsTokens.space2),
        for (var i = 0; i < count; i++)
          Container(
            width: i == index ? 14 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: i == index ? BsTokens.brand : const Color(0xFFCFD4DA),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }
}
