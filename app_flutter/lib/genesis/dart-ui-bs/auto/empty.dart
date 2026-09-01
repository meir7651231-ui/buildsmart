// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__rewards_hub_screen:_Empty (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class Empty extends StatelessWidget {
  const Empty(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: BsTokens.space5),
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: BsTokens.mutedLight, fontSize: 14)),
    );
  }
}
