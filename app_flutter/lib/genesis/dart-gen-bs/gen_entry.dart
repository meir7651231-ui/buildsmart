// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: המחולל
// 🧬 בקשה: המחולל: · הירו 🧬 המחולל של המחצב | כותבים משפט בעברית - מקבלים מסך חי · כותרת המפעל במספרים - עדכון חי מהאטלס · נתון ⚛️ 381 לבנים ויזואליות על המדף · נתון 🧠 438 אטומי לוגיקה פעילים · נתון 🖼️ 79 מסכים הורכבו מחדש · כותרת גשר הלוגיקה פועם · חישוב החודש העברי כרגע לפי מנוע מאור · חישוב קוד הזמנה דטרמיניסטי "genesis" · כותרת הבחירה כאן מחליפה את האטום שמתחתיה · בחירה מה בונים היום: הגדרות / ניהול / דוחות · מתג 🔔 התראות למסך ההגדרות · שדה שם מסך הניהול · נתון 📊 3 דוחות מוכנים להפקה · תגיות הצורות שהוא מבין: מתג / שדה / מספר / כפתור / באנר / בחירה / תגיות / כרטיס / כותרת / שורה / נתון / חישוב · באנר נכתב והורכב בידי המחולל מהידע החי שלו — מאטומים קיימים בלבד · כפתור ✨ צרו מסך חדש
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · RStat · RStat · RStat · CaSubTitle · RStat · RStat · CaSubTitle · UnitSegmentToggle · ChipWrap · CoinBanner · ActionRow · SwitchRow · InlineTextRow · RStat
import '../dart-data-bs/auto/gen_entry_content.dart';
import '../dart-maor/gen-join-code.dart';
import '../dart-maor/heb-month-he.dart';
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
import 'package:flutter/material.dart';

class GenEntryScreen extends StatefulWidget {
  const GenEntryScreen({super.key});

  @override
  State<GenEntryScreen> createState() => _GenEntryScreenState();
}

class _GenEntryScreenState extends State<GenEntryScreen> {
  bool _v1 = false;
  String _t2 = '';
  int _n3 = 0;
  String _t4 = '';

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
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: hebMonthHe(DateTime.now()), label: gen_entry_stat_label4), RStat(value: genJoinCode('genesis'), label: gen_entry_stat_label5)])),
          CaSubTitle(gen_entry_header_text3),
          UnitSegmentToggle(options: const <({String label, bool enabled})>[(label: gen_entry_radio_option, enabled: true), (label: gen_entry_radio_option2, enabled: true), (label: gen_entry_radio_option3, enabled: true)], selectedIndex: _n3, onSelect: (v) => setState(() => _n3 = v), selectedBgColor: BsTokens.cardLight, selectedFgColor: BsTokens.inkLight, enabledFgColor: BsTokens.inkLight, disabledFgColor: BsTokens.inkLight, borderColor: BsTokens.divider),
          IndexedStack(index: _n3, children: [SwitchRow(label: gen_entry_switch_label, value: _v1, onChanged: (v) => setState(() => _v1 = v)), InlineTextRow(label: gen_entry_textfield_label, hint: gen_entry_textfield_hint, value: _t2, onChanged: (v) => setState(() => _t2 = v)), Row(children: [RStat(value: gen_entry_stat_value4, label: gen_entry_stat_label6)])]),
          ChipWrap(options: const <String>[gen_entry_chip_option, gen_entry_chip_option2, gen_entry_chip_option3, gen_entry_chip_option4, gen_entry_chip_option5, gen_entry_chip_option6, gen_entry_chip_option7, gen_entry_chip_option8, gen_entry_chip_option9, gen_entry_chip_option10, gen_entry_chip_option11, gen_entry_chip_option12], selected: _t4, onSelect: (v) => setState(() => _t4 = v)),
          CoinBanner(coins: 0, sub: gen_entry_banner_sub),
          ActionRow(label: gen_entry_button_label, onTap: () => _toast(gen_entry_button_toast)),
          ],
        ),
      ),
    );
  }
}
