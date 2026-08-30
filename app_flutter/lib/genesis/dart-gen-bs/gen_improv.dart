// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: יכולת מאולתרת - שרשרת חמישה
// 🧬 בקשה: יכולת מאולתרת - שרשרת חמישה: · הירו 🎲 יכולת מאולתרת - חמישה אטומים שהגרלתי וחיברתי לבד | תבחר 5 אטומים רנדלמיים תחבר בין ותוציא את היכולת הכי טוב וחדשה שלה · כותרת שרשרת חיה - חמישה אטומי לוגיקה מחוברים - פלט כל שלב מוזרם לשלב הבא · אטום ChipWrap סטטוס בא במסירת חלוקה קדימה בלבד: pickup / enroute / delivered · חישוב סטטוס בא במסירת חלוקה קדימה בלבד (advanceStatus) · חישוב מפתח חודש (monthKey) · חישוב פניית תא לאינדקס עמודה בסיס (colRefToIndex) · חישוב אם שפת אתר (isRtlLang) · חישוב סיווג אזור של מספר טלפון (phoneRegion) · באנר הגרלתי חמישה אטומי לוגיקה ושרשרתי אותם לצינור אחד - יכולת שלא היתה בשום מסך - מחר שרשרת חדשה
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · ChipWrap · CoinBanner · RStat · RStat · RStat · RStat · RStat
import '../dart-data-bs/auto/gen_improv_content.dart';
import '../dart-maor/advance-status.dart';
import '../dart-maor/col-ref-to-index.dart';
import '../dart-maor/is-rtl-lang.dart';
import '../dart-maor/month-key.dart';
import '../dart-maor/phone-region.dart';
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
          Row(children: [RStat(value: monthKey((advanceStatus(_t1))), label: gen_improv_stat_label2)]),
          Row(children: [RStat(value: colRefToIndex((monthKey((advanceStatus(_t1))))).toString(), label: gen_improv_stat_label3)]),
          Row(children: [RStat(value: isRtlLang((colRefToIndex((monthKey((advanceStatus(_t1))))).toString())).toString(), label: gen_improv_stat_label4)]),
          Row(children: [RStat(value: phoneRegion((isRtlLang((colRefToIndex((monthKey((advanceStatus(_t1))))).toString())).toString())), label: gen_improv_stat_label5)]),
          CoinBanner(coins: 0, sub: gen_improv_banner_sub),
          ],
        ),
      ),
    );
  }
}
