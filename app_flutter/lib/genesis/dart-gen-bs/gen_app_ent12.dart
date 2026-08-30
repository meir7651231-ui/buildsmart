// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הירו 🗂️ עובד | ישות מורכבת — טופס + טבלה
// 🧬 בקשה: הירו 🗂️ עובד | ישות מורכבת — טופס + טבלה · כותרת טופס עובד · אטום InlineTextRow שם · אטום GlowField תפקיד · אטום InlineTextRow טלפון · אטום InlineTextRow חברה · אטום NumberStepper עלות לשעה · אטום AnimatedToggle סטטוס · אטום FabMenu שמירה · כותרת חוקים פר-שדה · חישוב אין שקעים שם פרטי (kForType) · חישוב נרמול טלפון למפתח דדופ (normPhone) · כותרת רשומות עובד · אטום DataGrid עובד · באנר ישות עובד: 6 שדות · 2 חוקים · מהמדף
// 🧬 אטומים שנבחרו: CaSubTitle · InlineTextRow · GlowField · InlineTextRow · InlineTextRow · NumberStepper · AnimatedToggle · FabMenu · CaSubTitle · RStat · RStat · CaSubTitle · DataGrid · CoinBanner
import '../dart-data-bs/auto/gen_app_ent12_content.dart';
import '../dart-maor/norm-phone.dart';
import '../dart-ui-bs/animated_toggle.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/inline_text_row.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/data_grid.dart';
import '../dart-ui-bs/fab_menu.dart';
import '../dart-ui-bs/glow_field.dart';
import '../dart-ui-bs/number_stepper.dart';
import '../dart/k_for_type.dart';
import 'package:flutter/material.dart';

class GenAppEnt12Screen extends StatefulWidget {
  const GenAppEnt12Screen({super.key});

  @override
  State<GenAppEnt12Screen> createState() => _GenAppEnt12ScreenState();
}

class _GenAppEnt12ScreenState extends State<GenAppEnt12Screen> {
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
        appBar: AppBar(title: Text(gen_app_ent12_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          CaSubTitle(gen_app_ent12_header_text),
          InlineTextRow(label: gen_app_ent12_textfield_label, hint: gen_app_ent12_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v)),
          GlowField(hint: gen_app_ent12_glowfield_hint, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          InlineTextRow(label: gen_app_ent12_textfield_label2, hint: gen_app_ent12_textfield_hint2, value: _t2, onChanged: (v) => setState(() => _t2 = v)),
          InlineTextRow(label: gen_app_ent12_textfield_label3, hint: gen_app_ent12_textfield_hint3, value: _t3, onChanged: (v) => setState(() => _t3 = v)),
          NumberStepper(label: gen_app_ent12_numstep_label, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          AnimatedToggle(label: gen_app_ent12_toggle_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FabMenu(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent12_header_text2),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: kForType(null).toString(), label: gen_app_ent12_stat_label), RStat(value: normPhone(null), label: gen_app_ent12_stat_label2)])),
          CaSubTitle(gen_app_ent12_header_text3),
          DataGrid(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_app_ent12_banner_sub),
          ],
        ),
      ),
    );
  }
}
