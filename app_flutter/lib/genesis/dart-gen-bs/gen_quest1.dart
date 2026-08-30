// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: עולם משחק שלם - חדר 1
// 🧬 בקשה: עולם משחק שלם - חדר 1: · הירו 🎯 עולם משחק שלם של מסע בריחה - חדרים שמובילים זה אל זה חידות חיות שמגיבות לשחקן ושערים נסתרים בדרך אל היציאה | מטרה אחת קיבלתי - את המבנה האטומים והחיבורים בחרתי לבד · כותרת תחנת הבחירה - הדאטה מתוך האטום והבחירה מוזרמת למנוע · אטום ChipWrap סטטוס בא במסירת חלוקה קדימה בלבד: pickup / enroute / delivered · חישוב סטטוס בא במסירת חלוקה קדימה בלבד (advanceStatus) · כותרת תחנת ההזנה - כל הקלדה מפעילה שרשרת מנועים · שדה הקלידו ערך עבור סיווג אזור של מספר טלפון · חישוב סיווג אזור של מספר טלפון (phoneRegion) · חישוב תקינות של ארגון (isValidSlug) · חישוב מפתח פיצול של תרומה מסלול (purposeKeyOf) · ניווט quest2 השער אל החדר הבא | המסע ממשיך · באנר מטרה אחת קיבלתי מהבעלים - את כל השאר תכננתי בחרתי וחיווטתי לבד מהמדף החי
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · ChipWrap · CaSubTitle · InlineTextRow · HeroCard · CoinBanner · RStat · RStat · RStat · RStat
import '../dart-data-bs/auto/gen_quest1_content.dart';
import '../dart-maor/advance-status.dart';
import '../dart-maor/is-valid-slug.dart';
import '../dart-maor/phone-region.dart';
import '../dart-maor/purpose-key-of.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/chip_wrap.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/inline_text_row.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/hero_card.dart';
import 'gen_quest.dart';
import 'package:flutter/material.dart';

class GenQuest1Screen extends StatefulWidget {
  const GenQuest1Screen({super.key});

  @override
  State<GenQuest1Screen> createState() => _GenQuest1ScreenState();
}

class _GenQuest1ScreenState extends State<GenQuest1Screen> {
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
        appBar: AppBar(title: Text(gen_quest1_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_quest1_card_glyph, title: gen_quest1_card_title, sub: gen_quest1_card_sub, onTap: () => _toast(gen_quest1_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CaSubTitle(gen_quest1_header_text),
          ChipWrap(options: const <String>[gen_quest1_chip_option, gen_quest1_chip_option2, gen_quest1_chip_option3], selected: _t1, onSelect: (v) => setState(() => _t1 = v)),
          Row(children: [RStat(value: advanceStatus(_t1), label: gen_quest1_stat_label)]),
          CaSubTitle(gen_quest1_header_text2),
          InlineTextRow(label: gen_quest1_textfield_label, hint: gen_quest1_textfield_hint, value: _t2, onChanged: (v) => setState(() => _t2 = v)),
          Row(children: [RStat(value: phoneRegion(_t2), label: gen_quest1_stat_label2)]),
          Row(children: [RStat(value: isValidSlug((phoneRegion(_t2))).toString(), label: gen_quest1_stat_label3)]),
          Row(children: [RStat(value: purposeKeyOf((isValidSlug((phoneRegion(_t2))).toString())), label: gen_quest1_stat_label4)]),
          HeroCard(glyph: gen_quest1_card_glyph2, title: gen_quest1_card_title2, sub: gen_quest1_card_sub2, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GenQuestScreen())), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CoinBanner(coins: 0, sub: gen_quest1_banner_sub),
          ],
        ),
      ),
    );
  }
}
