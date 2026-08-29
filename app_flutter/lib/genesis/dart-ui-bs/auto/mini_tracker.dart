// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__manager_dashboard_screen:_MiniTracker (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class MiniTracker extends StatelessWidget {
  const MiniTracker({required this.stageIdx});

  final int stageIdx;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < kManagerOrderFlow.length; i++) ...[
          Expanded(
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: i <= stageIdx ? BsTokens.brand : const Color(0xFFEDEDED),
                borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              ),
            ),
          ),
          if (i < kManagerOrderFlow.length - 1) const SizedBox(width: 4),
        ],
      ],
    );
  }
}
