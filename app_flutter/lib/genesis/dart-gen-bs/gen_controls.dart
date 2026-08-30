// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: רכיבים חיים - שדות ובקרות
// 🧬 בקשה: רכיבים חיים - שדות ובקרות: · הירו 🎛️ שדות ובקרות | קלט ומתגים שהמחולל מרכיב ממשפט · כותרת שדות קלט · מיקוד 54 הקלד כאן · חיפוש 54 חפש משהו · כותרת בקרות אינטראקטיביות · נדנדה 40 מצב פעיל · וי 40 אשר את התנאים · מחוון 40 עוצמת הזוהר · כוכבים 40 5 דרג אותנו · באנר כל בקרה כאן חיה ומגיבה - נבחרת ממילה בעברית
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · GlowField · SearchField · CaSubTitle · AnimatedToggle · CheckPop · GlowSlider · StarRating · CoinBanner
import '../dart-data-bs/auto/gen_controls_content.dart';
import '../dart-ui-bs/animated_toggle.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/check_pop.dart';
import '../dart-ui-bs/glow_field.dart';
import '../dart-ui-bs/glow_slider.dart';
import '../dart-ui-bs/hero_card.dart';
import '../dart-ui-bs/search_field.dart';
import '../dart-ui-bs/star_rating.dart';
import 'package:flutter/material.dart';

class GenControlsScreen extends StatefulWidget {
  const GenControlsScreen({super.key});

  @override
  State<GenControlsScreen> createState() => _GenControlsScreenState();
}

class _GenControlsScreenState extends State<GenControlsScreen> {
  

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_controls_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_controls_card_glyph, title: gen_controls_card_title, sub: gen_controls_card_sub, onTap: () => _toast(gen_controls_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CaSubTitle(gen_controls_header_text),
          GlowField(hint: gen_controls_glowfield_hint, height: 54, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          SearchField(hint: gen_controls_searchfield_hint, height: 54, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_controls_header_text2),
          AnimatedToggle(label: gen_controls_toggle_label, height: 40, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CheckPop(label: gen_controls_checkpop_label, height: 40, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          GlowSlider(label: gen_controls_glowslider_label, height: 40, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          StarRating(label: gen_controls_stars_label, height: 40, stars: 5, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_controls_banner_sub),
          ],
        ),
      ),
    );
  }
}
