// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הירו 🗂️ חשבונית | ישות מורכבת — טופס + טבלה
// 🧬 בקשה: הירו 🗂️ חשבונית | ישות מורכבת — טופס + טבלה · כותרת טופס חשבונית · אטום NumberStepper מספר · אטום InlineTextRow לקוח · אטום QtyStepper סכום · אטום GlowField מס · אטום DatePills תאריך · אטום AnimatedToggle סטטוס · אטום FabMenu שמירה · כותרת רשומות חשבונית · אטום DataGrid חשבונית · באנר ישות חשבונית: 6 שדות · מהמדף
// 🧬 אטומים שנבחרו: CaSubTitle · NumberStepper · InlineTextRow · QtyStepper · GlowField · DatePills · AnimatedToggle · FabMenu · CaSubTitle · DataGrid · CoinBanner
import '../dart-data-bs/auto/gen_app_ent5_content.dart';
import '../dart-ui-bs/animated_toggle.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/inline_text_row.dart';
import '../dart-ui-bs/auto/qty_stepper.dart';
import '../dart-ui-bs/data_grid.dart';
import '../dart-ui-bs/date_pills.dart';
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
  int _n2 = 0;

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
          NumberStepper(label: gen_app_ent5_numstep_label, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          InlineTextRow(label: gen_app_ent5_textfield_label, hint: gen_app_ent5_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v)),
          QtyStepper(qty: _n2, onChanged: (v) => setState(() => _n2 = v)),
          GlowField(hint: gen_app_ent5_glowfield_hint, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          DatePills(height: 16, days: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
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
