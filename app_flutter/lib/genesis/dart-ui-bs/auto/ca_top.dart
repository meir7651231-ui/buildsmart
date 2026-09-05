// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__rewards_hub_screen:_CaTop (בנייה-חכמה main) · צרור-2
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class CaTop extends StatelessWidget {
  const CaTop({required this.title, required this.pill, this.danger = false});

  final String title;
  final String pill;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: BsTokens.space2),
        _Pill(pill, danger: danger),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text, {this.danger = false});

  final String text;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: danger ? const Color(0xFFFFEBEE) : const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: danger ? const Color(0xFFC62828) : BsTokens.inkLight,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
