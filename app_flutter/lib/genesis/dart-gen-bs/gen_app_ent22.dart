// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הירו 🗂️ ליקוי | ישות מורכבת — טופס + טבלה
// 🧬 בקשה: הירו 🗂️ ליקוי | ישות מורכבת — טופס + טבלה · אטום BreadcrumbTrail ליקוי: נפתח / בטיפול / תוקן / נבדק / נסגר · כותרת טופס ליקוי · אטום NumberStepper מספר · אטום InlineTextRow מיקום · אטום InlineTextRow תיאור · אטום GlowField חומרה · אטום InlineTextRow אחראי · אטום DatePills תאריך יעד · אטום AnimatedToggle סטטוס · אטום FabMenu שמירה · אטום NeonButton קדם לבטיפול · כותרת חוקים פר-שדה · חישוב מספר סידורי של (excelSerialToIso) · חישוב תאריך לתצוגה (fmtDate) · כותרת רשומות ליקוי · אטום DataGrid ליקוי · באנר ישות ליקוי: 7 שדות · 5-שלבי workflow · 2 חוקים · מהמדף
// 🧬 אטומים שנבחרו: BreadcrumbTrail · CaSubTitle · NumberStepper · InlineTextRow · InlineTextRow · GlowField · InlineTextRow · DatePills · AnimatedToggle · FabMenu · NeonButton · CaSubTitle · RStat · RStat · CaSubTitle · DataGrid · CoinBanner
import '../dart-data-bs/auto/gen_app_ent22_content.dart';
import '../dart-maor/excel-serial-to-iso.dart';
import '../dart-maor/fmt-date.dart';
import '../dart-ui-bs/animated_toggle.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/inline_text_row.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/breadcrumb_trail.dart';
import '../dart-ui-bs/data_grid.dart';
import '../dart-ui-bs/date_pills.dart';
import '../dart-ui-bs/fab_menu.dart';
import '../dart-ui-bs/glow_field.dart';
import '../dart-ui-bs/neon_button.dart';
import '../dart-ui-bs/number_stepper.dart';
import 'package:flutter/material.dart';

class GenAppEnt22Screen extends StatefulWidget {
  const GenAppEnt22Screen({super.key});

  @override
  State<GenAppEnt22Screen> createState() => _GenAppEnt22ScreenState();
}

class _GenAppEnt22ScreenState extends State<GenAppEnt22Screen> {
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
        appBar: AppBar(title: Text(gen_app_ent22_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          BreadcrumbTrail(labels: const <String>[gen_app_ent22_crumbs_option, gen_app_ent22_crumbs_option2, gen_app_ent22_crumbs_option3, gen_app_ent22_crumbs_option4, gen_app_ent22_crumbs_option5], height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent22_header_text),
          NumberStepper(label: gen_app_ent22_numstep_label, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          InlineTextRow(label: gen_app_ent22_textfield_label, hint: gen_app_ent22_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v)),
          InlineTextRow(label: gen_app_ent22_textfield_label2, hint: gen_app_ent22_textfield_hint2, value: _t2, onChanged: (v) => setState(() => _t2 = v)),
          GlowField(hint: gen_app_ent22_glowfield_hint, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          InlineTextRow(label: gen_app_ent22_textfield_label3, hint: gen_app_ent22_textfield_hint3, value: _t3, onChanged: (v) => setState(() => _t3 = v)),
          DatePills(height: 16, days: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          AnimatedToggle(label: gen_app_ent22_toggle_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FabMenu(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NeonButton(label: gen_app_ent22_neon_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, onPressed: () => _toast(gen_app_ent22_neon_toast)),
          CaSubTitle(gen_app_ent22_header_text2),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: excelSerialToIso(null), label: gen_app_ent22_stat_label), RStat(value: fmtDate(null), label: gen_app_ent22_stat_label2)])),
          CaSubTitle(gen_app_ent22_header_text3),
          DataGrid(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_app_ent22_banner_sub),
          ],
        ),
      ),
    );
  }
}
