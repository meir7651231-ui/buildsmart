// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הירו 🗂️ חשבון חלקי | ישות מורכבת — טופס + טבלה
// 🧬 בקשה: הירו 🗂️ חשבון חלקי | ישות מורכבת — טופס + טבלה · אטום BreadcrumbTrail חשבון חלקי: הוכן / אושר מנהל / אושר מפקח / אושר לקוח / שולם · כותרת טופס חשבון חלקי · אטום InlineTextRow פרויקט · אטום GlowField תקופה · אטום NumberStepper אחוז ביצוע · אטום InlineTextRow ערך נוכחי · אטום InlineTextRow עיכבון · אטום QtyStepper יתרה · אטום AnimatedToggle סטטוס · אטום FabMenu שמירה · אטום NeonButton קדם לאושר מנהל · כותרת חוקים פר-שדה · חישוב אין שקעים שם פרטי (kForType) · כותרת רשומות חשבון חלקי · אטום DataGrid חשבון חלקי · באנר ישות חשבון חלקי: 7 שדות · 5-שלבי workflow · 1 חוקים · מהמדף
// 🧬 אטומים שנבחרו: BreadcrumbTrail · CaSubTitle · InlineTextRow · GlowField · NumberStepper · InlineTextRow · InlineTextRow · QtyStepper · AnimatedToggle · FabMenu · NeonButton · CaSubTitle · RStat · CaSubTitle · DataGrid · CoinBanner
import '../dart-data-bs/auto/gen_app_ent29_content.dart';
import '../dart-ui-bs/animated_toggle.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/inline_text_row.dart';
import '../dart-ui-bs/auto/qty_stepper.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/breadcrumb_trail.dart';
import '../dart-ui-bs/data_grid.dart';
import '../dart-ui-bs/fab_menu.dart';
import '../dart-ui-bs/glow_field.dart';
import '../dart-ui-bs/neon_button.dart';
import '../dart-ui-bs/number_stepper.dart';
import '../dart/k_for_type.dart';
import 'package:flutter/material.dart';

class GenAppEnt29Screen extends StatefulWidget {
  const GenAppEnt29Screen({super.key});

  @override
  State<GenAppEnt29Screen> createState() => _GenAppEnt29ScreenState();
}

class _GenAppEnt29ScreenState extends State<GenAppEnt29Screen> {
  String _t1 = '';
  String _t2 = '';
  String _t3 = '';
  int _n4 = 0;

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_app_ent29_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          BreadcrumbTrail(labels: const <String>[gen_app_ent29_crumbs_option, gen_app_ent29_crumbs_option2, gen_app_ent29_crumbs_option3, gen_app_ent29_crumbs_option4, gen_app_ent29_crumbs_option5], height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent29_header_text),
          InlineTextRow(label: gen_app_ent29_textfield_label, hint: gen_app_ent29_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v)),
          GlowField(hint: gen_app_ent29_glowfield_hint, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NumberStepper(label: gen_app_ent29_numstep_label, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          InlineTextRow(label: gen_app_ent29_textfield_label2, hint: gen_app_ent29_textfield_hint2, value: _t2, onChanged: (v) => setState(() => _t2 = v)),
          InlineTextRow(label: gen_app_ent29_textfield_label3, hint: gen_app_ent29_textfield_hint3, value: _t3, onChanged: (v) => setState(() => _t3 = v)),
          QtyStepper(qty: _n4, onChanged: (v) => setState(() => _n4 = v)),
          AnimatedToggle(label: gen_app_ent29_toggle_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FabMenu(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NeonButton(label: gen_app_ent29_neon_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, onPressed: () => _toast(gen_app_ent29_neon_toast)),
          CaSubTitle(gen_app_ent29_header_text2),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: kForType(null).toString(), label: gen_app_ent29_stat_label)])),
          CaSubTitle(gen_app_ent29_header_text3),
          DataGrid(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_app_ent29_banner_sub),
          ],
        ),
      ),
    );
  }
}
