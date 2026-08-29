// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__install_studio_screen:_SheetClose (בנייה-חכמה main) · צרור-2 · props-שורש: label, message, onTap
// התוכן: new/dart-data-bs/auto/screens__install_studio_screen_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class SheetClose extends StatelessWidget {
  SheetClose({required this.label, required this.message, required this.onTap});
  final String label;
  final String message;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 0, 2),
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            shape: const CircleBorder(),
            child: Semantics(
              button: true,
              label: label,
              child: Tooltip(
                message: message,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onTap,
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(Icons.close, color: _ink, size: 22),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

const _ink = BsTokens.inkLight;
