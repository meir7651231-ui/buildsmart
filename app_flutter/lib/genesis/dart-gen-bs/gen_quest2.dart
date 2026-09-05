// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: עולם משחק שלם - חדר 2
// 🧬 בקשה: עולם משחק שלם - חדר 2: · הירו 🎯 עולם משחק שלם של מסע בריחה - חדרים שמובילים זה אל זה חידות חיות שמגיבות לשחקן ושערים נסתרים בדרך אל היציאה | מטרה אחת קיבלתי - את המבנה האטומים והחיבורים בחרתי לבד · כותרת בורר המנועים - הבחירה מחליפה את המנוע החי המוצג · בחירה מגיעים כפרמטרים או כותב כי או פרש ימים: מגיעים כפרמטרים / כותב כי / פרש ימים · חישוב מגיעים כפרמטרים אין טהור דטרמיניסטי (validDateRange) · חישוב כותב כי וא מבוסס (isoLocal) · חישוב פרש ימים קלנדרי בין שני תאריכים חסין בונה חצות משני (daysBetweenDst) · מתג 🔓 מתג השער - פתיחתו חושפת מנוע חבוי · חישוב קופסה חיווט לוח עברי מלבנים עיוורות דאטה כרעת טוהר (hebMonthHeWired) · ניווט quest1 חזרה אל תחילת המסע | המסע ממשיך · באנר מטרה אחת קיבלתי מהבעלים - את כל השאר תכננתי בחרתי וחיווטתי לבד מהמדף החי
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · UnitSegmentToggle · SwitchRow · HeroCard · CoinBanner · RStat · RStat · RStat · RStat
import '../dart-data-bs/auto/gen_quest2_content.dart';
import '../dart-maor/heb-cal-box.dart';
import '../dart-maor/iso-local.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/auto/switch_row.dart';
import '../dart-ui-bs/hero_card.dart';
import '../dart-ui-bs/screens__lipskey_product_sheet/unit_segment_toggle.dart';
import '../dart/days_between_dst.dart';
import '../dart/valid_date_range.dart';
import 'gen_quest1.dart';
import 'package:flutter/material.dart';

class GenQuest2Screen extends StatefulWidget {
  const GenQuest2Screen({super.key});

  @override
  State<GenQuest2Screen> createState() => _GenQuest2ScreenState();
}

class _GenQuest2ScreenState extends State<GenQuest2Screen> {
  int _n1 = 0;
  bool _v2 = false;

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_quest2_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_quest2_card_glyph, title: gen_quest2_card_title, sub: gen_quest2_card_sub, onTap: () => _toast(gen_quest2_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CaSubTitle(gen_quest2_header_text),
          UnitSegmentToggle(options: const <({String label, bool enabled})>[(label: gen_quest2_radio_option, enabled: true), (label: gen_quest2_radio_option2, enabled: true), (label: gen_quest2_radio_option3, enabled: true)], selectedIndex: _n1, onSelect: (v) => setState(() => _n1 = v), selectedBgColor: BsTokens.cardLight, selectedFgColor: BsTokens.inkLight, enabledFgColor: BsTokens.inkLight, disabledFgColor: BsTokens.inkLight, borderColor: BsTokens.divider),
          IndexedStack(index: _n1, children: [Row(children: [RStat(value: validDateRange(DateTime.now(), DateTime.now()).toString(), label: gen_quest2_stat_label)]), Row(children: [RStat(value: isoLocal(DateTime.now()), label: gen_quest2_stat_label2)]), Row(children: [RStat(value: daysBetweenDst(DateTime.now(), DateTime.now()).toString(), label: gen_quest2_stat_label3)])]),
          SwitchRow(label: gen_quest2_switch_label, value: _v2, onChanged: (v) => setState(() => _v2 = v)),
          if (_v2) Row(children: [RStat(value: hebMonthHeWired(DateTime.now()), label: gen_quest2_stat_label4)]),
          HeroCard(glyph: gen_quest2_card_glyph2, title: gen_quest2_card_title2, sub: gen_quest2_card_sub2, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GenQuest1Screen())), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CoinBanner(coins: 0, sub: gen_quest2_banner_sub),
          ],
        ),
      ),
    );
  }
}
