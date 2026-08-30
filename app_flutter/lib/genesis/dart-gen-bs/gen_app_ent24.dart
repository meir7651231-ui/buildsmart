// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: 🗂️ נוכחות
// 🧬 בקשה: הירו 🗂️ נוכחות | ישות מורכבת — טופס + טבלה · כותרת טופס נוכחות · אטום FieldRow עובד · אטום FieldRow פרויקט · אטום FieldRow תאריך · אטום FieldRow כניסה · אטום FieldRow יציאה · אטום NumberStepper שעות · אטום FieldRow אישור · אטום FabMenu שמירה · כותרת רשומות נוכחות · אטום DataGrid נוכחות · כותרת 🔗 מנוע-חוקים חי · 1 חוקים מהמדף · חישוב תאריך לתצוגה (fmtDate) · באנר ישות נוכחות: 7 שדות · 1 חוקים חיים · מהמדף
// 🧬 אטומים שנבחרו: CaSubTitle · FieldRow · FieldRow · FieldRow · FieldRow · FieldRow · NumberStepper · FieldRow · FabMenu · CaSubTitle · DataGrid · CaSubTitle · RStat · CoinBanner
import '../dart-data-bs/auto/gen_app_ent24_content.dart';
import '../dart-maor/fmt-date.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/data_grid.dart';
import '../dart-ui-bs/fab_menu.dart';
import '../dart-ui-bs/field_row.dart';
import '../dart-ui-bs/number_stepper.dart';
import 'package:flutter/material.dart';

class GenAppEnt24Screen extends StatefulWidget {
  const GenAppEnt24Screen({super.key});

  @override
  State<GenAppEnt24Screen> createState() => _GenAppEnt24ScreenState();
}

class _GenAppEnt24ScreenState extends State<GenAppEnt24Screen> {
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
        appBar: AppBar(title: Text(gen_app_ent24_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          CaSubTitle(gen_app_ent24_header_text),
          FieldRow(label: gen_app_ent24_textfield_label, hint: gen_app_ent24_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent24_textfield_label2, hint: gen_app_ent24_textfield_hint2, value: _t2, onChanged: (v) => setState(() => _t2 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent24_textfield_label3, hint: gen_app_ent24_textfield_hint3, value: _t3, onChanged: (v) => setState(() => _t3 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent24_textfield_label4, hint: gen_app_ent24_textfield_hint4, value: _t4, onChanged: (v) => setState(() => _t4 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent24_textfield_label5, hint: gen_app_ent24_textfield_hint5, value: _t5, onChanged: (v) => setState(() => _t5 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          NumberStepper(label: gen_app_ent24_numstep_label, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FieldRow(label: gen_app_ent24_textfield_label6, hint: gen_app_ent24_textfield_hint6, value: _t6, onChanged: (v) => setState(() => _t6 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FabMenu(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent24_header_text2),
          DataGrid(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent24_header_text3),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: fmtDate(null), label: gen_app_ent24_stat_label)])),
          CoinBanner(coins: 0, sub: gen_app_ent24_banner_sub),
          ],
        ),
      ),
    );
  }
}
