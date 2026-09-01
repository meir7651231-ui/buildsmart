// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__tasks_screen:_PrimaryBtn (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/app_theme.dart';

class PrimaryBtn extends StatelessWidget {
  const PrimaryBtn({required this.label, required this.onTap, super.key});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: BsTokens.brand,
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: bsOnAccent(context),
                    fontWeight: FontWeight.w800,
                    fontSize: 14)),
          ),
        ),
      );
}
