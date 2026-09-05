// 🧬 חולל ע"י המחולל (genesis-gen, הכרעות 17+18) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: ניהול צוות
// 🧬 בקשה: ניהול צוות: · שדה שם העובד · מספר ימי עבודה בשבוע · מתג קבלת התראות · מתג גישה למחסן · כפתור הוספת עובד
// 🧬 אטומים שנבחרו: InlineTextRow · QtyStepper · SwitchRow · SwitchRow · ActionRow
import '../dart-data-bs/auto/gen_team_content.dart';
import '../dart-ui-bs/auto/action_row.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/inline_text_row.dart';
import '../dart-ui-bs/auto/qty_stepper.dart';
import '../dart-ui-bs/auto/switch_row.dart';
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
        appBar: AppBar(title: Text(gen_team_app_bar_title)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
          InlineTextRow(label: gen_team_textfield_label, hint: gen_team_textfield_hint, value: _t1, onChanged: (v) => setState(() => _t1 = v)),
          QtyStepper(qty: _n2, onChanged: (v) => setState(() => _n2 = v)),
          SwitchRow(label: gen_team_switch_label, value: _v3, onChanged: (v) => setState(() => _v3 = v)),
          SwitchRow(label: gen_team_switch_label2, value: _v4, onChanged: (v) => setState(() => _v4 = v)),
          ActionRow(label: gen_team_button_label, onTap: () => _toast(gen_team_button_toast)),
          ],
        ),
      ),
    );
  }
}
