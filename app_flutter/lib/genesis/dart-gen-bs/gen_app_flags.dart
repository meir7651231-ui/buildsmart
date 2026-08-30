// ✨ חולל ע"י מנוע-הרינדור (render-ds) — מסך-מערכת. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_flags_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_toggle_tile.dart';
import 'package:flutter/material.dart';

class GenAppFlagsScreen extends StatelessWidget {
  const GenAppFlagsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_flags_c0,
      subtitle: gen_app_flags_c1,
      icon: gen_app_flags_c2,
      children: [
        DsSection(title: gen_app_flags_c3, children: [
        DsToggleTile(label: gen_app_flags_c4),
        DsToggleTile(label: gen_app_flags_c5),
        DsToggleTile(label: gen_app_flags_c6),
        DsToggleTile(label: gen_app_flags_c7),
        DsToggleTile(label: gen_app_flags_c8),
        DsToggleTile(label: gen_app_flags_c9),
        DsToggleTile(label: gen_app_flags_c10),
        DsToggleTile(label: gen_app_flags_c11),
        DsToggleTile(label: gen_app_flags_c12),
        DsToggleTile(label: gen_app_flags_c13),
        DsToggleTile(label: gen_app_flags_c14),
        DsToggleTile(label: gen_app_flags_c15),
        ]),
      ],
    );
  }
}
