// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: רכיבים חיים - משוב
// 🧬 בקשה: רכיבים חיים - משוב: · הירו 🔔 משוב | התראות התקדמות וסטטוס ממשפט · כותרת התראות · התראה 52 הפעולה הושלמה בהצלחה · סרגל 44 מד התקדמות · סטטוס 44 מחובר עכשיו · תג 32 חדש · באנר כל חיווי כאן חי - נבחר ממילה בעברית
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · AlertBanner · LinearProgress · LiveStatusDot · BadgePill · CoinBanner
import '../dart-data-bs/auto/gen_feedback10_content.dart';
import '../dart-ui-bs/alert_banner.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/badge_pill.dart';
import '../dart-ui-bs/hero_card.dart';
import '../dart-ui-bs/linear_progress.dart';
import '../dart-ui-bs/live_status_dot.dart';
import 'package:flutter/material.dart';

class GenFeedback10Screen extends StatefulWidget {
  const GenFeedback10Screen({super.key});

  @override
  State<GenFeedback10Screen> createState() => _GenFeedback10ScreenState();
}

class _GenFeedback10ScreenState extends State<GenFeedback10Screen> {
  

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_feedback10_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_feedback10_card_glyph, title: gen_feedback10_card_title, sub: gen_feedback10_card_sub, onTap: () => _toast(gen_feedback10_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CaSubTitle(gen_feedback10_header_text),
          AlertBanner(label: gen_feedback10_alert_label, height: 52, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          LinearProgress(height: 44, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          LiveStatusDot(label: gen_feedback10_statusdot_label, height: 44, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          BadgePill(label: gen_feedback10_badgepill_label, height: 32, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_feedback10_banner_sub),
          ],
        ),
      ),
    );
  }
}
