// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__store_screen:_SmartQtyStepper (בנייה-חכמה main) · צרור-1 · props-שורש: message, message2, label, label2
// התוכן: new/dart-data-bs/auto/screens__store_screen_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class StoreSmartQtyStepper extends StatelessWidget {
  StoreSmartQtyStepper({required this.message, required this.message2, required this.label, required this.label2, 
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });
  final String message;
  final String message2;
  final String label;
  final String label2;

  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    Widget btn(IconData icon, VoidCallback onTap) => Tooltip(
      message: icon == Icons.add ? message : message2,
      child: Semantics(
        button: true,
        label: icon == Icons.add ? label : label2,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          // ≥48dp tap target (a11y) — icon visuals unchanged.
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: Icon(icon, size: 18, color: BsTokens.brand),
            ),
          ),
        ),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        color: BsTokens.brand.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(Icons.remove, onMinus),
          SizedBox(
            width: 22,
            child: Text(
              '$qty',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          btn(Icons.add, onPlus),
        ],
      ),
    );
  }
}
