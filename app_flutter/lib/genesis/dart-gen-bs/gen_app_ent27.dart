// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הירו 🗂️ אחריות | ישות מורכבת — טופס + טבלה
// 🧬 בקשה: הירו 🗂️ אחריות | ישות מורכבת — טופס + טבלה · אטום BreadcrumbTrail אחריות: דווח / אושר / בטיפול / נסגר · כותרת טופס אחריות · אטום InlineTextRow פרויקט · אטום GlowField אזור · אטום InlineTextRow תיאור · אטום DatePills תוקף אחריות · אטום InlineTextRow קבלן אחראי · אטום AnimatedToggle סטטוס · אטום FabMenu שמירה · אטום NeonButton קדם לאושר · כותרת חוקים פר-שדה · חישוב סיווג אזור של מספר (phoneRegion) · כותרת רשומות אחריות · אטום DataGrid אחריות · באנר ישות אחריות: 6 שדות · 4-שלבי workflow · 1 חוקים · מהמדף
// 🧬 אטומים שנבחרו: BreadcrumbTrail · CaSubTitle · InlineTextRow · GlowField · InlineTextRow · DatePills · InlineTextRow · AnimatedToggle · FabMenu · NeonButton · CaSubTitle · RStat · CaSubTitle · DataGrid · CoinBanner
import '../dart-data-bs/auto/gen_app_ent27_content.dart';
import '../dart-maor/phone-region.dart';
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
import 'package:flutter/material.dart';

class GenAppEnt27Screen extends StatefulWidget {
  const GenAppEnt27Screen({super.key});

  @override
  State<GenAppEnt27Screen> createState() => _GenAppEnt27ScreenState();
}

class _GenAppEnt27ScreenState extends State<GenAppEnt27Screen> {
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
        appBar: AppBar(title: Text(gen_app_ent27_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          BreadcrumbTrail(labels: const <String>[gen_app_ent27_crumbs_option, gen_app_ent27_crumbs_option2, gen_app_ent27_crumbs_option3, gen_app_ent27_crumbs_option4], height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent27_header_text),
          InlineTextRow(label: gen_app_ent27_textfield_label, hint: gen_app_ent27_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v)),
          GlowField(hint: gen_app_ent27_glowfield_hint, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          InlineTextRow(label: gen_app_ent27_textfield_label2, hint: gen_app_ent27_textfield_hint2, value: _t2, onChanged: (v) => setState(() => _t2 = v)),
          DatePills(height: 16, days: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          InlineTextRow(label: gen_app_ent27_textfield_label3, hint: gen_app_ent27_textfield_hint3, value: _t3, onChanged: (v) => setState(() => _t3 = v)),
          AnimatedToggle(label: gen_app_ent27_toggle_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FabMenu(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NeonButton(label: gen_app_ent27_neon_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, onPressed: () => _toast(gen_app_ent27_neon_toast)),
          CaSubTitle(gen_app_ent27_header_text2),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: phoneRegion(null), label: gen_app_ent27_stat_label)])),
          CaSubTitle(gen_app_ent27_header_text3),
          DataGrid(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_app_ent27_banner_sub),
          ],
        ),
      ),
    );
  }
}
