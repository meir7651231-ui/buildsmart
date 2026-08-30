// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: רכיבים חיים - טפסים ובוררים
// 🧬 בקשה: רכיבים חיים - טפסים ובוררים: · הירו 📋 טפסים ובוררים | מדרגה נפתח ומקלדת ממשפט · כותרת בוררים · מדרגה 40 3 כמות פריטים · נפתח 52 בחר: אפשרות ראשונה / שנייה / שלישית · תאריך 60 7 בחר תאריך · מקלדת 240 מקלדת ספרות · באנר כל רכיב כאן חי - נבחר ממילה בעברית
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · NumberStepper · DropSelect · DatePills · PinPad · CoinBanner
import '../dart-data-bs/auto/gen_form9_content.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/date_pills.dart';
import '../dart-ui-bs/dropdown_menu.dart';
import '../dart-ui-bs/hero_card.dart';
import '../dart-ui-bs/number_stepper.dart';
import '../dart-ui-bs/pin_pad.dart';
import 'package:flutter/material.dart';

class GenForm9Screen extends StatefulWidget {
  const GenForm9Screen({super.key});

  @override
  State<GenForm9Screen> createState() => _GenForm9ScreenState();
}

class _GenForm9ScreenState extends State<GenForm9Screen> {
  

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_form9_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_form9_card_glyph, title: gen_form9_card_title, sub: gen_form9_card_sub, onTap: () => _toast(gen_form9_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CaSubTitle(gen_form9_header_text),
          NumberStepper(label: gen_form9_numstep_label, height: 40, target: 3, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          DropSelect(labels: const <String>[gen_form9_dropdown_option, gen_form9_dropdown_option2, gen_form9_dropdown_option3], height: 52, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          DatePills(height: 60, days: 7, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          PinPad(height: 240, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_form9_banner_sub),
          ],
        ),
      ),
    );
  }
}
