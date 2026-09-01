// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: features__catalog_config__catalog_config_screen:_EmptyState (בנייה-חכמה main) · צרור-1 · props-שורש: label
// התוכן: new/dart-data-bs/auto/features__catalog_config__catalog_config_screen_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class EmptyState extends StatelessWidget {
  EmptyState({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('📦', style: TextStyle(fontSize: 48)),
          SizedBox(height: BsTokens.space3),
          Text(
            label,
            style: TextStyle(
              color: BsTokens.inkLight,
              fontSize: BsTokens.typeTitleSm,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
