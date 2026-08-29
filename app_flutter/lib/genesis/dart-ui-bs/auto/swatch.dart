// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__studio__panes__theme_pane:_Swatch (בנייה-חכמה main) · צרור-1 · props-שורש: label
// התוכן: new/dart-data-bs/auto/screens__studio__panes__theme_pane_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class Swatch extends StatelessWidget {
  Swatch({required this.label, 
    required this.color,
    required this.selected,
    required this.onTap,
    super.key,
  });
  final String label;

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? BsTokens.inkLight : Colors.black12,
                width: selected ? 3 : 1,
              ),
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 22)
                : null,
          ),
        ),
      );
}
