// ✨ חולל ע"י מנוע-הרינדור (render-ds) על מערכת-העיצוב — סכמה ⇒ מסך-פרימיום. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_ent27_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_date_field.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_toggle_tile.dart';
import 'package:flutter/material.dart';

class GenAppEnt27Screen extends StatelessWidget {
  const GenAppEnt27Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_ent27_c0,
      subtitle: gen_app_ent27_c1,
      icon: gen_app_ent27_c2,
      bottomBar: DsPrimaryButton(label: gen_app_ent27_c3),
      children: [
      DsWorkflow(steps: const [gen_app_ent27_c7, gen_app_ent27_c8, gen_app_ent27_c9, gen_app_ent27_c10], current: 2),
      DsSection(title: gen_app_ent27_c4, children: [
        DsField(label: gen_app_ent27_c11, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent27_c12, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent27_c13, hint: '', value: '', onChanged: (_) {}),
        DsDateField(label: gen_app_ent27_c14),
        DsField(label: gen_app_ent27_c15, hint: '', value: '', onChanged: (_) {}),
        DsToggleTile(label: gen_app_ent27_c16),
      ]),
      DsSection(title: gen_app_ent27_c5, children: const [DsEmpty(label: gen_app_ent27_c6)]),
      ],
    );
  }
}
