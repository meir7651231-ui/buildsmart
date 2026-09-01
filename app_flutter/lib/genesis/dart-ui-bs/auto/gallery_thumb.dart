// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__camera_sheet:_GalleryThumb (בנייה-חכמה main) · צרור-1 · props-שורש: label2, message
// התוכן: new/dart-data-bs/auto/screens__camera_sheet_content.dart
import 'package:flutter/material.dart';

class GalleryThumb extends StatelessWidget {
  GalleryThumb({required this.label2, required this.message, 
    required this.bg,
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final String label2;
  final String message;

  final Color bg;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${label2}$label',
      child: Tooltip(
        message: '${message}$label',
        child: GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 72, height: 72,
              color: bg,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.black38, size: 26),
                  const SizedBox(height: 4),
                  Text(label,
                      style: const TextStyle(color: Colors.white38, fontSize: 9)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
