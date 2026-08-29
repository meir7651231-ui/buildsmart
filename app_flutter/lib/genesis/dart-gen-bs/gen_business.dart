// 🧬 חולל ע"י המחולל (genesis-gen, הכרעה 17) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: פרופיל עסק
// 🧬 בקשה: פרופיל עסק: כותרת פרטי העסק, שדה שם העסק, בחירה סוג עסק: קבלן / חנות / ספק, תגיות תחומי עבודה: חשמל / אינסטלציה / צבע, מתג 🔔 קבלת התראות, כפתור עדכון פרופיל
// 🧬 אטומים שנבחרו: CaSubTitle · FieldLabel · UnitSegmentToggle · ChipWrap · ChatSettingsSwitchRow · ChatSettingsActionRow
import '../dart-data-bs/auto/gen_business_content.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/chat_settings_action_row.dart';
import '../dart-ui-bs/auto/chat_settings_switch_row.dart';
import '../dart-ui-bs/auto/chip_wrap.dart';
import '../dart-ui-bs/auto/field_label.dart';
import '../dart-ui-bs/screens__lipskey_product_sheet/unit_segment_toggle.dart';
import 'package:flutter/material.dart';

class GenBusinessScreen extends StatefulWidget {
  const GenBusinessScreen({super.key});

  @override
  State<GenBusinessScreen> createState() => _GenBusinessScreenState();
}

class _GenBusinessScreenState extends State<GenBusinessScreen> {
  int _n1 = 0;
  String _t2 = '';
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
        appBar: AppBar(title: Text(gen_business_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          CaSubTitle(gen_business_header_text),
          FieldLabel(gen_business_textfield_text),
          UnitSegmentToggle(options: const <({String label, bool enabled})>[(label: gen_business_radio_option, enabled: true), (label: gen_business_radio_option2, enabled: true), (label: gen_business_radio_option3, enabled: true)], selectedIndex: _n1, onSelect: (v) => setState(() => _n1 = v), selectedBgColor: BsTokens.cardLight, selectedFgColor: BsTokens.inkLight, enabledFgColor: BsTokens.inkLight, disabledFgColor: BsTokens.inkLight, borderColor: BsTokens.divider),
          ChipWrap(options: const <String>[gen_business_chip_option, gen_business_chip_option2, gen_business_chip_option3], selected: _t2, onSelect: (v) => setState(() => _t2 = v)),
          ChatSettingsSwitchRow(fallback: gen_business_switch_fallback, label: gen_business_switch_label, value: _v3, onChanged: (v) => setState(() => _v3 = v)),
          ChatSettingsActionRow(label: gen_business_button_label, buttonLabel: gen_business_button_button_label, onTap: () => _toast(gen_business_button_toast)),
          ],
        ),
      ),
    );
  }
}
