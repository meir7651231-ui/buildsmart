// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__camera_sheet:_ShutterButton (בנייה-חכמה main) · צרור-1 · props-שורש: label2, label3, label4
// התוכן: new/dart-data-bs/auto/screens__camera_sheet_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class ShutterButton extends StatelessWidget {
  ShutterButton({required this.label2, required this.label3, required this.label4, 
    required this.label,
    required this.busy,
    required this.onTap,
  });
  final String label2;
  final String label3;
  final String label4;

  final String label;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${label2}$label',
      child: Material(
        color: busy ? const Color(0xFF555555) : BsTokens.brand,
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: busy ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (busy)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  const Text('📸', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  busy ? label3 : '${label4}$label',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
