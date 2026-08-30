// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: רכיבים חיים - גרפים
// 🧬 בקשה: רכיבים חיים - גרפים: · הירו 📊 גרפים חיים | תרשימים שהמחולל מרכיב ממשפט · כותרת נתונים חזותיים · עמודות 150 7 תרשים עמודות · מגמה 130 20 קו מגמה · עוגה 170 5 תרשים טבעת · מד 160 מד ביצועים · חום 150 8 מפת חום · באנר כל גרף כאן חי - נבחר ממילה בעברית
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · BarChart · LineSpark · DonutChart · RadialGauge · HeatGrid · CoinBanner
import '../dart-data-bs/auto/gen_charts_content.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/bar_chart.dart';
import '../dart-ui-bs/donut_chart.dart';
import '../dart-ui-bs/heat_grid.dart';
import '../dart-ui-bs/hero_card.dart';
import '../dart-ui-bs/line_spark.dart';
import '../dart-ui-bs/radial_gauge.dart';
import 'package:flutter/material.dart';

class GenChartsScreen extends StatefulWidget {
  const GenChartsScreen({super.key});

  @override
  State<GenChartsScreen> createState() => _GenChartsScreenState();
}

class _GenChartsScreenState extends State<GenChartsScreen> {
  

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_charts_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_charts_card_glyph, title: gen_charts_card_title, sub: gen_charts_card_sub, onTap: () => _toast(gen_charts_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CaSubTitle(gen_charts_header_text),
          BarChart(height: 150, bars: 7, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          LineSpark(height: 130, points: 20, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          DonutChart(height: 170, slices: 5, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          RadialGauge(height: 160, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          HeatGrid(height: 150, cells: 8, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_charts_banner_sub),
          ],
        ),
      ),
    );
  }
}
