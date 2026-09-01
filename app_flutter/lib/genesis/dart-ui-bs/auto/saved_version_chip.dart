// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__catalog_screen:_SavedVersionChip (בנייה-חכמה main) · צרור-1 · props-שורש: message, label2, message2, label3
// התוכן: new/dart-data-bs/auto/screens__catalog_screen_content.dart
import 'package:flutter/material.dart';

class SavedVersionChip extends StatelessWidget {
  SavedVersionChip({required this.message, required this.label2, required this.message2, required this.label3, 
    required this.label,
    required this.onLoad,
    required this.onDelete,
  });
  final String message;
  final String label2;
  final String message2;
  final String label3;

  final String label;
  final VoidCallback onLoad;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: message,
            child: Semantics(
              button: true,
              label: '${label2}$label',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onLoad,
                // ≥48dp tap target (a11y) — label text stays 10.5sp; only
                // the hit area (and the violet pill) grows.
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(minWidth: 48, minHeight: 48),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 3, 6, 3),
                      child: Text(label,
                          style: const TextStyle(
                              color: Color(0xFF5B21B6),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Tooltip(
            message: message2,
            child: Semantics(
              button: true,
              label: '${label3}$label',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onDelete,
                // ≥48dp tap target around the small ✕ (a11y).
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: Icon(Icons.close,
                        size: 12, color: Color(0xFF7C3AED)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
