// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__rewards_hub_screen:_Bar (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class Bar extends StatelessWidget {
  const Bar({required this.pct});

  final int pct;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      child: LinearProgressIndicator(
        value: pct / 100,
        minHeight: 8,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        valueColor: const AlwaysStoppedAnimation<Color>(BsTokens.brand),
      ),
    );
  }
}
