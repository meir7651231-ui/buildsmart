// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: רכיבים חיים - ניווט ודשבורד
// 🧬 בקשה: רכיבים חיים - ניווט ודשבורד: · הירו 🧭 ניווט ודשבורד | שלבים צירים ומקטעים ממשפט · כותרת ניווט · מקטעים 44 תצוגה: יומי / שבועי / חודשי · פירורים 40 נתיב: בית / מוצרים / פרטים · כותרת התקדמות · שלבים 60 4 שלבי הרשמה · ציר 44 4 אירועים אחרונים · פילוח 14 5 פילוח דירוגים · באנר כל רכיב כאן חי - נבחר ממילה בעברית
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · SegPicker · BreadcrumbTrail · CaSubTitle · StepFlow · Timeline · RatingBars · CoinBanner
import '../dart-data-bs/auto/gen_navflow_content.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/breadcrumb_trail.dart';
import '../dart-ui-bs/hero_card.dart';
import '../dart-ui-bs/rating_bars.dart';
import '../dart-ui-bs/seg_picker.dart';
import '../dart-ui-bs/step_flow.dart';
import '../dart-ui-bs/timeline_flow.dart';
import 'package:flutter/material.dart';

class GenNavflowScreen extends StatefulWidget {
  const GenNavflowScreen({super.key});

  @override
  State<GenNavflowScreen> createState() => _GenNavflowScreenState();
}

class _GenNavflowScreenState extends State<GenNavflowScreen> {
  

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_navflow_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_navflow_card_glyph, title: gen_navflow_card_title, sub: gen_navflow_card_sub, onTap: () => _toast(gen_navflow_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CaSubTitle(gen_navflow_header_text),
          SegPicker(labels: const <String>[gen_navflow_segment_option, gen_navflow_segment_option2, gen_navflow_segment_option3], height: 44, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          BreadcrumbTrail(labels: const <String>[gen_navflow_crumbs_option, gen_navflow_crumbs_option2, gen_navflow_crumbs_option3], height: 40, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_navflow_header_text2),
          StepFlow(height: 60, steps: 4, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          Timeline(height: 44, events: 4, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          RatingBars(height: 14, bars: 5, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_navflow_banner_sub),
          ],
        ),
      ),
    );
  }
}
