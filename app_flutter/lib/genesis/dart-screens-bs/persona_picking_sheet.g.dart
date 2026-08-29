// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__persona_picking_sheet.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/banner.dart';
import '../dart-ui-bs/auto/grip.dart';
import '../dart-ui-bs/auto/split_control.dart';
import '../dart-data-bs/auto/screens__persona_picking_sheet_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class PersonaPickingSheetTokens {
  const PersonaPickingSheetTokens({required this.bg, required this.fg});
  final Color bg;
  final Color fg;
}

class PersonaPickingSheetComposed extends StatelessWidget {
  const PersonaPickingSheetComposed({required this.splitInto, required this.text, required this.t, super.key});


  final int splitInto;
  final String text;
  final PersonaPickingSheetTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          Grip(
            
          ),
          Banner(
            text: text,
            bg: t.bg,
            fg: t.fg,
          ),
          SplitControl(
            fallback: split_control_fallback,
            label: split_control_label,
            label2: split_control_label2,
            splitInto: splitInto,
          ),
        ],
      );
}
