// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: עולם משחק שלם - חדר 2
// 🧬 בקשה: עולם משחק שלם - חדר 2: · הירו 🎯 עולם משחק שלם של מסע בריחה - חדרים שמובילים זה אל זה חידות חיות שמגיבות לשחקן ושערים נסתרים בדרך אל היציאה | מטרה אחת קיבלתי - את המבנה האטומים והחיבורים בחרתי לבד · מתג 🔓 מתג השער - פתיחתו חושפת מנוע חבוי · חישוב שם חודש עברי (hebMonthHe) · ניווט quest1 חזרה אל תחילת המסע | המסע ממשיך · באנר מטרה אחת קיבלתי מהבעלים - את כל השאר תכננתי בחרתי וחיווטתי לבד מהמדף החי
// 🧬 אטומים שנבחרו: HeroCard · SwitchRow · HeroCard · CoinBanner · RStat
import '../dart-data-bs/auto/gen_quest2_content.dart';
import '../dart-maor/heb-month-he.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/auto/switch_row.dart';
import '../dart-ui-bs/hero_card.dart';
import 'gen_quest1.dart';
import 'package:flutter/material.dart';

class GenQuest2Screen extends StatefulWidget {
  const GenQuest2Screen({super.key});

  @override
  State<GenQuest2Screen> createState() => _GenQuest2ScreenState();
}

class _GenQuest2ScreenState extends State<GenQuest2Screen> {
  bool _v1 = false;

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_quest2_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_quest2_card_glyph, title: gen_quest2_card_title, sub: gen_quest2_card_sub, onTap: () => _toast(gen_quest2_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          SwitchRow(label: gen_quest2_switch_label, value: _v1, onChanged: (v) => setState(() => _v1 = v)),
          if (_v1) Row(children: [RStat(value: hebMonthHe(DateTime.now()), label: gen_quest2_stat_label)]),
          HeroCard(glyph: gen_quest2_card_glyph2, title: gen_quest2_card_title2, sub: gen_quest2_card_sub2, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GenQuest1Screen())), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CoinBanner(coins: 0, sub: gen_quest2_banner_sub),
          ],
        ),
      ),
    );
  }
}
