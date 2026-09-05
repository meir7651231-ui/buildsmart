// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: חתימת-אותיות עברית לשעה על השעון - כמה דקות עברו מחצות הלילה כתוב בגימטריה
// 🧬 בקשה: חתימת-אותיות עברית לשעה על השעון - כמה דקות עברו מחצות הלילה כתוב בגימטריה: · הירו 🧪 חתימת-אותיות עברית לשעה על השעון - כמה דקות עברו מחצות הלילה כתוב בגימטריה | יכולת שהוזמנה ולא היתה קיימת - הרכבתי אותה לבד מ-2 אטומים והוכחתי על 2 דוגמאות · כותרת תחנת ההוכחה - הדוגמאות שהוזמנו מדליקות את השרשרת · אטום ChipWrap חתימת-אותיות עברית לשעה על השעון - כמה דקות עברו מחצות הלילה כתוב בגימטריה: 07:45 / 13:05 · חישוב לדקות מחצות (timeToMin) · חישוב גימטריה מספר אותיות עבריות (gem) · כותרת תחנת הקלט החופשי - הקלידו כל ערך והשרשרת רצה חיה · שדה הקלידו ערך עבור חתימת-אותיות עברית לשעה · חישוב לדקות מחצות (timeToMin) · חישוב גימטריה מספר אותיות עבריות (gem) · באנר ההרכבה שמצאתי - timeToMin ⟵ gem - כל הדוגמאות עברו
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · ChipWrap · CaSubTitle · InlineTextRow · CoinBanner · RStat · RStat · RStat · RStat
import '../dart-data-bs/auto/gen_captimegematria_content.dart';
import '../dart-maor/gematria.dart';
import '../dart-maor/time-to-min.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/chip_wrap.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/inline_text_row.dart';
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
  String _t2 = '';

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
          CaSubTitle(gen_captimegematria_header_text),
          ChipWrap(options: const <String>[gen_captimegematria_chip_option, gen_captimegematria_chip_option2], selected: _t1, onSelect: (v) => setState(() => _t1 = v)),
          Row(children: [RStat(value: timeToMin(_t1).toString(), label: gen_captimegematria_stat_label)]),
          Row(children: [RStat(value: gem((num.tryParse((timeToMin(_t1).toString())) ?? double.nan), const ['', gen_captimegematria_calc_arg, gen_captimegematria_calc_arg2, gen_captimegematria_calc_arg3, gen_captimegematria_calc_arg4, gen_captimegematria_calc_arg5, gen_captimegematria_calc_arg6, gen_captimegematria_calc_arg7, gen_captimegematria_calc_arg8, gen_captimegematria_calc_arg9], const ['', gen_captimegematria_calc_arg10, gen_captimegematria_calc_arg11, gen_captimegematria_calc_arg12, gen_captimegematria_calc_arg13, gen_captimegematria_calc_arg14, gen_captimegematria_calc_arg15, gen_captimegematria_calc_arg16, gen_captimegematria_calc_arg17, gen_captimegematria_calc_arg18], const ['', gen_captimegematria_calc_arg19, gen_captimegematria_calc_arg20, gen_captimegematria_calc_arg21, gen_captimegematria_calc_arg22, gen_captimegematria_calc_arg23, gen_captimegematria_calc_arg24, gen_captimegematria_calc_arg25, gen_captimegematria_calc_arg26, gen_captimegematria_calc_arg27], const {'k1': gen_captimegematria_calc_arg28, 'k2': gen_captimegematria_calc_arg29, 'k3': gen_captimegematria_calc_arg30, 'k4': gen_captimegematria_calc_arg31, 'k5': 100, 'k6': 15, 'k7': 10}), label: gen_captimegematria_stat_label2)]),
          CaSubTitle(gen_captimegematria_header_text2),
          InlineTextRow(label: gen_captimegematria_textfield_label, hint: gen_captimegematria_textfield_hint, value: _t2, onChanged: (v) => setState(() => _t2 = v)),
          Row(children: [RStat(value: timeToMin(_t2).toString(), label: gen_captimegematria_stat_label3)]),
          Row(children: [RStat(value: gem((num.tryParse((timeToMin(_t2).toString())) ?? double.nan), const ['', gen_captimegematria_calc_arg32, gen_captimegematria_calc_arg33, gen_captimegematria_calc_arg34, gen_captimegematria_calc_arg35, gen_captimegematria_calc_arg36, gen_captimegematria_calc_arg37, gen_captimegematria_calc_arg38, gen_captimegematria_calc_arg39, gen_captimegematria_calc_arg40], const ['', gen_captimegematria_calc_arg41, gen_captimegematria_calc_arg42, gen_captimegematria_calc_arg43, gen_captimegematria_calc_arg44, gen_captimegematria_calc_arg45, gen_captimegematria_calc_arg46, gen_captimegematria_calc_arg47, gen_captimegematria_calc_arg48, gen_captimegematria_calc_arg49], const ['', gen_captimegematria_calc_arg50, gen_captimegematria_calc_arg51, gen_captimegematria_calc_arg52, gen_captimegematria_calc_arg53, gen_captimegematria_calc_arg54, gen_captimegematria_calc_arg55, gen_captimegematria_calc_arg56, gen_captimegematria_calc_arg57, gen_captimegematria_calc_arg58], const {'k1': gen_captimegematria_calc_arg59, 'k2': gen_captimegematria_calc_arg60, 'k3': gen_captimegematria_calc_arg61, 'k4': gen_captimegematria_calc_arg62, 'k5': 100, 'k6': 15, 'k7': 10}), label: gen_captimegematria_stat_label4)]),
          CoinBanner(coins: 0, sub: gen_captimegematria_banner_sub),
          ],
        ),
      ),
    );
  }
}
