// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__site_hub_screen:_CardTop (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class CardTop extends StatelessWidget {
  const CardTop({required this.left, required this.trailing});
  final String left;
  final Widget trailing;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              left,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          trailing,
        ],
      );
}
