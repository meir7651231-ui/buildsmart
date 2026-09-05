// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__trade_builder__accessory_rule_editor:_EmptyAccessories (בנייה-חכמה main) · צרור-1 · props-שורש: fallback
// התוכן: new/dart-data-bs/auto/screens__trade_builder__accessory_rule_editor_content.dart
// משרת-גם (זהה-מבנית): screens__trade_builder__category_tree_editor:_EmptyCategories · screens__trade_builder__trade_builder_home:_EmptyTrades
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/config_theme.dart';

class EmptyAccessories extends StatelessWidget {
  EmptyAccessories({required this.fallback});
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
          Text('🧩', style: TextStyle(fontSize: 34)),
          SizedBox(height: BsTokens.space2),
          CfgText(
            'accessory_rule_editor.t05',
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
