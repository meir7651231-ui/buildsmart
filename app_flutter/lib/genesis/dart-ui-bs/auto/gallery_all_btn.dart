// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__camera_sheet:_GalleryAllBtn (בנייה-חכמה main) · צרור-1 · props-שורש: label, message, fallback
// התוכן: new/dart-data-bs/auto/screens__camera_sheet_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';

class GalleryAllBtn extends StatelessWidget {
  GalleryAllBtn({required this.label, required this.message, required this.fallback, required this.onTap});
  final String label;
  final String message;
  final String fallback;

  /// Null while a capture is already in flight (the button is disabled).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: message,
        child: GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 72, height: 72,
              color: const Color(0xFF222222),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined,
                      color: BsTokens.brand, size: 26),
                  SizedBox(height: 4),
                  CfgText('camera_sheet.t06', fallback,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: BsTokens.brand, fontSize: 9, height: 1.3)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
