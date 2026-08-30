// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הירו 🎯 דשבורד הנהלה עם פרויקטים | נבנה מתיאור חופשי
// 🧬 בקשה: הירו 🎯 דשבורד הנהלה עם פרויקטים | נבנה מתיאור חופשי · אטום FinHead דשבורד הנהלה עם פרויקטים · אטום FinRow דשבורד הנהלה עם פרויקטים · אטום FinRows דשבורד הנהלה עם פרויקטים · אטום FinCallout דשבורד הנהלה עם פרויקטים · אטום CaPrimary דשבורד הנהלה עם פרויקטים · אטום GridHubCard דשבורד הנהלה עם פרויקטים · אטום AiFinTile דשבורד הנהלה עם פרויקטים · אטום SubRow דשבורד הנהלה עם פרויקטים · אטום ProjectChip פרויקטים · כותרת דשבורד הנהלה עם פרויקטים · לוגיקה חיה · חישוב כרעת מנהל (isAdmin) · באנר המחולל מרכיב UI + לוגיקה מהמדף, ובחר לבד לפי משמעות
// 🧬 אטומים שנבחרו: FinHead · FinRow · FinRows · FinCallout · CaPrimary · GridHubCard · AiFinTile · SubRow · ProjectChip · CaSubTitle · RStat · CoinBanner
import '../dart-data-bs/auto/gen_app_scr6_content.dart';
import '../dart-maor/is-admin.dart';
import '../dart-ui-bs/auto/ai_fin_tile.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_primary.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/fin_callout.dart';
import '../dart-ui-bs/auto/fin_head.dart';
import '../dart-ui-bs/auto/fin_row.dart';
import '../dart-ui-bs/auto/fin_rows.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/auto/sub_row.dart';
import '../dart-ui-bs/screens__store_screen/grid_hub_card.dart';
import '../dart-ui-bs/screens__store_screen/project_chip.dart';
import 'package:flutter/material.dart';

class GenAppScr6Screen extends StatefulWidget {
  const GenAppScr6Screen({super.key});

  @override
  State<GenAppScr6Screen> createState() => _GenAppScr6ScreenState();
}

class _GenAppScr6ScreenState extends State<GenAppScr6Screen> {
  String _t1 = '';
  String _t2 = '';

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_app_scr6_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          FinHead(ic: gen_app_scr6_other_ic, title: gen_app_scr6_other_title, sub: gen_app_scr6_other_sub),
          FinRow(gen_app_scr6_row_label, _t1),
          FinRows(const <Widget>[]),
          FinCallout(label: gen_app_scr6_other_label, value: _t2),
          CaPrimary(label: gen_app_scr6_other_label2, onTap: () => _toast(gen_app_scr6_other_toast)),
          GridHubCard(emoji: gen_app_scr6_card_glyph, title: gen_app_scr6_card_title, preview: gen_app_scr6_card_preview, isFav: false, favAddLabel: gen_app_scr6_card_fav_add_label, favRemoveLabel: gen_app_scr6_card_fav_remove_label, onFavToggle: () => _toast(gen_app_scr6_card_toast), onTap: () => _toast(gen_app_scr6_card_toast2), surfaceColor: BsTokens.cardLight, borderColor: BsTokens.divider, badgeColor: BsTokens.inkLight, badgeInkColor: BsTokens.inkLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, favActiveColor: BsTokens.brand, favIdleColor: BsTokens.inkLight),
          AiFinTile(ic: gen_app_scr6_row_ic, title: gen_app_scr6_row_title, sub: gen_app_scr6_row_sub, onTap: () => _toast(gen_app_scr6_row_toast)),
          SubRow(label: gen_app_scr6_row_label2, label2: gen_app_scr6_row_label22, allocated: 0, spent: 0, ic: gen_app_scr6_row_ic2, name: gen_app_scr6_row_name),
          ProjectChip(label: gen_app_scr6_chip_label, active: false, onTap: () => _toast(gen_app_scr6_chip_toast), activeColor: BsTokens.brand, activeInkColor: BsTokens.brand, idleColor: BsTokens.inkLight, idleInkColor: BsTokens.inkLight),
          CaSubTitle(gen_app_scr6_header_text),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [RStat(value: isAdmin(null, null).toString(), label: gen_app_scr6_stat_label)])),
          CoinBanner(coins: 0, sub: gen_app_scr6_banner_sub),
          ],
        ),
      ),
    );
  }
}
