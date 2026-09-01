// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__catalog_screen:_MiniQtyBtn (בנייה-חכמה main) · צרור-1 · props-שורש: label, label2
// התוכן: new/dart-data-bs/auto/screens__catalog_screen_content.dart
import 'package:flutter/material.dart';

class MiniQtyBtn extends StatelessWidget {
  MiniQtyBtn({required this.label, required this.label2, required this.icon, required this.onTap});
  final String label;
  final String label2;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: icon == Icons.add ? label : label2,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        // ≥48dp tap target (a11y) — the visible +/- glyph stays 12dp; only
        // the hit area (and the grey pill) grows.
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Icon(
              icon,
              size: 12,
              color: onTap != null
                  ? Colors.black54
                  : const Color(0xFFCCCCCC),
            ),
          ),
        ),
      ),
    );
  }
}
