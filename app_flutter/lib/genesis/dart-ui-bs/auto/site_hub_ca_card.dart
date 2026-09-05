// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__site_hub_screen:_CaCard (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class SiteHubCaCard extends StatelessWidget {
  const SiteHubCaCard({required this.child, this.overdue = false});
  final Widget child;
  final bool overdue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: BsTokens.space2),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: overdue ? const Color(0xFFF2A516) : const Color(0xFFE6E6E6),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
