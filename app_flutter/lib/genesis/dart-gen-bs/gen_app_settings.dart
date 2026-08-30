// ✨ חולל ע"י מנוע-הרינדור (render-ds) — מסך-מערכת. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_settings_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_toggle_tile.dart';
import 'package:flutter/material.dart';

class GenAppSettingsScreen extends StatelessWidget {
  const GenAppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_settings_c0,
      subtitle: gen_app_settings_c1,
      icon: gen_app_settings_c2,
      children: [
        DsSection(title: gen_app_settings_c3, children: [
        DsToggleTile(label: gen_app_settings_c4),
        DsToggleTile(label: gen_app_settings_c5),
        DsToggleTile(label: gen_app_settings_c6),
        ]),
      ],
    );
  }
}
