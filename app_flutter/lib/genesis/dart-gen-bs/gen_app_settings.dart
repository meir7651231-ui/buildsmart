// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: הירו ⚙️ הגדרות | סנכרון · גיבוי · הרשאות
// 🧬 בקשה: הירו ⚙️ הגדרות | סנכרון · גיבוי · הרשאות · אטום LiveStatusDot מחובר · מסונכרן · אטום SwitchRow עבודה אופליין · אטום NeonButton גיבוי עכשיו · באנר סנכרון · זיהוי-התנגשויות · גיבוי · ייצוא
// 🧬 אטומים שנבחרו: LiveStatusDot · SwitchRow · NeonButton · CoinBanner
import '../dart-data-bs/auto/gen_app_settings_content.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/switch_row.dart';
import '../dart-ui-bs/live_status_dot.dart';
import '../dart-ui-bs/neon_button.dart';
import 'package:flutter/material.dart';

class GenAppSettingsScreen extends StatefulWidget {
  const GenAppSettingsScreen({super.key});

  @override
  State<GenAppSettingsScreen> createState() => _GenAppSettingsScreenState();
}

class _GenAppSettingsScreenState extends State<GenAppSettingsScreen> {
  bool _v1 = false;

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_app_settings_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          LiveStatusDot(label: gen_app_settings_statusdot_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, fillColor: BsTokens.cardLight),
          SwitchRow(label: gen_app_settings_switch_label, value: _v1, onChanged: (v) => setState(() => _v1 = v)),
          NeonButton(label: gen_app_settings_neon_label, height: 16, radius: 12, accentColor: BsTokens.brand, baseColor: BsTokens.inkLight, onPressed: () => _toast(gen_app_settings_neon_toast)),
          CoinBanner(coins: 0, sub: gen_app_settings_banner_sub),
          ],
        ),
      ),
    );
  }
}
