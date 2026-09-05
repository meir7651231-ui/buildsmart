// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__rewards_hub_screen:_FinRow (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class RewardsHubFinRow extends StatelessWidget {
  const RewardsHubFinRow({required this.label, required this.value, this.up = false});

  final String label;
  final String value;
  final bool up;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: BsTokens.inkLight, fontSize: 14)),
          Text(value,
              style: TextStyle(
                color: up ? const Color(0xFF2E7D32) : BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              )),
        ],
      ),
    );
  }
}
