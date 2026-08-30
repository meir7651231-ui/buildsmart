// ✨ חולל ע"י מנוע-הרינדור (render-ds) על מערכת-העיצוב — סכמה ⇒ מסך-פרימיום. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_ent17_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_date_field.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_toggle_tile.dart';
import 'package:flutter/material.dart';

class GenAppEnt17Screen extends StatelessWidget {
  const GenAppEnt17Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_ent17_c0,
      subtitle: gen_app_ent17_c1,
      icon: gen_app_ent17_c2,
      bottomBar: DsPrimaryButton(label: gen_app_ent17_c3),
      children: [
      DsWorkflow(steps: const [gen_app_ent17_c7, gen_app_ent17_c8, gen_app_ent17_c9], current: 2),
      DsSection(title: gen_app_ent17_c4, children: [
        DsField(label: gen_app_ent17_c10, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent17_c11, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent17_c12, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent17_c13, hint: '', value: '', onChanged: (_) {}),
        DsDateField(label: gen_app_ent17_c14),
        DsField(label: gen_app_ent17_c15, hint: '', value: '', onChanged: (_) {}),
        DsDateField(label: gen_app_ent17_c16),
        DsToggleTile(label: gen_app_ent17_c17),
      ]),
      DsSection(title: gen_app_ent17_c5, children: const [DsEmpty(label: gen_app_ent17_c6)]),
      ],
    );
  }
}
