// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__ai_hub_screen:AiBar (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class AiBar extends StatelessWidget {
  const AiBar({required this.pct, this.danger = false, super.key});

  final int pct;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      child: LinearProgressIndicator(
        value: pct / 100,
        minHeight: 8,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation<Color>(
          danger ? const Color(0xFFE53935) : BsTokens.brand,
        ),
      ),
    );
  }
}
