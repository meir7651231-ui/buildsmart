// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הירו 🗂️ משימה | ישות מורכבת — טופס + טבלה
// 🧬 בקשה: הירו 🗂️ משימה | ישות מורכבת — טופס + טבלה · אטום BreadcrumbTrail משימה: מתוכננת / בתהליך / בבדיקה / הושלמה · כותרת טופס משימה · אטום InlineTextRow שם · אטום GlowField אחראי · אטום DatePills תאריך יעד · אטום InlineTextRow עדיפות · אטום NumberStepper אחוז ביצוע · אטום AnimatedToggle סטטוס · אטום FabMenu שמירה · אטום NeonButton קדם לבתהליך · כותרת רשומות משימה · אטום DataGrid משימה · באנר ישות משימה: 6 שדות · 4-שלבי workflow · מהמדף
// 🧬 אטומים שנבחרו: BreadcrumbTrail · CaSubTitle · InlineTextRow · GlowField · DatePills · InlineTextRow · NumberStepper · AnimatedToggle · FabMenu · NeonButton · CaSubTitle · DataGrid · CoinBanner
import '../dart-data-bs/auto/gen_app_ent4_content.dart';
import '../dart-ui-bs/animated_toggle.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/inline_text_row.dart';
import '../dart-ui-bs/breadcrumb_trail.dart';
import '../dart-ui-bs/data_grid.dart';
import '../dart-ui-bs/date_pills.dart';
import '../dart-ui-bs/fab_menu.dart';
import '../dart-ui-bs/glow_field.dart';
import '../dart-ui-bs/neon_button.dart';
import '../dart-ui-bs/number_stepper.dart';
import 'package:flutter/material.dart';

class GenAppEnt4Screen extends StatefulWidget {
  const GenAppEnt4Screen({super.key});

  @override
  State<GenAppEnt4Screen> createState() => _GenAppEnt4ScreenState();
}

class _GenAppEnt4ScreenState extends State<GenAppEnt4Screen> {
  String _t1 = '';
  String _t2 = '';

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_app_ent4_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          BreadcrumbTrail(labels: const <String>[gen_app_ent4_crumbs_option, gen_app_ent4_crumbs_option2, gen_app_ent4_crumbs_option3, gen_app_ent4_crumbs_option4], height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent4_header_text),
          InlineTextRow(label: gen_app_ent4_textfield_label, hint: gen_app_ent4_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v)),
          GlowField(hint: gen_app_ent4_glowfield_hint, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          DatePills(height: 16, days: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          InlineTextRow(label: gen_app_ent4_textfield_label2, hint: gen_app_ent4_textfield_hint2, value: _t2, onChanged: (v) => setState(() => _t2 = v)),
          NumberStepper(label: gen_app_ent4_numstep_label, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          AnimatedToggle(label: gen_app_ent4_toggle_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FabMenu(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NeonButton(label: gen_app_ent4_neon_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, onPressed: () => _toast(gen_app_ent4_neon_toast)),
          CaSubTitle(gen_app_ent4_header_text2),
          DataGrid(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_app_ent4_banner_sub),
          ],
        ),
      ),
    );
  }
}
