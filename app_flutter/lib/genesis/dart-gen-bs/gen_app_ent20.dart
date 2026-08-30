// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: 🗂️ שינוי עבודה
// 🧬 בקשה: הירו 🗂️ שינוי עבודה | ישות מורכבת — טופס + טבלה · אטום BreadcrumbTrail שינוי עבודה: בקשה / תומחר / אושר פנימי / אושר לקוח / בוצע · כותרת טופס שינוי עבודה · אטום NumberStepper מספר · אטום FieldRow פרויקט · אטום FieldRow סיבה · אטום NumberStepper מחיר ללקוח · אטום FieldRow השפעה על זמן · אטום FieldRow מאשר · אטום AnimatedToggle סטטוס · אטום FabMenu שמירה · אטום NeonButton קדם לתומחר · כותרת רשומות שינוי עבודה · אטום DataGrid שינוי עבודה · כותרת 🔗 מנוע-חוקים חי · 1 חוקים מהמדף · חישוב מספר סידורי של (excelSerialToIso) · באנר ישות שינוי עבודה: 7 שדות · 5-שלבי workflow · 1 חוקים חיים · מהמדף
// 🧬 אטומים שנבחרו: BreadcrumbTrail · CaSubTitle · NumberStepper · FieldRow · FieldRow · NumberStepper · FieldRow · FieldRow · AnimatedToggle · FabMenu · NeonButton · CaSubTitle · DataGrid · CaSubTitle · RStat · CoinBanner
import '../dart-data-bs/auto/gen_app_ent20_content.dart';
import '../dart-maor/excel-serial-to-iso.dart';
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

class GenAppEnt20Screen extends StatefulWidget {
  const GenAppEnt20Screen({super.key});

  @override
  State<GenAppEnt20Screen> createState() => _GenAppEnt20ScreenState();
}

class _GenAppEnt20ScreenState extends State<GenAppEnt20Screen> {
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
        appBar: AppBar(title: Text(gen_app_ent20_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          BreadcrumbTrail(labels: const <String>[gen_app_ent20_crumbs_option, gen_app_ent20_crumbs_option2, gen_app_ent20_crumbs_option3, gen_app_ent20_crumbs_option4, gen_app_ent20_crumbs_option5], height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent20_header_text),
          NumberStepper(label: gen_app_ent20_numstep_label, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FieldRow(label: gen_app_ent20_textfield_label, hint: gen_app_ent20_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent20_textfield_label2, hint: gen_app_ent20_textfield_hint2, value: _t2, onChanged: (v) => setState(() => _t2 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          NumberStepper(label: gen_app_ent20_numstep_label2, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FieldRow(label: gen_app_ent20_textfield_label3, hint: gen_app_ent20_textfield_hint3, value: _t3, onChanged: (v) => setState(() => _t3 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent20_textfield_label4, hint: gen_app_ent20_textfield_hint4, value: _t4, onChanged: (v) => setState(() => _t4 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          AnimatedToggle(label: gen_app_ent20_toggle_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FabMenu(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NeonButton(label: gen_app_ent20_neon_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, onPressed: () => _toast(gen_app_ent20_neon_toast)),
          CaSubTitle(gen_app_ent20_header_text2),
          DataGrid(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent20_header_text3),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: excelSerialToIso(null), label: gen_app_ent20_stat_label)])),
          CoinBanner(coins: 0, sub: gen_app_ent20_banner_sub),
          ],
        ),
      ),
    );
  }
}
