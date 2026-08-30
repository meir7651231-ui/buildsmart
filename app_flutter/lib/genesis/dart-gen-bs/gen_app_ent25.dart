// ✨ חולל ע"י מנוע-הרינדור (render-ds) על מערכת-העיצוב — סכמה ⇒ מסך-פרימיום. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_ent25_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_toggle_tile.dart';
import 'package:flutter/material.dart';

class GenAppEnt25Screen extends StatelessWidget {
  const GenAppEnt25Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_ent25_c0,
      subtitle: gen_app_ent25_c1,
      icon: gen_app_ent25_c2,
      bottomBar: DsPrimaryButton(label: gen_app_ent25_c3),
      children: [
      DsWorkflow(steps: const [gen_app_ent25_c7, gen_app_ent25_c8, gen_app_ent25_c9, gen_app_ent25_c10, gen_app_ent25_c11], current: 2),
      DsSection(title: gen_app_ent25_c4, children: [
        DsField(label: gen_app_ent25_c12, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent25_c13, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent25_c14, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent25_c15, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent25_c16, hint: '', value: '', onChanged: (_) {}),
        DsToggleTile(label: gen_app_ent25_c17),
      ]),
      DsSection(title: gen_app_ent25_c5, children: const [DsEmpty(label: gen_app_ent25_c6)]),
      ],
    );
  }
}
