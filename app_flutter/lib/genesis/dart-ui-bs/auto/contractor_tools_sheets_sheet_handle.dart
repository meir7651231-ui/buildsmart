// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__contractor_tools_sheets:_SheetHandle (בנייה-חכמה main) · צרור-1 · props-שורש: label, tooltip, onPressed
// התוכן: new/dart-data-bs/auto/screens__contractor_tools_sheets_content.dart
import 'package:flutter/material.dart';

class ContractorToolsSheetsSheetHandle extends StatelessWidget {
  ContractorToolsSheetsSheetHandle({required this.label, required this.tooltip, required this.onPressed});
  final String label;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Semantics(
            button: true,
            label: label,
            child: IconButton(
              tooltip: tooltip,
              icon: const Icon(Icons.close, color: Color(0xFF888888)),
              onPressed: onPressed,
            ),
          ),
        ),
      ],
    );
  }
}
