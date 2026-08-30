// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: רכיבים חיים - קלט מתקדם
// 🧬 בקשה: רכיבים חיים - קלט מתקדם: · הירו 🔢 קלט מתקדם | קוד טווח וצבעים ממשפט · כותרת קלט · קוד 48 6 קוד אימות · טווח 30 טווח מחירים · צבעים 40 6 בחר צבע · תיוג 34 תיוג: עברית / עיצוב / פלאטר · באנר כל קלט כאן חי - נבחר ממילה בעברית
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · OtpInput · DualRange · ColorSwatchRow · TagInput · CoinBanner
import '../dart-data-bs/auto/gen_input9_content.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/color_swatch.dart';
import '../dart-ui-bs/dual_range.dart';
import '../dart-ui-bs/hero_card.dart';
import '../dart-ui-bs/otp_input.dart';
import '../dart-ui-bs/tag_input.dart';
import 'package:flutter/material.dart';

class GenInput9Screen extends StatefulWidget {
  const GenInput9Screen({super.key});

  @override
  State<GenInput9Screen> createState() => _GenInput9ScreenState();
}

class _GenInput9ScreenState extends State<GenInput9Screen> {
  

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_input9_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_input9_card_glyph, title: gen_input9_card_title, sub: gen_input9_card_sub, onTap: () => _toast(gen_input9_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CaSubTitle(gen_input9_header_text),
          OtpInput(height: 48, boxes: 6, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          DualRange(height: 30, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          ColorSwatchRow(height: 40, swatches: 6, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          TagInput(labels: const <String>[gen_input9_taginput_option, gen_input9_taginput_option2, gen_input9_taginput_option3], height: 34, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_input9_banner_sub),
          ],
        ),
      ),
    );
  }
}
