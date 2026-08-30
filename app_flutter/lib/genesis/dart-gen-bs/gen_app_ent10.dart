// ✨ חולל ע"י מנוע-הרינדור (render-ds) על מערכת-העיצוב — סכמה ⇒ מסך-פרימיום. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_ent10_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_date_field.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_number_field.dart';
import '../dart-ui-bs/ds/ds_toggle_tile.dart';
import 'package:flutter/material.dart';

class GenAppEnt10Screen extends StatelessWidget {
  const GenAppEnt10Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_ent10_c0,
      subtitle: gen_app_ent10_c1,
      icon: gen_app_ent10_c2,
      bottomBar: DsPrimaryButton(label: gen_app_ent10_c3),
      children: [
      DsWorkflow(steps: const [gen_app_ent10_c7, gen_app_ent10_c8, gen_app_ent10_c9, gen_app_ent10_c10, gen_app_ent10_c11], current: 2),
      DsSection(title: gen_app_ent10_c4, children: [
        DsField(label: gen_app_ent10_c12, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent10_c13, hint: '', value: '', onChanged: (_) {}),
        DsField(label: gen_app_ent10_c14, hint: '', value: '', onChanged: (_) {}),
        DsDateField(label: gen_app_ent10_c15),
        DsField(label: gen_app_ent10_c16, hint: '', value: '', onChanged: (_) {}),
        DsNumberField(label: gen_app_ent10_c17),
        DsToggleTile(label: gen_app_ent10_c18),
      ]),
      DsSection(title: gen_app_ent10_c5, children: const [DsEmpty(label: gen_app_ent10_c6)]),
      ],
    );
  }
}
