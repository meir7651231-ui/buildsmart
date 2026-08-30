// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: 🗂️ חוזה
// 🧬 בקשה: הירו 🗂️ חוזה | ישות מורכבת — טופס + טבלה · אטום BreadcrumbTrail חוזה: טיוטה / נחתם / פעיל / הושלם · כותרת טופס חוזה · אטום NumberStepper מספר · אטום FieldRow סוג · אטום FieldRow פרויקט · אטום NumberStepper סכום · אטום FieldRow תאריך חתימה · אטום FieldRow התחלה · אטום FieldRow סיום · אטום FieldRow עיכבון · אטום AnimatedToggle סטטוס · אטום FabMenu שמירה · אטום NeonButton קדם לנחתם · כותרת רשומות חוזה · אטום DataGrid חוזה · כותרת 🔗 מנוע-חוקים חי · 3 חוקים מהמדף · חישוב מספר סידורי של (excelSerialToIso) · חישוב עיטוף סכום שקלים לתצוגה (shekel) · חישוב תאריך לתצוגה (fmtDate) · באנר ישות חוזה: 9 שדות · 4-שלבי workflow · 3 חוקים חיים · מהמדף
// 🧬 אטומים שנבחרו: BreadcrumbTrail · CaSubTitle · NumberStepper · FieldRow · FieldRow · NumberStepper · FieldRow · FieldRow · FieldRow · FieldRow · AnimatedToggle · FabMenu · NeonButton · CaSubTitle · DataGrid · CaSubTitle · RStat · RStat · RStat · CoinBanner
import '../dart-data-bs/auto/gen_app_ent8_content.dart';
import '../dart-maor/excel-serial-to-iso.dart';
import '../dart-maor/fmt-date.dart';
import '../dart-maor/shekel.dart';
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

class GenAppEnt8Screen extends StatefulWidget {
  const GenAppEnt8Screen({super.key});

  @override
  State<GenAppEnt8Screen> createState() => _GenAppEnt8ScreenState();
}

class _GenAppEnt8ScreenState extends State<GenAppEnt8Screen> {
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
        appBar: AppBar(title: Text(gen_app_ent8_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          BreadcrumbTrail(labels: const <String>[gen_app_ent8_crumbs_option, gen_app_ent8_crumbs_option2, gen_app_ent8_crumbs_option3, gen_app_ent8_crumbs_option4], height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent8_header_text),
          NumberStepper(label: gen_app_ent8_numstep_label, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FieldRow(label: gen_app_ent8_textfield_label, hint: gen_app_ent8_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent8_textfield_label2, hint: gen_app_ent8_textfield_hint2, value: _t2, onChanged: (v) => setState(() => _t2 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          NumberStepper(label: gen_app_ent8_numstep_label2, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FieldRow(label: gen_app_ent8_textfield_label3, hint: gen_app_ent8_textfield_hint3, value: _t3, onChanged: (v) => setState(() => _t3 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent8_textfield_label4, hint: gen_app_ent8_textfield_hint4, value: _t4, onChanged: (v) => setState(() => _t4 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent8_textfield_label5, hint: gen_app_ent8_textfield_hint5, value: _t5, onChanged: (v) => setState(() => _t5 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent8_textfield_label6, hint: gen_app_ent8_textfield_hint6, value: _t6, onChanged: (v) => setState(() => _t6 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          AnimatedToggle(label: gen_app_ent8_toggle_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FabMenu(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NeonButton(label: gen_app_ent8_neon_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, onPressed: () => _toast(gen_app_ent8_neon_toast)),
          CaSubTitle(gen_app_ent8_header_text2),
          DataGrid(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent8_header_text3),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: excelSerialToIso(null), label: gen_app_ent8_stat_label), RStat(value: shekel(null), label: gen_app_ent8_stat_label2), RStat(value: fmtDate(null), label: gen_app_ent8_stat_label3)])),
          CoinBanner(coins: 0, sub: gen_app_ent8_banner_sub),
          ],
        ),
      ),
    );
  }
}
