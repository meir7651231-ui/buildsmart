// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: חדר בקרה - משימה לירח
// 🧬 בקשה: חדר בקרה - משימה לירח: · הירו 🚀 חדר בקרה - משימה לירח | אטומים שנולדו לצדקה ולבניין - מחווטים לעולם הפוך · כותרת אות קריאה - הקלידו שם משימה והמנוע טובע קוד · שדה הקלידו את שם המשימה · חישוב קוד זמנה דטרמיניסטי · כותרת אתר הנחיתה - הבחירה מחליפה את התדרוך · בחירה ים השקט או הקוטב הדרומי או הצד הרחוק: ים השקט / הקוטב הדרומי / הצד הרחוק · נתון 🌑 3 ימי שהייה במישורי הבזלת · נתון 🧊 14 ימי קידוח בקרח הקוטבי · נתון 📡 7 ימים ללא קשר ישיר עם כדור הארץ · כותרת שעון המשימה - הלוח העברי חי · חישוב שם חודש עברי · כותרת מספר המשימה בגימטריה · חישוב גימטריה מספר אותיות עבריות 5786 · מתג 🛰️ ערוץ קשר פתוח · שורה 📻 יומן תדרים - ערוץ חירום 121.5 מגהרץ · נתון 🚀 42 שלבי שיגור בתוכנית הטיסה · באנר כל אטום כאן נולד לקבלות ולמלאי ולחוגים - והמחולל חיווט מהם חדר בקרה לחלל · כפתור 🚀 שיגור
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · InlineTextRow · CaSubTitle · UnitSegmentToggle · CaSubTitle · CheckRow · CaSubTitle · RStat · SwitchRow · RStat · CoinBanner · ActionRow · RStat · RStat · RStat · RStat · CheckRow
import '../dart-data-bs/auto/gen_mission_content.dart';
import '../dart-maor/gematria.dart';
import '../dart-maor/gen-join-code.dart';
import '../dart-ui-bs/auto/action_row.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/check_row.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/inline_text_row.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/auto/switch_row.dart';
import '../dart-ui-bs/hero_card.dart';
import '../dart-ui-bs/screens__lipskey_product_sheet/unit_segment_toggle.dart';
import 'package:flutter/material.dart';

class GenMissionScreen extends StatefulWidget {
  const GenMissionScreen({super.key});

  @override
  State<GenMissionScreen> createState() => _GenMissionScreenState();
}

class _GenMissionScreenState extends State<GenMissionScreen> {
  String _t1 = '';
  int _n2 = 0;
  bool _v3 = false;

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_mission_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_mission_card_glyph, title: gen_mission_card_title, sub: gen_mission_card_sub, onTap: () => _toast(gen_mission_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CaSubTitle(gen_mission_header_text),
          InlineTextRow(label: gen_mission_textfield_label, hint: gen_mission_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v)),
          Row(children: [RStat(value: genJoinCode(_t1), label: gen_mission_stat_label)]),
          CaSubTitle(gen_mission_header_text2),
          UnitSegmentToggle(options: const <({String label, bool enabled})>[(label: gen_mission_radio_option, enabled: true), (label: gen_mission_radio_option2, enabled: true), (label: gen_mission_radio_option3, enabled: true)], selectedIndex: _n2, onSelect: (v) => setState(() => _n2 = v), selectedBgColor: BsTokens.cardLight, selectedFgColor: BsTokens.inkLight, enabledFgColor: BsTokens.inkLight, disabledFgColor: BsTokens.inkLight, borderColor: BsTokens.divider),
          IndexedStack(index: _n2, children: [Row(children: [RStat(value: gen_mission_stat_value, label: gen_mission_stat_label2)]), Row(children: [RStat(value: gen_mission_stat_value2, label: gen_mission_stat_label3)]), Row(children: [RStat(value: gen_mission_stat_value3, label: gen_mission_stat_label4)])]),
          CaSubTitle(gen_mission_header_text3),
          CheckRow(pass: false, label: gen_mission_row_label),
          CaSubTitle(gen_mission_header_text4),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: gem(5786, const ['', gen_mission_calc_arg, gen_mission_calc_arg2, gen_mission_calc_arg3, gen_mission_calc_arg4, gen_mission_calc_arg5, gen_mission_calc_arg6, gen_mission_calc_arg7, gen_mission_calc_arg8, gen_mission_calc_arg9], const ['', gen_mission_calc_arg10, gen_mission_calc_arg11, gen_mission_calc_arg12, gen_mission_calc_arg13, gen_mission_calc_arg14, gen_mission_calc_arg15, gen_mission_calc_arg16, gen_mission_calc_arg17, gen_mission_calc_arg18], const ['', gen_mission_calc_arg19, gen_mission_calc_arg20, gen_mission_calc_arg21, gen_mission_calc_arg22, gen_mission_calc_arg23, gen_mission_calc_arg24, gen_mission_calc_arg25, gen_mission_calc_arg26, gen_mission_calc_arg27], const {'k1': gen_mission_calc_arg28, 'k2': gen_mission_calc_arg29, 'k3': gen_mission_calc_arg30, 'k4': gen_mission_calc_arg31, 'k5': 100, 'k6': 15, 'k7': 10}), label: gen_mission_stat_label5)])),
          SwitchRow(label: gen_mission_switch_label, value: _v3, onChanged: (v) => setState(() => _v3 = v)),
          if (_v3) CheckRow(pass: false, label: gen_mission_row_label2),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: gen_mission_stat_value4, label: gen_mission_stat_label6)])),
          CoinBanner(coins: 0, sub: gen_mission_banner_sub),
          ActionRow(label: gen_mission_button_label, onTap: () => _toast(gen_mission_button_toast)),
          ],
        ),
      ),
    );
  }
}
