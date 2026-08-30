// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הירו 🗂️ תקציב | ישות מורכבת — טופס + טבלה
// 🧬 בקשה: הירו 🗂️ תקציב | ישות מורכבת — טופס + טבלה · כותרת טופס תקציב · אטום InlineTextRow פרויקט · אטום GlowField סעיף · אטום NumberStepper תקציב מאושר · אטום QtyStepper עלות מחויבת · אטום NumberStepper עלות בפועל · אטום InlineTextRow תחזית · אטום InlineTextRow סטייה · אטום FabMenu שמירה · כותרת רשומות תקציב · אטום DataGrid תקציב · באנר ישות תקציב: 7 שדות · מהמדף
// 🧬 אטומים שנבחרו: CaSubTitle · InlineTextRow · GlowField · NumberStepper · QtyStepper · NumberStepper · InlineTextRow · InlineTextRow · FabMenu · CaSubTitle · DataGrid · CoinBanner
import '../dart-data-bs/auto/gen_app_ent9_content.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/inline_text_row.dart';
import '../dart-ui-bs/auto/qty_stepper.dart';
import '../dart-ui-bs/data_grid.dart';
import '../dart-ui-bs/fab_menu.dart';
import '../dart-ui-bs/glow_field.dart';
import '../dart-ui-bs/number_stepper.dart';
import 'package:flutter/material.dart';

class GenAppEnt9Screen extends StatefulWidget {
  const GenAppEnt9Screen({super.key});

  @override
  State<GenAppEnt9Screen> createState() => _GenAppEnt9ScreenState();
}

class _GenAppEnt9ScreenState extends State<GenAppEnt9Screen> {
  String _t1 = '';
  int _n2 = 0;
  String _t3 = '';
  String _t4 = '';

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_app_ent9_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          CaSubTitle(gen_app_ent9_header_text),
          InlineTextRow(label: gen_app_ent9_textfield_label, hint: gen_app_ent9_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v)),
          GlowField(hint: gen_app_ent9_glowfield_hint, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NumberStepper(label: gen_app_ent9_numstep_label, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          QtyStepper(qty: _n2, onChanged: (v) => setState(() => _n2 = v)),
          NumberStepper(label: gen_app_ent9_numstep_label2, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          InlineTextRow(label: gen_app_ent9_textfield_label2, hint: gen_app_ent9_textfield_hint2, value: _t3, onChanged: (v) => setState(() => _t3 = v)),
          InlineTextRow(label: gen_app_ent9_textfield_label3, hint: gen_app_ent9_textfield_hint3, value: _t4, onChanged: (v) => setState(() => _t4 = v)),
          FabMenu(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent9_header_text2),
          DataGrid(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_app_ent9_banner_sub),
          ],
        ),
      ),
    );
  }
}
