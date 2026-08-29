// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__courier_forms_screen:_PillButton (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/app_theme.dart';

class CourierFormsPillButton extends StatelessWidget {
  const CourierFormsPillButton({
    required this.id,
    required this.label,
    required this.onPressed,
    this.filled = true,
  });

  final String id;
  final String label;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    // excludeSemantics — the inner Text equals the label (F-50).
    // composite hide: whole pill gone when the org hides this element
    return CfgVisible(
      id,
      child: Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: filled ? BsTokens.brand : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: onPressed,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              border:
                  filled ? null : Border.all(color: const Color(0xFFE2E2E2)),
            ),
            child: CfgText(
              id,
              label,
              style: TextStyle(
                // bsOnAccent on the brand fill (F-28) — high-contrast safe.
                color: filled ? bsOnAccent(context) : BsTokens.inkLight,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}
