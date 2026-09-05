// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__camera_sheet.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/barcode_reticle.dart';
import '../dart-ui-bs/auto/gallery_all_btn.dart';
import '../dart-ui-bs/auto/gallery_thumb.dart';
import '../dart-ui-bs/auto/mode_frame.dart';
import '../dart-ui-bs/auto/shutter_button.dart';
import '../dart-data-bs/auto/screens__camera_sheet_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class CameraSheetTokens {
  const CameraSheetTokens({required this.bg});
  final Color bg;
}

class CameraSheetComposed extends StatelessWidget {
  const CameraSheetComposed({required this.onTap, required this.onTap2, required this.busy, required this.emoji, required this.hint, required this.icon, required this.label, required this.t, super.key});

  final VoidCallback onTap;
  final VoidCallback? onTap2;
  final bool busy;
  final String emoji;
  final String hint;
  final IconData icon;
  final String label;
  final CameraSheetTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          BarcodeReticle(
            
          ),
          ModeFrame(
            emoji: emoji,
            hint: hint,
          ),
          ShutterButton(
            label2: shutter_button_label2,
            label3: shutter_button_label3,
            label4: shutter_button_label4,
            label: label,
            busy: busy,
            onTap: onTap,
          ),
          GalleryAllBtn(
            label: gallery_all_btn_label,
            message: gallery_all_btn_message,
            fallback: gallery_all_btn_fallback,
            onTap: onTap2,
          ),
          GalleryThumb(
            label2: gallery_thumb_label2,
            message: gallery_thumb_message,
            bg: t.bg,
            icon: icon,
            label: label,
            onTap: onTap,
          ),
        ],
      );
}
