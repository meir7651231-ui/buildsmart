// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__chats_screen:_Pill (בנייה-חכמה main) · Stateless
// משרת-גם (זהה-מבנית): screens__regression_panel_screen:_Pill
import 'package:flutter/material.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/app_theme.dart';

class Pill extends StatelessWidget {
  const Pill({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          active
              ? BsTokens.brand
              : Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: active ? bsOnAccent(context) : const Color(0xFFAAAAAA),
              fontSize: 13,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
