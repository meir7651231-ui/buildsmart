// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: רכיבים חיים - כפתורים וחלונות
// 🧬 בקשה: רכיבים חיים - כפתורים וחלונות: · הירו 🧩 רכיבים חיים | כפתורים וחלונות שהמחולל מרכיב ממשפט · כותרת כפתורים אינטראקטיביים · ניאון 54 שגר עכשיו · אדווה 54 גל מגע · ברק 54 גרדיאנט נודד · מגנט 54 משיכה מגנטית · כותרת חלונות · זכוכית 150 חלון זכוכית | שקוף ומטושטש עם כניסה מונפשת · זרקור 150 זרקור נע | אור סורק מתחת לטקסט · באנר כל רכיב כאן אינטראקטיבי וחי - נבחר ממילה בעברית
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · NeonButton · RippleButton · GradientPulseButton · MagneticButton · CaSubTitle · GlassCard · SpotlightCard · CoinBanner
import '../dart-data-bs/auto/gen_components_content.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/glass_card.dart';
import '../dart-ui-bs/gradient_pulse_button.dart';
import '../dart-ui-bs/hero_card.dart';
import '../dart-ui-bs/magnetic_button.dart';
import '../dart-ui-bs/neon_button.dart';
import '../dart-ui-bs/ripple_button.dart';
import '../dart-ui-bs/spotlight_card.dart';
import 'package:flutter/material.dart';

class GenComponentsScreen extends StatefulWidget {
  const GenComponentsScreen({super.key});

  @override
  State<GenComponentsScreen> createState() => _GenComponentsScreenState();
}

class _GenComponentsScreenState extends State<GenComponentsScreen> {
  

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_components_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_components_card_glyph, title: gen_components_card_title, sub: gen_components_card_sub, onTap: () => _toast(gen_components_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CaSubTitle(gen_components_header_text),
          NeonButton(label: gen_components_neon_label, height: 54, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, onPressed: () => _toast(gen_components_neon_toast)),
          RippleButton(label: gen_components_ripple_label, height: 54, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, onPressed: () => _toast(gen_components_ripple_toast)),
          GradientPulseButton(label: gen_components_gradientbtn_label, height: 54, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, labelColor: BsTokens.inkLight, onPressed: () => _toast(gen_components_gradientbtn_toast)),
          MagneticButton(label: gen_components_magnet_label, height: 54, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, onPressed: () => _toast(gen_components_magnet_toast)),
          CaSubTitle(gen_components_header_text2),
          GlassCard(title: gen_components_glass_title, sub: gen_components_glass_sub, height: 150, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          SpotlightCard(title: gen_components_spotlight_title, sub: gen_components_spotlight_sub, height: 150, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_components_banner_sub),
          ],
        ),
      ),
    );
  }
}
