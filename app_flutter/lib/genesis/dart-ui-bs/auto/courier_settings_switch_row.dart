// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__courier_settings_screen:_SwitchRow (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';

class CourierSettingsSwitchRow extends StatelessWidget {
  const CourierSettingsSwitchRow({
    required this.cfgId,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String cfgId;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: CfgText(
        cfgId,
        label,
        style: const TextStyle(color: BsTokens.inkLight),
      ),
      value: value,
      activeColor: BsTokens.brand,
      onChanged: onChanged,
    );
  }
}
