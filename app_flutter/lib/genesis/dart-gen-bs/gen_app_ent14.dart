// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: 🗂️ הזמנת רכש
// 🧬 בקשה: הירו 🗂️ הזמנת רכש | ישות מורכבת — טופס + טבלה · אטום BreadcrumbTrail הזמנת רכש: בקשה / אושר / הוזמן / נמסר · כותרת טופס הזמנת רכש · אטום NumberStepper מספר · אטום FieldRow ספק · אטום FieldRow פרויקט · אטום NumberStepper כמות · אטום NumberStepper מחיר · אטום FieldRow תאריך אספקה · אטום AnimatedToggle סטטוס · אטום FabMenu שמירה · אטום NeonButton קדם לאושר · כותרת רשומות הזמנת רכש · אטום DataGrid הזמנת רכש · כותרת 🔗 מנוע-חוקים חי · 2 חוקים מהמדף · חישוב מספר סידורי של (excelSerialToIso) · חישוב תאריך לתצוגה (fmtDate) · באנר ישות הזמנת רכש: 7 שדות · 4-שלבי workflow · 2 חוקים חיים · מהמדף
// 🧬 אטומים שנבחרו: BreadcrumbTrail · CaSubTitle · NumberStepper · FieldRow · FieldRow · NumberStepper · NumberStepper · FieldRow · AnimatedToggle · FabMenu · NeonButton · CaSubTitle · DataGrid · CaSubTitle · RStat · RStat · CoinBanner
import '../dart-data-bs/auto/gen_app_ent14_content.dart';
import '../dart-maor/excel-serial-to-iso.dart';
import '../dart-maor/fmt-date.dart';
import '../dart-ui-bs/animated_toggle.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/breadcrumb_trail.dart';
import '../dart-ui-bs/data_grid.dart';
import '../dart-ui-bs/fab_menu.dart';
import '../dart-ui-bs/field_row.dart';
import '../dart-ui-bs/neon_button.dart';
import '../dart-ui-bs/number_stepper.dart';
import 'package:flutter/material.dart';

class GenAppEnt14Screen extends StatefulWidget {
  const GenAppEnt14Screen({super.key});

  @override
  State<GenAppEnt14Screen> createState() => _GenAppEnt14ScreenState();
}

class _GenAppEnt14ScreenState extends State<GenAppEnt14Screen> {
  String _t1 = '';
  String _t2 = '';
  String _t3 = '';

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_app_ent14_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          BreadcrumbTrail(labels: const <String>[gen_app_ent14_crumbs_option, gen_app_ent14_crumbs_option2, gen_app_ent14_crumbs_option3, gen_app_ent14_crumbs_option4], height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent14_header_text),
          NumberStepper(label: gen_app_ent14_numstep_label, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FieldRow(label: gen_app_ent14_textfield_label, hint: gen_app_ent14_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent14_textfield_label2, hint: gen_app_ent14_textfield_hint2, value: _t2, onChanged: (v) => setState(() => _t2 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          NumberStepper(label: gen_app_ent14_numstep_label2, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NumberStepper(label: gen_app_ent14_numstep_label3, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FieldRow(label: gen_app_ent14_textfield_label3, hint: gen_app_ent14_textfield_hint3, value: _t3, onChanged: (v) => setState(() => _t3 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          AnimatedToggle(label: gen_app_ent14_toggle_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FabMenu(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NeonButton(label: gen_app_ent14_neon_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, onPressed: () => _toast(gen_app_ent14_neon_toast)),
          CaSubTitle(gen_app_ent14_header_text2),
          DataGrid(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent14_header_text3),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: excelSerialToIso(null), label: gen_app_ent14_stat_label), RStat(value: fmtDate(null), label: gen_app_ent14_stat_label2)])),
          CoinBanner(coins: 0, sub: gen_app_ent14_banner_sub),
          ],
        ),
      ),
    );
  }
}
