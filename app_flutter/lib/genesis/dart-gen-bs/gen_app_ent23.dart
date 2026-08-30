// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הירו 🗂️ אירוע בטיחות | ישות מורכבת — טופס + טבלה
// 🧬 בקשה: הירו 🗂️ אירוע בטיחות | ישות מורכבת — טופס + טבלה · אטום BreadcrumbTrail אירוע בטיחות: דווח / נחסם / בתחקיר / טופל / נסגר · כותרת טופס אירוע בטיחות · אטום DatePills תאריך · אטום InlineTextRow מיקום · אטום GlowField חומרה · אטום InlineTextRow מעורבים · אטום InlineTextRow תיאור · אטום InlineTextRow גורם שורש · אטום AnimatedToggle סטטוס · אטום FabMenu שמירה · אטום NeonButton קדם לנחסם · כותרת חוקים פר-שדה · חישוב תאריך לתצוגה (fmtDate) · כותרת רשומות אירוע בטיחות · אטום DataGrid אירוע בטיחות · באנר ישות אירוע בטיחות: 7 שדות · 5-שלבי workflow · 1 חוקים · מהמדף
// 🧬 אטומים שנבחרו: BreadcrumbTrail · CaSubTitle · DatePills · InlineTextRow · GlowField · InlineTextRow · InlineTextRow · InlineTextRow · AnimatedToggle · FabMenu · NeonButton · CaSubTitle · RStat · CaSubTitle · DataGrid · CoinBanner
import '../dart-data-bs/auto/gen_app_ent23_content.dart';
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
import '../dart-ui-bs/neon_button.dart';
import 'package:flutter/material.dart';

class GenAppEnt23Screen extends StatefulWidget {
  const GenAppEnt23Screen({super.key});

  @override
  State<GenAppEnt23Screen> createState() => _GenAppEnt23ScreenState();
}

class _GenAppEnt23ScreenState extends State<GenAppEnt23Screen> {
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
        appBar: AppBar(title: Text(gen_app_ent23_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          BreadcrumbTrail(labels: const <String>[gen_app_ent23_crumbs_option, gen_app_ent23_crumbs_option2, gen_app_ent23_crumbs_option3, gen_app_ent23_crumbs_option4, gen_app_ent23_crumbs_option5], height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent23_header_text),
          DatePills(height: 16, days: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          InlineTextRow(label: gen_app_ent23_textfield_label, hint: gen_app_ent23_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v)),
          GlowField(hint: gen_app_ent23_glowfield_hint, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          InlineTextRow(label: gen_app_ent23_textfield_label2, hint: gen_app_ent23_textfield_hint2, value: _t2, onChanged: (v) => setState(() => _t2 = v)),
          InlineTextRow(label: gen_app_ent23_textfield_label3, hint: gen_app_ent23_textfield_hint3, value: _t3, onChanged: (v) => setState(() => _t3 = v)),
          InlineTextRow(label: gen_app_ent23_textfield_label4, hint: gen_app_ent23_textfield_hint4, value: _t4, onChanged: (v) => setState(() => _t4 = v)),
          AnimatedToggle(label: gen_app_ent23_toggle_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          FabMenu(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          NeonButton(label: gen_app_ent23_neon_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, onPressed: () => _toast(gen_app_ent23_neon_toast)),
          CaSubTitle(gen_app_ent23_header_text2),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: fmtDate(null), label: gen_app_ent23_stat_label)])),
          CaSubTitle(gen_app_ent23_header_text3),
          DataGrid(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_app_ent23_banner_sub),
          ],
        ),
      ),
    );
  }
}
