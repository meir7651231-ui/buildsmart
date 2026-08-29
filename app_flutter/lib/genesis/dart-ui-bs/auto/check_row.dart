// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__trade_builder__trade_publish_sheet:_CheckRow (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class CheckRow extends StatelessWidget {
  const CheckRow({required this.pass, required this.label});

  final bool pass;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          pass ? '✓' : '✗',
          style: TextStyle(
            color: pass ? BsTokens.successDark : BsTokens.dangerDark,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: BsTokens.space2),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
