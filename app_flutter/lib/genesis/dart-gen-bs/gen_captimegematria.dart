// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: חתימת-אותיות עברית לשעה על השעון - כמה דקות עברו מחצות הלילה כתוב בגימטריה
// 🧬 בקשה: חתימת-אותיות עברית לשעה על השעון - כמה דקות עברו מחצות הלילה כתוב בגימטריה: · הירו 🧪 חתימת-אותיות עברית לשעה על השעון - כמה דקות עברו מחצות הלילה כתוב בגימטריה | יכולת שהוזמנה ולא היתה קיימת - הרכבתי אותה לבד מ-2 אטומים והוכחתי על 2 דוגמאות · אטום ChipWrap חתימת-אותיות עברית לשעה על השעון - כמה דקות עברו מחצות הלילה כתוב בגימטריה: 07:45 / 13:05 · חישוב לדקות מחצות (timeToMin) · חישוב גימטריה מספר אותיות עבריות (gem) · באנר ההרכבה שמצאתי - timeToMin ⟵ gem - כל הדוגמאות עברו
// 🧬 אטומים שנבחרו: HeroCard · ChipWrap · CoinBanner · RStat · RStat
import '../dart-data-bs/auto/gen_captimegematria_content.dart';
import '../dart-maor/gematria.dart';
import '../dart-maor/time-to-min.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/chip_wrap.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/hero_card.dart';
import 'package:flutter/material.dart';

class GenCaptimegematriaScreen extends StatefulWidget {
  const GenCaptimegematriaScreen({super.key});

  @override
  State<GenCaptimegematriaScreen> createState() => _GenCaptimegematriaScreenState();
}

class _GenCaptimegematriaScreenState extends State<GenCaptimegematriaScreen> {
  String _t1 = '';

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_captimegematria_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_captimegematria_card_glyph, title: gen_captimegematria_card_title, sub: gen_captimegematria_card_sub, onTap: () => _toast(gen_captimegematria_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          ChipWrap(options: const <String>[gen_captimegematria_chip_option, gen_captimegematria_chip_option2], selected: _t1, onSelect: (v) => setState(() => _t1 = v)),
          Row(children: [RStat(value: timeToMin(_t1).toString(), label: gen_captimegematria_stat_label)]),
          Row(children: [RStat(value: gem((num.tryParse((timeToMin(_t1).toString())) ?? double.nan)), label: gen_captimegematria_stat_label2)]),
          CoinBanner(coins: 0, sub: gen_captimegematria_banner_sub),
          ],
        ),
      ),
    );
  }
}
