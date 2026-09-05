// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__ai_hub_screen:AiCardTop (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class AiCardTop extends StatelessWidget {
  const AiCardTop({
    required this.title,
    required this.pill,
    this.danger = false,
    super.key,
  });

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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: danger ? const Color(0xFFFFEBEE) : const Color(0xFFF1F1F1),
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          ),
          child: Text(
            pill,
            style: TextStyle(
              color: danger ? const Color(0xFFC62828) : BsTokens.inkLight,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
