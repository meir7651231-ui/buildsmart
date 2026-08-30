// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: רכיבים חיים - טקסט מונפש
// 🧬 בקשה: רכיבים חיים - טקסט מונפש: · הירו ✍️ טקסט מונפש | כיתוב חי שהמחולל מרכיב ממשפט · כותרת מספרים וטקסט · ספירה 60 1240 סה"כ הרשמות · הקלדה 50 בונים את העתיד עכשיו · כיתוב 60 עיצוב מדהים · רץ 44 חדשות רצות כאן בלולאה · באנר כל כיתוב כאן חי - נבחר ממילה בעברית
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · CountUp · TypeWriter · GradientText · Marquee · CoinBanner
import '../dart-data-bs/auto/gen_text_content.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/count_up.dart';
import '../dart-ui-bs/gradient_text.dart';
import '../dart-ui-bs/hero_card.dart';
import '../dart-ui-bs/marquee.dart';
import '../dart-ui-bs/type_writer.dart';
import 'package:flutter/material.dart';

class GenTextScreen extends StatefulWidget {
  const GenTextScreen({super.key});

  @override
  State<GenTextScreen> createState() => _GenTextScreenState();
}

class _GenTextScreenState extends State<GenTextScreen> {
  

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_text_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_text_card_glyph, title: gen_text_card_title, sub: gen_text_card_sub, onTap: () => _toast(gen_text_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CaSubTitle(gen_text_header_text),
          CountUp(label: gen_text_countup_label, height: 60, target: 1240, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          TypeWriter(text: gen_text_typewriter_text, height: 50, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          GradientText(text: gen_text_gtext_text, height: 60, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          Marquee(text: gen_text_marquee_text, height: 44, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_text_banner_sub),
          ],
        ),
      ),
    );
  }
}
