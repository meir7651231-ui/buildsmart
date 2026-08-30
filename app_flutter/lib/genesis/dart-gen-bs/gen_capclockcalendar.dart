// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: מסע-בזמן של השעון - שעת-יממה נהפכת לתאריך-תצוגה כשכל דקה מחצות נספרת כיום שלם בלוח
// 🧬 בקשה: מסע-בזמן של השעון - שעת-יממה נהפכת לתאריך-תצוגה כשכל דקה מחצות נספרת כיום שלם בלוח: · הירו 🧪 מסע-בזמן של השעון - שעת-יממה נהפכת לתאריך-תצוגה כשכל דקה מחצות נספרת כיום שלם בלוח | יכולת שהוזמנה ולא היתה קיימת - הרכבתי אותה לבד מ-3 אטומים והוכחתי על 2 דוגמאות · אטום ChipWrap מסע-בזמן של השעון - שעת-יממה נהפכת לתאריך-תצוגה כשכל דקה מחצות נספרת כיום שלם בלוח: 13:05 / 07:45 · חישוב לדקות מחצות (timeToMin) · חישוב מספר סידורי של (excelSerialToIso) · חישוב תאריך לתצוגה (fmtDate) · באנר ההרכבה שמצאתי - timeToMin ⟵ excelSerialToIso ⟵ fmtDate - כל הדוגמאות עברו
// 🧬 אטומים שנבחרו: HeroCard · ChipWrap · CoinBanner · RStat · RStat · RStat
import '../dart-data-bs/auto/gen_capclockcalendar_content.dart';
import '../dart-maor/excel-serial-to-iso.dart';
import '../dart-maor/fmt-date.dart';
import '../dart-maor/time-to-min.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/chip_wrap.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/hero_card.dart';
import 'package:flutter/material.dart';

class GenCapclockcalendarScreen extends StatefulWidget {
  const GenCapclockcalendarScreen({super.key});

  @override
  State<GenCapclockcalendarScreen> createState() => _GenCapclockcalendarScreenState();
}

class _GenCapclockcalendarScreenState extends State<GenCapclockcalendarScreen> {
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
        appBar: AppBar(title: Text(gen_capclockcalendar_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_capclockcalendar_card_glyph, title: gen_capclockcalendar_card_title, sub: gen_capclockcalendar_card_sub, onTap: () => _toast(gen_capclockcalendar_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          ChipWrap(options: const <String>[gen_capclockcalendar_chip_option, gen_capclockcalendar_chip_option2], selected: _t1, onSelect: (v) => setState(() => _t1 = v)),
          Row(children: [RStat(value: timeToMin(_t1).toString(), label: gen_capclockcalendar_stat_label)]),
          Row(children: [RStat(value: excelSerialToIso((timeToMin(_t1).toString())), label: gen_capclockcalendar_stat_label2)]),
          Row(children: [RStat(value: fmtDate((excelSerialToIso((timeToMin(_t1).toString())))), label: gen_capclockcalendar_stat_label3)]),
          CoinBanner(coins: 0, sub: gen_capclockcalendar_banner_sub),
          ],
        ),
      ),
    );
  }
}
