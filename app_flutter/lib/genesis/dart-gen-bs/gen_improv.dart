// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: יכולת מאולתרת - צינור חי
// 🧬 בקשה: יכולת מאולתרת - צינור חי: · הירו 🎲 יכולת מאולתרת - חמישה אטומים שהגרלתי וחיברתי לבד | תבחר 5 אטומים רנדלמיים תחבר בין ותוציא את היכולת הכי טוב וחדשה שלה · כותרת צינור חי - הדאטה מתוך האטום עצמו והבחירה מוזרמת לפונקציה · אטום ChipWrap סטטוס בא במסירת חלוקה קדימה בלבד: pickup / enroute / delivered · חישוב סטטוס בא במסירת חלוקה קדימה בלבד · באנר מצאתי לבד פונקציה עם תחום ערכים מוצהר חילצתי את הדאטה שלה וחיברתי צינור - בחירה מחושבת לתוצאה
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · ChipWrap · CoinBanner · RStat
import '../dart-data-bs/auto/gen_improv_content.dart';
import '../dart-maor/advance-status.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/chip_wrap.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/hero_card.dart';
import 'package:flutter/material.dart';

class GenImprovScreen extends StatefulWidget {
  const GenImprovScreen({super.key});

  @override
  State<GenImprovScreen> createState() => _GenImprovScreenState();
}

class _GenImprovScreenState extends State<GenImprovScreen> {
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
        appBar: AppBar(title: Text(gen_improv_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_improv_card_glyph, title: gen_improv_card_title, sub: gen_improv_card_sub, onTap: () => _toast(gen_improv_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CaSubTitle(gen_improv_header_text),
          ChipWrap(options: const <String>[gen_improv_chip_option, gen_improv_chip_option2, gen_improv_chip_option3], selected: _t1, onSelect: (v) => setState(() => _t1 = v)),
          Row(children: [RStat(value: advanceStatus(_t1), label: gen_improv_stat_label)]),
          CoinBanner(coins: 0, sub: gen_improv_banner_sub),
          ],
        ),
      ),
    );
  }
}
