// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הירו 🗂️ סעיף כתב כמויות | ישות מורכבת — טופס + טבלה
// 🧬 בקשה: הירו 🗂️ סעיף כתב כמויות | ישות מורכבת — טופס + טבלה · כותרת טופס סעיף כתב כמויות · אטום InlineTextRow קוד · אטום GlowField פרק · אטום InlineTextRow תיאור · אטום InlineTextRow יחידת מידה · אטום NumberStepper כמות · אטום QtyStepper מחיר יחידה · אטום NumberStepper מחיר מכירה · אטום AnimatedToggle סטטוס · אטום FabMenu שמירה · כותרת רשומות סעיף כתב כמויות · אטום DataGrid סעיף כתב כמויות · באנר ישות סעיף כתב כמויות: 8 שדות · מהמדף
// 🧬 אטומים שנבחרו: CaSubTitle · InlineTextRow · GlowField · InlineTextRow · InlineTextRow · NumberStepper · QtyStepper · NumberStepper · AnimatedToggle · FabMenu · CaSubTitle · DataGrid · CoinBanner
import '../dart-data-bs/auto/gen_app_ent5_content.dart';
import '../dart-ui-bs/animated_toggle.dart';
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

class GenAppEnt5Screen extends StatefulWidget {
  const GenAppEnt5Screen({super.key});

  @override
  State<GenAppEnt5Screen> createState() => _GenAppEnt5ScreenState();
}

class _GenAppEnt5ScreenState extends State<GenAppEnt5Screen> {
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
        appBar: AppBar(title: Text(gen_app_ent5_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          CaSubTitle(gen_app_ent5_header_text),
          InlineTextRow(label: gen_app_ent5_textfield_label, hint: gen_app_ent5_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v)),
          GlowField(hint: gen_app_ent5_glowfield_hint, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          InlineTextRow(label: gen_app_ent5_textfield_label2, hint: gen_app_ent5_textfield_hint2, value: _t2, onChanged: (v) => setState(() => _t2 = v)),
          InlineTextRow(label: gen_app_ent5_textfield_label3, hint: gen_app_ent5_textfield_hint3, value: _t3, onChanged: (v) => setState(() => _t3 = v)),
          NumberStepper(label: gen_app_ent5_numstep_label, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          QtyStepper(qty: _n4, onChanged: (v) => setState(() => _n4 = v)),
          NumberStepper(label: gen_app_ent5_numstep_label2, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          AnimatedToggle(label: gen_app_ent5_toggle_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FabMenu(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent5_header_text2),
          DataGrid(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_app_ent5_banner_sub),
          ],
        ),
      ),
    );
  }
}
