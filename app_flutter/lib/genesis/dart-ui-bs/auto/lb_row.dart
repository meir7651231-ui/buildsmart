// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__rewards_hub_screen:_LbRow (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/config_theme.dart';

class LbRow extends StatelessWidget {
  const LbRow({
    required this.rank,
    required this.name,
    required this.coins,
    required this.me,
  });

  final String rank;
  final String name;
  final int coins;
  final bool me;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: BsTokens.space2),
      padding: const EdgeInsets.symmetric(
        horizontal: BsTokens.space3,
        vertical: BsTokens.space3,
      ),
      decoration: BoxDecoration(
        color: me ? const Color(0xFFFFF3E0) : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        border: Border.all(
          color: me ? const Color(0xFFFFB74D) : const Color(0xFFEEEEEE),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(rank, style: const TextStyle(fontSize: 18)),
          ),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: BsTokens.inkLight,
                fontWeight: me ? FontWeight.w800 : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Text('🪙 $coins',
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              )),
        ],
      ),
    );
  }
}
