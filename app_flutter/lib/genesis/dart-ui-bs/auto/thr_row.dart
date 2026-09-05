// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__finance_hub_sheets:_ThrRow (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/config_theme.dart';

class ThrRow extends StatelessWidget {
  const ThrRow({required this.label, required this.hit});
  final String label;
  final bool hit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: BsTokens.space2),
      padding: const EdgeInsets.symmetric(
        horizontal: BsTokens.space3,
        vertical: BsTokens.space3,
      ),
      decoration: BoxDecoration(
        color: hit ? const Color(0xFFFFF3E0) : const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        border: Border.all(
          color: hit ? const Color(0xFFFFCC80) : const Color(0xFFE6E8EC),
        ),
      ),
      child: Row(
        children: [
          // proto: hit ? '⚠️' : '○'
          Text(hit ? '⚠️' : '○', style: const TextStyle(fontSize: 16)),
          const SizedBox(width: BsTokens.space2),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: BsTokens.inkLight, fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }
}
