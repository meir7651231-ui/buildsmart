// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הירו 🎯 דשבורד מנהל אתר עם משימות היום | נבנה מתיאור חופשי
// 🧬 בקשה: הירו 🎯 דשבורד מנהל אתר עם משימות היום | נבנה מתיאור חופשי · אטום StripGroupCard דשבורד מנהל אתר עם משימות היום · אטום StockTab דשבורד מנהל אתר עם משימות היום · אטום ChipCloud דשבורד מנהל אתר עם משימות היום · אטום EmptyStateCard דשבורד מנהל אתר עם משימות היום · אטום BareStat דשבורד מנהל אתר עם משימות היום · אטום WorkerNav דשבורד מנהל אתר עם משימות היום · אטום SummaryCard דשבורד מנהל אתר עם משימות היום · אטום TitledSection דשבורד מנהל אתר עם משימות היום · אטום MiniCalendar משימות היום · אטום HeroCard עובדים באתר · אטום InfoHeadLine חומרים · כותרת דשבורד מנהל אתר עם משימות היום · לוגיקה חיה · חישוב כרעת מנהל (isAdmin) · באנר המחולל מרכיב UI + לוגיקה מהמדף, ובחר לבד לפי משמעות
// 🧬 אטומים שנבחרו: StripGroupCard · StockTab · ChipCloud · EmptyStateCard · BareStat · WorkerNav · SummaryCard · TitledSection · MiniCalendar · HeroCard · InfoHeadLine · CaSubTitle · RStat · CoinBanner
import '../dart-data-bs/auto/gen_app_scr32_content.dart';
import '../dart-maor/is-admin.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/auto/stock_tab.dart';
import '../dart-ui-bs/auto/summary_card.dart';
import '../dart-ui-bs/auto/worker_nav.dart';
import '../dart-ui-bs/bare_stat.dart';
import '../dart-ui-bs/chip_cloud.dart';
import '../dart-ui-bs/empty_state_card.dart';
import '../dart-ui-bs/hero_card.dart';
import '../dart-ui-bs/mini_calendar.dart';
import '../dart-ui-bs/screens__lipskey_product_sheet/info_head_line.dart';
import '../dart-ui-bs/screens__lipskey_product_sheet/strip_group_card.dart';
import '../dart-ui-bs/titled_section.dart';
import 'package:flutter/material.dart';

class GenAppScr32Screen extends StatefulWidget {
  const GenAppScr32Screen({super.key});

  @override
  State<GenAppScr32Screen> createState() => _GenAppScr32ScreenState();
}

class _GenAppScr32ScreenState extends State<GenAppScr32Screen> {
  String _t1 = '';
  int _n2 = 0;
  String _t3 = '';

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_app_scr32_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          StripGroupCard(children: const <Widget>[], surfaceColor: BsTokens.cardLight, borderColor: BsTokens.divider),
          StockTab(label: gen_app_scr32_other_label, on: false, onTap: () => _toast(gen_app_scr32_other_toast)),
          ChipCloud(labels: const <String>[], height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          EmptyStateCard(glyph: gen_app_scr32_card_glyph, message: gen_app_scr32_card_message, surfaceColor: BsTokens.cardLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          BareStat(value: _t1, label: gen_app_scr32_stat_label, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight),
          WorkerNav(label: gen_app_scr32_other_label2, label2: gen_app_scr32_other_label22, label3: gen_app_scr32_other_label3, label4: gen_app_scr32_other_label4, currentIndex: 0, onTap: (v) => setState(() => _n2 = v), chatOn: false),
          SummaryCard(label: gen_app_scr32_card_label, label2: gen_app_scr32_card_label2, label3: gen_app_scr32_card_label3, label4: gen_app_scr32_card_label4, value: _t3, label5: gen_app_scr32_card_label5, subtotal: 0, vat: 0, deliveryFee: 0, total: 0, vatInclusive: false),
          TitledSection(title: gen_app_scr32_header_title, inkColor: BsTokens.inkLight, child: const SizedBox(height: 4)),
          MiniCalendar(height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          HeroCard(glyph: gen_app_scr32_card_glyph2, title: gen_app_scr32_card_title, sub: gen_app_scr32_card_sub, onTap: () => _toast(gen_app_scr32_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          InfoHeadLine(text: gen_app_scr32_other_text, tint: BsTokens.inkLight),
          CaSubTitle(gen_app_scr32_header_text),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: isAdmin(null, null).toString(), label: gen_app_scr32_stat_label2)])),
          CoinBanner(coins: 0, sub: gen_app_scr32_banner_sub),
          ],
        ),
      ),
    );
  }
}
