// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__finance_hub_sheets:_FinRows (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/config_theme.dart';

class FinRows extends StatelessWidget {
  const FinRows(this.children);
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        border: Border.all(color: const Color(0xFFE6E8EC)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: BsTokens.space4),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFE6E8EC)),
            children[i],
          ],
        ],
      ),
    );
  }
}
