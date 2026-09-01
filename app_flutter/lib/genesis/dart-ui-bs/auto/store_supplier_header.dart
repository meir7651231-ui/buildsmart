// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__store_screen:_SupplierHeader (בנייה-חכמה main) · צרור-1 · props-שורש: fallback
// התוכן: new/dart-data-bs/auto/screens__store_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';

class StoreSupplierHeader extends StatelessWidget {
  StoreSupplierHeader({required this.fallback, required this.name});
  final String fallback;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            '🏪 $name',
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          CfgText(
            'store_screen.supplier_lead_time',
            fallback,
            style: TextStyle(color: Color(0xFF888888), fontSize: 11),
          ),
        ],
      ),
    );
  }
}
