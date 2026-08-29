// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__smart_project_screen:_Hero (בנייה-חכמה main) · צרור-1 · props-שורש: label, label2
// התוכן: new/dart-data-bs/auto/screens__smart_project_screen_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/config_theme.dart';

class Hero extends StatelessWidget {
  Hero(
      {required this.label, required this.label2, required this.title,
      required this.done,
      required this.total,
      required this.pct});
  final String label;
  final String label2;
  final String title;
  final int done;
  final int total;
  final int pct;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BsTokens.space4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title,
              style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 16)),
          const SizedBox(height: BsTokens.space3),
          ClipRRect(
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              minHeight: 10,
              backgroundColor: const Color(0xFFEDEDED),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(BsTokens.brand),
            ),
          ),
          const SizedBox(height: BsTokens.space2),
          Text('$done${label}$total${label2}$pct%',
              style: const TextStyle(
                  color: BsTokens.mutedLight, fontSize: 13)),
        ],
      ),
    );
  }
}
