// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: 🗂️ קריאת תחזוקה
// 🧬 בקשה: הירו 🗂️ קריאת תחזוקה | ישות מורכבת — טופס + טבלה · אטום BreadcrumbTrail קריאת תחזוקה: דווח / סווג / בטיפול / תוקן / נסגר · כותרת טופס קריאת תחזוקה · אטום FieldRow ציוד · אטום FieldRow מיקום · אטום InlineTextRow תיאור · אטום FieldRow דחיפות · אטום FieldRow אחראי · אטום AnimatedToggle סטטוס · אטום FabMenu שמירה · אטום NeonButton קדם לסווג · כותרת רשומות קריאת תחזוקה · אטום DataGrid קריאת תחזוקה · באנר ישות קריאת תחזוקה: 6 שדות · 5-שלבי workflow · מהמדף
// 🧬 אטומים שנבחרו: BreadcrumbTrail · CaSubTitle · FieldRow · FieldRow · InlineTextRow · FieldRow · FieldRow · AnimatedToggle · FabMenu · NeonButton · CaSubTitle · DataGrid · CoinBanner
import '../dart-data-bs/auto/gen_app_ent25_content.dart';
import '../dart-ui-bs/animated_toggle.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/inline_text_row.dart';
import '../dart-ui-bs/breadcrumb_trail.dart';
import '../dart-ui-bs/data_grid.dart';
import '../dart-ui-bs/fab_menu.dart';
import '../dart-ui-bs/field_row.dart';
import '../dart-ui-bs/neon_button.dart';
import 'package:flutter/material.dart';

class GenAppEnt25Screen extends StatefulWidget {
  const GenAppEnt25Screen({super.key});

  @override
  State<GenAppEnt25Screen> createState() => _GenAppEnt25ScreenState();
}

class _GenAppEnt25ScreenState extends State<GenAppEnt25Screen> {
  String _t1 = '';
  String _t2 = '';
  String _t3 = '';
  String _t4 = '';
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
        appBar: AppBar(title: Text(gen_app_ent25_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          BreadcrumbTrail(labels: const <String>[gen_app_ent25_crumbs_option, gen_app_ent25_crumbs_option2, gen_app_ent25_crumbs_option3, gen_app_ent25_crumbs_option4, gen_app_ent25_crumbs_option5], height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent25_header_text),
          FieldRow(label: gen_app_ent25_textfield_label, hint: gen_app_ent25_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent25_textfield_label2, hint: gen_app_ent25_textfield_hint2, value: _t2, onChanged: (v) => setState(() => _t2 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          InlineTextRow(label: gen_app_ent25_textfield_label3, hint: gen_app_ent25_textfield_hint3, value: _t3, onChanged: (v) => setState(() => _t3 = v)),
          FieldRow(label: gen_app_ent25_textfield_label4, hint: gen_app_ent25_textfield_hint4, value: _t4, onChanged: (v) => setState(() => _t4 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          FieldRow(label: gen_app_ent25_textfield_label5, hint: gen_app_ent25_textfield_hint5, value: _t5, onChanged: (v) => setState(() => _t5 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, accentColor: BsTokens.brand, fillColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          AnimatedToggle(label: gen_app_ent25_toggle_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FabMenu(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NeonButton(label: gen_app_ent25_neon_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, onPressed: () => _toast(gen_app_ent25_neon_toast)),
          CaSubTitle(gen_app_ent25_header_text2),
          DataGrid(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_app_ent25_banner_sub),
          ],
        ),
      ),
    );
  }
}
