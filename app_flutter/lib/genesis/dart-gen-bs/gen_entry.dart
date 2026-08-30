// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: המחולל
// 🧬 בקשה: המחולל: · הירו 🧬 המחולל של המחצב | דיוקן עצמי חי - את כל ההדגמות כאן בחרתי בעצמי · כותרת המפעל במספרים - עדכון חי מהאטלס · נתון ⚛️ 381 לבנים ויזואליות על המדף · נתון 🧠 445 אטומי לוגיקה פעילים · נתון 🖼️ 79 מסכים הורכבו מחדש · כותרת גשר הלוגיקה - פונקציה שבחרתי מהמדף · חישוב קופסה חיווט לוח עברי מלבנים עיוורות דאטה כרעת טוהר · כותרת יכולת מורכבת - שדה מזין חישוב חי · שדה הקלידו ערך עבור דין אדר · חישוב דין אדר · כותרת חיבור אטום לאטום - הבחירה מחליפה את המוצג · בחירה מתג או שדה או נתון: מתג / שדה / נתון · מתג מתג · שדה שדה · נתון נתון · כותרת חיבור בין מסכים - המסכים שיצרתי מבקשות · ניווט business פרופיל עסק | נוצר מבקשה בעברית - הקישו לפתיחה · ניווט capclockcalendar מסע-בזמן של השעון - שעת-יממה נהפכת לתאריך-תצוגה כשכל דקה מחצות נספרת כיום שלם בלוח | נוצר מבקשה בעברית - הקישו לפתיחה · ניווט capmailphone שחזור מספר טלפון לתצוגה ישראלית תקנית מתוך שורה שהגיעה עטופה בקידוד-מייל ישן | נוצר מבקשה בעברית - הקישו לפתיחה · ניווט captimegematria חתימת-אותיות עברית לשעה על השעון - כמה דקות עברו מחצות הלילה כתוב בגימטריה | נוצר מבקשה בעברית - הקישו לפתיחה · ניווט improv יכולת מאולתרת - שרשרת חמישה | נוצר מבקשה בעברית - הקישו לפתיחה · ניווט mission חדר בקרה - משימה לירח | נוצר מבקשה בעברית - הקישו לפתיחה · ניווט quest1 עולם משחק שלם - חדר 1 | נוצר מבקשה בעברית - הקישו לפתיחה · ניווט quest2 עולם משחק שלם - חדר 2 | נוצר מבקשה בעברית - הקישו לפתיחה · ניווט shipping הגדרות משלוחים | נוצר מבקשה בעברית - הקישו לפתיחה · ניווט team ניהול צוות | נוצר מבקשה בעברית - הקישו לפתיחה · כותרת אוצר-דאטה חי - אטום-דאטה שחולץ בטיהור והפך חומר-בנייה · דאטה DOW_HE DOW_HE · תגיות הצורות שאני מבין: מתג / שדה / מספר / כפתור / באנר / בחירה / תגיות / כרטיס / כותרת / שורה / נתון / חישוב · באנר את המסך הזה כתבתי והרכבתי לבד מהידע החי שלי - מאטומים קיימים בלבד · כפתור ✨ צרו מסך חדש
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · RStat · RStat · RStat · CaSubTitle · RStat · CaSubTitle · InlineTextRow · CaSubTitle · UnitSegmentToggle · CaSubTitle · HeroCard · HeroCard · HeroCard · HeroCard · HeroCard · HeroCard · HeroCard · HeroCard · HeroCard · HeroCard · CaSubTitle · ChipWrap · ChipWrap · CoinBanner · ActionRow · RStat · SwitchRow · InlineTextRow · RStat
import '../dart-data-bs/auto/gen_entry_content.dart';
import '../dart-data-maor/explain-call-data.dart';
import '../dart-maor/adar-norm.dart';
import '../dart-maor/heb-cal-box.dart';
import '../dart-ui-bs/auto/action_row.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/chip_wrap.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/inline_text_row.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/auto/switch_row.dart';
import '../dart-ui-bs/hero_card.dart';
import '../dart-ui-bs/screens__lipskey_product_sheet/unit_segment_toggle.dart';
import 'gen_business.dart';
import 'gen_capclockcalendar.dart';
import 'gen_capmailphone.dart';
import 'gen_captimegematria.dart';
import 'gen_improv.dart';
import 'gen_mission.dart';
import 'gen_quest1.dart';
import 'gen_quest2.dart';
import 'gen_shipping.dart';
import 'gen_team.dart';
import 'package:flutter/material.dart';

class GenEntryScreen extends StatefulWidget {
  const GenEntryScreen({super.key});

  @override
  State<GenEntryScreen> createState() => _GenEntryScreenState();
}

class _GenEntryScreenState extends State<GenEntryScreen> {
  String _t1 = '';
  bool _v2 = false;
  String _t3 = '';
  String _t4 = '';
  int _n5 = 0;
  String _t6 = '';
  String _t7 = '';

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_entry_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_entry_card_glyph, title: gen_entry_card_title, sub: gen_entry_card_sub, onTap: () => _toast(gen_entry_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CaSubTitle(gen_entry_header_text),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: gen_entry_stat_value, label: gen_entry_stat_label), RStat(value: gen_entry_stat_value2, label: gen_entry_stat_label2), RStat(value: gen_entry_stat_value3, label: gen_entry_stat_label3)])),
          CaSubTitle(gen_entry_header_text2),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: hebMonthHeWired(DateTime.now()), label: gen_entry_stat_label4)])),
          CaSubTitle(gen_entry_header_text3),
          InlineTextRow(label: gen_entry_textfield_label, hint: gen_entry_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v)),
          Row(children: [RStat(value: adarNorm(_t1), label: gen_entry_stat_label5)]),
          CaSubTitle(gen_entry_header_text4),
          UnitSegmentToggle(options: const <({String label, bool enabled})>[(label: gen_entry_radio_option, enabled: true), (label: gen_entry_radio_option2, enabled: true), (label: gen_entry_radio_option3, enabled: true)], selectedIndex: _n5, onSelect: (v) => setState(() => _n5 = v), selectedBgColor: BsTokens.cardLight, selectedFgColor: BsTokens.inkLight, enabledFgColor: BsTokens.inkLight, disabledFgColor: BsTokens.inkLight, borderColor: BsTokens.divider),
          IndexedStack(index: _n5, children: [SwitchRow(label: gen_entry_switch_label, value: _v2, onChanged: (v) => setState(() => _v2 = v)), InlineTextRow(label: gen_entry_textfield_label2, hint: gen_entry_textfield_hint2, value: _t3, onChanged: (v) => setState(() => _t3 = v)), Row(children: [RStat(value: _t4, label: gen_entry_stat_label6)])]),
          CaSubTitle(gen_entry_header_text5),
          HeroCard(glyph: gen_entry_card_glyph2, title: gen_entry_card_title2, sub: gen_entry_card_sub2, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GenBusinessScreen())), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          HeroCard(glyph: gen_entry_card_glyph3, title: gen_entry_card_title3, sub: gen_entry_card_sub3, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GenCapclockcalendarScreen())), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          HeroCard(glyph: gen_entry_card_glyph4, title: gen_entry_card_title4, sub: gen_entry_card_sub4, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GenCapmailphoneScreen())), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          HeroCard(glyph: gen_entry_card_glyph5, title: gen_entry_card_title5, sub: gen_entry_card_sub5, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GenCaptimegematriaScreen())), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          HeroCard(glyph: gen_entry_card_glyph6, title: gen_entry_card_title6, sub: gen_entry_card_sub6, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GenImprovScreen())), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          HeroCard(glyph: gen_entry_card_glyph7, title: gen_entry_card_title7, sub: gen_entry_card_sub7, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GenMissionScreen())), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          HeroCard(glyph: gen_entry_card_glyph8, title: gen_entry_card_title8, sub: gen_entry_card_sub8, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GenQuest1Screen())), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          HeroCard(glyph: gen_entry_card_glyph9, title: gen_entry_card_title9, sub: gen_entry_card_sub9, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GenQuest2Screen())), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          HeroCard(glyph: gen_entry_card_glyph10, title: gen_entry_card_title10, sub: gen_entry_card_sub10, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GenShippingScreen())), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          HeroCard(glyph: gen_entry_card_glyph11, title: gen_entry_card_title11, sub: gen_entry_card_sub11, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GenTeamScreen())), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CaSubTitle(gen_entry_header_text6),
          ChipWrap(options: DOW_HE, selected: _t6, onSelect: (v) => setState(() => _t6 = v)),
          ChipWrap(options: const <String>[gen_entry_chip_option, gen_entry_chip_option2, gen_entry_chip_option3, gen_entry_chip_option4, gen_entry_chip_option5, gen_entry_chip_option6, gen_entry_chip_option7, gen_entry_chip_option8, gen_entry_chip_option9, gen_entry_chip_option10, gen_entry_chip_option11, gen_entry_chip_option12], selected: _t7, onSelect: (v) => setState(() => _t7 = v)),
          CoinBanner(coins: 0, sub: gen_entry_banner_sub),
          ActionRow(label: gen_entry_button_label, onTap: () => _toast(gen_entry_button_toast)),
          ],
        ),
      ),
    );
  }
}
