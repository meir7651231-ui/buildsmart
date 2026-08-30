// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הירו 🏗️ האפליקציה שלי | נבנתה מאפיון-חופשי
// 🧬 בקשה: הירו 🏗️ האפליקציה שלי | נבנתה מאפיון-חופשי · ניווט app_ent1 🗂️ פרויקט · ניווט app_ent2 🗂️ לקוח · ניווט app_ent3 🗂️ משימה · ניווט app_scr4 📊 דשבורד הנהלה עם פרויקטים · ניווט app_scr5 📊 לוח זמנים גאנט עם משימות · ניווט app_scr6 📊 דוח יומי עם מזג אוויר · באנר 6 מסכים · המחולל הרכיב אפליקציה שלמה מהמדף
// 🧬 אטומים שנבחרו: HeroCard · HeroCard · HeroCard · HeroCard · HeroCard · HeroCard · CoinBanner
import '../dart-data-bs/auto/gen_app_hub_content.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/hero_card.dart';
import 'gen_app_ent1.dart';
import 'gen_app_ent2.dart';
import 'gen_app_ent3.dart';
import 'gen_app_scr4.dart';
import 'gen_app_scr5.dart';
import 'gen_app_scr6.dart';
import 'package:flutter/material.dart';

class GenAppHubScreen extends StatefulWidget {
  const GenAppHubScreen({super.key});

  @override
  State<GenAppHubScreen> createState() => _GenAppHubScreenState();
}

class _GenAppHubScreenState extends State<GenAppHubScreen> {
  

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_app_hub_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_app_hub_card_glyph, title: gen_app_hub_card_title, sub: gen_app_hub_card_sub, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GenAppEnt1Screen())), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          HeroCard(glyph: gen_app_hub_card_glyph2, title: gen_app_hub_card_title2, sub: gen_app_hub_card_sub2, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GenAppEnt2Screen())), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          HeroCard(glyph: gen_app_hub_card_glyph3, title: gen_app_hub_card_title3, sub: gen_app_hub_card_sub3, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GenAppEnt3Screen())), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          HeroCard(glyph: gen_app_hub_card_glyph4, title: gen_app_hub_card_title4, sub: gen_app_hub_card_sub4, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GenAppScr4Screen())), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          HeroCard(glyph: gen_app_hub_card_glyph5, title: gen_app_hub_card_title5, sub: gen_app_hub_card_sub5, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GenAppScr5Screen())), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          HeroCard(glyph: gen_app_hub_card_glyph6, title: gen_app_hub_card_title6, sub: gen_app_hub_card_sub6, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GenAppScr6Screen())), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CoinBanner(coins: 6, sub: gen_app_hub_banner_sub),
          ],
        ),
      ),
    );
  }
}
