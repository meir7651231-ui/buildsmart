// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: 🗂️ אומדן
// 🧬 בקשה: הירו 🗂️ אומדן | ישות מורכבת — טופס + טבלה · כותרת טופס אומדן · אטום FieldRow פרויקט · אטום FieldRow לקוח · אטום FieldRow גרסה · אטום FieldRow תאריך · אטום NumberStepper עלות צפויה · אטום NumberStepper מחיר · אטום NumberStepper רווח יעד · אטום FieldRow תוקף · אטום AnimatedToggle סטטוס · אטום FabMenu שמירה · כותרת רשומות אומדן · אטום DataGrid אומדן · באנר ישות אומדן: 9 שדות · מהמדף
// 🧬 אטומים שנבחרו: CaSubTitle · FieldRow · FieldRow · FieldRow · FieldRow · NumberStepper · NumberStepper · NumberStepper · FieldRow · AnimatedToggle · FabMenu · CaSubTitle · DataGrid · CoinBanner
import '../dart-data-bs/auto/gen_app_ent6_content.dart';
import '../dart-ui-bs/animated_toggle.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/data_grid.dart';
import '../dart-ui-bs/fab_menu.dart';
import '../dart-ui-bs/field_row.dart';
import '../dart-ui-bs/number_stepper.dart';
import 'package:flutter/material.dart';

class GenAppEnt6Screen extends StatefulWidget {
  const GenAppEnt6Screen({super.key});

  @override
  State<GenAppEnt6Screen> createState() => _GenAppEnt6ScreenState();
}

class _GenAppEnt6ScreenState extends State<GenAppEnt6Screen> {
  String _t1 = '';
  String _t2 = '';
  String _t3 = '';
  String _t4 = '';
  String _t5 = '';

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_app_ent6_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          CaSubTitle(gen_app_ent6_header_text),
          FieldRow(label: gen_app_ent6_textfield_label, hint: gen_app_ent6_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent6_textfield_label2, hint: gen_app_ent6_textfield_hint2, value: _t2, onChanged: (v) => setState(() => _t2 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent6_textfield_label3, hint: gen_app_ent6_textfield_hint3, value: _t3, onChanged: (v) => setState(() => _t3 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent6_textfield_label4, hint: gen_app_ent6_textfield_hint4, value: _t4, onChanged: (v) => setState(() => _t4 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          NumberStepper(label: gen_app_ent6_numstep_label, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NumberStepper(label: gen_app_ent6_numstep_label2, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NumberStepper(label: gen_app_ent6_numstep_label3, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FieldRow(label: gen_app_ent6_textfield_label5, hint: gen_app_ent6_textfield_hint5, value: _t5, onChanged: (v) => setState(() => _t5 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          AnimatedToggle(label: gen_app_ent6_toggle_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FabMenu(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent6_header_text2),
          DataGrid(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_app_ent6_banner_sub),
          ],
        ),
      ),
    );
  }
}
