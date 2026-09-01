// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הגדרות משלוחים
// 🧬 בקשה: הגדרות משלוחים: · מתג איסוף עצמי מהחנות · שדה כתובת ברירת מחדל · מתג עדכוני סטטוס בוואטסאפ · מספר ימי אספקה · כפתור שמירת הגדרות
// 🧬 אטומים שנבחרו: SwitchRow · InlineTextRow · SwitchRow · QtyStepper · ActionRow
import '../dart-data-bs/auto/gen_shipping_content.dart';
import '../dart-ui-bs/auto/action_row.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/inline_text_row.dart';
import '../dart-ui-bs/auto/qty_stepper.dart';
import '../dart-ui-bs/auto/switch_row.dart';
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
        appBar: AppBar(title: Text(gen_shipping_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          SwitchRow(label: gen_shipping_switch_label, value: _v1, onChanged: (v) => setState(() => _v1 = v)),
          InlineTextRow(label: gen_shipping_textfield_label, hint: gen_shipping_textfield_hint, value: _t2, onChanged: (v) => setState(() => _t2 = v)),
          SwitchRow(label: gen_shipping_switch_label2, value: _v3, onChanged: (v) => setState(() => _v3 = v)),
          QtyStepper(qty: _n4, onChanged: (v) => setState(() => _n4 = v)),
          ActionRow(label: gen_shipping_button_label, onTap: () => _toast(gen_shipping_button_toast)),
          ],
        ),
      ),
    );
  }
}
