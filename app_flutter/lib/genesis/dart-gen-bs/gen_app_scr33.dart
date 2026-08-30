// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: 🎯 דשבורד כספים עם הכנסות
// 🧬 בקשה: הירו 🎯 דשבורד כספים עם הכנסות | נבנה מתיאור חופשי · אטום FinHead ליד | 9 שדות · 7 שלבים · אטום FinRow לקוח | 8 שדות · אטום FinRows פרויקט | 12 שדות · 6 שלבים · אטום FinCallout שדה | 10 שדות · אטום CaPrimary סעיף כתב כמויות | 8 שדות · אטום GridHubCard אומדן | 9 שדות · אטום AiFinTile הצעה | 7 שדות · 5 שלבים · אטום SubRow חוזה | 9 שדות · 4 שלבים · באנר המחולל מרכיב UI + לוגיקה מהמדף, ובחר לבד לפי משמעות
// 🧬 אטומים שנבחרו: FinHead · FinRow · FinRows · FinCallout · CaPrimary · GridHubCard · AiFinTile · SubRow · CoinBanner
import '../dart-data-bs/auto/gen_app_scr33_content.dart';
import '../dart-ui-bs/auto/ai_fin_tile.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_primary.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/fin_callout.dart';
import '../dart-ui-bs/auto/fin_head.dart';
import '../dart-ui-bs/auto/fin_row.dart';
import '../dart-ui-bs/auto/fin_rows.dart';
import '../dart-ui-bs/auto/sub_row.dart';
import '../dart-ui-bs/screens__store_screen/grid_hub_card.dart';
import 'package:flutter/material.dart';

class GenAppScr33Screen extends StatefulWidget {
  const GenAppScr33Screen({super.key});

  @override
  State<GenAppScr33Screen> createState() => _GenAppScr33ScreenState();
}

class _GenAppScr33ScreenState extends State<GenAppScr33Screen> {
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
        appBar: AppBar(title: Text(gen_app_scr33_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          FinHead(ic: gen_app_scr33_other_ic, title: gen_app_scr33_other_title, sub: gen_app_scr33_other_sub),
          FinRow(gen_app_scr33_row_label, _t1),
          FinRows(const <Widget>[]),
          FinCallout(label: gen_app_scr33_other_label, value: _t2),
          CaPrimary(label: gen_app_scr33_other_label2, onTap: () => _toast(gen_app_scr33_other_toast)),
          GridHubCard(emoji: gen_app_scr33_card_glyph, title: gen_app_scr33_card_title, preview: gen_app_scr33_card_preview, isFav: false, favAddLabel: gen_app_scr33_card_fav_add_label, favRemoveLabel: gen_app_scr33_card_fav_remove_label, onFavToggle: () => _toast(gen_app_scr33_card_toast), onTap: () => _toast(gen_app_scr33_card_toast2), surfaceColor: BsTokens.cardLight, borderColor: BsTokens.divider, badgeColor: BsTokens.inkLight, badgeInkColor: BsTokens.inkLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, favActiveColor: BsTokens.brand, favIdleColor: BsTokens.inkLight),
          AiFinTile(ic: gen_app_scr33_row_ic, title: gen_app_scr33_row_title, sub: gen_app_scr33_row_sub, onTap: () => _toast(gen_app_scr33_row_toast)),
          SubRow(label: gen_app_scr33_row_label2, label2: gen_app_scr33_row_label22, allocated: 0, spent: 0, ic: gen_app_scr33_row_ic2, name: gen_app_scr33_row_name),
          CoinBanner(coins: 0, sub: gen_app_scr33_banner_sub),
          ],
        ),
      ),
    );
  }
}
