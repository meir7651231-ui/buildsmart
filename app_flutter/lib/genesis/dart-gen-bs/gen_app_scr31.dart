// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הירו 🎯 דשבורד מנהל פרויקט עם התקדמות | נבנה מתיאור חופשי
// 🧬 בקשה: הירו 🎯 דשבורד מנהל פרויקט עם התקדמות | נבנה מתיאור חופשי · אטום LinearProgress התקדמות · אטום GanttBar גאנט · אטום BreadcrumbTrail נתיב קריטי · כותרת דשבורד מנהל פרויקט עם התקדמות · לוגיקה חיה · חישוב כרעת מנהל (isAdmin) · באנר המחולל מרכיב UI + לוגיקה מהמדף, ובחר לבד לפי משמעות
// 🧬 אטומים שנבחרו: LinearProgress · GanttBar · BreadcrumbTrail · CaSubTitle · RStat · CoinBanner
import '../dart-data-bs/auto/gen_app_scr31_content.dart';
import '../dart-maor/is-admin.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/breadcrumb_trail.dart';
import '../dart-ui-bs/gantt_bar.dart';
import '../dart-ui-bs/linear_progress.dart';
import 'package:flutter/material.dart';

class GenAppScr31Screen extends StatefulWidget {
  const GenAppScr31Screen({super.key});

  @override
  State<GenAppScr31Screen> createState() => _GenAppScr31ScreenState();
}

class _GenAppScr31ScreenState extends State<GenAppScr31Screen> {
  

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_app_scr31_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          LinearProgress(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          GanttBar(height: 16, rows: 0, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          BreadcrumbTrail(labels: const <String>[], height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CaSubTitle(gen_app_scr31_header_text),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: isAdmin(null, null).toString(), label: gen_app_scr31_stat_label)])),
          CoinBanner(coins: 0, sub: gen_app_scr31_banner_sub),
          ],
        ),
      ),
    );
  }
}
