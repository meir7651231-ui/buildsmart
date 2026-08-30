// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: רכיבים חיים - ויזואליזציה מתקדמת
// 🧬 בקשה: רכיבים חיים - ויזואליזציה מתקדמת: · הירו 🗺️ ויזואליזציה מתקדמת | לוח גאנט ומכ"ם ממשפט · כותרת נתונים ולוח · לוח 150 לוח חודשי · גאנט 22 5 תרשים גאנט · רדאר 170 6 מכ"ם ביצועים · פסקול 90 24 גל אודיו · באנר כל תרשים כאן חי - נבחר ממילה בעברית
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · MiniCalendar · GanttBar · RadarChart · WaveformBars · CoinBanner
import '../dart-data-bs/auto/gen_viz_content.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/gantt_bar.dart';
import '../dart-ui-bs/hero_card.dart';
import '../dart-ui-bs/mini_calendar.dart';
import '../dart-ui-bs/radar_chart.dart';
import '../dart-ui-bs/waveform_bars.dart';
import 'package:flutter/material.dart';

class GenVizScreen extends StatefulWidget {
  const GenVizScreen({super.key});

  @override
  State<GenVizScreen> createState() => _GenVizScreenState();
}

class _GenVizScreenState extends State<GenVizScreen> {
  

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_viz_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_viz_card_glyph, title: gen_viz_card_title, sub: gen_viz_card_sub, onTap: () => _toast(gen_viz_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CaSubTitle(gen_viz_header_text),
          MiniCalendar(height: 150, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          GanttBar(height: 22, rows: 5, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          RadarChart(height: 170, axes: 6, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          WaveformBars(height: 90, bars: 24, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_viz_banner_sub),
          ],
        ),
      ),
    );
  }
}
