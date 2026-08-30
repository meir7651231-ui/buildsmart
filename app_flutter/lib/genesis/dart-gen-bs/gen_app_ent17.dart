// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הירו 🗂️ מסמך | ישות מורכבת — טופס + טבלה
// 🧬 בקשה: הירו 🗂️ מסמך | ישות מורכבת — טופס + טבלה · אטום BreadcrumbTrail מסמך: טיוטה / נבדק / אושר · כותרת טופס מסמך · אטום InlineTextRow פרויקט · אטום GlowField סוג · אטום InlineTextRow שם · אטום InlineTextRow גרסה · אטום DatePills תאריך · אטום InlineTextRow מאשר · אטום MiniCalendar תוקף · אטום AnimatedToggle סטטוס · אטום FabMenu שמירה · אטום NeonButton קדם לנבדק · כותרת חוקים פר-שדה · חישוב אין שקעים שם פרטי (kForType) · חישוב תאריך לתצוגה (fmtDate) · כותרת רשומות מסמך · אטום DataGrid מסמך · באנר ישות מסמך: 8 שדות · 3-שלבי workflow · 2 חוקים · מהמדף
// 🧬 אטומים שנבחרו: BreadcrumbTrail · CaSubTitle · InlineTextRow · GlowField · InlineTextRow · InlineTextRow · DatePills · InlineTextRow · MiniCalendar · AnimatedToggle · FabMenu · NeonButton · CaSubTitle · RStat · RStat · CaSubTitle · DataGrid · CoinBanner
import '../dart-data-bs/auto/gen_app_ent17_content.dart';
import '../dart-maor/fmt-date.dart';
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
import '../dart-ui-bs/mini_calendar.dart';
import '../dart-ui-bs/neon_button.dart';
import '../dart/k_for_type.dart';
import 'package:flutter/material.dart';

class GenAppEnt17Screen extends StatefulWidget {
  const GenAppEnt17Screen({super.key});

  @override
  State<GenAppEnt17Screen> createState() => _GenAppEnt17ScreenState();
}

class _GenAppEnt17ScreenState extends State<GenAppEnt17Screen> {
  String _t1 = '';
  String _t2 = '';
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
        appBar: AppBar(title: Text(gen_app_ent17_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          BreadcrumbTrail(labels: const <String>[gen_app_ent17_crumbs_option, gen_app_ent17_crumbs_option2, gen_app_ent17_crumbs_option3], height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent17_header_text),
          InlineTextRow(label: gen_app_ent17_textfield_label, hint: gen_app_ent17_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v)),
          GlowField(hint: gen_app_ent17_glowfield_hint, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          InlineTextRow(label: gen_app_ent17_textfield_label2, hint: gen_app_ent17_textfield_hint2, value: _t2, onChanged: (v) => setState(() => _t2 = v)),
          InlineTextRow(label: gen_app_ent17_textfield_label3, hint: gen_app_ent17_textfield_hint3, value: _t3, onChanged: (v) => setState(() => _t3 = v)),
          DatePills(height: 16, days: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          InlineTextRow(label: gen_app_ent17_textfield_label4, hint: gen_app_ent17_textfield_hint4, value: _t4, onChanged: (v) => setState(() => _t4 = v)),
          MiniCalendar(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          AnimatedToggle(label: gen_app_ent17_toggle_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FabMenu(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NeonButton(label: gen_app_ent17_neon_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, onPressed: () => _toast(gen_app_ent17_neon_toast)),
          CaSubTitle(gen_app_ent17_header_text2),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: kForType(null).toString(), label: gen_app_ent17_stat_label), RStat(value: fmtDate(null), label: gen_app_ent17_stat_label2)])),
          CaSubTitle(gen_app_ent17_header_text3),
          DataGrid(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_app_ent17_banner_sub),
          ],
        ),
      ),
    );
  }
}
