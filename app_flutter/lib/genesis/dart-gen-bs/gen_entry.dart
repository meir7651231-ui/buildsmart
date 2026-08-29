// 🧬 חולל ע"י המחולל (genesis-gen, הכרעה 17) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: המחולל
// 🧬 בקשה: המחולל: הירו 🧬 המחולל של המחצב | משפט בעברית נהיה מסך עובד, כותרת מה יש במפעל, נתון ⚛️ 381 אטומים ויזואליים על המדף, נתון 🧠 996 אטומי לוגיקה מומרים ומוכנים, נתון 🏭 79 מסכים הורכבו מחדש מהלבנים, כותרת הצורות שהמחולל מבין, תגיות צורות: מתג / שדה / מספר / בורר / תגיות / כרטיס / כותרת / כפתור, באנר המסך הזה נוצר על ידי המחולל עצמו — מאטומים קיימים בלבד, כפתור ✨ צרו מסך חדש
// 🧬 אטומים שנבחרו: HeroCard · CaSubTitle · RStat · RStat · RStat · CaSubTitle · ChipWrap · CoinBanner · ChatSettingsActionRow
import '../dart-data-bs/auto/gen_entry_content.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/chat_settings_action_row.dart';
import '../dart-ui-bs/auto/chip_wrap.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-ui-bs/hero_card.dart';
import 'package:flutter/material.dart';

class GenEntryScreen extends StatefulWidget {
  const GenEntryScreen({super.key});

  @override
  State<GenEntryScreen> createState() => _GenEntryScreenState();
}

class _GenEntryScreenState extends State<GenEntryScreen> {
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
        appBar: AppBar(title: Text(gen_entry_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          HeroCard(glyph: gen_entry_card_glyph, title: gen_entry_card_title, sub: gen_entry_card_sub, onTap: () => _toast(gen_entry_card_toast), cardColor: BsTokens.cardLight, inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, borderColor: BsTokens.divider, radius: 12),
          CaSubTitle(gen_entry_header_text),
          RStat(value: gen_entry_stat_value, label: gen_entry_stat_label),
          RStat(value: gen_entry_stat_value2, label: gen_entry_stat_label2),
          RStat(value: gen_entry_stat_value3, label: gen_entry_stat_label3),
          CaSubTitle(gen_entry_header_text2),
          ChipWrap(options: const <String>[gen_entry_chip_option, gen_entry_chip_option2, gen_entry_chip_option3, gen_entry_chip_option4, gen_entry_chip_option5, gen_entry_chip_option6, gen_entry_chip_option7, gen_entry_chip_option8], selected: _t1, onSelect: (v) => setState(() => _t1 = v)),
          CoinBanner(coins: 0, sub: gen_entry_banner_sub),
          ChatSettingsActionRow(label: gen_entry_button_label, buttonLabel: gen_entry_button_button_label, onTap: () => _toast(gen_entry_button_toast)),
          ],
        ),
      ),
    );
  }
}
