// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__site_hub_screen:_CaPill (בנייה-חכמה main) · צרור-2
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class CaPill extends StatelessWidget {
  const CaPill(this.label, {this.done = false});
  final String label;
  final bool done;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: done
            ? const Color(0x24737578)
            : const Color(0x241F6F6B),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: done ? BsTokens.mutedLight : _kBrandDark,
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
      ),
    );
  }
}

const Color _kBrandDark = BsTokens.brandDark;
