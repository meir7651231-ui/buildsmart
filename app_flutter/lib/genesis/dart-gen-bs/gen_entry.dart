// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: המחולל
// 🧬 בקשה: המחולל: · הירו 🧬 המחולל של המחצב | כותבים משפט בעברית - מקבלים מסך חי · כותרת המפעל במספרים · נתון ⚛️ 381 לבנים ויזואליות · נתון 🧠 617 אטומי לוגיקה פעילים · נתון 🏭 79 מסכים הורכבו מחדש · נתון 🟢 1672 קבצים ירוקים בקומפיילר · כותרת גשר הלוגיקה פועם · חישוב החודש העברי כרגע לפי מנוע מאור · חישוב קוד הזמנה דטרמיניסטי "genesis" · כותרת נסו בעצמכם · בחירה מה בונים היום: מסך הגדרות / מסך ניהול / מסך דוחות · מתג 🌙 מצב לילה · כפתור ✨ צרו מסך חדש · באנר נבנה כולו בידי המחולל — מאטומים קיימים בלבד
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · RStat · RStat · RStat · RStat · CaSubTitle · RStat · RStat · CaSubTitle · UnitSegmentToggle · SwitchRow · ActionRow · CoinBanner
import '../dart-data-bs/auto/gen_entry_content.dart';
import '../dart-maor/gen-join-code.dart';
import '../dart-maor/heb-month-he.dart';
import '../dart-ui-bs/auto/action_row.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
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
        appBar: AppBar(title: Text(gen_entry_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_entry_card_glyph, title: gen_entry_card_title, sub: gen_entry_card_sub, onTap: () => _toast(gen_entry_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CaSubTitle(gen_entry_header_text),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: gen_entry_stat_value, label: gen_entry_stat_label), RStat(value: gen_entry_stat_value2, label: gen_entry_stat_label2), RStat(value: gen_entry_stat_value3, label: gen_entry_stat_label3), RStat(value: gen_entry_stat_value4, label: gen_entry_stat_label4)])),
          CaSubTitle(gen_entry_header_text2),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: hebMonthHe(DateTime.now()), label: gen_entry_stat_label5), RStat(value: genJoinCode('genesis'), label: gen_entry_stat_label6)])),
          CaSubTitle(gen_entry_header_text3),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [UnitSegmentToggle(options: const <({String label, bool enabled})>[(label: gen_entry_radio_option, enabled: true), (label: gen_entry_radio_option2, enabled: true), (label: gen_entry_radio_option3, enabled: true)], selectedIndex: _n1, onSelect: (v) => setState(() => _n1 = v), selectedBgColor: BsTokens.cardLight, selectedFgColor: BsTokens.inkLight, enabledFgColor: BsTokens.inkLight, disabledFgColor: BsTokens.inkLight, borderColor: BsTokens.divider)])),
          SwitchRow(label: gen_entry_switch_label, value: _v2, onChanged: (v) => setState(() => _v2 = v)),
          ActionRow(label: gen_entry_button_label, onTap: () => _toast(gen_entry_button_toast)),
          CoinBanner(coins: 0, sub: gen_entry_banner_sub),
          ],
        ),
      ),
    );
  }
}
