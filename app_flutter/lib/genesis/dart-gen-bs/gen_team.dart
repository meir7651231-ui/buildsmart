// 🧬 חולל ע"י המחולל (genesis-gen, הכרעה 17) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: ניהול צוות
// 🧬 בקשה: ניהול צוות: שדה שם העובד, מספר ימי עבודה בשבוע, מתג קבלת התראות, מתג גישה למחסן, כפתור הוספת עובד
// 🧬 אטומים שנבחרו: InlineTextRow · SettingsNumberRow · SwitchRow · SwitchRow · ActionRow
import '../dart-data-bs/auto/gen_team_content.dart';
import '../dart-ui-bs/auto/action_row.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/inline_text_row.dart';
import '../dart-ui-bs/auto/switch_row.dart';
import '../dart-ui-bs/screens__store_settings_screen/settings_number_row.dart';
import 'package:flutter/material.dart';

class GenTeamScreen extends StatefulWidget {
  const GenTeamScreen({super.key});

  @override
  State<GenTeamScreen> createState() => _GenTeamScreenState();
}

class _GenTeamScreenState extends State<GenTeamScreen> {
  String _t1 = '';
  int _n2 = 0;
  bool _v3 = false;
  bool _v4 = false;

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(title: Text(gen_team_t8)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          InlineTextRow(label: gen_team_t1, hint: gen_team_t2, value: _t1, onChanged: (v) => setState(() => _t1 = v)),
          SettingsNumberRow(label: gen_team_t3, value: _n2, onChanged: (v) => setState(() => _n2 = v), inkColor: BsTokens.inkLight, mutedColor: BsTokens.mutedLight, cursorColor: BsTokens.brand, fillColor: BsTokens.cardLight),
          SwitchRow(label: gen_team_t4, value: _v3, onChanged: (v) => setState(() => _v3 = v)),
          SwitchRow(label: gen_team_t5, value: _v4, onChanged: (v) => setState(() => _v4 = v)),
          ActionRow(label: gen_team_t6, onTap: () => _toast(gen_team_t7)),
          ],
        ),
      ),
    );
  }
}
