// 🧼 אטום · ZoomHintBadge — תג-רמז קטן: אייקון-זום + תווית על גלולה כהה.
// מוצא: screens__lipskey_product_sheet.dart:1734-1758 (_ZoomHint).
// התווית (t_e6ec4e84 · cfg: lipskey_product_sheet.zoom) מוזרקת מ-content.
import 'package:flutter/material.dart';

class ZoomHintBadge extends StatelessWidget {
  const ZoomHintBadge({
    required this.label,
    required this.bgColor,
    required this.borderColor,
    required this.fgColor,
    this.icon = Icons.zoom_in,
    super.key,
  });
  final String label;
  final Color bgColor, borderColor, fgColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: fgColor, size: 14),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: fgColor, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
