// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__persona_picking_sheet:_SplitControl (בנייה-חכמה main) · צרור-1 · props-שורש: fallback, label, label2
// התוכן: new/dart-data-bs/auto/screens__persona_picking_sheet_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/app_theme.dart';

class SplitControl extends StatelessWidget {
  SplitControl({required this.fallback, required this.label, required this.label2, required this.splitInto, required this.onSelect});
  final String fallback;
  final String label;
  final String label2;
  final int splitInto;
  final void Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CfgText(
            'persona_picking_sheet.t12',
            fallback,
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: BsTokens.space2),
          Row(
            children: [
              for (final g in const [1, 2, 3]) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onSelect(g),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: splitInto == g
                          ? BsTokens.brand
                          : Colors.transparent,
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                      ),
                    ),
                    child: Text(
                      g == 1 ? label : '$g${label2}',
                      style: TextStyle(
                        color: splitInto == g
                            ? bsOnAccent(context)
                            : BsTokens.inkLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ),
                if (g != 3) const SizedBox(width: BsTokens.space2),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
