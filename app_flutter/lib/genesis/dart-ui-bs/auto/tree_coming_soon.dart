// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__catalog_screen:_TreeComingSoon (בנייה-חכמה main) · צרור-1 · מודל-שוטח: 2 שדות · props-שורש: fallback, fallback2, title, emoji
// התוכן: new/dart-data-bs/auto/screens__catalog_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/screens/catalog_screen.dart';

class TreeComingSoon extends StatelessWidget {
  TreeComingSoon({required this.fallback, required this.fallback2, required this.title, required this.emoji, });
  final String fallback;
  final String fallback2;
  final String title;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: BsTokens.brand.withAlpha(20),
                shape: BoxShape.circle,
                border: Border.all(color: BsTokens.brand, width: 1.5)),
              alignment: Alignment.center,
              child: catAvatar(title, emoji, 44),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            // composite-hide: org hiding this id drops the whole "בקרוב" pill, not orphaned chrome
            CfgVisible('catalog_screen.t21', child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: BsTokens.brand,
                borderRadius: BorderRadius.circular(16),
              ),
              child: CfgText('catalog_screen.t21',
                fallback,
                style: TextStyle(
                  color: bsOnAccent(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )),
            const SizedBox(height: 12),
            CfgText('catalog_screen.t22', 
              fallback2,
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF888888), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
