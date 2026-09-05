// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__rewards_hub_screen:_CaCard (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/config_theme.dart';

class CaCard extends StatelessWidget {
  const CaCard({required this.child, required this.overdue});

  final Widget child;
  final bool overdue;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: BsTokens.space2),
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        border: Border.all(
          color: overdue ? const Color(0xFFE57373) : const Color(0xFFEEEEEE),
        ),
      ),
      child: child,
    );
  }
}
