// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__trade_builder__accessory_rule_editor:_PriceChip (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class PriceChip extends StatelessWidget {
  const PriceChip({required this.price});

  final int price;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        '₪$price',
        style: const TextStyle(
          color: BsTokens.inkLight,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      side: const BorderSide(color: Color(0xFFEDEDED)),
    );
  }
}
