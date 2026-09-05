// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__chats_screen:_CircleFab (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/app_theme.dart';

class CircleFab extends StatelessWidget {
  const CircleFab({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    // a11y (#a11y-round3 idiom): the icon-only send/mic FAB is a bare
    // GestureDetector — additively label it for screen-reader + tooltip
    // without changing size/layout.
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Tooltip(
        message: semanticLabel,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: BsTokens.brand,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: bsOnAccent(context), size: 22),
          ),
        ),
      ),
    );
  }
}
