// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: עיצוב חי - מפעל המושן
// 🧬 בקשה: עיצוב חי - מפעל המושן: · הירו 🎆 מפעל המוֹשֶׁן | שמונה אטומי-הנפשה שהמחולל בוחר ממשפט · כותרת שדה האורות · גל 200 60 2 שדה אורות נושם · כותרת שדה החלקיקים · חלקיקים 200 90 2 ניצוצות עולות · כותרת הילת הזוהר · פעימה 200 3 הילה נושמת · כותרת שלד הריצוד · ריצוד 200 4 טעינה מרצדת · כותרת מטאטא הגרדיאנט · סחף 160 2 קשת מסתובבת · כותרת עומק התלת ממד · תלת 220 4 שכבות בעומק · כותרת השדה הגנרטיבי · רעש 200 16 תבנית משתנה · כותרת התפרצות הקונפטי · פיצוץ 200 80 2 חגיגה מתפרצת · באנר כל פיקסל כאן חושב מהמחצב - צבעים וגובה מוזרקים בחיווט
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · AuroraField · CaSubTitle · ParticleField · CaSubTitle · GlowPulse · CaSubTitle · ShimmerSkeleton · CaSubTitle · GradientSweep · CaSubTitle · ParallaxTilt · CaSubTitle · GenerativeCanvas · CaSubTitle · ConfettiBurst · CoinBanner
import '../dart-data-bs/auto/gen_crazy_content.dart';
import '../dart-ui-bs/aurora_field.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/confetti_burst.dart';
import '../dart-ui-bs/generative_canvas.dart';
import '../dart-ui-bs/glow_pulse.dart';
import '../dart-ui-bs/gradient_sweep.dart';
import '../dart-ui-bs/hero_card.dart';
import '../dart-ui-bs/parallax_tilt.dart';
import '../dart-ui-bs/particle_field.dart';
import '../dart-ui-bs/shimmer_skeleton.dart';
import 'package:flutter/material.dart';

class GenCrazyScreen extends StatefulWidget {
  const GenCrazyScreen({super.key});

  @override
  State<GenCrazyScreen> createState() => _GenCrazyScreenState();
}

class _GenCrazyScreenState extends State<GenCrazyScreen> {
  

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_crazy_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_crazy_card_glyph, title: gen_crazy_card_title, sub: gen_crazy_card_sub, onTap: () => _toast(gen_crazy_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CaSubTitle(gen_crazy_header_text),
          AuroraField(height: 200, bands: 60, speed: 2, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_crazy_header_text2),
          ParticleField(height: 200, dots: 90, speed: 2, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_crazy_header_text3),
          GlowPulse(height: 200, speed: 3, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_crazy_header_text4),
          ShimmerSkeleton(height: 200, bars: 4, speed: 16, radius: 12, baseColor: BsTokens.inkLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_crazy_header_text5),
          GradientSweep(height: 160, speed: 2, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_crazy_header_text6),
          ParallaxTilt(height: 220, layers: 4, speed: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_crazy_header_text7),
          GenerativeCanvas(height: 200, cells: 16, speed: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_crazy_header_text8),
          ConfettiBurst(height: 200, pieces: 80, speed: 2, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_crazy_banner_sub),
          ],
        ),
      ),
    );
  }
}
