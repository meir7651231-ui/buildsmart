// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__courier_portal_tab:_DestinationCard (בנייה-חכמה main) · צרור-1 · מודל-שוטח: 1 שדות · props-שורש: fallback, haul
// התוכן: new/dart-data-bs/auto/screens__courier_portal_tab_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/data/supplier_data.dart';

class DestinationCard extends StatelessWidget {
  DestinationCard({required this.fallback, required this.haul, });
  final String fallback;
  final String haul;

  @override
  Widget build(BuildContext context) {
    final haul = haulInfo(haul);
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space2),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(BsTokens.space4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(BsTokens.radiusCard)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '📦 ${id} · ${who}',
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '📍 ${site}',
              style: const TextStyle(color: BsTokens.inkLight, fontSize: 13.5),
            ),
            Text(
              '${haul.ic} ${haul.name} · ${kOrderStageLabel[stage]}',
              style: const TextStyle(
                color: BsTokens.mutedLight,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: BsTokens.space2),
            // SERVER-READY: הכפתור קיים ומעוצב אך מושבת בכנות — אין שרת ניווט.
            FilledButton(
              onPressed: null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                ),
              ),
              child: CfgText(
                'courier_portal_tab.t03',
                fallback,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
