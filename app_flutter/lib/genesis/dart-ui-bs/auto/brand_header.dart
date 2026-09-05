// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__lipskey_brand_screen:_BrandHeader (בנייה-חכמה main) · צרור-1 · props-שורש: fallback, label, label2
// התוכן: new/dart-data-bs/auto/screens__lipskey_brand_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';

class BrandHeader extends StatelessWidget {
  BrandHeader(
      {required this.fallback, required this.label, required this.label2, required this.totalProducts, required this.totalCats});
  final String fallback;
  final String label;
  final String label2;
  final int totalProducts;
  final int totalCats;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF0D1B2A), Color(0xFF13132A)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFF3D5A80).withOpacity(0.4), width: 0.8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          const Text('🏭', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CfgText(
                    'lipskey_brand_screen.header_title', fallback,
                    style: TextStyle(
                        color: Color(0xFF64FFDA),
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                Text('$totalProducts${label}$totalCats${label2}',
                    style: const TextStyle(
                        color: Colors.black38, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
