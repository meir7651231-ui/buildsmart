// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הירו 🗂️ נוכחות | ישות מורכבת — טופס + טבלה
// 🧬 בקשה: הירו 🗂️ נוכחות | ישות מורכבת — טופס + טבלה · כותרת טופס נוכחות · אטום InlineTextRow עובד · אטום GlowField פרויקט · אטום DatePills תאריך · אטום InlineTextRow כניסה · אטום InlineTextRow יציאה · אטום NumberStepper שעות · אטום InlineTextRow אישור · אטום FabMenu שמירה · כותרת חוקים פר-שדה · חישוב תאריך לתצוגה (fmtDate) · כותרת רשומות נוכחות · אטום DataGrid נוכחות · באנר ישות נוכחות: 7 שדות · 1 חוקים · מהמדף
// 🧬 אטומים שנבחרו: CaSubTitle · InlineTextRow · GlowField · DatePills · InlineTextRow · InlineTextRow · NumberStepper · InlineTextRow · FabMenu · CaSubTitle · RStat · CaSubTitle · DataGrid · CoinBanner
import '../dart-data-bs/auto/gen_app_ent24_content.dart';
import '../dart-maor/fmt-date.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/inline_text_row.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/data_grid.dart';
import '../dart-ui-bs/date_pills.dart';
import '../dart-ui-bs/fab_menu.dart';
import '../dart-ui-bs/glow_field.dart';
import '../dart-ui-bs/number_stepper.dart';
import 'package:flutter/material.dart';

class GenAppEnt24Screen extends StatefulWidget {
  const GenAppEnt24Screen({super.key});

  @override
  State<GenAppEnt24Screen> createState() => _GenAppEnt24ScreenState();
}

class _GenAppEnt24ScreenState extends State<GenAppEnt24Screen> {
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
        appBar: AppBar(title: Text(gen_app_ent24_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          CaSubTitle(gen_app_ent24_header_text),
          InlineTextRow(label: gen_app_ent24_textfield_label, hint: gen_app_ent24_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v)),
          GlowField(hint: gen_app_ent24_glowfield_hint, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          DatePills(height: 16, days: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          InlineTextRow(label: gen_app_ent24_textfield_label2, hint: gen_app_ent24_textfield_hint2, value: _t2, onChanged: (v) => setState(() => _t2 = v)),
          InlineTextRow(label: gen_app_ent24_textfield_label3, hint: gen_app_ent24_textfield_hint3, value: _t3, onChanged: (v) => setState(() => _t3 = v)),
          NumberStepper(label: gen_app_ent24_numstep_label, height: 16, target: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          InlineTextRow(label: gen_app_ent24_textfield_label4, hint: gen_app_ent24_textfield_hint4, value: _t4, onChanged: (v) => setState(() => _t4 = v)),
          FabMenu(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_ent24_header_text2),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: fmtDate(null), label: gen_app_ent24_stat_label)])),
          CaSubTitle(gen_app_ent24_header_text3),
          DataGrid(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_app_ent24_banner_sub),
          ],
        ),
      ),
    );
  }
}
