// 🧬 חולל ע"י המחולל (genesis-gen, הכרעה 17) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: פרופיל עסק
// 🧬 בקשה: פרופיל עסק: כותרת פרטי העסק, שדה שם העסק, בחירה סוג עסק: קבלן / חנות / ספק, תגיות תחומי עבודה: חשמל / אינסטלציה / צבע, מתג 🔔 קבלת התראות, כפתור עדכון פרופיל
// 🧬 אטומים שנבחרו: CaSubTitle · SettingsInlineTextRow · UnitSegmentToggle · ChipWrap · ChatSettingsSwitchRow · ChatSettingsActionRow
import '../dart-data-bs/auto/gen_business_content.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/chat_settings_action_row.dart';
import '../dart-ui-bs/auto/chat_settings_switch_row.dart';
import '../dart-ui-bs/auto/chip_wrap.dart';
import '../dart-ui-bs/screens__chat_settings_screen/settings_inline_text_row.dart';
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
        appBar: AppBar(title: Text(gen_business_t15)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          CaSubTitle(gen_business_t1),
          SettingsInlineTextRow(label: gen_business_t2, hint: gen_business_t3, value: _t1, onChanged: (v) => setState(() => _t1 = v), labelColor: BsTokens.inkLight, inkColor: BsTokens.inkLight, cursorColor: BsTokens.brand, hintColor: BsTokens.mutedLight, fillColor: BsTokens.cardLight),
          UnitSegmentToggle(options: const <({String label, bool enabled})>[(label: gen_business_t4, enabled: true), (label: gen_business_t5, enabled: true), (label: gen_business_t6, enabled: true)], selectedIndex: _n2, onSelect: (v) => setState(() => _n2 = v), selectedBgColor: BsTokens.cardLight, selectedFgColor: BsTokens.inkLight, enabledFgColor: BsTokens.inkLight, disabledFgColor: BsTokens.inkLight, borderColor: BsTokens.divider),
          ChipWrap(options: const <String>[gen_business_t7, gen_business_t8, gen_business_t9], selected: _t3, onSelect: (v) => setState(() => _t3 = v)),
          ChatSettingsSwitchRow(fallback: gen_business_t10, label: gen_business_t11, value: _v4, onChanged: (v) => setState(() => _v4 = v)),
          ChatSettingsActionRow(label: gen_business_t12, buttonLabel: gen_business_t13, onTap: () => _toast(gen_business_t14)),
          ],
        ),
      ),
    );
  }
}
