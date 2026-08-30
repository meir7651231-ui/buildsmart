// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: רכיבים חיים - שכבות-על
// 🧬 בקשה: רכיבים חיים - שכבות-על: · הירו 🪟 שכבות-על | דיאלוג טולטיפ ושלד ממשפט · כותרת מודאלים · דיאלוג 200 לאשר את הפעולה | הפעולה בלתי-הפיכה · טולטיפ 80 טיפ שימושי כאן · כותרת מצב · שלד 120 שלד טעינה · שעון 60 90 ספירה לאחור · באנר כל רכיב כאן חי - נבחר ממילה בעברית
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · ModalDialog · TooltipBubble · CaSubTitle · SkeletonCard · Countdown · CoinBanner
import '../dart-data-bs/auto/gen_overlay10_content.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/countdown_timer.dart';
import '../dart-ui-bs/hero_card.dart';
import '../dart-ui-bs/modal_dialog.dart';
import '../dart-ui-bs/skeleton_card.dart';
import '../dart-ui-bs/tooltip_bubble.dart';
import 'package:flutter/material.dart';

class GenOverlay10Screen extends StatefulWidget {
  const GenOverlay10Screen({super.key});

  @override
  State<GenOverlay10Screen> createState() => _GenOverlay10ScreenState();
}

class _GenOverlay10ScreenState extends State<GenOverlay10Screen> {
  

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_overlay10_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_overlay10_card_glyph, title: gen_overlay10_card_title, sub: gen_overlay10_card_sub, onTap: () => _toast(gen_overlay10_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CaSubTitle(gen_overlay10_header_text),
          ModalDialog(title: gen_overlay10_dialog_title, sub: gen_overlay10_dialog_sub, height: 200, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          TooltipBubble(text: gen_overlay10_tooltip_text, height: 80, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_overlay10_header_text2),
          SkeletonCard(height: 120, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          Countdown(height: 60, target: 90, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_overlay10_banner_sub),
          ],
        ),
      ),
    );
  }
}
