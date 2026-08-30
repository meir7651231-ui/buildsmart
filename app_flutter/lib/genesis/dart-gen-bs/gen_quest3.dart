// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: עולם משחק שלם - חדר 3
// 🧬 בקשה: עולם משחק שלם - חדר 3: · הירו 🎯 עולם משחק שלם של מסע בריחה - חדרים שמובילים זה אל זה חידות חיות שמגיבות לשחקן ושערים נסתרים בדרך אל היציאה | מטרה אחת קיבלתי - את המבנה האטומים והחיבורים בחרתי לבד · מתג 🔓 מתג השער - פתיחתו חושפת מנוע חבוי · חישוב מגיעים כפרמטרים אין טהור דטרמיניסטי (validDateRange) · ניווט quest1 חזרה אל תחילת המסע | המסע ממשיך · באנר מטרה אחת קיבלתי מהבעלים - את כל השאר תכננתי בחרתי וחיווטתי לבד מהמדף החי
// 🧬 אטומים שנבחרו: HeroCard · SwitchRow · HeroCard · CoinBanner · RStat
import '../dart-data-bs/auto/gen_quest3_content.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/auto/switch_row.dart';
import '../dart-ui-bs/hero_card.dart';
import '../dart/valid_date_range.dart';
import 'gen_quest1.dart';
import 'package:flutter/material.dart';

class GenQuest3Screen extends StatefulWidget {
  const GenQuest3Screen({super.key});

  @override
  State<GenQuest3Screen> createState() => _GenQuest3ScreenState();
}

class _GenQuest3ScreenState extends State<GenQuest3Screen> {
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
        appBar: AppBar(title: Text(gen_quest3_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_quest3_card_glyph, title: gen_quest3_card_title, sub: gen_quest3_card_sub, onTap: () => _toast(gen_quest3_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          SwitchRow(label: gen_quest3_switch_label, value: _v1, onChanged: (v) => setState(() => _v1 = v)),
          if (_v1) Row(children: [RStat(value: validDateRange(DateTime.now(), DateTime.now()).toString(), label: gen_quest3_stat_label)]),
          HeroCard(glyph: gen_quest3_card_glyph2, title: gen_quest3_card_title2, sub: gen_quest3_card_sub2, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GenQuest1Screen())), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CoinBanner(coins: 0, sub: gen_quest3_banner_sub),
          ],
        ),
      ),
    );
  }
}
