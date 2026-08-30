// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: 🗂️ שדה
// 🧬 בקשה: הירו 🗂️ שדה | ישות מורכבת — טופס + טבלה · אטום BreadcrumbTrail שדה: חדש / נשלח / בבדיקה / נענה / מאושר / סגור · כותרת טופס שדה · אטום NumberStepper מספר · אטום FieldRow פרויקט · אטום FieldRow תחום · אטום FieldRow שאלה · אטום FieldRow מועד נדרש · אטום FieldRow דחיפות · אטום NumberStepper השפעת עלות · אטום AnimatedToggle סטטוס · אטום FabMenu שמירה · אטום NeonButton קדם לנשלח · כותרת רשומות שדה · אטום DataGrid שדה · באנר ישות שדה: 8 שדות · 6-שלבי workflow · מהמדף
// 🧬 אטומים שנבחרו: BreadcrumbTrail · CaSubTitle · NumberStepper · FieldRow · FieldRow · FieldRow · FieldRow · FieldRow · NumberStepper · AnimatedToggle · FabMenu · NeonButton · CaSubTitle · DataGrid · CoinBanner
import '../dart-data-bs/auto/gen_app_ent18_content.dart';
import '../dart-ui-bs/animated_toggle.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/breadcrumb_trail.dart';
import '../dart-ui-bs/data_grid.dart';
import '../dart-ui-bs/fab_menu.dart';
import '../dart-ui-bs/field_row.dart';
import '../dart-ui-bs/neon_button.dart';
import '../dart-ui-bs/number_stepper.dart';
import 'package:flutter/material.dart';

class GenAppEnt18Screen extends StatefulWidget {
  const GenAppEnt18Screen({super.key});

  @override
  State<GenAppEnt18Screen> createState() => _GenAppEnt18ScreenState();
}

class _GenAppEnt18ScreenState extends State<GenAppEnt18Screen> {
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
        appBar: AppBar(title: Text(gen_app_ent18_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          BreadcrumbTrail(labels: const <String>[gen_app_ent18_crumbs_option, gen_app_ent18_crumbs_option2, gen_app_ent18_crumbs_option3, gen_app_ent18_crumbs_option4, gen_app_ent18_crumbs_option5, gen_app_ent18_crumbs_option6], height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent18_header_text),
          NumberStepper(label: gen_app_ent18_numstep_label, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FieldRow(label: gen_app_ent18_textfield_label, hint: gen_app_ent18_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent18_textfield_label2, hint: gen_app_ent18_textfield_hint2, value: _t2, onChanged: (v) => setState(() => _t2 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent18_textfield_label3, hint: gen_app_ent18_textfield_hint3, value: _t3, onChanged: (v) => setState(() => _t3 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent18_textfield_label4, hint: gen_app_ent18_textfield_hint4, value: _t4, onChanged: (v) => setState(() => _t4 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent18_textfield_label5, hint: gen_app_ent18_textfield_hint5, value: _t5, onChanged: (v) => setState(() => _t5 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          NumberStepper(label: gen_app_ent18_numstep_label2, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          AnimatedToggle(label: gen_app_ent18_toggle_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FabMenu(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NeonButton(label: gen_app_ent18_neon_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, onPressed: () => _toast(gen_app_ent18_neon_toast)),
          CaSubTitle(gen_app_ent18_header_text2),
          DataGrid(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_app_ent18_banner_sub),
          ],
        ),
      ),
    );
  }
}
