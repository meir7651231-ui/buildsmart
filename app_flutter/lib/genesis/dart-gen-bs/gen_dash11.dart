// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: רכיבים חיים - כרטיסי-דשבורד
// 🧬 בקשה: רכיבים חיים - כרטיסי-דשבורד: · הירו 📊 כרטיסי-דשבורד | ביצועים מזג ופריט ממשפט · כותרת מדדים · ביצועים 140 2480₪ | הכנסה חודשית · מזג 160 28° | שמש חלקית · פריט 64 הזמנה חדשה התקבלה | לפני 5 דקות · בלוק 90 מדדים: מבקרים / הזמנות / הכנסה · באנר כל רכיב כאן חי - נבחר ממילה בעברית
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · TrendCard · WeatherCard · NotifItem · StatBlock · CoinBanner
import '../dart-data-bs/auto/gen_dash11_content.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/hero_card.dart';
import '../dart-ui-bs/notif_item.dart';
import '../dart-ui-bs/stat_block.dart';
import '../dart-ui-bs/trend_card.dart';
import '../dart-ui-bs/weather_card.dart';
import 'package:flutter/material.dart';

class GenDash11Screen extends StatefulWidget {
  const GenDash11Screen({super.key});

  @override
  State<GenDash11Screen> createState() => _GenDash11ScreenState();
}

class _GenDash11ScreenState extends State<GenDash11Screen> {
  

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_dash11_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_dash11_card_glyph, title: gen_dash11_card_title, sub: gen_dash11_card_sub, onTap: () => _toast(gen_dash11_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CaSubTitle(gen_dash11_header_text),
          TrendCard(title: gen_dash11_statcard_title, sub: gen_dash11_statcard_sub, height: 140, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          WeatherCard(title: gen_dash11_weather_title, sub: gen_dash11_weather_sub, height: 160, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NotifItem(title: gen_dash11_notifitem_title, sub: gen_dash11_notifitem_sub, height: 64, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          StatBlock(labels: const <String>[gen_dash11_statblock_option, gen_dash11_statblock_option2, gen_dash11_statblock_option3], height: 90, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_dash11_banner_sub),
          ],
        ),
      ),
    );
  }
}
