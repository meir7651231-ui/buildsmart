// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הירו 🗂️ ליד | ישות מורכבת — טופס + טבלה
// 🧬 בקשה: הירו 🗂️ ליד | ישות מורכבת — טופס + טבלה · אטום BreadcrumbTrail ליד: חדש / קשר / אפיון / סיור / תמחור / הצעה / זכה · כותרת טופס ליד · אטום InlineTextRow שם · אטום GlowField חברה · אטום InlineTextRow טלפון · אטום InlineTextRow מייל · אטום InlineTextRow סוג פרויקט · אטום InlineTextRow מיקום · אטום NumberStepper תקציב · אטום InlineTextRow ציון · אטום AnimatedToggle סטטוס · אטום FabMenu שמירה · אטום NeonButton קדם לקשר · כותרת חוקים פר-שדה · חישוב אין שקעים שם פרטי (kForType) · חישוב נרמול טלפון למפתח דדופ (normPhone) · כותרת רשומות ליד · אטום DataGrid ליד · באנר ישות ליד: 9 שדות · 7-שלבי workflow · 2 חוקים · מהמדף
// 🧬 אטומים שנבחרו: BreadcrumbTrail · CaSubTitle · InlineTextRow · GlowField · InlineTextRow · InlineTextRow · InlineTextRow · InlineTextRow · NumberStepper · InlineTextRow · AnimatedToggle · FabMenu · NeonButton · CaSubTitle · RStat · RStat · CaSubTitle · DataGrid · CoinBanner
import '../dart-data-bs/auto/gen_app_ent1_content.dart';
import '../dart-maor/norm-phone.dart';
import '../dart-ui-bs/animated_toggle.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/inline_text_row.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/breadcrumb_trail.dart';
import '../dart-ui-bs/data_grid.dart';
import '../dart-ui-bs/fab_menu.dart';
import '../dart-ui-bs/glow_field.dart';
import '../dart-ui-bs/neon_button.dart';
import '../dart-ui-bs/number_stepper.dart';
import '../dart/k_for_type.dart';
import 'package:flutter/material.dart';

class GenAppEnt1Screen extends StatefulWidget {
  const GenAppEnt1Screen({super.key});

  @override
  State<GenAppEnt1Screen> createState() => _GenAppEnt1ScreenState();
}

class _GenAppEnt1ScreenState extends State<GenAppEnt1Screen> {
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
        appBar: AppBar(title: Text(gen_app_ent1_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          BreadcrumbTrail(labels: const <String>[gen_app_ent1_crumbs_option, gen_app_ent1_crumbs_option2, gen_app_ent1_crumbs_option3, gen_app_ent1_crumbs_option4, gen_app_ent1_crumbs_option5, gen_app_ent1_crumbs_option6, gen_app_ent1_crumbs_option7], height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent1_header_text),
          InlineTextRow(label: gen_app_ent1_textfield_label, hint: gen_app_ent1_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v)),
          GlowField(hint: gen_app_ent1_glowfield_hint, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          InlineTextRow(label: gen_app_ent1_textfield_label2, hint: gen_app_ent1_textfield_hint2, value: _t2, onChanged: (v) => setState(() => _t2 = v)),
          InlineTextRow(label: gen_app_ent1_textfield_label3, hint: gen_app_ent1_textfield_hint3, value: _t3, onChanged: (v) => setState(() => _t3 = v)),
          InlineTextRow(label: gen_app_ent1_textfield_label4, hint: gen_app_ent1_textfield_hint4, value: _t4, onChanged: (v) => setState(() => _t4 = v)),
          InlineTextRow(label: gen_app_ent1_textfield_label5, hint: gen_app_ent1_textfield_hint5, value: _t5, onChanged: (v) => setState(() => _t5 = v)),
          NumberStepper(label: gen_app_ent1_numstep_label, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          InlineTextRow(label: gen_app_ent1_textfield_label6, hint: gen_app_ent1_textfield_hint6, value: _t6, onChanged: (v) => setState(() => _t6 = v)),
          AnimatedToggle(label: gen_app_ent1_toggle_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FabMenu(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NeonButton(label: gen_app_ent1_neon_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, onPressed: () => _toast(gen_app_ent1_neon_toast)),
          CaSubTitle(gen_app_ent1_header_text2),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: kForType(null).toString(), label: gen_app_ent1_stat_label), RStat(value: normPhone(null), label: gen_app_ent1_stat_label2)])),
          CaSubTitle(gen_app_ent1_header_text3),
          DataGrid(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_app_ent1_banner_sub),
          ],
        ),
      ),
    );
  }
}
