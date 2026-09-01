// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__courier_certs_screen:_PresetChip (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/app_theme.dart';

class PresetChip extends StatelessWidget {
  const PresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: selected ? BsTokens.brand : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: BsTokens.space3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              border:
                  selected ? null : Border.all(color: const Color(0xFFE2E2E2)),
            ),
            child: Text(
              label,
              style: TextStyle(
                // bsOnAccent on the selected brand fill (F-28).
                color: selected ? bsOnAccent(context) : BsTokens.inkLight,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
