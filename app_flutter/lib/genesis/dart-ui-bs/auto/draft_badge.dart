// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__studio__studio_top_bar:_DraftBadge (בנייה-חכמה main) · צרור-1 · props-שורש: label, label2, label3
// התוכן: new/dart-data-bs/auto/screens__studio__studio_top_bar_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class DraftBadge extends StatelessWidget {
  DraftBadge({required this.label, required this.label2, required this.label3, required this.count});
  final String label;
  final String label2;
  final String label3;

  final int count;

  @override
  Widget build(BuildContext context) {
    final has = count > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: has
            ? BsTokens.brand.withValues(alpha: 0.12)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      ),
      child: Text(
        has ? '${label}$count${label2}' : label3,
        style: TextStyle(
          color: has ? BsTokens.brandDark : BsTokens.mutedLight,
          fontWeight: FontWeight.w700,
          fontSize: BsTokens.typeCaption,
        ),
      ),
    );
  }
}
