// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: 🎚️ דגלי-יכולת
// 🧬 בקשה: הירו 🎚️ דגלי-יכולת | הפעלה/כיבוי מודולים · כותרת מודולים · אטום AnimatedToggle ליד · אטום AnimatedToggle לקוח · אטום AnimatedToggle פרויקט · אטום AnimatedToggle שדה · אטום AnimatedToggle סעיף כתב כמויות · אטום AnimatedToggle אומדן · אטום AnimatedToggle הצעה · אטום AnimatedToggle חוזה · אטום AnimatedToggle תקציב · אטום AnimatedToggle משימה · אטום AnimatedToggle דוח יומי · אטום AnimatedToggle עובד · באנר כיבוי מודול לא מוחק נתונים — rollback נשמר
// 🧬 אטומים שנבחרו: CaSubTitle · AnimatedToggle · AnimatedToggle · AnimatedToggle · AnimatedToggle · AnimatedToggle · AnimatedToggle · AnimatedToggle · AnimatedToggle · AnimatedToggle · AnimatedToggle · AnimatedToggle · AnimatedToggle · CoinBanner
import '../dart-data-bs/auto/gen_app_flags_content.dart';
import '../dart-ui-bs/animated_toggle.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import 'package:flutter/material.dart';

class GenAppFlagsScreen extends StatefulWidget {
  const GenAppFlagsScreen({super.key});

  @override
  State<GenAppFlagsScreen> createState() => _GenAppFlagsScreenState();
}

class _GenAppFlagsScreenState extends State<GenAppFlagsScreen> {
  

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_app_flags_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          CaSubTitle(gen_app_flags_header_text),
          AnimatedToggle(label: gen_app_flags_toggle_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          AnimatedToggle(label: gen_app_flags_toggle_label2, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          AnimatedToggle(label: gen_app_flags_toggle_label3, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          AnimatedToggle(label: gen_app_flags_toggle_label4, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          AnimatedToggle(label: gen_app_flags_toggle_label5, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          AnimatedToggle(label: gen_app_flags_toggle_label6, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          AnimatedToggle(label: gen_app_flags_toggle_label7, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          AnimatedToggle(label: gen_app_flags_toggle_label8, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          AnimatedToggle(label: gen_app_flags_toggle_label9, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          AnimatedToggle(label: gen_app_flags_toggle_label10, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          AnimatedToggle(label: gen_app_flags_toggle_label11, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          AnimatedToggle(label: gen_app_flags_toggle_label12, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          CoinBanner(coins: 0, sub: gen_app_flags_banner_sub),
          ],
        ),
      ),
    );
  }
}
