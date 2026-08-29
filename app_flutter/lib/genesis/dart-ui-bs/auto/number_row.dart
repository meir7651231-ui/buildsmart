// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__catalog_settings_screen:_NumberRow (בנייה-חכמה main) · צרור-1 · props-שורש: tooltip, tooltip2
// התוכן: new/dart-data-bs/auto/screens__catalog_settings_screen_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class NumberRow extends StatelessWidget {
  NumberRow({required this.tooltip, required this.tooltip2, 
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.suffix,
    required this.onChanged,
    this.step = 1,
  });
  final String tooltip;
  final String tooltip2;

  final String label;
  final int value;
  final int min;
  final int max;
  final String suffix;
  final int step;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: const TextStyle(color: BsTokens.inkLight)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: tooltip,
            icon: const Icon(Icons.remove, color: Colors.black54, size: 20),
            onPressed:
                value > min
                    ? () => onChanged((value - step).clamp(min, max))
                    : null,
          ),
          Text(
            suffix.isEmpty ? '$value' : '$value $suffix',
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
          IconButton(
            tooltip: tooltip2,
            icon: const Icon(Icons.add, color: Colors.black54, size: 20),
            onPressed:
                value < max
                    ? () => onChanged((value + step).clamp(min, max))
                    : null,
          ),
        ],
      ),
    );
  }
}
