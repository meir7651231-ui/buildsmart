// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__trade_builder__trade_define_step:_ColorSwatch (בנייה-חכמה main) · צרור-1 · props-שורש: label
// התוכן: new/dart-data-bs/auto/screens__trade_builder__trade_define_step_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class TradeBuilderTradeDefineStepColorSwatch extends StatelessWidget {
  TradeBuilderTradeDefineStepColorSwatch({required this.label, 
    required this.color,
    required this.index,
    required this.selected,
    required this.onTap,
  });
  final String label;

  final int color;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${label}${index + 1}',
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(color),
            shape: BoxShape.circle,
            border: selected
                ? Border.all(color: BsTokens.inkLight, width: 3)
                : Border.all(color: const Color(0xFFEDEDED)),
          ),
          child: selected
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}
