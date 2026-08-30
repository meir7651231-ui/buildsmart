// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הירו 🗂️ פרויקט | ישות מורכבת — טופס + טבלה
// 🧬 בקשה: הירו 🗂️ פרויקט | ישות מורכבת — טופס + טבלה · כותרת טופס פרויקט · אטום InlineTextRow שם · אטום GlowField כתובת · אטום NumberStepper תקציב · אטום DatePills תאריך התחלה · אטום ChatSettingsSwitchRow סטטוס · אטום FabMenu שמירה · כותרת רשומות פרויקט · אטום DataGrid פרויקט · כותרת מעבר-סטטוס · אטום NeonButton קדם סטטוס · באנר ישות פרויקט: 5 שדות · טופס + טבלה מהמדף
// 🧬 אטומים שנבחרו: CaSubTitle · InlineTextRow · GlowField · NumberStepper · DatePills · ChatSettingsSwitchRow · FabMenu · CaSubTitle · DataGrid · CaSubTitle · NeonButton · CoinBanner
import '../dart-data-bs/auto/gen_app_ent1_content.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/chat_settings_switch_row.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/inline_text_row.dart';
import '../dart-ui-bs/data_grid.dart';
import '../dart-ui-bs/date_pills.dart';
import '../dart-ui-bs/fab_menu.dart';
import '../dart-ui-bs/glow_field.dart';
import '../dart-ui-bs/neon_button.dart';
import '../dart-ui-bs/number_stepper.dart';
import 'package:flutter/material.dart';

class GenAppEnt1Screen extends StatefulWidget {
  const GenAppEnt1Screen({super.key});

  @override
  State<GenAppEnt1Screen> createState() => _GenAppEnt1ScreenState();
}

class _GenAppEnt1ScreenState extends State<GenAppEnt1Screen> {
  String _t1 = '';
  bool _v2 = false;

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
          CaSubTitle(gen_app_ent1_header_text),
          InlineTextRow(label: gen_app_ent1_textfield_label, hint: gen_app_ent1_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v)),
          GlowField(hint: gen_app_ent1_glowfield_hint, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NumberStepper(label: gen_app_ent1_numstep_label, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          DatePills(height: 16, days: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          ChatSettingsSwitchRow(fallback: gen_app_ent1_switch_fallback, label: gen_app_ent1_switch_label, value: _v2, onChanged: (v) => setState(() => _v2 = v)),
          FabMenu(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent1_header_text2),
          DataGrid(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent1_header_text3),
          NeonButton(label: gen_app_ent1_neon_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, onPressed: () => _toast(gen_app_ent1_neon_toast)),
          CoinBanner(coins: 0, sub: gen_app_ent1_banner_sub),
          ],
        ),
      ),
    );
  }
}
