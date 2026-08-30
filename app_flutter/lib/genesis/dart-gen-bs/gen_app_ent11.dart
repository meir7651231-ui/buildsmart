// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: 🗂️ דוח יומי
// 🧬 בקשה: הירו 🗂️ דוח יומי | ישות מורכבת — טופס + טבלה · כותרת טופס דוח יומי · אטום FieldRow פרויקט · אטום FieldRow תאריך · אטום FieldRow מזג אוויר · אטום FieldRow עובדים · אטום NumberStepper שעות · אטום NumberStepper אחוז התקדמות · אטום AnimatedToggle סטטוס · אטום FabMenu שמירה · כותרת רשומות דוח יומי · אטום DataGrid דוח יומי · באנר ישות דוח יומי: 7 שדות · מהמדף
// 🧬 אטומים שנבחרו: CaSubTitle · FieldRow · FieldRow · FieldRow · FieldRow · NumberStepper · NumberStepper · AnimatedToggle · FabMenu · CaSubTitle · DataGrid · CoinBanner
import '../dart-data-bs/auto/gen_app_ent11_content.dart';
import '../dart-ui-bs/animated_toggle.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/data_grid.dart';
import '../dart-ui-bs/fab_menu.dart';
import '../dart-ui-bs/field_row.dart';
import '../dart-ui-bs/number_stepper.dart';
import 'package:flutter/material.dart';

class GenAppEnt11Screen extends StatefulWidget {
  const GenAppEnt11Screen({super.key});

  @override
  State<GenAppEnt11Screen> createState() => _GenAppEnt11ScreenState();
}

class _GenAppEnt11ScreenState extends State<GenAppEnt11Screen> {
  String _t1 = '';
  String _t2 = '';
  String _t3 = '';
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
        appBar: AppBar(title: Text(gen_app_ent11_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          CaSubTitle(gen_app_ent11_header_text),
          FieldRow(label: gen_app_ent11_textfield_label, hint: gen_app_ent11_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent11_textfield_label2, hint: gen_app_ent11_textfield_hint2, value: _t2, onChanged: (v) => setState(() => _t2 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent11_textfield_label3, hint: gen_app_ent11_textfield_hint3, value: _t3, onChanged: (v) => setState(() => _t3 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent11_textfield_label4, hint: gen_app_ent11_textfield_hint4, value: _t4, onChanged: (v) => setState(() => _t4 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          NumberStepper(label: gen_app_ent11_numstep_label, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NumberStepper(label: gen_app_ent11_numstep_label2, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          AnimatedToggle(label: gen_app_ent11_toggle_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FabMenu(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent11_header_text2),
          DataGrid(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_app_ent11_banner_sub),
          ],
        ),
      ),
    );
  }
}
