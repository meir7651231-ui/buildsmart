// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: רכיבים חיים - תפריטים ומדיה
// 🧬 בקשה: רכיבים חיים - תפריטים ומדיה: · הירו 🎬 תפריטים ומדיה | גיליון קרוסלה ואווטארים ממשפט · כותרת תפריטים · מגירה 180 גיליון תחתון | פעולות נוספות · חיווי 56 נשמר בהצלחה · כותרת מדיה · צף 60 תפריט צף · פרצופים 56 8 משתתפים · קרוסלה 150 שקופיות: ראשונה / שנייה / שלישית · באנר כל רכיב כאן חי - נבחר ממילה בעברית
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · SlideSheet · SnackToast · CaSubTitle · FabMenu · AvatarStack · CarouselDeck · CoinBanner
import '../dart-data-bs/auto/gen_media_content.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/avatar_stack.dart';
import '../dart-ui-bs/carousel_deck.dart';
import '../dart-ui-bs/fab_menu.dart';
import '../dart-ui-bs/hero_card.dart';
import '../dart-ui-bs/slide_sheet.dart';
import '../dart-ui-bs/snack_toast.dart';
import 'package:flutter/material.dart';

class GenMediaScreen extends StatefulWidget {
  const GenMediaScreen({super.key});

  @override
  State<GenMediaScreen> createState() => _GenMediaScreenState();
}

class _GenMediaScreenState extends State<GenMediaScreen> {
  

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_media_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_media_card_glyph, title: gen_media_card_title, sub: gen_media_card_sub, onTap: () => _toast(gen_media_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CaSubTitle(gen_media_header_text),
          SlideSheet(title: gen_media_sheet_title, sub: gen_media_sheet_sub, height: 180, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          SnackToast(label: gen_media_snack_label, height: 56, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_media_header_text2),
          FabMenu(height: 60, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          AvatarStack(height: 56, faces: 8, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CarouselDeck(labels: const <String>[gen_media_carousel_option, gen_media_carousel_option2, gen_media_carousel_option3], height: 150, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_media_banner_sub),
          ],
        ),
      ),
    );
  }
}
