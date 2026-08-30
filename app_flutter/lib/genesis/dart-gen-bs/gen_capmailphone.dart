// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: שחזור מספר טלפון לתצוגה ישראלית תקנית מתוך שורה שהגיעה עטופה בקידוד-מייל ישן
// 🧬 בקשה: שחזור מספר טלפון לתצוגה ישראלית תקנית מתוך שורה שהגיעה עטופה בקידוד-מייל ישן: · הירו 🧪 שחזור מספר טלפון לתצוגה ישראלית תקנית מתוך שורה שהגיעה עטופה בקידוד-מייל ישן | יכולת שהוזמנה ולא היתה קיימת - הרכבתי אותה לבד מ-2 אטומים והוכחתי על 2 דוגמאות · אטום ChipWrap שחזור מספר טלפון לתצוגה ישראלית תקנית מתוך שורה שהגיעה עטופה בקידוד-מייל ישן: +972=2050-123=204567 / =2B972=2054-987=2065=2043 · חישוב פענוח מחרוזת (decodeQuotedPrintable) · חישוב עיצוב טלפון ישראלי מקור חוק (formatIsraeliPhone) · באנר ההרכבה שמצאתי - decodeQuotedPrintable ⟵ formatIsraeliPhone - כל הדוגמאות עברו
// 🧬 אטומים שנבחרו: HeroCard · ChipWrap · CoinBanner · RStat · RStat
import '../dart-data-bs/auto/gen_capmailphone_content.dart';
import '../dart-maor/decode-quoted-printable.dart';
import '../dart-maor/format-israeli-phone.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/chip_wrap.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/hero_card.dart';
import 'package:flutter/material.dart';

class GenCapmailphoneScreen extends StatefulWidget {
  const GenCapmailphoneScreen({super.key});

  @override
  State<GenCapmailphoneScreen> createState() => _GenCapmailphoneScreenState();
}

class _GenCapmailphoneScreenState extends State<GenCapmailphoneScreen> {
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
        appBar: AppBar(title: Text(gen_capmailphone_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_capmailphone_card_glyph, title: gen_capmailphone_card_title, sub: gen_capmailphone_card_sub, onTap: () => _toast(gen_capmailphone_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          ChipWrap(options: const <String>[gen_capmailphone_chip_option, gen_capmailphone_chip_option2], selected: _t1, onSelect: (v) => setState(() => _t1 = v)),
          Row(children: [RStat(value: decodeQuotedPrintable(_t1), label: gen_capmailphone_stat_label)]),
          Row(children: [RStat(value: formatIsraeliPhone((decodeQuotedPrintable(_t1))), label: gen_capmailphone_stat_label2)]),
          CoinBanner(coins: 0, sub: gen_capmailphone_banner_sub),
          ],
        ),
      ),
    );
  }
}
