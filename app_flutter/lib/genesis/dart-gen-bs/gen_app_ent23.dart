// ✨ חולל ע"י מנוע-הרינדור (render-ds) על מערכת-העיצוב — סכמה ⇒ מסך-פרימיום. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_ent23_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_date_field.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_toggle_tile.dart';
import 'package:flutter/material.dart';

class GenAppEnt23Screen extends StatelessWidget {
  const GenAppEnt23Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_ent23_c0,
      subtitle: gen_app_ent23_c1,
      icon: gen_app_ent23_c2,
      bottomBar: DsPrimaryButton(label: gen_app_ent23_c3),
      children: [
      DsWorkflow(steps: const [gen_app_ent23_c7, gen_app_ent23_c8, gen_app_ent23_c9, gen_app_ent23_c10, gen_app_ent23_c11], current: 2),
      DsSection(title: gen_app_ent23_c4, children: [
        DsDateField(label: gen_app_ent23_c12),
        DsField(label: gen_app_ent23_c13, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent23_c14, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent23_c15, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent23_c16, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent23_c17, hint: '', value: '', onChanged: (_) {}),
        DsToggleTile(label: gen_app_ent23_c18),
      ]),
      DsSection(title: gen_app_ent23_c5, children: const [DsEmpty(label: gen_app_ent23_c6)]),
      ],
    );
  }
}
