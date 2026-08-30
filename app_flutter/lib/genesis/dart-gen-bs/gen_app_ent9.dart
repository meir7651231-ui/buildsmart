// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: 🗂️ תקציב
// 🧬 בקשה: הירו 🗂️ תקציב | ישות מורכבת — טופס + טבלה · כותרת טופס תקציב · אטום FieldRow פרויקט · אטום FieldRow סעיף · אטום NumberStepper תקציב מאושר · אטום NumberStepper עלות מחויבת · אטום NumberStepper עלות בפועל · אטום FieldRow תחזית · אטום FieldRow סטייה · אטום FabMenu שמירה · כותרת רשומות תקציב · אטום DataGrid תקציב · באנר ישות תקציב: 7 שדות · מהמדף
// 🧬 אטומים שנבחרו: CaSubTitle · FieldRow · FieldRow · NumberStepper · NumberStepper · NumberStepper · FieldRow · FieldRow · FabMenu · CaSubTitle · DataGrid · CoinBanner
import '../dart-data-bs/auto/gen_app_ent9_content.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/data_grid.dart';
import '../dart-ui-bs/fab_menu.dart';
import '../dart-ui-bs/field_row.dart';
import '../dart-ui-bs/number_stepper.dart';
import 'package:flutter/material.dart';

class GenAppEnt9Screen extends StatefulWidget {
  const GenAppEnt9Screen({super.key});

  @override
  State<GenAppEnt9Screen> createState() => _GenAppEnt9ScreenState();
}

class _GenAppEnt9ScreenState extends State<GenAppEnt9Screen> {
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
        appBar: AppBar(title: Text(gen_app_ent9_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          CaSubTitle(gen_app_ent9_header_text),
          FieldRow(label: gen_app_ent9_textfield_label, hint: gen_app_ent9_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent9_textfield_label2, hint: gen_app_ent9_textfield_hint2, value: _t2, onChanged: (v) => setState(() => _t2 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          NumberStepper(label: gen_app_ent9_numstep_label, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NumberStepper(label: gen_app_ent9_numstep_label2, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NumberStepper(label: gen_app_ent9_numstep_label3, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FieldRow(label: gen_app_ent9_textfield_label3, hint: gen_app_ent9_textfield_hint3, value: _t3, onChanged: (v) => setState(() => _t3 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent9_textfield_label4, hint: gen_app_ent9_textfield_hint4, value: _t4, onChanged: (v) => setState(() => _t4 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FabMenu(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent9_header_text2),
          DataGrid(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_app_ent9_banner_sub),
          ],
        ),
      ),
    );
  }
}
