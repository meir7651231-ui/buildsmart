// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הירו 🎯 לוח זמנים גאנט עם משימות | נבנה מתיאור חופשי
// 🧬 בקשה: הירו 🎯 לוח זמנים גאנט עם משימות | נבנה מתיאור חופשי · אטום GanttBar משימות · אטום LineSpark אבני דרך · אטום BreadcrumbTrail נתיב קריטי · כותרת לוח זמנים גאנט עם משימות · לוגיקה חיה · חישוב קופסה חיווט לוח עברי (hebMonthHeWired) · באנר המחולל מרכיב UI + לוגיקה מהמדף, ובחר לבד לפי משמעות
// 🧬 אטומים שנבחרו: GanttBar · LineSpark · BreadcrumbTrail · CaSubTitle · RStat · CoinBanner
import '../dart-data-bs/auto/gen_app_scr5_content.dart';
import '../dart-maor/heb-cal-box.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/breadcrumb_trail.dart';
import '../dart-ui-bs/gantt_bar.dart';
import '../dart-ui-bs/line_spark.dart';
import 'package:flutter/material.dart';

class GenAppScr5Screen extends StatefulWidget {
  const GenAppScr5Screen({super.key});

  @override
  State<GenAppScr5Screen> createState() => _GenAppScr5ScreenState();
}

class _GenAppScr5ScreenState extends State<GenAppScr5Screen> {
  

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_app_scr5_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          GanttBar(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          LineSpark(height: 16, points: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          BreadcrumbTrail(labels: const <String>[], height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_scr5_header_text),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: hebMonthHeWired(DateTime.now()), label: gen_app_scr5_stat_label)])),
          CoinBanner(coins: 0, sub: gen_app_scr5_banner_sub),
          ],
        ),
      ),
    );
  }
}
