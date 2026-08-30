// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הירו 🎯 דשבורד מכירות מנהלים עם רקע קוסמי נושם | נבנה מתיאור חופשי
// 🧬 בקשה: הירו 🎯 דשבורד מכירות מנהלים עם רקע קוסמי נושם | נבנה מתיאור חופשי · גל 200 60 2 רקע מונפש · עוגה 150 5 תרשים-עוגה · מד 160 מד · לוח 150 לוח-חודש · מגמה 130 20 גרף-מגמה · פרופיל 230 כרטיס-פרופיל · חיפוש 52 שדה-חיפוש · מיקוד 52 שדה-קלט · כוכבים 44 5 דירוג-כוכבים · טבלה 30 5 טבלה · ניאון 54 המשך · ניאון 54 עוד · ניאון 54 פעולה · באנר המחולל הבין את התיאור ובחר את האטומים לבד
// 🧬 אטומים שנבחרו: AuroraField · DonutChart · RadialGauge · MiniCalendar · LineSpark · ProfileCard · SearchField · GlowField · StarRating · DataGrid · NeonButton · NeonButton · NeonButton · CoinBanner
import '../dart-data-bs/auto/gen_nl_content.dart';
import '../dart-ui-bs/aurora_field.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/data_grid.dart';
import '../dart-ui-bs/donut_chart.dart';
import '../dart-ui-bs/glow_field.dart';
import '../dart-ui-bs/line_spark.dart';
import '../dart-ui-bs/mini_calendar.dart';
import '../dart-ui-bs/neon_button.dart';
import '../dart-ui-bs/profile_card.dart';
import '../dart-ui-bs/radial_gauge.dart';
import '../dart-ui-bs/search_field.dart';
import '../dart-ui-bs/star_rating.dart';
import 'package:flutter/material.dart';

class GenNlScreen extends StatefulWidget {
  const GenNlScreen({super.key});

  @override
  State<GenNlScreen> createState() => _GenNlScreenState();
}

class _GenNlScreenState extends State<GenNlScreen> {
  

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_nl_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          AuroraField(height: 200, bands: 60, speed: 2, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          DonutChart(height: 150, slices: 5, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          RadialGauge(height: 160, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          MiniCalendar(height: 150, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          LineSpark(height: 130, points: 20, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          ProfileCard(title: gen_nl_profile_title, sub: gen_nl_profile_sub, height: 230, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          SearchField(hint: gen_nl_searchfield_hint, height: 52, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          GlowField(hint: gen_nl_glowfield_hint, height: 52, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          StarRating(label: gen_nl_stars_label, height: 44, stars: 5, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          DataGrid(height: 30, rows: 5, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NeonButton(label: gen_nl_neon_label, height: 54, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, onPressed: () => _toast(gen_nl_neon_toast)),
          NeonButton(label: gen_nl_neon_label2, height: 54, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, onPressed: () => _toast(gen_nl_neon_toast2)),
          NeonButton(label: gen_nl_neon_label3, height: 54, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, onPressed: () => _toast(gen_nl_neon_toast3)),
          CoinBanner(coins: 0, sub: gen_nl_banner_sub),
          ],
        ),
      ),
    );
  }
}
