// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: רכיבים חיים - טעינה ומעברים
// 🧬 בקשה: רכיבים חיים - טעינה ומעברים: · הירו ⏳ טעינה ומעברים | מצבי-טעינה וכניסות שהמחולל מרכיב ממשפט · כותרת מצבי טעינה · טוען 60 מסתובב · טבעת 90 התקדמות · נקודות 44 נקודות קופצות · כותרת מצב ריק ומעברים · ריק 160 אין עדיין נתונים | הוסיפו פריט ראשון להתחלה · מדורג 44 5 רשימה נכנסת בגלים · חשיפה 130 כרטיס נחשף | כניסה מונפשת בסקייל · באנר כל מצב כאן חי - נבחר ממילה בעברית
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · OrbitSpinner · ProgressRing · DotsLoader · CaSubTitle · AnimatedEmpty · StaggerList · RevealCard · CoinBanner
import '../dart-data-bs/auto/gen_states_content.dart';
import '../dart-ui-bs/animated_empty.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/dots_loader.dart';
import '../dart-ui-bs/hero_card.dart';
import '../dart-ui-bs/orbit_spinner.dart';
import '../dart-ui-bs/progress_ring.dart';
import '../dart-ui-bs/reveal_card.dart';
import '../dart-ui-bs/stagger_list.dart';
import 'package:flutter/material.dart';

class GenStatesScreen extends StatefulWidget {
  const GenStatesScreen({super.key});

  @override
  State<GenStatesScreen> createState() => _GenStatesScreenState();
}

class _GenStatesScreenState extends State<GenStatesScreen> {
  

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_states_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_states_card_glyph, title: gen_states_card_title, sub: gen_states_card_sub, onTap: () => _toast(gen_states_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CaSubTitle(gen_states_header_text),
          OrbitSpinner(height: 60, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight),
          ProgressRing(height: 90, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          DotsLoader(height: 44, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight),
          CaSubTitle(gen_states_header_text2),
          AnimatedEmpty(icon: Icons.tune, title: gen_states_empty_title, sub: gen_states_empty_sub, height: 160, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          StaggerList(height: 44, rows: 5, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          RevealCard(title: gen_states_reveal_title, sub: gen_states_reveal_sub, height: 130, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_states_banner_sub),
          ],
        ),
      ),
    );
  }
}
