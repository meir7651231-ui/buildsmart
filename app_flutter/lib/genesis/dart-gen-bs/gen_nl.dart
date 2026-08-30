// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הירו 🎯 לוח בקרה לאירוח עם כרטיס אורח | נבנה מתיאור חופשי
// 🧬 בקשה: הירו 🎯 לוח בקרה לאירוח עם כרטיס אורח | נבנה מתיאור חופשי · אטום BareStat כרטיס אורח · אטום DataGrid טבלת הזמנות · אטום MiniCalendar לוח חודש עברי · אטום DatePills תאריך לתצוגה · כותרת לוח בקרה לאירוח עם כרטיס אורח · לוגיקה חיה · חישוב תאריך לתצוגה (fmtDate) · חישוב קופסה חיווט לוח עברי (hebMonthHeWired) · חישוב שם חודש עברי (hebMonthHe) · באנר המחולל מרכיב UI + לוגיקה מהמדף, ובחר לבד לפי משמעות
// 🧬 אטומים שנבחרו: BareStat · DataGrid · MiniCalendar · DatePills · CaSubTitle · RStat · RStat · RStat · CoinBanner
import '../dart-data-bs/auto/gen_nl_content.dart';
import '../dart-maor/fmt-date.dart';
import '../dart-maor/heb-cal-box.dart';
import '../dart-maor/heb-month-he.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/bare_stat.dart';
import '../dart-ui-bs/data_grid.dart';
import '../dart-ui-bs/date_pills.dart';
import '../dart-ui-bs/mini_calendar.dart';
import 'package:flutter/material.dart';

class GenNlScreen extends StatefulWidget {
  const GenNlScreen({super.key});

  @override
  State<GenNlScreen> createState() => _GenNlScreenState();
}

class _GenNlScreenState extends State<GenNlScreen> {
  String _t1 = '';

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_nl_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          BareStat(value: _t1, label: gen_nl_stat_label, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight),
          DataGrid(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          MiniCalendar(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          DatePills(height: 16, days: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_nl_header_text),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: fmtDate(null), label: gen_nl_stat_label2), RStat(value: hebMonthHeWired(DateTime.now()), label: gen_nl_stat_label3), RStat(value: hebMonthHe(DateTime.now()), label: gen_nl_stat_label4)])),
          CoinBanner(coins: 0, sub: gen_nl_banner_sub),
          ],
        ),
      ),
    );
  }
}
