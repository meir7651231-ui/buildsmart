// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: יכולת מאולתרת - הגרלת היום
// 🧬 בקשה: יכולת מאולתרת - הגרלת היום: · הירו 🎲 יכולת מאולתרת - חמישה אטומים שהגרלתי וחיברתי לבד | תבחר 5 אטומים רנדלמיים תחבר בין ותוציא את היכולת הכי טוב וחדשה שלה · אטום ChatSettingsSwitchRow המתג הזה מדליק את האטום שמתחתיו · אטום FinTile צבע · אטום Callout פקק · אטום OrderCard ברך 90° · אטום ActionCard סוג · באנר את ההגרלה החיבורים והמסך הזה עשיתי לבד - מחר תצא הגרלה חדשה
// 🧬 אטומים שנבחרו: HeroCard · ChatSettingsSwitchRow · Callout · OrderCard · ActionCard · CoinBanner · FinTile
import '../dart-data-bs/auto/gen_improv_content.dart';
import '../dart-ui-bs/auto/action_card.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/callout.dart';
import '../dart-ui-bs/auto/chat_settings_switch_row.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/fin_tile.dart';
import '../dart-ui-bs/hero_card.dart';
import '../dart-ui-bs/order_card.dart';
import 'package:flutter/material.dart';

class GenImprovScreen extends StatefulWidget {
  const GenImprovScreen({super.key});

  @override
  State<GenImprovScreen> createState() => _GenImprovScreenState();
}

class _GenImprovScreenState extends State<GenImprovScreen> {
  bool _v1 = false;
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
        appBar: AppBar(title: Text(gen_improv_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_improv_card_glyph, title: gen_improv_card_title, sub: gen_improv_card_sub, onTap: () => _toast(gen_improv_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          ChatSettingsSwitchRow(fallback: gen_improv_switch_fallback, label: gen_improv_switch_label, value: _v1, onChanged: (v) => setState(() => _v1 = v)),
          if (_v1) FinTile(ic: gen_improv_row_ic, title: gen_improv_row_title, sub: gen_improv_row_sub, onTap: () => _toast(gen_improv_row_toast)),
          Callout(label: gen_improv_other_label, value: _t2),
          OrderCard(stageLabel: gen_improv_card_stage_label, itemsLabel: gen_improv_card_items_label, sumLabel: gen_improv_card_sum_label, onTap: () => _toast(gen_improv_card_toast2), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12, width: 16),
          ActionCard(color: BsTokens.inkLight, badge: gen_improv_button_badge, title: gen_improv_button_title, sub: gen_improv_button_sub, onTap: () => _toast(gen_improv_button_toast)),
          CoinBanner(coins: 0, sub: gen_improv_banner_sub),
          ],
        ),
      ),
    );
  }
}
