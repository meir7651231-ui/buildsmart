// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__trade_builder__accessory_rule_editor:_PillButton (בנייה-חכמה main) · Stateless
// משרת-גם (זהה-מבנית): screens__trade_builder__attribute_schema_editor:_PillButton · screens__trade_builder__category_tree_editor:_PillButton · screens__trade_builder__connection_rule_studio:_PillButton · screens__trade_builder__product_authoring_screen:_PillButton · screens__trade_builder__trade_publish_sheet:_PillButton
import 'package:flutter/material.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/app_theme.dart';

class TradeBuilderAccessoryRuleEditorPillButton extends StatelessWidget {
  const TradeBuilderAccessoryRuleEditorPillButton({
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Material(
        color: enabled ? BsTokens.brand : const Color(0xFFE2E2E2),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: enabled ? bsOnAccent(context) : BsTokens.mutedLight,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
