// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הירו 🗂️ ציוד | ישות מורכבת — טופס + טבלה
// 🧬 בקשה: הירו 🗂️ ציוד | ישות מורכבת — טופס + טבלה · כותרת טופס ציוד · אטום InlineTextRow שם · אטום GlowField סוג · אטום NumberStepper מספר סידורי · אטום InlineTextRow מיקום · אטום DatePills תוקף בדיקה · אטום QtyStepper שעות שימוש · אטום AnimatedToggle סטטוס · אטום FabMenu שמירה · כותרת חוקים פר-שדה · חישוב אין שקעים שם פרטי (kForType) · חישוב מספר סידורי של (excelSerialToIso) · כותרת רשומות ציוד · אטום DataGrid ציוד · באנר ישות ציוד: 7 שדות · 2 חוקים · מהמדף
// 🧬 אטומים שנבחרו: CaSubTitle · InlineTextRow · GlowField · NumberStepper · InlineTextRow · DatePills · QtyStepper · AnimatedToggle · FabMenu · CaSubTitle · RStat · RStat · CaSubTitle · DataGrid · CoinBanner
import '../dart-data-bs/auto/gen_app_ent16_content.dart';
import '../dart-maor/excel-serial-to-iso.dart';
import '../dart-ui-bs/animated_toggle.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/inline_text_row.dart';
import '../dart-ui-bs/auto/qty_stepper.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/data_grid.dart';
import '../dart-ui-bs/date_pills.dart';
import '../dart-ui-bs/fab_menu.dart';
import '../dart-ui-bs/glow_field.dart';
import '../dart-ui-bs/number_stepper.dart';
import '../dart/k_for_type.dart';
import 'package:flutter/material.dart';

class GenAppEnt16Screen extends StatefulWidget {
  const GenAppEnt16Screen({super.key});

  @override
  State<GenAppEnt16Screen> createState() => _GenAppEnt16ScreenState();
}

class _GenAppEnt16ScreenState extends State<GenAppEnt16Screen> {
  String _t1 = '';
  String _t2 = '';
  int _n3 = 0;

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_app_ent16_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          CaSubTitle(gen_app_ent16_header_text),
          InlineTextRow(label: gen_app_ent16_textfield_label, hint: gen_app_ent16_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v)),
          GlowField(hint: gen_app_ent16_glowfield_hint, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NumberStepper(label: gen_app_ent16_numstep_label, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          InlineTextRow(label: gen_app_ent16_textfield_label2, hint: gen_app_ent16_textfield_hint2, value: _t2, onChanged: (v) => setState(() => _t2 = v)),
          DatePills(height: 16, days: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          QtyStepper(qty: _n3, onChanged: (v) => setState(() => _n3 = v)),
          AnimatedToggle(label: gen_app_ent16_toggle_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FabMenu(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent16_header_text2),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: kForType(null).toString(), label: gen_app_ent16_stat_label), RStat(value: excelSerialToIso(null), label: gen_app_ent16_stat_label2)])),
          CaSubTitle(gen_app_ent16_header_text3),
          DataGrid(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_app_ent16_banner_sub),
          ],
        ),
      ),
    );
  }
}
