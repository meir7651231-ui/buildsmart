// 🧬 חולל ע"י המחולל (genesis-gen, הכרעה 17) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הגדרות משלוחים
// 🧬 בקשה: הגדרות משלוחים: מתג איסוף עצמי מהחנות, שדה כתובת ברירת מחדל, מתג עדכוני סטטוס בוואטסאפ, מספר ימי אספקה, כפתור שמירת הגדרות
// 🧬 אטומים שנבחרו: ChatSettingsSwitchRow · SettingsInlineTextRow · ChatSettingsSwitchRow · SettingsNumberRow · ChatSettingsActionRow
import '../dart-data-bs/auto/gen_shipping_content.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/chat_settings_action_row.dart';
import '../dart-ui-bs/auto/chat_settings_switch_row.dart';
import '../dart-ui-bs/screens__chat_settings_screen/settings_inline_text_row.dart';
import '../dart-ui-bs/screens__store_settings_screen/settings_number_row.dart';
import 'package:flutter/material.dart';

class GenShippingScreen extends StatefulWidget {
  const GenShippingScreen({super.key});

  @override
  State<GenShippingScreen> createState() => _GenShippingScreenState();
}

class _GenShippingScreenState extends State<GenShippingScreen> {
  bool _v1 = false;
  String _t2 = '';
  bool _v3 = false;
  int _n4 = 0;

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_shipping_t11)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          ChatSettingsSwitchRow(fallback: gen_shipping_t1, label: gen_shipping_t2, value: _v1, onChanged: (v) => setState(() => _v1 = v)),
          SettingsInlineTextRow(label: gen_shipping_t3, hint: gen_shipping_t4, value: _t2, onChanged: (v) => setState(() => _t2 = v), labelColor: BsTokens.inkLight, inkColor: BsTokens.inkLight, cursorColor: BsTokens.brand, hintColor: BsTokens.mutedLight, fillColor: BsTokens.cardLight),
          ChatSettingsSwitchRow(fallback: gen_shipping_t5, label: gen_shipping_t6, value: _v3, onChanged: (v) => setState(() => _v3 = v)),
          SettingsNumberRow(label: gen_shipping_t7, value: _n4, onChanged: (v) => setState(() => _n4 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, cursorColor: BsTokens.brand, fillColor: BsTokens.cardLight),
          ChatSettingsActionRow(label: gen_shipping_t8, buttonLabel: gen_shipping_t9, onTap: () => _toast(gen_shipping_t10)),
          ],
        ),
      ),
    );
  }
}
