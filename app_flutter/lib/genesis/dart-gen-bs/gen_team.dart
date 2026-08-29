// 🧬 חולל ע"י המחולל (genesis-gen, הכרעה 17) — בקשה ⇒ בחירת-אטומים ⇒ חיווט ⇒ מסך. אל תערוך ידנית.
// 🧬 שם: ניהול צוות
// 🧬 בקשה: ניהול צוות: שדה שם העובד, מספר ימי עבודה בשבוע, מתג קבלת התראות, מתג גישה למחסן, כפתור הוספת עובד
// 🧬 אטומים שנבחרו: FieldLabel · QtyStepper · ChatSettingsSwitchRow · ChatSettingsSwitchRow · ChatSettingsActionRow
import '../dart-data-bs/auto/gen_team_content.dart';
import '../dart-ui-bs/auto/bs_tokens.dart';
import '../dart-ui-bs/auto/chat_settings_action_row.dart';
import '../dart-ui-bs/auto/chat_settings_switch_row.dart';
import '../dart-ui-bs/auto/field_label.dart';
import '../dart-ui-bs/auto/qty_stepper.dart';
import 'package:flutter/material.dart';

class GenTeamScreen extends StatefulWidget {
  const GenTeamScreen({super.key});

  @override
  State<GenTeamScreen> createState() => _GenTeamScreenState();
}

class _GenTeamScreenState extends State<GenTeamScreen> {
  int _n1 = 0;
  bool _v2 = false;
  bool _v3 = false;

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
          FieldLabel(gen_team_textfield_text),
          QtyStepper(qty: 0, onChanged: (v) => setState(() => _n1 = v)),
          ChatSettingsSwitchRow(fallback: gen_team_switch_fallback, label: gen_team_switch_label, value: _v2, onChanged: (v) => setState(() => _v2 = v)),
          ChatSettingsSwitchRow(fallback: gen_team_switch_fallback2, label: gen_team_switch_label2, value: _v3, onChanged: (v) => setState(() => _v3 = v)),
          ChatSettingsActionRow(label: gen_team_button_label, buttonLabel: gen_team_button_button_label, onTap: () => _toast(gen_team_button_toast)),
          ],
        ),
      ),
    );
  }
}
