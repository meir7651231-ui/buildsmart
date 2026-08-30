// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: רכיבים חיים - וידג'טים מורכבים
// 🧬 בקשה: רכיבים חיים - וידג'טים מורכבים: · הירו 🧩 וידג'טים מורכבים | טאבים אקורדיון והיפוך שהמחולל מרכיב ממשפט · כותרת ניווט ותוכן · לשוניות 44 לשוניות: בית / פרופיל / הגדרות · אקורדיון 48 פאנלים: שאלה ראשונה / שאלה שנייה / שאלה שלישית · כותרת אינטראקציה · היפוך 120 הקש להיפוך | הצד השני · בועות 40 תגיות: עברית / עיצוב / הנפשה / פלאטר · עדכון 56 3 התראות · כותרת נתונים · טבלה 30 5 טבלה מונפשת · באנר כל וידג'ט כאן חי ומגיב - נבחר ממילה בעברית
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · AnimatedTabs · AccordionPanel · CaSubTitle · FlipTile · ChipCloud · NotifyBadge · CaSubTitle · DataGrid · CoinBanner
import '../dart-data-bs/auto/gen_widgets_content.dart';
import '../dart-ui-bs/accordion_panel.dart';
import '../dart-ui-bs/animated_tabs.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/chip_cloud.dart';
import '../dart-ui-bs/data_grid.dart';
import '../dart-ui-bs/flip_tile.dart';
import '../dart-ui-bs/hero_card.dart';
import '../dart-ui-bs/notify_badge.dart';
import 'package:flutter/material.dart';

class GenWidgetsScreen extends StatefulWidget {
  const GenWidgetsScreen({super.key});

  @override
  State<GenWidgetsScreen> createState() => _GenWidgetsScreenState();
}

class _GenWidgetsScreenState extends State<GenWidgetsScreen> {
  

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_widgets_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_widgets_card_glyph, title: gen_widgets_card_title, sub: gen_widgets_card_sub, onTap: () => _toast(gen_widgets_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CaSubTitle(gen_widgets_header_text),
          AnimatedTabs(labels: const <String>[gen_widgets_tabs_option, gen_widgets_tabs_option2, gen_widgets_tabs_option3], height: 44, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          AccordionPanel(labels: const <String>[gen_widgets_accordion_option, gen_widgets_accordion_option2, gen_widgets_accordion_option3], height: 48, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_widgets_header_text2),
          FlipTile(front: gen_widgets_flip_front, back: gen_widgets_flip_back, height: 120, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          ChipCloud(labels: const <String>[gen_widgets_chips_option, gen_widgets_chips_option2, gen_widgets_chips_option3, gen_widgets_chips_option4], height: 40, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NotifyBadge(icon: Icons.tune, height: 56, items: 3, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_widgets_header_text3),
          DataGrid(height: 30, rows: 5, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_widgets_banner_sub),
          ],
        ),
      ),
    );
  }
}
