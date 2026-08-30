// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: ראווה - כרטיס-הביקור החי של המחולל
// 🧬 בקשה: ראווה - כרטיס-הביקור החי של המחולל: · הירו 🧬 המחולל של המחצב | מפעל-האטומים החי - כל מספר כאן נמדד מהאטלס ברגע-החילול · כותרת המספרים החיים - מהאטלס ברגע-החילול · אטום KpiBox 381 לבנים ויזואליות | מדף-התצוגה החי · אטום KpiBox 445 אטומי לוגיקה פעילים | מדף-המנועים · אטום KpiBox 1271 אטומי דאטה | אוצר-הידע שחולץ בטיהור · כותרת צינור-הייצור - מהמחצבה אל המסך · אטום PipeLink 0.9 פירוק - זיקוק - הרכבה - חיווט | הזרימה חיה - כל ריצה של המנוע-האחד עוברת כאן · כותרת מנוע-הסינתזה - יכולות שהוזמנו והורכבו לבד · אטום StatsCard 4 0 0 4 הזמנות-יכולת | הוכחו על התאומים החיים - דוגמה-בדוגמה: הוכחו / בבדיקה / נדחו · אטום ManagerDashboardCreditBar 100 הזמנות שהוכחו מתוך שהוזמנו · כותרת היכולות בפעולה - הקישו לפתיחה · ניווט capmailphone שחזור מספר טלפון לתצוגה ישראלית תקנית מתוך שורה שהגיעה עטופה בקידוד-מייל ישן | נוצר מבקשה בעברית - הקישו לפתיחה · ניווט captimegematria חתימת-אותיות עברית לשעה על השעון - כמה דקות עברו מחצות הלילה כתוב בגימטריה | נוצר מבקשה בעברית - הקישו לפתיחה · ניווט capclockcalendar מסע-בזמן של השעון - שעת-יממה נהפכת לתאריך-תצוגה כשכל דקה מחצות נספרת כיום שלם בלוח | נוצר מבקשה בעברית - הקישו לפתיחה · ניווט capautodream הזמנה-עצמית - יכולת שחלמתי היום והוכחתי לבד - מסיר את איבר ואז זהות עובד קנונית | נוצר מבקשה בעברית - הקישו לפתיחה · ניווט improv יכולת מאולתרת - שרשרת חמישה | נוצר מבקשה בעברית - הקישו לפתיחה · ניווט quest1 עולם משחק שלם - חדר 1 | נוצר מבקשה בעברית - הקישו לפתיחה · באנר 11 שערי-המשטרה ירוקים על כל commit - את הראווה הזו מדדתי והרכבתי לבד מהאטלס החי
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · KpiBox · KpiBox · KpiBox · CaSubTitle · PipeLink · CaSubTitle · StatsCard · ManagerDashboardCreditBar · CaSubTitle · HeroCard · HeroCard · HeroCard · HeroCard · HeroCard · HeroCard · CoinBanner
import '../dart-data-bs/auto/gen_showcase_content.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/kpi_box.dart';
import '../dart-ui-bs/auto/manager_dashboard_credit_bar.dart';
import '../dart-ui-bs/auto/pipe_link.dart';
import '../dart-ui-bs/auto/stats_card.dart';
import '../dart-ui-bs/hero_card.dart';
import 'gen_capautodream.dart';
import 'gen_capclockcalendar.dart';
import 'gen_capmailphone.dart';
import 'gen_captimegematria.dart';
import 'gen_improv.dart';
import 'gen_quest1.dart';
import 'package:flutter/material.dart';

class GenShowcaseScreen extends StatefulWidget {
  const GenShowcaseScreen({super.key});

  @override
  State<GenShowcaseScreen> createState() => _GenShowcaseScreenState();
}

class _GenShowcaseScreenState extends State<GenShowcaseScreen> {
  

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_showcase_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_showcase_card_glyph, title: gen_showcase_card_title, sub: gen_showcase_card_sub, onTap: () => _toast(gen_showcase_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CaSubTitle(gen_showcase_header_text),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [KpiBox(label2: gen_showcase_stat_label2, value: gen_showcase_stat_value, label: gen_showcase_stat_label, onTap: () => _toast(gen_showcase_stat_toast)), KpiBox(label2: gen_showcase_stat_label22, value: gen_showcase_stat_value2, label: gen_showcase_stat_label3, onTap: () => _toast(gen_showcase_stat_toast2)), KpiBox(label2: gen_showcase_stat_label23, value: gen_showcase_stat_value3, label: gen_showcase_stat_label4, onTap: () => _toast(gen_showcase_stat_toast3))])),
          CaSubTitle(gen_showcase_header_text2),
          PipeLink(label: gen_showcase_other_label, label2: gen_showcase_other_label2, from: BsTokens.brand, to: BsTokens.inkLight, flow: 0.9, broken: false),
          CaSubTitle(gen_showcase_header_text3),
          StatsCard(fallback: gen_showcase_stat_fallback, label: gen_showcase_stat_label5, label2: gen_showcase_stat_label24, label3: gen_showcase_stat_label32, done: 4, inReview: 0, rejected: 0, total: 4),
          ManagerDashboardCreditBar(label: gen_showcase_other_label3, pct: 100, color: BsTokens.brand),
          CaSubTitle(gen_showcase_header_text4),
          HeroCard(glyph: gen_showcase_card_glyph2, title: gen_showcase_card_title2, sub: gen_showcase_card_sub2, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GenCapmailphoneScreen())), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          HeroCard(glyph: gen_showcase_card_glyph3, title: gen_showcase_card_title3, sub: gen_showcase_card_sub3, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GenCaptimegematriaScreen())), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          HeroCard(glyph: gen_showcase_card_glyph4, title: gen_showcase_card_title4, sub: gen_showcase_card_sub4, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GenCapclockcalendarScreen())), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          HeroCard(glyph: gen_showcase_card_glyph5, title: gen_showcase_card_title5, sub: gen_showcase_card_sub5, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GenCapautodreamScreen())), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          HeroCard(glyph: gen_showcase_card_glyph6, title: gen_showcase_card_title6, sub: gen_showcase_card_sub6, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GenImprovScreen())), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          HeroCard(glyph: gen_showcase_card_glyph7, title: gen_showcase_card_title7, sub: gen_showcase_card_sub7, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GenQuest1Screen())), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CoinBanner(coins: 11, sub: gen_showcase_banner_sub),
          ],
        ),
      ),
    );
  }
}
