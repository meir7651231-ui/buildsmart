// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הירו 🗂️ פרויקט | ישות מורכבת — טופס + טבלה
// 🧬 בקשה: הירו 🗂️ פרויקט | ישות מורכבת — טופס + טבלה · אטום BreadcrumbTrail פרויקט: תכנון / הצעה / חוזה / ביצוע / מסירה / נסגר · כותרת טופס פרויקט · אטום NumberStepper מספר · אטום InlineTextRow שם · אטום GlowField סוג · אטום InlineTextRow לקוח · אטום InlineTextRow כתובת · אטום QtyStepper שטח · אטום InlineTextRow מנהל פרויקט · אטום NumberStepper מחיר חוזה · אטום NumberStepper תקציב · אטום DatePills תאריך התחלה · אטום MiniCalendar תאריך סיום · אטום AnimatedToggle סטטוס · אטום FabMenu שמירה · אטום NeonButton קדם להצעה · כותרת חוקים פר-שדה · חישוב מספר סידורי של (excelSerialToIso) · חישוב אין שקעים שם פרטי (kForType) · חישוב כרעת מנהל (isAdmin) · חישוב פרטי במקור וצא לחוזה (nonEmptyString) · חישוב תאריך לתצוגה (fmtDate) · חישוב קלט חופשי או אם (parseAnyDate) · כותרת רשומות פרויקט · אטום DataGrid פרויקט · באנר ישות פרויקט: 12 שדות · 6-שלבי workflow · 6 חוקים · מהמדף
// 🧬 אטומים שנבחרו: BreadcrumbTrail · CaSubTitle · NumberStepper · InlineTextRow · GlowField · InlineTextRow · InlineTextRow · QtyStepper · InlineTextRow · NumberStepper · NumberStepper · DatePills · MiniCalendar · AnimatedToggle · FabMenu · NeonButton · CaSubTitle · RStat · RStat · RStat · RStat · RStat · RStat · CaSubTitle · DataGrid · CoinBanner
import '../dart-data-bs/auto/gen_app_ent3_content.dart';
import '../dart-maor/excel-serial-to-iso.dart';
import '../dart-maor/fmt-date.dart';
import '../dart-maor/is-admin.dart';
import '../dart-maor/parse-any-date.dart';
import '../dart-ui-bs/animated_toggle.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/inline_text_row.dart';
import '../dart-ui-bs/auto/qty_stepper.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/breadcrumb_trail.dart';
import '../dart-ui-bs/data_grid.dart';
import '../dart-ui-bs/date_pills.dart';
import '../dart-ui-bs/fab_menu.dart';
import '../dart-ui-bs/glow_field.dart';
import '../dart-ui-bs/mini_calendar.dart';
import '../dart-ui-bs/neon_button.dart';
import '../dart-ui-bs/number_stepper.dart';
import '../dart/k_for_type.dart';
import '../dart/non_empty_string.dart';
import 'package:flutter/material.dart';

class GenAppEnt3Screen extends StatefulWidget {
  const GenAppEnt3Screen({super.key});

  @override
  State<GenAppEnt3Screen> createState() => _GenAppEnt3ScreenState();
}

class _GenAppEnt3ScreenState extends State<GenAppEnt3Screen> {
  String _t1 = '';
  String _t2 = '';
  String _t3 = '';
  int _n4 = 0;
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
        appBar: AppBar(title: Text(gen_app_ent3_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          BreadcrumbTrail(labels: const <String>[gen_app_ent3_crumbs_option, gen_app_ent3_crumbs_option2, gen_app_ent3_crumbs_option3, gen_app_ent3_crumbs_option4, gen_app_ent3_crumbs_option5, gen_app_ent3_crumbs_option6], height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent3_header_text),
          NumberStepper(label: gen_app_ent3_numstep_label, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          InlineTextRow(label: gen_app_ent3_textfield_label, hint: gen_app_ent3_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v)),
          GlowField(hint: gen_app_ent3_glowfield_hint, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          InlineTextRow(label: gen_app_ent3_textfield_label2, hint: gen_app_ent3_textfield_hint2, value: _t2, onChanged: (v) => setState(() => _t2 = v)),
          InlineTextRow(label: gen_app_ent3_textfield_label3, hint: gen_app_ent3_textfield_hint3, value: _t3, onChanged: (v) => setState(() => _t3 = v)),
          QtyStepper(qty: _n4, onChanged: (v) => setState(() => _n4 = v)),
          InlineTextRow(label: gen_app_ent3_textfield_label4, hint: gen_app_ent3_textfield_hint4, value: _t5, onChanged: (v) => setState(() => _t5 = v)),
          NumberStepper(label: gen_app_ent3_numstep_label2, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NumberStepper(label: gen_app_ent3_numstep_label3, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          DatePills(height: 16, days: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          MiniCalendar(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          AnimatedToggle(label: gen_app_ent3_toggle_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FabMenu(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NeonButton(label: gen_app_ent3_neon_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, onPressed: () => _toast(gen_app_ent3_neon_toast)),
          CaSubTitle(gen_app_ent3_header_text2),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: excelSerialToIso(null), label: gen_app_ent3_stat_label), RStat(value: kForType(null).toString(), label: gen_app_ent3_stat_label2), RStat(value: isAdmin(null, null).toString(), label: gen_app_ent3_stat_label3), RStat(value: nonEmptyString(null) ?? '', label: gen_app_ent3_stat_label4), RStat(value: fmtDate(null), label: gen_app_ent3_stat_label5), RStat(value: parseAnyDate(null), label: gen_app_ent3_stat_label6)])),
          CaSubTitle(gen_app_ent3_header_text3),
          DataGrid(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_app_ent3_banner_sub),
          ],
        ),
      ),
    );
  }
}
