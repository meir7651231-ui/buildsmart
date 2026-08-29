// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: פרופיל עסק
// 🧬 בקשה: פרופיל עסק: · כותרת פרטי העסק · שדה שם העסק · בחירה סוג עסק: קבלן / חנות / ספק · תגיות תחומי עבודה: חשמל / אינסטלציה / צבע · מתג 🔔 קבלת התראות · כפתור עדכון פרופיל
// 🧬 אטומים שנבחרו: CaSubTitle · InlineTextRow · UnitSegmentToggle · ChipWrap · SwitchRow · ActionRow
import '../dart-data-bs/auto/gen_business_content.dart';
import '../dart-ui-bs/auto/action_row.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/chip_wrap.dart';
import '../dart-ui-bs/auto/inline_text_row.dart';
import '../dart-ui-bs/auto/switch_row.dart';
import '../dart-ui-bs/screens__lipskey_product_sheet/unit_segment_toggle.dart';
import 'package:flutter/material.dart';

class GenBusinessScreen extends StatefulWidget {
  const GenBusinessScreen({super.key});

  @override
  State<GenBusinessScreen> createState() => _GenBusinessScreenState();
}

class _GenBusinessScreenState extends State<GenBusinessScreen> {
  String _t1 = '';
  int _n2 = 0;
  String _t3 = '';
  bool _v4 = false;

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_business_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          CaSubTitle(gen_business_header_text),
          InlineTextRow(label: gen_business_textfield_label, hint: gen_business_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v)),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [UnitSegmentToggle(options: const <({String label, bool enabled})>[(label: gen_business_radio_option, enabled: true), (label: gen_business_radio_option2, enabled: true), (label: gen_business_radio_option3, enabled: true)], selectedIndex: _n2, onSelect: (v) => setState(() => _n2 = v), selectedBgColor: BsTokens.cardLight, selectedFgColor: BsTokens.inkLight, enabledFgColor: BsTokens.inkLight, disabledFgColor: BsTokens.inkLight, borderColor: BsTokens.divider)])),
          ChipWrap(options: const <String>[gen_business_chip_option, gen_business_chip_option2, gen_business_chip_option3], selected: _t3, onSelect: (v) => setState(() => _t3 = v)),
          SwitchRow(label: gen_business_switch_label, value: _v4, onChanged: (v) => setState(() => _v4 = v)),
          ActionRow(label: gen_business_button_label, onTap: () => _toast(gen_business_button_toast)),
          ],
        ),
      ),
    );
  }
}
