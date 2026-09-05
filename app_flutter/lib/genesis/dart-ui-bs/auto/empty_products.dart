// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__trade_builder__product_authoring_screen:_EmptyProducts (בנייה-חכמה main) · צרור-2 · props-שורש: fallback
// התוכן: new/dart-data-bs/auto/screens__trade_builder__product_authoring_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/config_theme.dart';

class EmptyProducts extends StatelessWidget {
  EmptyProducts({required this.fallback});
  final String fallback;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: BsTokens.space4,
        vertical: BsTokens.space5,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Column(
        children: [
          Text(_kProductEmoji, style: TextStyle(fontSize: 34)),
          SizedBox(height: BsTokens.space2),
          CfgText(
            'product_authoring_screen.t04',
            fallback,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: BsTokens.mutedLight,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

const String _kProductEmoji = '📦';
