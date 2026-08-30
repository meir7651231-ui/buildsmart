// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: רכיבים חיים - מפה ומדיה
// 🧬 בקשה: רכיבים חיים - מפה ומדיה: · הירו 📍 מפה ומדיה | סיכות סטורי ואייקונים ממשפט · כותרת מיקום · מפה 150 6 מפת סיכות · כותרת מדיה ובחירה · סטורי 90 טבעת סטורי · אייקונים 150 8 בחר אייקון · מסחר 60 4820 מדד השוק · באנר כל רכיב כאן חי - נבחר ממילה בעברית
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · MapPins · CaSubTitle · StoryRing · IconGrid · PriceTicker · CoinBanner
import '../dart-data-bs/auto/gen_rich_content.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/hero_card.dart';
import '../dart-ui-bs/icon_grid.dart';
import '../dart-ui-bs/map_pins.dart';
import '../dart-ui-bs/price_ticker.dart';
import '../dart-ui-bs/story_ring.dart';
import 'package:flutter/material.dart';

class GenRichScreen extends StatefulWidget {
  const GenRichScreen({super.key});

  @override
  State<GenRichScreen> createState() => _GenRichScreenState();
}

class _GenRichScreenState extends State<GenRichScreen> {
  

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_rich_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_rich_card_glyph, title: gen_rich_card_title, sub: gen_rich_card_sub, onTap: () => _toast(gen_rich_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CaSubTitle(gen_rich_header_text),
          MapPins(height: 150, pins: 6, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_rich_header_text2),
          StoryRing(height: 90, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          IconGrid(height: 150, cells: 8, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          PriceTicker(label: gen_rich_ticker_label, height: 60, target: 4820, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_rich_banner_sub),
          ],
        ),
      ),
    );
  }
}
