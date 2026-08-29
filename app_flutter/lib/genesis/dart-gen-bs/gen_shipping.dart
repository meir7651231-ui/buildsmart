// 🧬 חולל ע"י המחולל (genesis-gen, הכרעה 17) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הגדרות משלוחים
// 🧬 בקשה: הגדרות משלוחים: מתג איסוף עצמי מהחנות, שדה כתובת ברירת מחדל, מתג עדכוני סטטוס בוואטסאפ, מספר ימי אספקה, כפתור שמירת הגדרות
// 🧬 אטומים שנבחרו: ChatSettingsSwitchRow · FieldLabel · ChatSettingsSwitchRow · QtyStepper · ChatSettingsActionRow
import '../dart-data-bs/auto/gen_shipping_content.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/chat_settings_action_row.dart';
import '../dart-ui-bs/auto/chat_settings_switch_row.dart';
import '../dart-ui-bs/auto/field_label.dart';
import '../dart-ui-bs/auto/qty_stepper.dart';
import 'package:flutter/material.dart';

class GenShippingScreen extends StatefulWidget {
  const GenShippingScreen({super.key});

  @override
  State<GenShippingScreen> createState() => _GenShippingScreenState();
}

class _GenShippingScreenState extends State<GenShippingScreen> {
  bool _v1 = false;
  bool _v2 = false;
  int _n3 = 0;

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_shipping_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          ChatSettingsSwitchRow(fallback: gen_shipping_switch_fallback, label: gen_shipping_switch_label, value: _v1, onChanged: (v) => setState(() => _v1 = v)),
          FieldLabel(gen_shipping_textfield_text),
          ChatSettingsSwitchRow(fallback: gen_shipping_switch_fallback2, label: gen_shipping_switch_label2, value: _v2, onChanged: (v) => setState(() => _v2 = v)),
          QtyStepper(qty: 0, onChanged: (v) => setState(() => _n3 = v)),
          ChatSettingsActionRow(label: gen_shipping_button_label, buttonLabel: gen_shipping_button_button_label, onTap: () => _toast(gen_shipping_button_toast)),
          ],
        ),
      ),
    );
  }
}
