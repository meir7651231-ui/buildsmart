// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: 🗂️ שדה
// 🧬 בקשה: הירו 🗂️ שדה | ישות מורכבת — טופס + טבלה · כותרת טופס שדה · אטום FieldRow קוד · אטום FieldRow שם · אטום FieldRow שלב · אטום FieldRow אחראי · אטום FieldRow תאריך התחלה · אטום FieldRow תאריך סיום · אטום NumberStepper אחוז ביצוע · אטום NumberStepper תקציב · אטום NumberStepper עלות בפועל · אטום AnimatedToggle סטטוס · אטום FabMenu שמירה · כותרת רשומות שדה · אטום DataGrid שדה · כותרת 🔗 מנוע-חוקים חי · 3 חוקים מהמדף · חישוב אין שקעים שם פרטי (kForType) · חישוב תאריך לתצוגה (fmtDate) · חישוב קלט חופשי או אם (parseAnyDate) · באנר ישות שדה: 10 שדות · 3 חוקים חיים · מהמדף
// 🧬 אטומים שנבחרו: CaSubTitle · FieldRow · FieldRow · FieldRow · FieldRow · FieldRow · FieldRow · NumberStepper · NumberStepper · NumberStepper · AnimatedToggle · FabMenu · CaSubTitle · DataGrid · CaSubTitle · RStat · RStat · RStat · CoinBanner
import '../dart-data-bs/auto/gen_app_ent4_content.dart';
import '../dart-maor/fmt-date.dart';
import '../dart-maor/parse-any-date.dart';
import '../dart-ui-bs/animated_toggle.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/data_grid.dart';
import '../dart-ui-bs/fab_menu.dart';
import '../dart-ui-bs/field_row.dart';
import '../dart-ui-bs/number_stepper.dart';
import '../dart/k_for_type.dart';
import 'package:flutter/material.dart';

class GenAppEnt4Screen extends StatefulWidget {
  const GenAppEnt4Screen({super.key});

  @override
  State<GenAppEnt4Screen> createState() => _GenAppEnt4ScreenState();
}

class _GenAppEnt4ScreenState extends State<GenAppEnt4Screen> {
  String _t1 = '';
  String _t2 = '';
  String _t3 = '';
  String _t4 = '';
  String _t5 = '';
  String _t6 = '';

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_app_ent4_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          CaSubTitle(gen_app_ent4_header_text),
          FieldRow(label: gen_app_ent4_textfield_label, hint: gen_app_ent4_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent4_textfield_label2, hint: gen_app_ent4_textfield_hint2, value: _t2, onChanged: (v) => setState(() => _t2 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent4_textfield_label3, hint: gen_app_ent4_textfield_hint3, value: _t3, onChanged: (v) => setState(() => _t3 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent4_textfield_label4, hint: gen_app_ent4_textfield_hint4, value: _t4, onChanged: (v) => setState(() => _t4 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent4_textfield_label5, hint: gen_app_ent4_textfield_hint5, value: _t5, onChanged: (v) => setState(() => _t5 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent4_textfield_label6, hint: gen_app_ent4_textfield_hint6, value: _t6, onChanged: (v) => setState(() => _t6 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          NumberStepper(label: gen_app_ent4_numstep_label, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NumberStepper(label: gen_app_ent4_numstep_label2, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NumberStepper(label: gen_app_ent4_numstep_label3, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          AnimatedToggle(label: gen_app_ent4_toggle_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FabMenu(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent4_header_text2),
          DataGrid(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent4_header_text3),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: kForType(null).toString(), label: gen_app_ent4_stat_label), RStat(value: fmtDate(null), label: gen_app_ent4_stat_label2), RStat(value: parseAnyDate(null), label: gen_app_ent4_stat_label3)])),
          CoinBanner(coins: 0, sub: gen_app_ent4_banner_sub),
          ],
        ),
      ),
    );
  }
}
