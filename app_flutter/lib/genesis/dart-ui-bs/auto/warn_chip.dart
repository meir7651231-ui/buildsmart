// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__trade_builder__attribute_schema_editor:_WarnChip (בנייה-חכמה main) · צרור-2
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class WarnChip extends StatelessWidget {
  const WarnChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _kWarnColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _kWarnColor,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

const Color _kWarnColor = Color(0xFFB45309);
