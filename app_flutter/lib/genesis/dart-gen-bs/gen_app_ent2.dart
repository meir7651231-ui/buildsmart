// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: 🗂️ לקוח
// 🧬 בקשה: הירו 🗂️ לקוח | ישות מורכבת — טופס + טבלה · כותרת טופס לקוח · אטום FieldRow שם · אטום FieldRow חברה · אטום NumberStepper מספר עוסק · אטום FieldRow איש קשר · אטום FieldRow טלפון · אטום FieldRow מייל · אטום FieldRow כתובת · אטום FieldRow דירוג · אטום FabMenu שמירה · כותרת רשומות לקוח · אטום DataGrid לקוח · כותרת 🔗 מנוע-חוקים חי · 3 חוקים מהמדף · חישוב אין שקעים שם פרטי (kForType) · חישוב מספר סידורי של (excelSerialToIso) · חישוב נרמול טלפון למפתח דדופ (normPhone) · באנר ישות לקוח: 8 שדות · 3 חוקים חיים · מהמדף
// 🧬 אטומים שנבחרו: CaSubTitle · FieldRow · FieldRow · NumberStepper · FieldRow · FieldRow · FieldRow · FieldRow · FieldRow · FabMenu · CaSubTitle · DataGrid · CaSubTitle · RStat · RStat · RStat · CoinBanner
import '../dart-data-bs/auto/gen_app_ent2_content.dart';
import '../dart-maor/excel-serial-to-iso.dart';
import '../dart-maor/norm-phone.dart';
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

class GenAppEnt2Screen extends StatefulWidget {
  const GenAppEnt2Screen({super.key});

  @override
  State<GenAppEnt2Screen> createState() => _GenAppEnt2ScreenState();
}

class _GenAppEnt2ScreenState extends State<GenAppEnt2Screen> {
  String _t1 = '';
  String _t2 = '';
  String _t3 = '';
  String _t4 = '';
  String _t5 = '';
  String _t6 = '';
  String _t7 = '';

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_app_ent2_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          CaSubTitle(gen_app_ent2_header_text),
          FieldRow(label: gen_app_ent2_textfield_label, hint: gen_app_ent2_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent2_textfield_label2, hint: gen_app_ent2_textfield_hint2, value: _t2, onChanged: (v) => setState(() => _t2 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          NumberStepper(label: gen_app_ent2_numstep_label, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FieldRow(label: gen_app_ent2_textfield_label3, hint: gen_app_ent2_textfield_hint3, value: _t3, onChanged: (v) => setState(() => _t3 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent2_textfield_label4, hint: gen_app_ent2_textfield_hint4, value: _t4, onChanged: (v) => setState(() => _t4 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent2_textfield_label5, hint: gen_app_ent2_textfield_hint5, value: _t5, onChanged: (v) => setState(() => _t5 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent2_textfield_label6, hint: gen_app_ent2_textfield_hint6, value: _t6, onChanged: (v) => setState(() => _t6 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent2_textfield_label7, hint: gen_app_ent2_textfield_hint7, value: _t7, onChanged: (v) => setState(() => _t7 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FabMenu(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent2_header_text2),
          DataGrid(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent2_header_text3),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: kForType(null).toString(), label: gen_app_ent2_stat_label), RStat(value: excelSerialToIso(null), label: gen_app_ent2_stat_label2), RStat(value: normPhone(null), label: gen_app_ent2_stat_label3)])),
          CoinBanner(coins: 0, sub: gen_app_ent2_banner_sub),
          ],
        ),
      ),
    );
  }
}
