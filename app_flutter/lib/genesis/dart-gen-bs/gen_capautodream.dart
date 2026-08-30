// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הזמנה-עצמית - יכולת שחלמתי היום והוכחתי לבד - מסיר את איבר ואז מסיר את איבר
// 🧬 בקשה: הזמנה-עצמית - יכולת שחלמתי היום והוכחתי לבד - מסיר את איבר ואז מסיר את איבר: · הירו 🧪 הזמנה-עצמית - יכולת שחלמתי היום והוכחתי לבד - מסיר את איבר ואז מסיר את איבר | יכולת שהוזמנה ולא היתה קיימת - הרכבתי אותה לבד מ-2 אטומים והוכחתי על 2 דוגמאות · כותרת תחנת ההוכחה - הדוגמאות שהוזמנו מדליקות את השרשרת · אטום ChipWrap הזמנה-עצמית - יכולת שחלמתי היום והוכחתי לבד - מסיר את איבר ואז מסיר את איבר: עשרה / חשוון · חישוב מסיר את איבר תו אחרון (popCall) · חישוב מסיר את איבר תו אחרון (popCall) · כותרת תחנת הקלט החופשי - הקלידו כל ערך והשרשרת רצה חיה · שדה הקלידו ערך עבור הזמנה-עצמית - יכולת · חישוב מסיר את איבר תו אחרון (popCall) · חישוב מסיר את איבר תו אחרון (popCall) · באנר ההרכבה שמצאתי - popCall ⟵ popCall - כל הדוגמאות עברו
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · ChipWrap · CaSubTitle · InlineTextRow · CoinBanner · RStat · RStat · RStat · RStat
import '../dart-data-bs/auto/gen_capautodream_content.dart';
import '../dart-maor/pop-call.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/chip_wrap.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/inline_text_row.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/hero_card.dart';
import 'package:flutter/material.dart';

class GenCapautodreamScreen extends StatefulWidget {
  const GenCapautodreamScreen({super.key});

  @override
  State<GenCapautodreamScreen> createState() => _GenCapautodreamScreenState();
}

class _GenCapautodreamScreenState extends State<GenCapautodreamScreen> {
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
        appBar: AppBar(title: Text(gen_capautodream_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_capautodream_card_glyph, title: gen_capautodream_card_title, sub: gen_capautodream_card_sub, onTap: () => _toast(gen_capautodream_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CaSubTitle(gen_capautodream_header_text),
          ChipWrap(options: const <String>[gen_capautodream_chip_option, gen_capautodream_chip_option2], selected: _t1, onSelect: (v) => setState(() => _t1 = v)),
          Row(children: [RStat(value: popCall(_t1).toString(), label: gen_capautodream_stat_label)]),
          Row(children: [RStat(value: popCall((popCall(_t1).toString())).toString(), label: gen_capautodream_stat_label2)]),
          CaSubTitle(gen_capautodream_header_text2),
          InlineTextRow(label: gen_capautodream_textfield_label, hint: gen_capautodream_textfield_hint, value: _t2, onChanged: (v) => setState(() => _t2 = v)),
          Row(children: [RStat(value: popCall(_t2).toString(), label: gen_capautodream_stat_label3)]),
          Row(children: [RStat(value: popCall((popCall(_t2).toString())).toString(), label: gen_capautodream_stat_label4)]),
          CoinBanner(coins: 0, sub: gen_capautodream_banner_sub),
          ],
        ),
      ),
    );
  }
}
