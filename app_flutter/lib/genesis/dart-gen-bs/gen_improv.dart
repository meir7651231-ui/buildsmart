// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: יכולת מאולתרת - שרשרת חמישה
// 🧬 בקשה: יכולת מאולתרת - שרשרת חמישה: · הירו 🎲 יכולת מאולתרת - חמישה אטומים שהגרלתי וחיברתי לבד | תבחר 5 אטומים רנדלמיים תחבר בין ותוציא את היכולת הכי טוב וחדשה שלה · כותרת ערבוב שלושת המדפים - דאטה אקראית מהמדף מוזרמת לשרשרת מנועים אקראית · דאטה ORDER ORDER · חישוב מפתח חודש (monthKey) · חישוב אם שפת אתר (isRtlLang) · חישוב פניית תא לאינדקס עמודה בסיס (colRefToIndex) · חישוב אם מחרוזת יא ערך דגשה בטוח שם צבע (isSafeAccent) · חישוב תקינות של ארגון (isValidSlug) · באנר הגרלתי אטום-דאטה ושרשרת-מנועים משני מדפים שונים וחיברתי אותם לצינור חי אחד - מחר הגרלה חדשה
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · ChipWrap · CoinBanner · RStat · RStat · RStat · RStat · RStat
import '../dart-data-bs/auto/gen_improv_content.dart';
import '../dart-data-maor/advance-status-data.dart';
import '../dart-maor/col-ref-to-index.dart';
import '../dart-maor/is-rtl-lang.dart';
import '../dart-maor/is-safe-accent.dart';
import '../dart-maor/is-valid-slug.dart';
import '../dart-maor/month-key.dart';
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
          ChipWrap(options: ORDER, selected: _t1, onSelect: (v) => setState(() => _t1 = v)),
          Row(children: [RStat(value: monthKey(_t1), label: gen_improv_stat_label)]),
          Row(children: [RStat(value: isRtlLang((monthKey(_t1))).toString(), label: gen_improv_stat_label2)]),
          Row(children: [RStat(value: colRefToIndex((isRtlLang((monthKey(_t1))).toString())).toString(), label: gen_improv_stat_label3)]),
          Row(children: [RStat(value: isSafeAccent((colRefToIndex((isRtlLang((monthKey(_t1))).toString())).toString())).toString(), label: gen_improv_stat_label4)]),
          Row(children: [RStat(value: isValidSlug((isSafeAccent((colRefToIndex((isRtlLang((monthKey(_t1))).toString())).toString())).toString())).toString(), label: gen_improv_stat_label5)]),
          CoinBanner(coins: 0, sub: gen_improv_banner_sub),
          ],
        ),
      ),
    );
  }
}
